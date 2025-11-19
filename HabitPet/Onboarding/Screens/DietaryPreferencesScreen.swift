//
//  DietaryPreferencesScreen.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI

struct DietaryPreferencesScreen: View {
    @ObservedObject var data: OnboardingData
    @ObservedObject var navigator: OnboardingNavigator
    let onNext: () -> Void
    
    @FocusState private var isOtherFocused: Bool
    
    private let dietaryPreferences: [FoodOption] = [
        .init(id: "no_restrictions", name: "No restrictions", icon: "✅"),
        .init(id: "vegetarian", name: "Vegetarian", icon: "🌱"),
        .init(id: "vegan", name: "Vegan", icon: "🌿"),
        .init(id: "pescatarian", name: "Pescatarian", icon: "🐟"),
        .init(id: "low_carb_keto", name: "Low-carb / Keto", icon: "🥑")
    ]
    
    private let restrictions: [FoodOption] = [
        .init(id: "dairy_free", name: "Dairy-free", icon: "🧀"),
        .init(id: "gluten_free", name: "Gluten-free", icon: "🌾"),
        .init(id: "nut_free", name: "Nut-free", icon: "🥜"),
        .init(id: "soy_free", name: "Soy-free", icon: "🫘"),
        .init(id: "egg_free", name: "Egg-free", icon: "🥚"),
        .init(id: "shellfish_free", name: "Shellfish-free", icon: "🦐"),
        .init(id: "other", name: "Other", icon: "⚠️")
    ]
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Progress Bar with Back Button
                    OnboardingProgressBar(
                        currentStep: navigator.currentStep,
                        totalSteps: navigator.totalSteps,
                        sectionIndex: navigator.getSectionIndex(for: navigator.currentStep),
                        totalSections: 7,
                        canGoBack: navigator.canGoBack(),
                        onBack: { navigator.goBack() }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    // Content
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 8) {
                            Text("What type of diet do you prefer?")
                                .font(.system(size: 28, weight: .heavy, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Choose all that apply")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)
                        
                        // Preferences Section - Two Column Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Dietary Preferences")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            VStack(spacing: 8) {
                                // No restrictions - Full width
                                if let noRestrictions = dietaryPreferences.first(where: { $0.id == "no_restrictions" }) {
                                    Button(action: {
                                        if data.dietaryPreferences.contains(noRestrictions.id) {
                                            data.dietaryPreferences.remove(noRestrictions.id)
                                        } else {
                                            data.dietaryPreferences.removeAll()
                                            data.dietaryPreferences.insert(noRestrictions.id)
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Text(noRestrictions.icon)
                                            Text(noRestrictions.name)
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(ForkiTheme.textPrimary)
                                        }
                                        .padding(6)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(data.dietaryPreferences.contains(noRestrictions.id) ? ForkiTheme.surface.opacity(0.8) : ForkiTheme.surface.opacity(0.4))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(data.dietaryPreferences.contains(noRestrictions.id) ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: data.dietaryPreferences.contains(noRestrictions.id) ? 2 : 1.5)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Rest of preferences - Two column grid
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                    ForEach(dietaryPreferences.filter { $0.id != "no_restrictions" }) { pref in
                                        Button(action: {
                                            if data.dietaryPreferences.contains(pref.id) {
                                                data.dietaryPreferences.remove(pref.id)
                                            } else {
                                                data.dietaryPreferences.remove("no_restrictions")
                                                data.dietaryPreferences.insert(pref.id)
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Text(pref.icon)
                                                Text(pref.name)
                                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                                    .foregroundColor(ForkiTheme.textPrimary)
                                            }
                                            .padding(6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(data.dietaryPreferences.contains(pref.id) ? ForkiTheme.surface.opacity(0.8) : ForkiTheme.surface.opacity(0.4))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(data.dietaryPreferences.contains(pref.id) ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: data.dietaryPreferences.contains(pref.id) ? 2 : 1.5)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                        
                        // Restrictions Section - Two Column Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Allergies / Restrictions")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Select items you cannot have")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(restrictions) { restriction in
                                    Button(action: {
                                        if data.dietaryRestrictions.contains(restriction.id) {
                                            data.dietaryRestrictions.remove(restriction.id)
                                            if restriction.id == "other" {
                                                data.otherRestriction = ""
                                            }
                                        } else {
                                            data.dietaryRestrictions.insert(restriction.id)
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Text(restriction.icon)
                                            Text(restriction.name)
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(ForkiTheme.textPrimary)
                                        }
                                        .padding(6)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(data.dietaryRestrictions.contains(restriction.id) ? ForkiTheme.surface.opacity(0.8) : ForkiTheme.surface.opacity(0.4))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(data.dietaryRestrictions.contains(restriction.id) ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: data.dietaryRestrictions.contains(restriction.id) ? 2 : 1.5)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    // Show text field in grid next to "Other" button
                                    if restriction.id == "other" && data.dietaryRestrictions.contains("other") {
                                        TextField("Please specify", text: $data.otherRestriction)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(ForkiTheme.textPrimary)
                                            .padding(6)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .fill(ForkiTheme.surface.opacity(0.6))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                    .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
                                            )
                                            .focused($isOtherFocused)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    .forkiPanel()
                    .padding(.horizontal, 24)
                    
                    // Next Button
                    OnboardingPrimaryButton(
                        isEnabled: !data.dietaryPreferences.isEmpty || !data.dietaryRestrictions.isEmpty
                    ) {
                        onNext()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    DietaryPreferencesScreen(
        data: OnboardingData(),
        navigator: OnboardingNavigator(),
        onNext: {}
    )
}

