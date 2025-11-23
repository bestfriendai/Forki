//
//  ConfettiPreviewView.swift
//  Forki
//
//  Simple preview view to test purple confetti sparkle - matches Home Screen structure
//

import SwiftUI

struct ConfettiPreviewView: View {
    @State private var celebrating = false
    @State private var sparkleCount = 0
    @StateObject private var nutrition = NutritionState(goal: 2000)
    @StateObject private var userData: UserData = {
        let data = UserData()
        data.name = "Preview"
        return data
    }()
    
    // Derived
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        else if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }
    
    private var petMoodText: String {
        switch nutrition.avatarState {
        case .starving:
            return "Feed me…"
        case .sad:
            return "I'm hungry!"
        case .neutral:
            return "I'm here with you!"
        case .happy:
            return "Yum! Feeling good!"
        case .strong:
            return "Powered up!"
        case .overfull:
            return "I'm stuffed…"
        case .bloated:
            return "Too much…"
        case .dead:
            return "I need your help…"
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient (FORKI_Game)
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        avatarStage
                        
                        VStack(spacing: 20) {
                            Text("Purple Confetti Preview")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .padding(.top, 20)
                            
                            Text("Tap the button below to trigger purple confetti!")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                // Trigger purple confetti
                                SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
                                sparkleCount += 1
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20, weight: .bold))
                                    Text("Trigger Purple Confetti")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#9B59B6"), Color(hex: "#7B68C4")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(Color.white, lineWidth: 4)
                                        )
                                )
                                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 6)
                            }
                            
                            Text("Triggered: \(sparkleCount) time(s)")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 160)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 160)
                }
            }
        }
        .onReceive(SparkleEventBus.shared.sparklePublisher) { event in
            if event == .purpleConfetti {
                celebrating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    celebrating = false
                }
            }
        }
    }
    
    // MARK: - Sections (copied from HomeScreen)
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack(alignment: .top) {
                // Logo and subtitle - proportionally sized (FORKI: 40, NUTRITION PET: 15)
                VStack(alignment: .leading, spacing: 4) {
                    Text("FORKI")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(ForkiTheme.logo)
                        .shadow(color: ForkiTheme.logoShadow.opacity(0.35), radius: 6, x: 0, y: 4)
                    Text("NUTRITION PET")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary)
                        .tracking(1.6)
                }
                Spacer()
                ForkiBatteryView(percentage: nutrition.avatarEnergyPercentage)
            }
            
            VStack(alignment: .center, spacing: 4) {
                Text("\(greeting), \(userData.name)!")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Text(nutrition.petMessage)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var avatarStage: some View {
        ZStack {
            // Avatar stage background - FORKI_Game dark blue
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(ForkiTheme.avatarStageBackground)
                .modifier(SparkleOverlayModifier())
                .overlay(
                    // Pixelated starfield effect
                    ZStack {
                        // Small white stars
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                            .offset(x: -60, y: -80)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                            .offset(x: 80, y: -60)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2, height: 2)
                            .offset(x: -40, y: 100)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                            .offset(x: 100, y: 80)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2, height: 2)
                            .offset(x: -20, y: -40)
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 3, height: 3)
                            .offset(x: 60, y: 40)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color(hex: "#7B68C4"), lineWidth: 4) // Purple border - border-4
                )
                .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 14)
            
            VStack(spacing: 0) {
                // Speech bubble at top (moved up)
                ForkiSpeechBubble(text: petMoodText)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                
                // Avatar view circle (moved up)
                ZStack {
                    // Outer ring background
                    Circle()
                        .fill(ForkiTheme.avatarRing.opacity(0.6))
                        .frame(width: 208, height: 208)
                        .shadow(color: Color.black.opacity(0.1), radius: 18, x: 0, y: 10)
                    
                    // Fixed frame container to prevent layout shifts
                    ZStack {
                        // Solid square background behind video to hide any square edges
                        Rectangle()
                            .fill(ForkiTheme.avatarStageBackground) // Match the stage background color
                            .frame(width: 200, height: 200)
                        
                        AvatarView(
                            state: nutrition.avatarState,
                            showFeedingEffect: .constant(false),
                            size: 200,
                            isCircular: true  // Circular frame - clip video to circle
                        )
                        .clipShape(Circle()) // Clip to circle at SwiftUI level
                        .frame(width: 200, height: 200) // Fixed frame to prevent overflow
                        
                        // Celebration glow overlay (doesn't affect layout)
                        if celebrating {
                            Circle()
                                .fill(Color.purple.opacity(0.45))
                                .frame(width: 200, height: 200)
                                .blur(radius: 30)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: 200, height: 200) // Fixed frame prevents layout shifts
                    .clipShape(Circle()) // Clip entire ZStack (including square background) to circle
                    .scaleEffect(celebrating ? 1.06 : 1.0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.65), value: celebrating)
                    .clipped() // Ensure scale doesn't overflow
                }
                .compositingGroup() // Group layers together for better clipping
                .padding(.bottom, 16)
                
                // Meals logged text at bottom inside the Avatar Stage
                Text(mealsLoggedText)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380) // Slightly increased to fit everything
    }
    
    private var mealsLoggedText: String {
        let count = nutrition.mealsLoggedToday
        let mealWord = count == 1 ? "meal" : "meals"
        return "\(count) \(mealWord) logged today"
    }
}

