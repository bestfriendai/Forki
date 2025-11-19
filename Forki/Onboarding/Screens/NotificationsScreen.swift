//
//  NotificationsScreen.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

struct NotificationsScreen: View {
    // Onboarding flow properties
    private var onboardingData: OnboardingData?
    private var onboardingNavigator: OnboardingNavigator?
    private var onboardingComplete: (() -> Void)?
    
    // Legacy flow properties
    @Binding private var currentScreen: Int
    @Binding private var userData: UserData
    
    // Computed properties for onboarding flow
    private var isOnboardingFlow: Bool {
        onboardingData != nil && onboardingNavigator != nil
    }
    
    // Initializer for onboarding flow
    init(data: OnboardingData, navigator: OnboardingNavigator, onComplete: @escaping () -> Void) {
        self.onboardingData = data
        self.onboardingNavigator = navigator
        self.onboardingComplete = onComplete
        self._currentScreen = Binding<Int>(get: { 0 }, set: { _ in })
        self._userData = Binding<UserData>(get: { UserData() }, set: { _ in })
    }
    
    // Initializer for legacy flow
    init(currentScreen: Binding<Int>, userData: Binding<UserData>) {
        self.onboardingData = nil
        self.onboardingNavigator = nil
        self.onboardingComplete = nil
        self._currentScreen = currentScreen
        self._userData = userData
    }
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Progress Bar with Back Button (only for onboarding flow)
                    if let navigator = onboardingNavigator {
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
                    }
                    
                    // Content
                    VStack(spacing: 24) {
                        content
                            .forkiPanel()
                    }
                    .frame(maxWidth: 460)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 36)
                }
            }
        }
    }
    
    // MARK: Content
    private var content: some View {
        VStack(spacing: 24) {
            // Icon
            VStack {
                ZStack {
                    Circle()
                        .fill(ForkiTheme.surface)
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle()
                                .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
                        )
                        .shadow(color: ForkiTheme.borderPrimary.opacity(0.18), radius: 14, x: 0, y: 8)
                    Image(systemName: "bell.badge")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(ForkiTheme.highlightText)
                }
                .padding(.bottom, 16)
            }
            
            // Header
            VStack(spacing: 8) {
                Text("Stay on track with reminders")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Get gentle nudges to log meals, stay consistent, and hit your goals.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                BenefitRow(text: "Daily meal reminders")
                BenefitRow(text: "Weekly progress highlights")
                BenefitRow(text: "Motivation tips & quick recipes")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(ForkiTheme.surface.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
                    )
            )
            
            // Buttons
            VStack(spacing: 16) {
                Button {
                    if let data = onboardingData {
                        // Onboarding flow
                        data.notificationsEnabled = true
                        completeOnboarding()
                    } else {
                        // Legacy flow
                        userData.notifications = true
                        UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
                        UserDefaults.standard.set(true, forKey: "hp_hasOnboarded")
                        withAnimation { currentScreen = 6 }
                    }
                } label: {
                    Text("Enable Notifications")
                }
                .buttonStyle(ForkiPrimaryButtonStyle())
                
                Button {
                    if let data = onboardingData {
                        // Onboarding flow
                        data.notificationsEnabled = false
                        completeOnboarding()
                    } else {
                        // Legacy flow
                        userData.notifications = false
                        UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
                        UserDefaults.standard.set(true, forKey: "hp_hasOnboarded")
                        withAnimation { currentScreen = 6 }
                    }
                } label: {
                    Text("Maybe Later")
                }
                .buttonStyle(ForkiSecondaryButtonStyle())
            }
            
            // Footer
            Text("Users with reminders are 3× more consistent.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func completeOnboarding() {
        guard let data = onboardingData else { return }
        
        // Calculate snapshot for initialization
        let snapshot = WellnessSnapshotCalculator.calculateSnapshot(from: data)
        
        // Store snapshot data for avatar initialization
        UserDefaults.standard.set(snapshot.persona.personaType, forKey: "hp_personaID")
        UserDefaults.standard.set(snapshot.recommendedCalories, forKey: "hp_recommendedCalories")
        UserDefaults.standard.set(true, forKey: "hp_avatarNeedsInitialization")
        
        // Mark as onboarded
        UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
        UserDefaults.standard.set(true, forKey: "hp_hasOnboarded")
        
        // Complete onboarding
        onboardingComplete?()
    }
}

// MARK: - Benefit Row
private struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(ForkiTheme.actionOrange)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
        }
    }
}

// MARK: - Preview
#Preview {
    NotificationsScreen(
        data: OnboardingData(),
        navigator: OnboardingNavigator(),
        onComplete: {}
    )
}
