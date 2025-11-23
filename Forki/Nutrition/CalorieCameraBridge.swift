//
//  CalorieCameraBridge.swift
//  Forki
//

import SwiftUI
import CalorieCameraKit

/// Bridge between CalorieCameraKit and your food logging flow.
/// Emits a normalized AICameraNutritionResult back to Home.
struct CalorieCameraBridge: View {
    let onComplete: (AICameraCompletion) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var showCalorieCamera = false
    @State private var shouldDismiss = false

    var body: some View {
        ZStack {
            // Background gradient
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 16) {
                    // Title
                    Text("AI Calorie Camera")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                    
                    // Subtitle
                    Text("Snap your meal. Forki will analyze it instantly.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.highlightText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Microcopy
                    Text("Get instant calorie and macro estimates from a photo.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Button - Match RECIPES button styling but keep Title case
                Button {
                    showCalorieCamera = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Scan My Meal")
                            .font(.system(size: 18, weight: .bold, design: .rounded)) // Match Log Food font
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#F5C9E0"), Color(hex: "#E8B3D4")], // Pink gradient
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color(hex: "#DDA5CC"), lineWidth: 4) // Pink border
                            )
                    )
                    .foregroundColor(ForkiTheme.borderPrimary) // Purple text (same as status bubble)
                    .shadow(color: ForkiTheme.actionShadow, radius: 10, x: 0, y: 6)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showCalorieCamera) {
            CalorieCameraView(
                config: .development, // flip to .production when your backend is locked
                onResult: { result in
                    // Map CalorieCameraKit → AICameraNutritionResult
                    NSLog("📸 [Bridge] Received result from CalorieCameraKit: \(result.items.count) item(s), \(Int(result.total.mu)) kcal")
                    if let firstItem = result.items.first {
                        NSLog("📸 [Bridge] First item label: '\(firstItem.label)', calories: \(Int(firstItem.calories))")
                        NSLog("📸 [Bridge] First item evidence: \(firstItem.evidence)")
                    }
                    let converted = convertCalorieResult(result)
                    NSLog("📸 [Bridge] Converted to AICameraNutritionResult: label='\(converted.label)', calories=\(Int(converted.cFused))")
                    print("📸 [Bridge] FINAL LABEL BEING SENT: '\(converted.label)'")
                    DispatchQueue.main.async {
                        NSLog("📸 [Bridge] Calling onComplete with success result")
                        onComplete(.success(converted, sourceType: .camera))
                        showCalorieCamera = false
                        shouldDismiss = true
                        NSLog("📸 [Bridge] Camera dismissed, should show food logger")
                    }
                },
                onCancel: {
                    NSLog("🔴 [Bridge] onCancel callback called")
                    print("🔴 [Bridge] onCancel callback called")
                    DispatchQueue.main.async {
                        NSLog("🔴 [Bridge] Setting showCalorieCamera = false")
                        print("🔴 [Bridge] Setting showCalorieCamera = false")
                        onComplete(.cancelled)
                        showCalorieCamera = false
                        shouldDismiss = true
                        NSLog("🔴 [Bridge] showCalorieCamera set to false, shouldDismiss = true")
                        print("🔴 [Bridge] showCalorieCamera set to false, shouldDismiss = true")
                    }
                }
            )
        }
        .onChange(of: shouldDismiss) { oldValue, newValue in
            if newValue { dismiss() }
        }
    }

