//
//  ForkiApp.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

@main
struct ForkiApp: App {
    @StateObject private var userData = UserData()
    @StateObject private var nutrition: NutritionState
    
    init() {
        RapidSearch.shared.load()
        print("RapidSearch loaded: \(RapidSearch.shared.allItems.count) foods")
        // Initialize nutrition with recommended calories from UserDefaults
        let recommendedCalories = UserDefaults.standard.integer(forKey: "hp_recommendedCalories")
        _nutrition = StateObject(wrappedValue: NutritionState(goal: recommendedCalories > 0 ? recommendedCalories : 2000))
    }
    
    var body: some Scene {
        WindowGroup {
            ForkiFlow()
                .environmentObject(userData)
                .environmentObject(nutrition)
                .onAppear {
                    // Update nutrition goal if userData has a different recommendedCalories
                    if userData.recommendedCalories > 0 && userData.recommendedCalories != nutrition.caloriesGoal {
                        nutrition.setGoal(userData.recommendedCalories)
                    }
                    // Update personaID in nutrition if available
                    if userData.personaID > 0 {
                        nutrition.personaID = userData.personaID
                    }
                }
        }
    }
}

