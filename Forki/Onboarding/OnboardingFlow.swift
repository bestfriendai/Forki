//
//  OnboardingFlow.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI

struct OnboardingFlow: View {
    @StateObject private var data: OnboardingData
    @StateObject private var navigator = OnboardingNavigator()
    @ObservedObject var userData: UserData
    
    let onComplete: (OnboardingData) -> Void
    var onDismiss: (() -> Void)? = nil
    var isEditingMode: Bool = false
    
    init(userData: UserData, onComplete: @escaping (OnboardingData) -> Void, onDismiss: (() -> Void)? = nil, isEditingMode: Bool = false) {
        self.userData = userData
        self.onComplete = onComplete
        self.onDismiss = onDismiss
        self.isEditingMode = isEditingMode
        
        // Initialize OnboardingData from UserData if editing
        if isEditingMode {
            _data = StateObject(wrappedValue: OnboardingData.fromUserData(userData))
        } else {
            _data = StateObject(wrappedValue: OnboardingData())
        }
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        switch navigator.currentStep {
        case 0:
            // Section 1: Basic Info - Age/Gender
            // Always show back arrow - pass onDismiss if available, otherwise go back to previous screen
            AgeGenderScreen(data: data, navigator: navigator, onNext: {
                navigator.goNext()
            }, onDismiss: onDismiss ?? {
                // Default: if no custom dismiss handler, just go back in onboarding flow
                navigator.goBack()
            })
        case 1:
            // Section 1: Basic Info - Height
            HeightScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 2:
            // Section 1: Basic Info - Weight
            WeightScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 3:
            // Section 2: Goals - Primary Goal
            PrimaryGoalScreen(data: data, navigator: navigator) {
                // PrimaryGoalScreen handles skipping step 4 if needed
                navigator.goNext()
            }
        case 4:
            // Section 2: Goals - Goal Weight (conditional)
            GoalWeightScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 5:
            // Section 3: Dietary - Preferences & Restrictions
            DietaryPreferencesScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 6:
            // Section 4: Eating Behavior - Eating Habits
            EatingHabitsScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 7:
            // Section 5: Lifestyle - Activity Level
            ActivityLevelScreen(data: data, navigator: navigator) {
                navigator.goNext()
            }
        case 8:
            // Section 6: Personalized Results - Wellness Snapshot
            WellnessSnapshotScreen(data: data, navigator: navigator, userData: userData) {
                if isEditingMode {
                    // Editing mode ends here - complete without Notifications screen
                    // Don't clear hp_editingMode here - let ProfileScreen handle it
                    
                    // Extract personaID from WellnessSnapshot before completing
                    let snapshot = WellnessSnapshotCalculator.calculateSnapshot(from: data)
                    let personaID = snapshot.persona.personaType

                    // Save persona + calories
                    UserDefaults.standard.set(personaID, forKey: "hp_personaID")
                    UserDefaults.standard.set(snapshot.recommendedCalories, forKey: "hp_recommendedCalories")

                    data.personaIDValue = personaID

                    // Update NutritionState (editing mode - don't clear meals)
                    userData.nutrition.initializeFromSnapshot(
                        personaID: personaID,
                        recommendedCalories: snapshot.recommendedCalories,
                        clearMeals: false // Don't clear - preserve existing meals
                    )

                    // Complete editing - ProfileScreen will handle navigation and cleanup
                    onComplete(data)
                } else {
                    // New user flow - go to Notifications screen
                    navigator.goNext()
                }
            }
        case 9:
            // Section 7: Notifications (Final Step)
            NotificationsScreen(data: data, navigator: navigator) {
                // Finalize onboarding
                let snapshot = WellnessSnapshotCalculator.calculateSnapshot(from: data)
                let personaID = snapshot.persona.personaType

                // Save persona + calories
                UserDefaults.standard.set(personaID, forKey: "hp_personaID")
                UserDefaults.standard.set(snapshot.recommendedCalories, forKey: "hp_recommendedCalories")

                // Save onboarding start date for weekly challenges
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "hp_onboardingStartDate")

                // 🔐 Save signup date once for challenge week math
                if UserDefaults.standard.object(forKey: "hp_signupDate") == nil {
                    UserDefaults.standard.set(Date(), forKey: "hp_signupDate")
                }

                data.personaIDValue = personaID

                // 🔥 IMPORTANT: Initialize NutritionState for Day 1 (first-time onboarding - clear meals)
                userData.nutrition.initializeFromSnapshot(
                    personaID: personaID,
                    recommendedCalories: snapshot.recommendedCalories,
                    clearMeals: true // Clear meals for fresh start on first-time onboarding
                )

                // Complete onboarding
                onComplete(data)
            }
        default:
            AgeGenderScreen(data: data, navigator: navigator, onNext: {
                navigator.goNext()
            }, onDismiss: onDismiss)
        }
    }
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            currentStepView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
}

#Preview {
    OnboardingFlow(userData: UserData()) { data in
        print("Onboarding complete!")
    }
}