// MARK: - Helper Views (copied from HomeScreen)

private struct ForkiBatteryView: View {
    let percentage: Int
    @State private var pulseGlow = false

    private var batteryColor: Color {
        if percentage > 100 { return ForkiTheme.batteryFillOver }
        if percentage > 60  { return ForkiTheme.batteryFillHigh }
        if percentage > 30  { return ForkiTheme.batteryFillMedium }
        return ForkiTheme.batteryFillLow
    }

    private var filledSegments: Int {
        let ratio = min(max(Double(percentage) / 100.0, 0), 1.0)
        return Int(ratio * 5.0 + 0.001)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    if percentage > 110 {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.55))
                            .blur(radius: pulseGlow ? 14 : 4)
                            .scaleEffect(pulseGlow ? 1.12 : 0.96)
                            .animation(
                                Animation.easeInOut(duration: 1.3).repeatForever(),
                                value: pulseGlow
                            )
                            .onAppear { pulseGlow = true }
                            .onDisappear { pulseGlow = false }
                            .frame(width: 86, height: 44)
                    }

                    RoundedRectangle(cornerRadius: 10)
                        .fill(ForkiTheme.batteryTrack)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
                        )
                        .frame(width: 72, height: 34)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(ForkiTheme.borderPrimary)
                        .frame(width: 4, height: 12)
                        .offset(x: 38)

                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    index < filledSegments
                                    ? batteryColor
                                    : ForkiTheme.batteryTrack.opacity(0.35)
                                )
                                .frame(width: 10, height: 20)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.8),
                                    value: filledSegments
                                )
                        }
                    }
                }
                .frame(width: 78, height: 38)

                Text(percentage > 100 ? "Full+" : "\(percentage)%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(
                        percentage > 30 ? ForkiTheme.textPrimary : ForkiTheme.batteryFillLow
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }

            Text("LIFE ENERGY")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .tracking(2)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#1E2742").opacity(0.85),
                    Color(hex: "#2A3441").opacity(0.80)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#7B68C4"), lineWidth: 4)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
    }
}

private struct ForkiSpeechBubble: View {
    let text: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                Text(text.uppercased())
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "#4A148C"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(ForkiTheme.logo, lineWidth: 2)
                            )
                    )
                
                RoundedTriangleTail()
                    .fill(Color.white)
                    .overlay(
                        TriangleBottomEdgesOnly()
                            .stroke(ForkiTheme.logo, lineWidth: 2)
                    )
                    .frame(width: 20, height: 14)
                    .offset(x: 16, y: -4)
            }
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
}

private struct RoundedTriangleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 3
        let overlap: CGFloat = 2
        let midX = rect.midX
        
        var leftHalf = Path()
        leftHalf.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        leftHalf.addLine(to: CGPoint(x: midX, y: rect.maxY))
        leftHalf.addLine(to: CGPoint(x: midX, y: rect.minY - overlap))
        leftHalf.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.minX + cornerRadius/2, y: rect.minY - overlap/2)
        )
        leftHalf.closeSubpath()
        
        path.addPath(leftHalf)
        
        var rightHalf = leftHalf
        rightHalf = rightHalf.applying(CGAffineTransform(translationX: -midX, y: 0))
        rightHalf = rightHalf.applying(CGAffineTransform(scaleX: -1, y: 1))
        rightHalf = rightHalf.applying(CGAffineTransform(translationX: midX, y: 0))
        
        path.addPath(rightHalf)
        
        return path
    }
}

private struct TriangleBottomEdgesOnly: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 3
        let midX = rect.midX
        
        var leftEdge = Path()
        leftEdge.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        leftEdge.addLine(to: CGPoint(x: midX, y: rect.maxY))
        
        path.addPath(leftEdge)
        
        var rightEdge = leftEdge
        rightEdge = rightEdge.applying(CGAffineTransform(translationX: -midX, y: 0))
        rightEdge = rightEdge.applying(CGAffineTransform(scaleX: -1, y: 1))
        rightEdge = rightEdge.applying(CGAffineTransform(translationX: midX, y: 0))
        
        path.addPath(rightEdge)
        
        return path
    }
}

#Preview {
    ConfettiPreviewView()
}

