//
//  AgeGenderScreen.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI

struct AgeGenderScreen: View {
    @ObservedObject var data: OnboardingData
    @ObservedObject var navigator: OnboardingNavigator
    let onNext: () -> Void
    var onDismiss: (() -> Void)? = nil  // Optional dismiss handler (e.g., from Profile Screen or Sign Up/Sign In)
    
    @State private var currentAgeValue: Int = 25
    @FocusState private var isAgeFocused: Bool
    
    private var isAgeGenderValid: Bool {
        !data.age.isEmpty && data.gender != nil
    }
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Progress Bar with Back Button
                        // Always show back arrow on AgeGenderScreen
                        OnboardingProgressBar(
                            currentStep: navigator.currentStep,
                            totalSteps: navigator.totalSteps,
                            sectionIndex: navigator.getSectionIndex(for: navigator.currentStep),
                            totalSections: 6,
                            canGoBack: true, // Always allow going back from AgeGenderScreen
                            onBack: onDismiss ?? { }, // Use custom dismiss if available
                            onCustomBack: onDismiss  // Custom back handler (e.g., from Profile Screen or Sign Up/Sign In) - takes precedence
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Content
                        VStack(spacing: 0) {
                            // Header
                            VStack(spacing: 6) {
                                Text("🎂")
                                    .font(.system(size: 56))
                                    .padding(.bottom, 4)
                                
                                Text("How old are you?")
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("This helps us personalize your nutrition plan")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(ForkiTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 0) // Match spacing above "How tall are you?" on HeightScreen (16px from outer VStack spacing)
                            
                            // Age Selector
                            OnboardingAgeSelectorView(age: $data.age, currentValue: $currentAgeValue, isAgeFocused: $isAgeFocused)
                                .frame(height: 180)
                            
                            // Gender Selection
                            VStack(alignment: .center, spacing: 12) {
                                Text("Which gender describes you best?")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 8) // Add padding below question
                                
                                HStack(spacing: 12) {
                                    ForEach(GenderChoice.allCases) { choice in
                                        GenderPill(
                                            choice: choice,
                                            isSelected: data.gender == choice
                                        ) {
                                            data.gender = choice
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 6)
                            .padding(.top, 52) // More breathing room above "Which gender describes you best?"
                            .padding(.bottom, 0) // Spacing below matches HeightScreen (16px from outer VStack spacing)
                        }
                        .forkiPanel()
                        .padding(.horizontal, 24)
                        
                        // Next Button
                        OnboardingPrimaryButton(
                            isEnabled: isAgeGenderValid
                        ) {
                            onNext()
                        }
                        .id("nextButton") // For scrolling to it
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20) // Reduced padding - will adjust for keyboard
                    }
                    .frame(maxWidth: 460)
                }
                .scrollDismissesKeyboard(.interactively) // Allow dismissing keyboard by swiping down
                .onChange(of: isAgeFocused) { _, isFocused in
                    if isFocused {
                        // Scroll to show Next button when keyboard appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo("nextButton", anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: data.age) { _, _ in
                    if isAgeGenderValid {
                        // When age is set and gender is selected, scroll to show Next button
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("nextButton", anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: data.gender) { _, _ in
                    if isAgeGenderValid {
                        // When gender is selected and age is set, scroll to show Next button
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("nextButton", anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Age Selector
private struct OnboardingAgeSelectorView: View {
    @Binding var age: String
    @Binding var currentValue: Int
    @FocusState.Binding var isAgeFocused: Bool
    
    @State private var ageText: String = ""
    
    let minAge = 5
    let maxAge = 100
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Top padding above age circle
                Spacer()
                    .frame(height: 28)
                
                // Age Circle with TextField
                ZStack {
                    // Placeholder text when empty
                    if ageText.isEmpty {
                        Text("25")
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .foregroundColor(ForkiTheme.textSecondary.opacity(0.4))
                    }
                    
                    // TextField for typing
                    TextField("", text: $ageText)
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isAgeFocused)
                        .multilineTextAlignment(.center)
                        .frame(width: 120, height: 100)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: ageText) { _, newValue in
                            // Filter to allow only numeric input
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                ageText = filtered
                            }
                            
                            // Update currentValue and age binding
                            if let newAge = Int(filtered), (minAge...maxAge).contains(newAge) {
                                currentValue = newAge
                                age = "\(newAge)"
                            } else if filtered.isEmpty {
                                // Allow empty for editing
                                age = ""
                            }
                        }
                        .onChange(of: currentValue) { _, newValue in
                            // Sync text field when value changes from swipe
                            if ageText != "\(newValue)" {
                                ageText = "\(newValue)"
                            }
                        }
                }
                .frame(height: 100)
                .padding()
                .background(
                    Circle()
                        .fill(ForkiTheme.surface)
                        .overlay(
                            Circle()
                                .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
                        )
                        .shadow(color: ForkiTheme.borderPrimary.opacity(0.12), radius: 10, x: 0, y: 6)
                )
                .contentShape(Circle())
                .onTapGesture {
                    isAgeFocused = true
                }
                
                // Spacing between circle and text
                Spacer()
                    .frame(height: 20)
                
                Text("Swipe up or down to set your age")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
                    .padding(.bottom, 24) // Additional padding below the text
                
                // Bottom padding to create spacing to gender question
                Spacer()
                    .frame(height: 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                SpatialEventGesture()
                    .onChanged { events in
                        guard !isAgeFocused else { return }
                        guard let e = events.first(where: { $0.phase == .active }) else { return }
                        let y = max(0, min(e.location.y, geo.size.height))
                        let t = 1.0 - (y / geo.size.height)
                        let newAge = Int(round(CGFloat(minAge) + t * CGFloat(maxAge - minAge)))
                        currentValue = newAge.clamped(to: minAge...maxAge)
                        age = "\(currentValue)"
                        ageText = "\(currentValue)"
                    },
                including: isAgeFocused ? .subviews : .all
            )
            .onAppear {
                if let initial = Int(age), (minAge...maxAge).contains(initial) {
                    currentValue = initial
                    ageText = "\(initial)"
                } else {
                    currentValue = 25
                    age = "\(currentValue)"
                    ageText = "\(currentValue)"
                }
            }
        }
    }
}

// MARK: - Gender Pill
private struct GenderPill: View {
    let choice: GenderChoice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(choice.label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 40) // Reduced height for more compact buttons
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? ForkiTheme.surface : ForkiTheme.surface.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(ForkiTheme.borderPrimary.opacity(isSelected ? 0.8 : 0.25), lineWidth: isSelected ? 2.5 : 1.5)
                )
                .foregroundColor(isSelected ? ForkiTheme.textPrimary : ForkiTheme.textSecondary)
                .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.18 : 0), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Extension
// Note: clamped(to:) extension is defined in OnboardingData.swift

#Preview {
    AgeGenderScreen(
        data: OnboardingData(),
        navigator: OnboardingNavigator(),
        onNext: {}
    )
}

