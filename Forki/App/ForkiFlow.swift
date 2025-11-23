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
    @State private var onboardingSourceScreen: Int = 1 // Track which screen triggered onboarding (1 = Sign Up, 2 = Sign In)
    
    var body: some View {
        ZStack {
            if showOnboarding {
                // Show OnboardingFlow when user signs up/in
                OnboardingFlow(userData: userData, onComplete: { onboardingData in
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
                    
                    // CRITICAL: Save basic info to UserDefaults to ensure persistence
                    userData.saveBasicInfo()
                    
                    // Calculate and apply wellness snapshot to ensure BMI, bodyType, metabolism, and eatingPattern are set
                    let snapshot = WellnessSnapshotCalculator.calculateSnapshot(from: onboardingData)
                    userData.applySnapshot(snapshot)
                    
                    // Persona data already saved via applySnapshot above
                    // Just ensure it's set (should already be set from WellnessSnapshot)
                    let personaID = onboardingData.personaIDValue
                    if personaID > 0 {
                        userData.personaID = personaID
                        UserDefaults.standard.set(personaID, forKey: "hp_personaID")
                    }
                    
                    // CRITICAL: Initialize nutrition state with clearMeals: true for NEW users
                    // This ensures they start with a clean slate (no meals, default avatar state)
                    if personaID > 0 && snapshot.recommendedCalories > 0 {
                        userData.nutrition.initializeFromSnapshot(
                            personaID: personaID,
                            recommendedCalories: snapshot.recommendedCalories,
                            clearMeals: true // NEW USER - start fresh with no meals
                        )
                    }
                    
                    // Save onboarding completion and sign-in status
                    UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
                    UserDefaults.standard.set(true, forKey: "hp_hasOnboarded")
                    // Mark that user just completed onboarding to show camera tutorial
                    UserDefaults.standard.justCompletedOnboarding = true
                    #if DEBUG
                    print("📸 [ForkiFlow] Onboarding completed - set justCompletedOnboarding = true")
                    print("📸 [ForkiFlow] hasShownCameraTutorial = \(UserDefaults.standard.hasShownCameraTutorial)")
                    #endif
                    
                    // Save user data to Supabase
                    Task {
                        if let userId = UserDefaults.standard.string(forKey: "supabase_user_id") {
                            do {
                                try await SupabaseAuthService.shared.saveUserData(
                                    userId: userId,
                                    userData: userData,
                                    onboardingData: onboardingData
                                )
                            } catch {
                                print("Failed to save user data to Supabase: \(error)")
                                // Continue anyway - local data is saved
                            }
                        }
                    }
                    
                    // Navigate to Home Screen
                    withAnimation {
                        showOnboarding = false
                        currentScreen = 6
                    }
                }, onDismiss: {
                    // Go back to the screen that triggered onboarding
                    withAnimation {
                        showOnboarding = false
                        currentScreen = onboardingSourceScreen
                    }
                })
            } else {
                switch currentScreen {
                case 0:
                    IntroScreen(currentScreen: $currentScreen, userData: userData)
                case 1:
                    SignUpScreen(currentScreen: $currentScreen, userData: userData) {
                        // On successful signup, start onboarding
                        onboardingSourceScreen = 1 // Track that we came from Sign Up
                        withAnimation {
                            showOnboarding = true
                        }
                    }
                case 2:
                    SignInScreen(currentScreen: $currentScreen, userData: userData) {
                        // On successful signin, check if user has completed onboarding
                        // If they have onboarding data, go directly to Home Screen
                        // Otherwise, start onboarding
                        let hasOnboarded = UserDefaults.standard.bool(forKey: "hp_hasOnboarded") ||
                                         (!userData.age.isEmpty && !userData.height.isEmpty && !userData.weight.isEmpty)
                        
                        if hasOnboarded {
                            // User already has an account with onboarding data - go to Home
                            withAnimation {
                                currentScreen = 6
                            }
                        } else {
                            // New user or incomplete onboarding - start onboarding
                            onboardingSourceScreen = 2 // Track that we came from Sign In
                            withAnimation {
                                showOnboarding = true
                            }
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
                
                // Try to load latest user data from Supabase if we have a user ID
                Task {
                    if let userId = UserDefaults.standard.string(forKey: "supabase_user_id") {
                        do {
                            // Get session token for authentication
                            let session = SupabaseAuthService.shared.getCurrentSession()
                            let accessToken = session?.accessToken
                            
                            if let loadedUserData = try await SupabaseAuthService.shared.loadUserData(userId: userId, accessToken: accessToken) {
                                await MainActor.run {
                                    // Update userData with latest from Supabase
                                    userData.name = loadedUserData.name
                                    userData.email = loadedUserData.email
                                    userData.age = loadedUserData.age
                                    userData.gender = loadedUserData.gender
                                    userData.height = loadedUserData.height
                                    userData.weight = loadedUserData.weight
                                    userData.goal = loadedUserData.goal
                                    userData.goalDuration = loadedUserData.goalDuration
                                    userData.foodPreferences = loadedUserData.foodPreferences
                                    userData.notifications = loadedUserData.notifications
                                    userData.selectedCharacter = loadedUserData.selectedCharacter
                                    userData.personaID = loadedUserData.personaID
                                    userData.recommendedCalories = loadedUserData.recommendedCalories
                                    userData.eatingPattern = loadedUserData.eatingPattern
                                    userData.BMI = loadedUserData.BMI
                                    userData.bodyType = loadedUserData.bodyType
                                    userData.metabolism = loadedUserData.metabolism
                                    userData.recommendedMacros = loadedUserData.recommendedMacros
                                    
                                    // Also update local storage
                                    UserDefaults.standard.set(loadedUserData.name, forKey: "hp_userName")
                                    UserDefaults.standard.set(loadedUserData.personaID, forKey: "hp_personaID")
                                    UserDefaults.standard.set(loadedUserData.recommendedCalories, forKey: "hp_recommendedCalories")
                                    
                                    // CRITICAL: Save basic info to UserDefaults to ensure persistence
                                    loadedUserData.saveBasicInfo()
                                    
                                    // Initialize nutrition state with persona and calories to restore avatar state
                                    // clearMeals: false - preserve existing meal logs (will load from Supabase)
                                    if loadedUserData.personaID > 0 && loadedUserData.recommendedCalories > 0 {
                                        nutrition.initializeFromSnapshot(
                                            personaID: loadedUserData.personaID,
                                            recommendedCalories: loadedUserData.recommendedCalories,
                                            clearMeals: false // Don't clear - load from Supabase
                                        )
                                    }
                                    
                                    // Load meal logs from Supabase to restore user's meal history
                                    // This will calculate avatar state and battery life from the loaded meals
                                    Task {
                                        await nutrition.loadMealLogsFromSupabase()
                                        
                                        // After loading meal logs, update avatar state if needed (time-based checks)
                                        await MainActor.run {
                                            // Update avatar state based on current time and loaded meal logs
                                            // This handles time-based checks (e.g., 6pm starving) and ensures
                                            // avatar state is correct based on current conditions
                                            nutrition.updateAvatarStateIfNeeded()
                                            
                                            NSLog("✅ [ForkiFlow] Session restored - meals: \(nutrition.loggedMeals.count), calories: \(nutrition.caloriesCurrent)/\(nutrition.caloriesGoal), avatar: \(nutrition.avatarState.rawValue), battery: \(nutrition.avatarEnergyPercentage)%")
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Failed to load user data from Supabase: \(error)")
                            // Continue with local data - try to load meal logs anyway
                            Task {
                                await nutrition.loadMealLogsFromSupabase()
                                await MainActor.run {
                                    nutrition.loadAvatarState()
                                    nutrition.updateAvatarStateIfNeeded()
                                }
                            }
                        }
                    }
                }
                
                currentScreen = 6
            }
        }
    }
}

#Preview {
    ForkiFlow()
}
