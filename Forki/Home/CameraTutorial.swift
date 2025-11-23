//
//  CameraTutorial.swift
//  Forki
//
//  Camera tutorial system for first-time users
//

import SwiftUI

// ============================================================
// 0. PreferenceKey to read the camera button position
// ============================================================
struct CameraButtonPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// ============================================================
// 1. Create a simple onboarding flag so the tutorial shows once
// ============================================================
extension UserDefaults {
    private static let tutorialKey = "forki_camera_tutorial_shown"
    private static let justCompletedOnboardingKey = "forki_just_completed_onboarding"

    var hasShownCameraTutorial: Bool {
        get { bool(forKey: Self.tutorialKey) }
        set { set(newValue, forKey: Self.tutorialKey) }
    }
    
    var justCompletedOnboarding: Bool {
        get { bool(forKey: Self.justCompletedOnboardingKey) }
        set { set(newValue, forKey: Self.justCompletedOnboardingKey) }
    }
    
    // MARK: - Debug/Testing Helper
    #if DEBUG
    /// Reset all first-time user flags for testing
    /// Call this to test the app as a brand new user
    static func resetFirstTimeUserFlags() {
        let defaults = UserDefaults.standard
        defaults.hasShownCameraTutorial = false
        defaults.justCompletedOnboarding = false
        defaults.set(false, forKey: "hp_isSignedIn")
        defaults.set(false, forKey: "hp_hasOnboarded")
        defaults.removeObject(forKey: "hp_personaID")
        defaults.removeObject(forKey: "hp_recommendedCalories")
        defaults.removeObject(forKey: "hp_avatarNeedsInitialization")
        defaults.removeObject(forKey: "hp_onboardingStartDate")
        defaults.removeObject(forKey: "hp_signupDate")
        defaults.removeObject(forKey: "hp_userEmail")
        defaults.removeObject(forKey: "hp_userName")
        defaults.removeObject(forKey: "supabase_user_id")
        print("✅ [CameraTutorial] Reset all first-time user flags - app will behave as new user")
    }
    #endif
}

// ============================================================
// 2. Floating Speech Bubble View
// ============================================================
struct CameraTutorialBubble: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text("📸 Try logging your first meal!\nTap the camera to scan your food.")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .lineSpacing(3)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .padding(.trailing, 8) // Add padding for X button
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.black.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                
                // Arrow at the bottom inside the bubble
                Image(systemName: "arrow.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            
            // X button in top right corner
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// ============================================================
// 3. Add Pulsing Circle Highlight for Camera Button
// ============================================================
struct CameraPulseCircle: View {
    @State private var pulse = false

    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.8), lineWidth: 3)
            .frame(width: 70, height: 70)
            .scaleEffect(pulse ? 1.15 : 0.9)
            .opacity(pulse ? 0.9 : 0.4)
            .animation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: pulse
            )
            .onAppear { pulse = true }
    }
}

// ============================================================
// 4. Add Modifier to Overlay Tutorial on Home Screen
// ============================================================
struct CameraTutorialModifier: ViewModifier {
    @State private var show = false
    @Binding var showAICamera: Bool
    @Binding var isOnHomeScreen: Bool // Track if we're actually on Home Screen (not showing overlays)
    
