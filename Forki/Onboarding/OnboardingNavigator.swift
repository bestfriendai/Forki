//
//  OnboardingNavigator.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI
import UIKit

class OnboardingNavigator: ObservableObject {
    @Published var currentStep: Int = 0
    
    // Total steps: 10 screens (added Notifications screen)
    let totalSteps = 10
    
    // Section mapping
    // Section 1 (Basic Info): steps 0-2 (Age/Gender, Height, Weight)
    // Section 2 (Goals): steps 3-4 (Primary Goals, Goal Weight)
    // Section 3 (Dietary): step 5 (Dietary Preferences)
    // Section 4 (Eating Habits): step 6 (Eating Habits)
    // Section 5 (Lifestyle): step 7 (Activity Level)
    // Section 6 (Personalized Results): step 8 (Wellness Snapshot)
    // Section 7 (Notifications): step 9 (Notifications - Final Step)
    
    func getSectionIndex(for step: Int) -> Int {
        switch step {
        case 0...2: return 0 // Basic Info
        case 3...4: return 1 // Goals
        case 5: return 2 // Dietary
        case 6: return 3 // Eating Habits
        case 7: return 4 // Lifestyle
        case 8: return 5 // Personalized Results
        case 9: return 6 // Notifications (Final Step)
        default: return 0
        }
    }
    
    // Check if a step requires keyboard input
    private func stepRequiresKeyboard(_ step: Int) -> Bool {
        switch step {
        case 0: return true  // AgeGenderScreen - has TextField
        case 1: return true  // HeightScreen - has TextField
        case 2: return true  // WeightScreen - has TextField
        case 4: return true  // GoalWeightScreen - has TextField
        default: return false // All other screens don't need keyboard
        }
    }
    
    // Dismiss keyboard smoothly
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func canGoNext() -> Bool {
        return currentStep < totalSteps - 1
    }
    
    func canGoBack() -> Bool {
        return currentStep > 0
    }
    
    func goNext() {
        guard canGoNext() else { return }
        
        let nextStep = currentStep + 1
        let currentStepHasKeyboard = stepRequiresKeyboard(currentStep)
        let nextStepNeedsKeyboard = stepRequiresKeyboard(nextStep)
        
        // If current step has keyboard and next step doesn't need it, dismiss keyboard smoothly
        if currentStepHasKeyboard && !nextStepNeedsKeyboard {
            dismissKeyboard()
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentStep = nextStep
        }
    }
    
    func goBack() {
        guard canGoBack() else { return }
        
        let previousStep = currentStep - 1
        let currentStepHasKeyboard = stepRequiresKeyboard(currentStep)
        let previousStepNeedsKeyboard = stepRequiresKeyboard(previousStep)
        
        // Dismiss keyboard when going back from a keyboard screen to a non-keyboard screen
        if currentStepHasKeyboard && !previousStepNeedsKeyboard {
            dismissKeyboard()
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentStep = previousStep
        }
    }
}

