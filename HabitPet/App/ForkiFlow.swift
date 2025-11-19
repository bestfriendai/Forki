//
//  ForkiFlow.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

struct ForkiFlow: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var nutrition: NutritionState
    
    @State private var currentScreen: Int = 0
    @State private var loggedFoods: [LoggedFood] = []
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if showOnboarding {
                // Show OnboardingFlow when user signs up/in
                OnboardingFlow(userData: userData) { onboardingData in
                    // Convert OnboardingData to UserData and save
                    let convertedUserData = onboardingData.toUserData()
                    // Copy converted data to existing userData (preserving snapshot data)
                    userData.age = convertedUserData.age
                    userData.gender = convertedUserData.gender
                    userData.height = convertedUserData.height
                    userData.weight = convertedUserData.weight
                    userData.goal = convertedUserData.goal
                    userData.foodPreferences = convertedUserData.foodPreferences
                    userData.notifications = convertedUserData.notifications
                    userData.selectedCharacter = convertedUserData.selectedCharacter
                    
                    // Save onboarding completion and sign-in status
                    UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
                    UserDefaults.standard.set(true, forKey: "hp_hasOnboarded")
                    
                    // Persona data already saved via applySnapshot in WellnessSnapshotScreen
                    // Just ensure it's set (should already be set from WellnessSnapshot)
                    let personaID = onboardingData.personaIDValue
                    if personaID > 0 {
                        userData.personaID = personaID
                        UserDefaults.standard.set(personaID, forKey: "hp_personaID")
                    }
                    
                    // Navigate to Home Screen
                    withAnimation {
                        showOnboarding = false
                        currentScreen = 6
                    }
                }
            } else {
                switch currentScreen {
                case 0:
                    IntroScreen(currentScreen: $currentScreen, userData: userData)
                case 1:
                    SignUpScreen(currentScreen: $currentScreen, userData: userData) {
                        // On successful signup, start onboarding
                        withAnimation {
                            showOnboarding = true
                        }
                    }
                case 2:
                    SignInScreen(currentScreen: $currentScreen, userData: userData) {
                        // On successful signin, start onboarding
                        withAnimation {
                            showOnboarding = true
                        }
                    }
                case 6:
                    HomeScreen(loggedFoods: loggedFoods) {
                        // Sign out callback - navigate to Sign Up screen
                        withAnimation {
                            currentScreen = 1
                        }
                    }
                case 7:
                    RecipesView(
                        currentScreen: $currentScreen, 
                        loggedFoods: $loggedFoods,
                        onFoodLogged: { _ in },
                        userData: userData
                    )
                default:
                    HomeScreen(loggedFoods: loggedFoods)
                }
            }
        }
        .animation(.easeInOut, value: currentScreen)
        .animation(.easeInOut, value: showOnboarding)
        .transition(.slide)
        .onAppear {
            // If the user has previously completed onboarding/signed in, skip to Home
            if UserDefaults.standard.bool(forKey: "hp_isSignedIn") ||
               UserDefaults.standard.bool(forKey: "hp_hasOnboarded") {
                // UserData.init() already loads persisted name and snapshot data
                // Just load email if available
                if let savedEmail = UserDefaults.standard.string(forKey: "hp_userEmail") {
                    userData.email = savedEmail
                }
                currentScreen = 6
            }
        }
    }
}

#Preview {
    ForkiFlow()
}