    /// Convert CalorieResult from CalorieCameraKit to AICameraNutritionResult
    private func convertCalorieResult(_ result: CalorieResult) -> AICameraNutritionResult {
        let primary = result.items.first
        var label = primary?.label ?? "Detected Food"
        
        // Only use "Detected Food" as fallback if label is truly generic or missing
        // Preserve actual food names from the API
        let originalLabel = label
        let lowerLabel = label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        NSLog("📸 [Bridge] Checking label: '\(originalLabel)' (lowercase: '\(lowerLabel)')")
        
        // List of generic terms that should be converted to "Detected Food"
        let genericTerms = ["geometry", "food", "meal", "dish", "home-cooked food", "unknown food", "nutrition label", "restaurant item"]
        
        if lowerLabel.isEmpty || genericTerms.contains(lowerLabel) {
            label = "Detected Food"
            NSLog("📸 [Bridge] Label '\(originalLabel)' is generic, converting to 'Detected Food'")
        } else {
            // Preserve the original capitalization from API (it's already properly formatted)
            // Only capitalize if it's all lowercase
            if label == label.lowercased() {
                // All lowercase - capitalize first letter of each word
                label = label.capitalized
            }
            // Otherwise keep the original capitalization from API
            NSLog("📸 [Bridge] Label '\(originalLabel)' is valid, keeping as '\(label)'")
        }
        
        let bridgeMsg = "📸 [Bridge] Food label: '\(label)' (original: '\(primary?.label ?? "nil")')"
        NSLog(bridgeMsg)
        print(bridgeMsg) // Also use print for visibility

        let cFused = max(0, result.total.mu)
        let sigmaCFused = max(0, result.total.sigma)

        // SIMPLIFIED: Check if evidence contains API macros (stored as "macros:protein:2,carbs:60,fat:30")
        var proteinG: Double = 0
        var carbsG: Double = 0
        var fatsG: Double = 0
        
        // Try to extract macros from evidence if available
        if let evidence = primary?.evidence.first(where: { $0.hasPrefix("macros:") }) {
            let macrosString = String(evidence.dropFirst(7)) // Remove "macros:" prefix
            let components = macrosString.split(separator: ",")
            for component in components {
                let parts = component.split(separator: ":")
                if parts.count == 2, let value = Double(parts[1]) {
                    switch parts[0] {
                    case "protein": proteinG = value
                    case "carbs": carbsG = value
                    case "fat": fatsG = value
                    default: break
                    }
                }
            }
            NSLog("📊 [Bridge] Extracted macros from evidence: protein=\(proteinG), carbs=\(carbsG), fat=\(fatsG)")
        }
        
        // If no macros from evidence, calculate heuristically
        if proteinG == 0 && carbsG == 0 && fatsG == 0 {
            NSLog("📊 [Bridge] No macros in evidence, calculating heuristically from calories")
            // Use standard macro ratios: 25% protein, 45% carbs, 30% fats
            proteinG = max(0, (cFused * 0.25) / 4.0)  // 4 kcal/g protein
            carbsG   = max(0, (cFused * 0.45) / 4.0)  // 4 kcal/g carbs
            fatsG    = max(0, (cFused * 0.30) / 9.0)  // 9 kcal/g fats
        }
        
        // Reasonable nutrition thresholds for a single food item
        let maxProtein = 200.0  // 200g max protein per item
        let maxCarbs   = 300.0   // 300g max carbs per item
        let maxFats    = 200.0   // 200g max fats per item
        
        // Safety caps: prevent absurd macro values
        proteinG = min(proteinG, maxProtein)
        carbsG   = min(carbsG,   maxCarbs)
        fatsG    = min(fatsG,    maxFats)
        
        // Cap calories too (based on macros + reasonable max)
        let maxCalories = 2000.0  // 2000 kcal max per item
        let cappedCFused = min(cFused, maxCalories)
        
        NSLog("📊 [Bridge] Final macros: protein=\(proteinG), carbs=\(carbsG), fats=\(fatsG), calories=\(cappedCFused)")

        func r1(_ x: Double) -> Double { (x * 10).rounded() / 10 }

        return AICameraNutritionResult(
            label: label,
            confidence: 0.8,
            volumeML: primary?.volumeML ?? 0,
            sigmaV: primary?.sigma ?? 0,
            rho: 1.0, // Default density (g/mL) - can be improved with priors in future
            sigmaRho: 0.1,
            e: 1.4,
            sigmaE: 0.1,
            cFused: cappedCFused,
            sigmaCFused: sigmaCFused,
            protein: r1(proteinG),
            carbs:   r1(carbsG),
            fats:    r1(fatsG)
        )
    }
}

#Preview {
    CalorieCameraBridge { result in
        print("Camera result: \(result)")
    }
}