    func body(content: Content) -> some View {
        ZStack {
            content

            // Only show tutorial when on Home Screen
            if show && isOnHomeScreen {
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let screenHeight = geometry.size.height
                    let safeAreaBottom = geometry.safeAreaInsets.bottom
                    let safeAreaTop = geometry.safeAreaInsets.top
                    
                    // Camera button position calculation:
                    // Nav bar is at bottom, camera button is centered horizontally
                    // Camera button has .offset(y: -24) from nav bar center
                    // Button is 68x68, centered in nav bar (3rd of 5 items)
                    // Nav bar padding: 12px vertical, 12px horizontal
                    // Camera button center Y = screenHeight - safeAreaBottom - 41 (fine-tuned value)
                    let cameraButtonCenterX = screenWidth / 2
                    let cameraButtonCenterY = screenHeight - safeAreaBottom - 41
                    
                    // Speech bubble position - above camera button
                    // Bubble should be 90px above the camera button
                    let speechBubbleCenterY = cameraButtonCenterY - 90 - 34 // 34 is half of button height (68/2)
                    
                    ZStack {
                        // Pulse circle directly on camera button
                        CameraPulseCircle()
                            .position(
                                x: cameraButtonCenterX,
                                y: cameraButtonCenterY
                            )
                        
                        // Bubble appears above the camera button
                        CameraTutorialBubble(onDismiss: {
                            dismissTutorial()
                        })
                        .position(
                            x: cameraButtonCenterX,
                            y: speechBubbleCenterY
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .onAppear {
            #if DEBUG
            print("📸 [CameraTutorial] HomeScreen appeared - checking tutorial conditions")
            print("📸 [CameraTutorial] justCompletedOnboarding: \(UserDefaults.standard.justCompletedOnboarding)")
            print("📸 [CameraTutorial] hasShownCameraTutorial: \(UserDefaults.standard.hasShownCameraTutorial)")
            print("📸 [CameraTutorial] isOnHomeScreen: \(isOnHomeScreen)")
            #endif
            
            // Check immediately and also after delays to catch cases where flag is set after view appears
            checkAndShowTutorial()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                checkAndShowTutorial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkAndShowTutorial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                checkAndShowTutorial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                checkAndShowTutorial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                checkAndShowTutorial()
            }
        }
        .onChange(of: showAICamera) { oldValue, newValue in
            // Dismiss tutorial when camera is opened (user tapped camera button)
            if newValue && show {
                dismissTutorial()
            }
        }
        .onChange(of: isOnHomeScreen) { oldValue, newValue in
            // Re-check when user returns to home screen
            if newValue && !oldValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkAndShowTutorial()
                }
            }
        }
    }
    
    private func checkAndShowTutorial() {
        // Only show tutorial for first-time users who just completed onboarding
        let justCompleted = UserDefaults.standard.justCompletedOnboarding
        let hasShown = UserDefaults.standard.hasShownCameraTutorial
        
        // Debug logging to help diagnose issues
        #if DEBUG
        print("📸 [CameraTutorial] checkAndShowTutorial - justCompleted: \(justCompleted), hasShown: \(hasShown), show: \(show), isOnHomeScreen: \(isOnHomeScreen)")
        #endif
        
        // Check if we should show the tutorial
        guard justCompleted else {
            #if DEBUG
            if !justCompleted {
                print("📸 [CameraTutorial] Not showing - justCompleted is false")
            }
            #endif
            return
        }
        
        guard !hasShown else {
            #if DEBUG
            print("📸 [CameraTutorial] Not showing - hasShown is true")
            #endif
            return
        }
        
        guard !show else {
            #if DEBUG
            print("📸 [CameraTutorial] Not showing - already showing")
            #endif
            return
        }
        
        guard isOnHomeScreen else {
            #if DEBUG
            print("📸 [CameraTutorial] Not showing - not on home screen")
            #endif
            return
        }
        
        // Show tutorial immediately if conditions are met
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Double-check conditions haven't changed
            let stillJustCompleted = UserDefaults.standard.justCompletedOnboarding
            let stillHasShown = UserDefaults.standard.hasShownCameraTutorial
            
            #if DEBUG
            print("📸 [CameraTutorial] Delayed check - justCompleted: \(stillJustCompleted), hasShown: \(stillHasShown), show: \(self.show), isOnHomeScreen: \(self.isOnHomeScreen)")
            #endif
            
            if stillJustCompleted && !stillHasShown && !self.show && self.isOnHomeScreen {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    self.show = true
                    #if DEBUG
                    print("📸 [CameraTutorial] ✅ Showing tutorial now!")
                    #endif
                }
            } else {
                #if DEBUG
                if !stillJustCompleted {
                    print("📸 [CameraTutorial] ❌ Not showing - justCompleted became false")
                }
                if stillHasShown {
                    print("📸 [CameraTutorial] ❌ Not showing - hasShown became true")
                }
                if self.show {
                    print("📸 [CameraTutorial] ❌ Not showing - already showing")
                }
                if !self.isOnHomeScreen {
                    print("📸 [CameraTutorial] ❌ Not showing - not on home screen")
                }
                #endif
            }
        }
    }
    
    private func dismissTutorial() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            show = false
        }
        // Mark tutorial as shown for this user
        UserDefaults.standard.hasShownCameraTutorial = true
        UserDefaults.standard.justCompletedOnboarding = false // Clear the flag after showing
    }
}

// ============================================================
// 5. View Extension for Easy Application
// ============================================================
extension View {
    func cameraTutorial(showAICamera: Binding<Bool>, isOnHomeScreen: Binding<Bool>) -> some View {
        self.modifier(CameraTutorialModifier(showAICamera: showAICamera, isOnHomeScreen: isOnHomeScreen))
    }
}

// ============================================================
// 6. Preview for Testing Tutorial Visibility
// ============================================================
#Preview("Camera Tutorial Preview") {
    // Set flags to show tutorial in preview
    UserDefaults.standard.justCompletedOnboarding = true
    UserDefaults.standard.hasShownCameraTutorial = false
    
    // Create mock environment objects (matching HomeScreen preview pattern)
    let userData: UserData = {
        let data = UserData()
        data.name = "Preview User"
        data.email = "preview@example.com"
        return data
    }()
    
    return HomeScreen(loggedFoods: [])
        .environmentObject(userData)
        .environmentObject(NutritionState(goal: 2000))
}

