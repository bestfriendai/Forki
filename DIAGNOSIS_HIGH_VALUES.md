# Diagnosis: Extremely High Calorie/Macro Values

## Problem

User scanned a **Biscoff Cookie** and got:
- Calories: **2,000** (max cap hit)
- Protein: **200.0g** (max cap hit)
- Carbs: **300.0g** (max cap hit)
- Fats: **155.6g** (very high, below 200g cap)

**Expected values for a Biscoff cookie:**
- Calories: ~30-50 kcal
- Protein: ~0.5-1g
- Carbs: ~4-6g
- Fats: ~1-2g

## Root Cause Analysis

The fact that **all values hit the safety caps** indicates the underlying calculation is producing values **10-100x too high**. This suggests:

### Possible Issues:

1. **Geometry Estimator V2 - Volume Calculation Error**
   - Volume might be calculated in wrong units (mL vs L)
   - Depth map might have unit conversion error
   - Area calculation might be off by orders of magnitude

2. **API Macro Scaling Error**
   - API macros are per 100g, but might be scaled incorrectly
   - Scale factor might be way too high
   - Upper bound calculation might be wrong

3. **Unit Conversion Error**
   - Volume: mL vs L (1000x difference)
   - Mass: g vs kg (1000x difference)
   - Depth: m vs cm vs mm (10-1000x difference)

4. **Geometry Estimator Returning Extreme Values**
   - If geometry estimator calculates volume incorrectly
   - Then calories = volume × density × kcal/g
   - Could easily produce 1000+ calories for a cookie

## Investigation Steps

### Step 1: Check What API Returns
Need to see logs showing:
- What calories does API return?
- What macros does API return?
- What is the scale factor being applied?

### Step 2: Check Geometry Estimator
Need to see logs showing:
- What volume is calculated? (should be ~10-50 mL for a cookie)
- What depth values are being used?
- What area is calculated?

### Step 3: Check Macro Calculation
Need to see:
- Are API macros per 100g or per portion?
- What scale factor is applied?
- Are macros being scaled correctly?

## Most Likely Cause

**Geometry Estimator V2 is calculating volume incorrectly**, then:
1. Volume is way too high (e.g., 1000 mL instead of 10 mL)
2. Calories = volume × density × kcal/g → produces 1000+ calories
3. Macros are scaled from these high calories → hit caps

## Fix Strategy

1. **Add logging** to see actual values before caps are applied
2. **Check volume calculation** in GeometryEstimatorV2
3. **Verify unit conversions** (mL, L, m, cm, mm)
4. **Check if depth data is causing issues** (might be in wrong units)
5. **Add validation** to reject obviously wrong values before scaling

## Immediate Action

Need to see the **actual logs** from the capture to diagnose:
- What did the API return?
- What did Geometry Estimator calculate?
- What scale factors were applied?
- What values were calculated before caps?

