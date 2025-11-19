import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RequestBody {
  label?: string
  imageBase64?: string
  imageUrl?: string
  mimeType?: string
}

interface NutritionLabel {
  servingSize: string
  caloriesPerServing: number
  totalServings: number
}

interface MenuItem {
  restaurant: string
  itemName: string
  calories: number
}

interface Priors {
  density: { mu: number; sigma: number }
  kcalPerG: { mu: number; sigma: number }
}

interface AnalysisItem {
  label: string
  confidence: number
  calories: number
  sigmaCalories: number
  path: 'label' | 'menu' | 'geometry'
  evidence: string[]
  nutritionLabel?: NutritionLabel
  menuItem?: MenuItem
  priors?: Priors
  macros?: { proteinG: number; carbsG: number; fatG: number }
}

interface Response {
  items: AnalysisItem[]
  meta: {
    used: string[]
    latencyMs: number
  }
}

// ---- Supabase Storage helpers (server-side upload for public URL) ----
async function ensureBucketPublic(bucket: string, supabaseUrl: string, serviceKey: string) {
  const res = await fetch(`${supabaseUrl}/storage/v1/bucket`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${serviceKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ name: bucket, public: true })
  })
  if (res.ok) return
  // 409 Conflict if already exists
  if (res.status !== 409) {
    const text = await res.text().catch(() => '')
    throw new Error(`Failed to ensure bucket: ${res.status} ${text}`)
  }
}

function parseDataUrl(dataUrl: string): { mime: string; data: Uint8Array } {
  const match = dataUrl.match(/^data:([^;]+);base64,(.*)$/)
  if (!match) throw new Error('Invalid data URL')
  const mime = match[1]
  const b64 = match[2]
  const bin = atob(b64)
  const bytes = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i)
  return { mime, data: bytes }
}

