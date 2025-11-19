//
//  OnboardingData+UserData.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import Foundation

extension OnboardingData {
    /// Converts OnboardingData to UserData for integration with existing app flow
    func toUserData() -> UserData {
        var userData = UserData()
        
        // Basic Info
        userData.age = self.age
        userData.gender = self.gender?.rawValue ?? ""
        
        // Height - convert to string format (store in cm for consistency)
        if heightUnit == .feet {
            if let feet = Int(heightFeet), let inches = Int(heightInches) {
                let totalInches = feet * 12 + inches
                let cmValue = Double(totalInches) * 2.54
                let cm = Int(cmValue.rounded())
                userData.height = "\(cm)"
            }
        } else {
            userData.height = heightCm
        }
        
        // Weight - convert to string format (store in kg for consistency)
        if weightUnit == .lbs {
            if let lbs = Double(weightLbs) {
                let kgValue = lbs * 0.453592
                let kg = Int(kgValue.rounded())
                userData.weight = "\(kg)"
            }
        } else {
            userData.weight = weightKg
        }
        
        // Goals - map to new canonical goal strings
        if primaryGoals.contains("lose_weight") {
            userData.goal = "Lose weight"
        } else if primaryGoals.contains("gain_weight") {
            userData.goal = "Gain weight / build muscle"
        } else if primaryGoals.contains("maintain_weight") {
            userData.goal = "Maintain my weight"
        } else if primaryGoals.contains("improve_habits") {
            userData.goal = "Build healthier eating habits"
        } else if primaryGoals.contains("boost_energy") {
            userData.goal = "Boost energy & reduce stress"
        }
        
        // Food Preferences - combine preferences and restrictions
        userData.foodPreferences = Array(dietaryPreferences.union(dietaryRestrictions))
        
        // Notifications
        userData.notifications = self.notificationsEnabled
        
        return userData
    }
}

