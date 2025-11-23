//
//  OnboardingData+UserData.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import Foundation

extension OnboardingData {
    /// Initialize OnboardingData from UserData (for editing mode)
    static func fromUserData(_ userData: UserData) -> OnboardingData {
        let data = OnboardingData()
        
        // Basic Info
        data.age = userData.age
        data.gender = GenderChoice(rawValue: userData.gender.lowercased())
        
        // Height - convert from cm back to feet/inches or cm
        if let heightCm = Int(userData.height) {
            data.heightCm = "\(heightCm)"
            data.heightUnit = .cm
            // Also set feet/inches for display
            let totalInches = Double(heightCm) / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            data.heightFeet = "\(feet)"
            data.heightInches = "\(inches)"
        }
        
        // Weight - convert from kg (stored as String with decimals) back to lbs or kg
        // Default to lbs for US users
        if let weightKg = Double(userData.weight) {
            data.weightKg = String(format: "%.1f", weightKg)
            // Convert to lbs for pre-population (most users use lbs)
            let weightLbs = weightKg * 2.20462
            data.weightLbs = String(format: "%.1f", weightLbs)
            data.weightUnit = .lbs  // Default to lbs
        }
        
        // Goals
        let goal = userData.normalizedGoal.lowercased()
        if goal.contains("lose") {
            data.primaryGoals = ["lose_weight"]
        } else if goal.contains("gain") || goal.contains("build muscle") {
            data.primaryGoals = ["gain_weight"]
        } else if goal.contains("maintain") {
            data.primaryGoals = ["maintain_weight"]
        } else if goal.contains("habits") {
            data.primaryGoals = ["improve_habits"]
        } else if goal.contains("energy") || goal.contains("stress") {
            data.primaryGoals = ["boost_energy"]
        }
        
        // Food Preferences
        data.dietaryPreferences = Set(userData.foodPreferences)
        
        // Notifications
        data.notificationsEnabled = userData.notifications
        
        return data
    }
    
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
        // Store with one decimal place to preserve precision for accurate conversion back to lbs
        if weightUnit == .lbs {
            if let lbs = Double(weightLbs) {
                let kgValue = lbs * 0.453592
                // Store with one decimal place to preserve accuracy
                let kgRounded = (kgValue * 10).rounded() / 10
                userData.weight = String(format: "%.1f", kgRounded)
            }
        } else {
            // If entered in kg, store as-is (may have decimal)
            if let kg = Double(weightKg) {
                userData.weight = String(format: "%.1f", kg)
            } else {
                userData.weight = weightKg
            }
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