async function uploadDataUrlToStorage(
  dataUrl: string,
  opts: { bucket: string; prefix?: string; supabaseUrl: string; serviceKey: string }
): Promise<string> {
  const { mime, data } = parseDataUrl(dataUrl)
  const fname = `${opts.prefix || 'captures'}/${Date.now()}-${crypto.randomUUID()}.jpg`
  const uploadUrl = `${opts.supabaseUrl}/storage/v1/object/${opts.bucket}/${fname}`
  const res = await fetch(uploadUrl, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${opts.serviceKey}`,
      'Content-Type': mime,
      'x-upsert': 'true'
    },
    body: data
  })
  if (!res.ok) {
    const t = await res.text().catch(() => '')
    throw new Error(`Storage upload failed: ${res.status} ${t}`)
  }
  // Public URL
  return `${opts.supabaseUrl}/storage/v1/object/public/${opts.bucket}/${fname}`
}

async function analyzeWithOpenAI(imageData: string, prompt: string): Promise<any> {
  const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
  if (!openaiApiKey) {
    throw new Error('OPENAI_API_KEY not configured')
  }

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 12_000) // 12s server-side timeout

  const requestBody = {
    model: 'gpt-4o-mini',
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: prompt },
          { type: 'image_url', image_url: { url: imageData, detail: 'low' as const } }
        ]
      }
    ],
    max_tokens: 300,
    temperature: 0.1,
    response_format: { type: 'json_object' as const }
  }

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${openaiApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(requestBody),
    signal: controller.signal
  })

  clearTimeout(timeout)

  if (!response.ok) {
    const errorText = await response.text()
    console.error('OpenAI API error response:', errorText)
    throw new Error(`OpenAI API error: ${response.status} ${response.statusText} - ${errorText}`)
  }

  const data = await response.json()
  return data.choices[0].message.content
}

function detectImageType(imageData: string): 'label' | 'menu' | 'geometry' {
  // Simple heuristic-based detection
  // In a real implementation, you might use a more sophisticated approach
  
  // For now, we'll use a simple approach based on the prompt
  // This is a placeholder - in practice, you'd want to analyze the image content
  return 'geometry' // Default to geometry path for home-cooked food
}

async function analyzeLabelPath(imageData: string): Promise<AnalysisItem> {
  const prompt = `Analyze this nutrition label image and extract the following information in JSON format (macros MUST be per 100 grams of edible portion):
  {
    "label": "Product name",
    "servingSize": "Serving size description",
    "caloriesPerServing": number,
    "totalServings": number,
    "confidence": number between 0 and 1,
    "macros": { // per 100g
      "proteinG": number,
      "carbsG": number,
      "fatG": number
    }
  }
  
  Focus on accuracy and only return valid JSON.`
  
  const result = await analyzeWithOpenAI(imageData, prompt)
  
  try {
    const parsed = JSON.parse(result)
    return {
      label: parsed.label || 'Unknown Product',
      confidence: parsed.confidence || 0.8,
      calories: parsed.caloriesPerServing || 200,
      sigmaCalories: Math.round(parsed.caloriesPerServing * 0.1) || 20,
      path: 'label',
      evidence: ['Analyzer', 'OpenAI', 'Label'],
      macros: parsed.macros || { proteinG: 0, carbsG: 0, fatG: 0 },
      nutritionLabel: {
        servingSize: parsed.servingSize || '1 serving',
        caloriesPerServing: parsed.caloriesPerServing || 200,
        totalServings: parsed.totalServings || 1
      }
    }
  } catch (error) {
    // Fallback if JSON parsing fails
    return {
      label: 'Nutrition Label',
      confidence: 0.6,
      calories: 200,
      sigmaCalories: 20,
      path: 'label',
      evidence: ['Analyzer', 'OpenAI', 'Label'],
      macros: { proteinG: 0, carbsG: 0, fatG: 0 },
      nutritionLabel: {
        servingSize: '1 serving',
        caloriesPerServing: 200,
        totalServings: 1
      }
    }
  }
}

async function analyzeMenuPath(imageData: string): Promise<AnalysisItem> {
  const prompt = `Analyze this restaurant food image and identify the menu item. Return JSON format (macros MUST be per 100 grams of edible portion):
  {
    "restaurant": "Restaurant name or type",
    "itemName": "Menu item name",
    "calories": estimated_calories,
    "confidence": number between 0 and 1,
    "macros": { // per 100g
      "proteinG": number,
      "carbsG": number,
      "fatG": number
    }
  }
  
  Focus on accuracy and only return valid JSON.`
  
  const result = await analyzeWithOpenAI(imageData, prompt)
  
  try {
    const parsed = JSON.parse(result)
    return {
      label: parsed.itemName || 'Restaurant Item',
      confidence: parsed.confidence || 0.7,
      calories: parsed.calories || 500,
      sigmaCalories: Math.round(parsed.calories * 0.15) || 75,
      path: 'menu',
      evidence: ['Analyzer', 'OpenAI', 'Menu'],
      macros: parsed.macros || { proteinG: 0, carbsG: 0, fatG: 0 },
      menuItem: {
        restaurant: parsed.restaurant || 'Unknown Restaurant',
        itemName: parsed.itemName || 'Unknown Item',
        calories: parsed.calories || 500
      }
    }
  } catch (error) {
    // Fallback if JSON parsing fails
    return {
      label: 'Restaurant Item',
      confidence: 0.6,
      calories: 500,
      sigmaCalories: 75,
      path: 'menu',
      evidence: ['Analyzer', 'OpenAI', 'Menu'],
      macros: { proteinG: 0, carbsG: 0, fatG: 0 },
      menuItem: {
        restaurant: 'Unknown Restaurant',
        itemName: 'Unknown Item',
        calories: 500
      }
    }
  }
}

async function analyzeGeometryPath(imageData: string): Promise<AnalysisItem> {
  console.log('[analyzeGeometryPath] Starting OpenAI API call...')
  
  const prompt = `You are a food identification and nutrition analysis expert. Analyze this food image and provide a DETAILED, DESCRIPTIVE name for the food item(s) visible.

CRITICAL INSTRUCTIONS FOR LABEL:
1. If multiple foods are visible, create a descriptive name that includes ALL visible foods (e.g., "Mixed Fruit Plate (Apple, Kiwi, and Pears)", "Mixed Salad with Vegetables and Dressing", "Chicken Rice Bowl with Vegetables")
2. If it's a single food item, use its specific name (e.g., "Apple", "Chicken Breast", "Rice Bowl")
3. Be descriptive and specific - include details like preparation method, accompaniments, or ingredients when visible
4. Do NOT use generic terms like "food", "meal", "dish", or "home-cooked food"
5. Use proper title case (capitalize important words)

Return a JSON object with this exact structure:
{
  "label": "Descriptive food name (e.g., 'Mixed Fruit Plate (Apple, Kiwi, and Pears)', 'Mixed Salad with Vegetables and Dressing', 'Chicken Rice Bowl', 'Grilled Salmon with Vegetables')",
  "estimatedCalories": number (estimated total calories for the visible portion),
  "density": {
    "mu": number (density in g/mL, typically 0.7-1.2 for most foods),
    "sigma": number (uncertainty, typically 0.1-0.2)
  },
  "kcalPerG": {
    "mu": number (calories per gram, typically 1.0-4.0),
    "sigma": number (uncertainty, typically 0.1-0.5)
  },
  "confidence": number between 0 and 1 (how confident you are in the identification),
  "macros": {
    "proteinG": number (grams of protein per 100g),
    "carbsG": number (grams of carbs per 100g),
    "fatG": number (grams of fat per 100g)
  }
}

EXAMPLES OF GOOD LABELS:
- "Mixed Fruit Plate (Apple, Kiwi, and Pears)"
- "Mixed Salad with Vegetables and Dressing"
- "Chicken Rice Bowl with Vegetables"
- "Grilled Salmon with Roasted Vegetables"
- "Pasta with Tomato Sauce and Meatballs"

Return ONLY valid JSON, no additional text or explanation`
  
  let result: string
  try {
    result = await analyzeWithOpenAI(imageData, prompt)
    console.log('[analyzeGeometryPath] OpenAI API call succeeded, response length:', result?.length || 0)
    console.log('[analyzeGeometryPath] Raw OpenAI response (first 200 chars):', result?.substring(0, 200) || 'empty')
  } catch (openaiError) {
    console.error('[analyzeGeometryPath] OpenAI API call failed:', openaiError)
    console.error('[analyzeGeometryPath] Error type:', openaiError?.constructor?.name || 'Unknown')
    console.error('[analyzeGeometryPath] Error message:', openaiError?.message || 'No message')
    
    // If OpenAI API fails, return a fallback that indicates the failure
    return {
      label: 'Unknown Food',
      confidence: 0.3,
      calories: 200,
      sigmaCalories: 100,
      path: 'geometry',
      evidence: ['Analyzer', 'OpenAI', 'Geometry', 'API_Failed'],
      macros: { proteinG: 0, carbsG: 0, fatG: 0 },
      priors: {
        density: { mu: 0.85, sigma: 0.13 },
        kcalPerG: { mu: 1.30, sigma: 0.26 }
      }
    }
  }
  
  try {
    // Clean the response - remove markdown code blocks if present
    let cleaned = result.trim()
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.replace(/^```json\s*/, '').replace(/\s*```$/, '')
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.replace(/^```\s*/, '').replace(/\s*```$/, '')
    }
    
    const parsed = JSON.parse(cleaned)
    
    // Validate and sanitize the label
    let foodLabel = parsed.label || 'Unknown Food'
    if (typeof foodLabel !== 'string') {
      foodLabel = String(foodLabel)
    }
    // Remove generic terms and ensure it's a specific food name
    foodLabel = foodLabel.trim()
    if (foodLabel.toLowerCase() === 'food' || 
        foodLabel.toLowerCase() === 'meal' || 
        foodLabel.toLowerCase() === 'dish' ||
        foodLabel.toLowerCase() === 'home-cooked food' ||
        foodLabel.toLowerCase() === 'geometry') {
      foodLabel = 'Unknown Food'
    }
    
    // PRESERVE proper title case from OpenAI (don't force lowercase on rest of string)
    // Only ensure first letter is uppercase if the entire string is lowercase
    if (foodLabel.length > 0) {
      // Check if the entire string is lowercase (needs capitalization)
      if (foodLabel === foodLabel.toLowerCase()) {
        // Convert to title case: capitalize first letter of each word
        foodLabel = foodLabel.split(' ').map(word => {
          if (word.length === 0) return word
          // Handle words with parentheses: "apple" -> "Apple", "(apple" -> "(Apple"
          if (word.startsWith('(')) {
            return '(' + word.substring(1, 2).toUpperCase() + word.substring(2)
          }
          return word.substring(0, 1).toUpperCase() + word.substring(1)
        }).join(' ')
      }
      // If it already has mixed case (like "Mixed Fruit Plate"), preserve it as-is
    }
    
    console.log(`[analyzeGeometryPath] Parsed label: "${foodLabel}", calories: ${parsed.estimatedCalories}`)
    console.log(`[analyzeGeometryPath] ✅ SUCCESS - OpenAI returned valid food label: "${foodLabel}"`)
    
    return {
      label: foodLabel,
      confidence: Math.max(0, Math.min(1, parsed.confidence || 0.6)),
      calories: parsed.estimatedCalories || 300,
      sigmaCalories: Math.round((parsed.estimatedCalories || 300) * 0.2) || 60,
      path: 'geometry',
      evidence: ['Analyzer', 'OpenAI', 'Geometry'],
      macros: parsed.macros || { proteinG: 0, carbsG: 0, fatG: 0 },
      priors: {
        density: parsed.density || { mu: 0.85, sigma: 0.13 },
        kcalPerG: parsed.kcalPerG || { mu: 1.30, sigma: 0.26 }
      }
    }
  } catch (parseError) {
    console.error('[analyzeGeometryPath] JSON parsing failed:', parseError)
    console.error('[analyzeGeometryPath] Raw response:', result)
    console.error('[analyzeGeometryPath] Error type:', parseError?.constructor?.name || 'Unknown')
    console.error('[analyzeGeometryPath] Error message:', parseError?.message || 'No message')
    
    // Try to extract label from raw response as fallback
    let extractedLabel = 'Unknown Food'
    // Improved regex to capture labels with parentheses and special characters
    const labelMatch = result.match(/"label"\s*:\s*"([^"]+)"/i) || 
                      result.match(/label["\s:]+"([^"]+)"/i) ||
                      result.match(/label["\s:]+([a-zA-Z\s\(\)\-,]+)/i)
    if (labelMatch && labelMatch[1]) {
      extractedLabel = labelMatch[1].trim()
      if (extractedLabel.length > 0 && 
          !['food', 'meal', 'dish', 'geometry'].includes(extractedLabel.toLowerCase())) {
        // Preserve title case if already present, otherwise capitalize first letter of each word
        if (extractedLabel === extractedLabel.toLowerCase()) {
          extractedLabel = extractedLabel.split(' ').map(word => {
            if (word.length === 0) return word
            if (word.startsWith('(')) {
              return '(' + word.substring(1, 2).toUpperCase() + word.substring(2)
            }
            return word.substring(0, 1).toUpperCase() + word.substring(1)
          }).join(' ')
        }
        // If it already has mixed case, preserve it
      } else {
        extractedLabel = 'Unknown Food'
      }
    }
    
    console.log(`[analyzeGeometryPath] Using fallback label: "${extractedLabel}"`)
    console.log(`[analyzeGeometryPath] ⚠️ WARNING - JSON parsing failed, using extracted label: "${extractedLabel}"`)
    
    // Fallback if JSON parsing fails - but still return something useful
    return {
      label: extractedLabel,
      confidence: 0.5,
      calories: 300,
      sigmaCalories: 60,
      path: 'geometry',
      evidence: ['Analyzer', 'OpenAI', 'Geometry', 'Fallback'],
      macros: { proteinG: 0, carbsG: 0, fatG: 0 },
      priors: {
        density: { mu: 0.85, sigma: 0.13 },
        kcalPerG: { mu: 1.30, sigma: 0.26 }
      }
    }
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  try {
    const { label, imageBase64, imageUrl, mimeType }: RequestBody = await req.json()

    if (!imageBase64 && !imageUrl) {
      return new Response(
        JSON.stringify({ error: 'Either imageBase64 or imageUrl is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Normalize to a valid URL for OpenAI Vision:
    // - If it's an http(s) URL, keep it
    // - If it's already a data URL, keep it
    // - Otherwise, treat any other string as raw base64 and wrap as data URL
    let imageData = imageUrl || ''
    const looksLikeUrl = (s: string) => /^https?:\/\//i.test(s)
    const looksLikeDataUrl = (s: string) => /^data:/i.test(s)
    const looksLikeRawBase64 = (s: string) => /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(s.slice(0, Math.min(200, s.length)))

    if (!imageData) {
      const raw = imageBase64 || ''
      if (raw) {
        if (looksLikeUrl(raw) || looksLikeDataUrl(raw)) {
          imageData = raw
        } else {
          const mt = mimeType && mimeType.startsWith('image/') ? mimeType : 'image/jpeg'
          imageData = `data:${mt};base64,${raw}`
        }
      }
    } else {
      // imageUrl provided but if someone passed raw base64 by mistake, fix it
      if (!looksLikeUrl(imageData) && !looksLikeDataUrl(imageData)) {
        const mt = mimeType && mimeType.startsWith('image/') ? mimeType : 'image/jpeg'
        imageData = `data:${mt};base64,${imageData}`
      }
    }

    // If we have a data URL here, try to upload to Storage for a fetchable URL.
    // If this fails (e.g., missing/invalid service role), gracefully fall back to the data URL.
    if (looksLikeDataUrl(imageData)) {
      const supabaseUrl = Deno.env.get('SUPABASE_URL') || `https://uisjdlxdqfovuwurmdop.supabase.co`
      const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
      if (serviceKey) {
        try {
          const bucket = 'ai-uploads'
          await ensureBucketPublic(bucket, supabaseUrl, serviceKey)
          const publicUrl = await uploadDataUrlToStorage(imageData, {
            bucket,
            supabaseUrl,
            serviceKey,
            prefix: 'camera'
          })
          imageData = publicUrl
        } catch (e) {
          console.warn('Storage upload failed, continuing with data URL:', e)
        }
      }
    }

    // Detect image type to determine analysis path
    const imageType = detectImageType(imageData)
    
    let analysisResult: AnalysisItem

    // Route to appropriate analysis path
    switch (imageType) {
      case 'label':
        analysisResult = await analyzeLabelPath(imageData)
        break
      case 'menu':
        analysisResult = await analyzeMenuPath(imageData)
        break
      case 'geometry':
      default:
        analysisResult = await analyzeGeometryPath(imageData)
        break
    }

    // Log the analysis result for debugging
    console.log(`[analyze_food] Analysis complete: label="${analysisResult.label}", calories=${analysisResult.calories}, path=${analysisResult.path}`)
    console.log(`[analyze_food] ⚠️ CHECK LABEL: Is it generic? "${analysisResult.label}"`)
    
    // Check if label is generic
    const lowerLabel = analysisResult.label.toLowerCase().trim()
    const isGeneric = ['unknown food', 'food', 'meal', 'dish', 'geometry', 'home-cooked food'].includes(lowerLabel)
    if (isGeneric) {
      console.log(`[analyze_food] ⚠️⚠️⚠️ WARNING: Label "${analysisResult.label}" is GENERIC - OpenAI may have failed or returned fallback`)
    } else {
      console.log(`[analyze_food] ✅ Label "${analysisResult.label}" looks valid`)
    }
    
    const response: Response = {
      items: [analysisResult],
      meta: {
        used: ['supabase', 'openai'],
        latencyMs: Date.now() - startTime
      }
    }

    // Log the full response being sent
    console.log(`[analyze_food] Sending response:`, JSON.stringify(response, null, 2))

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error in analyze_food function:', error)
    
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Internal server error',
        meta: {
          used: ['supabase'],
          latencyMs: Date.now() - startTime
        }
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
