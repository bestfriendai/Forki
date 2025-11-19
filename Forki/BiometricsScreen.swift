//
//  BiometricsScreen.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

// MARK: - Gender
enum GenderChoice: String, CaseIterable, Identifiable {
    case man = "man"
    case woman = "woman"
    case nonBinary = "non-binary"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .man:       return "Man"
        case .woman:     return "Woman"
        case .nonBinary: return "Non-binary"
        }
    }

    var icon: String {
        switch self {
        case .man:       return "♂"
        case .woman:     return "♀"
        case .nonBinary: return "🜬"
        }
    }
}

struct BiometricsScreen: View {
    @Binding var currentScreen: Int
    @Binding var userData: UserData

    // step = 0 → Age + Gender (combined)
    // step = 1 → Height
    // step = 2 → Weight
    @State private var step: Int = 0
    @State private var selectedGender: GenderChoice? = nil

    private let heightGradient: [Color] = [Color(hex: "#a855f7"), Color(hex: "#ec4899")]
    private let weightGradient: [Color] = [Color(hex: "#facc15"), Color(hex: "#f97316")]
    private let ageGradient:    [Color] = [Color(hex: "#4ade80"), Color(hex: "#3b82f6")]

    var body: some View {
        ZStack {
            ForkiTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    progressDots
                    
                    VStack(spacing: 24) {
                        if step == 0 {
                            ageGenderHeader
                            ageGenderContent
                        } else if step == 1 {
                            heightHeader
                            heightContent
                        } else {
                            weightHeader
                            weightContent
                        }
                    }
                    .forkiPanel()
                    
                    Button {
                        handleNext()
                    } label: {
                        Text(step < 2 ? "Continue" : "Finish")
                    }
                    .buttonStyle(ForkiPrimaryButtonStyle())
                    .disabled(!isStepValid)
                    .opacity(isStepValid ? 1 : 0.5)
                    
                    Button {
                        handleNext(skip: true)
                    } label: {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(ForkiSecondaryButtonStyle())
                }
                .frame(maxWidth: 460)
                .padding(.horizontal, 24)
                .padding(.vertical, 36)
            }
        }
        .onAppear {
            // If user already has a gender, map it to our local enum
            if !userData.gender.isEmpty,
               let g = GenderChoice(rawValue: userData.gender.lowercased()) {
                selectedGender = g
            }
        }
    }

    // MARK: - Derived

    private var isStepValid: Bool {
        switch step {
        case 0:
            return !userData.age.trimmingCharacters(in: .whitespaces).isEmpty && selectedGender != nil
        case 1:
            return !userData.height.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            return !userData.weight.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i <= step ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Age + Gender (Step 0)

    private var ageGenderHeader: some View {
        VStack(spacing: 6) {
            Text("🎂")
                .font(.system(size: 56))
                .padding(.bottom, 4)

            Text("How old are you?")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("This helps us personalize your nutrition plan")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
    }

    private var ageGenderContent: some View {
        VStack(spacing: 24) {
            // Age swipe (same trendy circular readout)
            AgeSelectorView(age: $userData.age)
                .frame(height: 220)
                .padding(.top, 6)

            // Gender question + choices
            VStack(alignment: .leading, spacing: 12) {
                // Title as a question, plus some breathing room under it
                Text("Which gender describes you best?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .padding(.bottom, 6) // extra spacing under title

                // Pills
                HStack(spacing: 12) {
                    ForEach(GenderChoice.allCases) { choice in
                        GenderPill(
                            choice: choice,
                            isSelected: selectedGender == choice
                        ) {
                            selectedGender = choice
                            userData.gender = choice.rawValue
                        }
                        .accessibilityLabel("\(choice.label)")
                        .accessibilityHint("Double tap to select \(choice.label)")
                    }
                }
            }
            .padding(.horizontal, 6)

        }
    }

    // MARK: - Height (Step 1)

    private var heightHeader: some View {
        VStack(spacing: 6) {
            Text("📏")
                .font(.system(size: 56))
                .padding(.bottom, 4)

            Text("What's your height?")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("We'll use this to calculate your nutritional needs")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
    }

    private var heightContent: some View {
        VStack(spacing: 20) {
            ForkiView(
                size: 200,
                heightScale: $userData.heightScale,
                widthScale: $userData.weightScale
            )
            .frame(width: 200, height: 240)
            .animation(.easeInOut(duration: 0.25), value: userData.heightScale)
            .animation(.easeInOut(duration: 0.25), value: userData.weightScale)

            DialPicker(
                value: Binding(
                    get: { CGFloat(Int(userData.height) ?? 170) },
                    set: { newVal in
                        userData.height = "\(Int(newVal))"
                        userData.heightScale = normalizeScale(newVal / 170.0)
                    }
                ),
                range: 120...220,
                step: 1,
                formatter: { cm in
                    let (ft, inch) = cmToFeetInches(cm: cm)
                    return "\(ft)′\(inch)″"
                },
                onChange: { newVal in
                    userData.height = "\(Int(newVal))"
                    userData.heightScale = normalizeScale(newVal / 170.0)
                }
            )
            .frame(height: 160)
        }
    }

    // MARK: - Weight (Step 2)

    private var weightHeader: some View {
        VStack(spacing: 6) {
            Text("⚖️")
                .font(.system(size: 56))
                .padding(.bottom, 4)

            Text("What's your current weight?")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("This helps us track your progress")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
    }

    private var weightContent: some View {
        VStack(spacing: 20) {
            ForkiView(
                size: 200,
                heightScale: $userData.heightScale,
                widthScale: $userData.weightScale
            )
            .frame(width: 200, height: 240)
            .animation(.interpolatingSpring(stiffness: 200, damping: 10), value: userData.weightScale)

            DialPicker(
                value: Binding(
                    get: { CGFloat(Int(userData.weight) ?? 70) },
                    set: { newVal in
                        userData.weight = "\(Int(newVal))"
                        userData.weightScale = normalizeScale(newVal / 70.0)
                    }
                ),
                range: 40...150,
                step: 1,
                formatter: { kg in "\(kgToLbs(kg: kg)) lbs" },
                onChange: { newVal in
                    userData.weight = "\(Int(newVal))"
                    userData.weightScale = normalizeScale(newVal / 70.0)
                }
            )
            .frame(height: 160)
        }
    }

    // MARK: - Actions

    private func handleNext(skip: Bool = false) {
        if step < 2 {
            withAnimation(.easeInOut) { step += 1 }
            return
        }
        // Finished – advance to next onboarding screen
        withAnimation(.easeInOut) { currentScreen += 1 }
    }
}

// MARK: - Gender Pill

private struct GenderPill: View {
    let choice: GenderChoice
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(choice.icon)
                Text(choice.label.capitalized)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? ForkiTheme.surface : ForkiTheme.surface.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(ForkiTheme.borderPrimary.opacity(isSelected ? 0.6 : 0.25), lineWidth: 1.5)
            )
            .foregroundColor(isSelected ? ForkiTheme.textPrimary : ForkiTheme.textSecondary)
            .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.18 : 0), radius: 6, x: 0, y: 3)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Age Selector (unchanged from your style)

struct AgeSelectorView: View {
    @Binding var age: String
    @State private var currentValue: Int = 25

    let minAge = 5
    let maxAge = 100

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 16) {
                Text("\(currentValue)")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
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

                Text("Swipe up or down to set your age")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                SpatialEventGesture()
                    .onChanged { events in
                        guard let e = events.first(where: { $0.phase == .active }) else { return }
                        let y = max(0, min(e.location.y, geo.size.height))
                        let t = 1.0 - (y / geo.size.height)
                        let newAge = Int(round(CGFloat(minAge) + t * CGFloat(maxAge - minAge)))
                        currentValue = newAge.clamped(to: minAge...maxAge)
                        age = "\(currentValue)"
                    }
            )
            .onAppear {
                if let initial = Int(age), (minAge...maxAge).contains(initial) {
                    currentValue = initial
                } else {
                    currentValue = 25
                    age = "\(currentValue)"
                }
            }
        }
    }
}

// MARK: - Dial Picker & Helpers (same as your existing)

struct DialPicker: View {
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let step: CGFloat
    let formatter: (CGFloat) -> String
    var onChange: (CGFloat) -> Void
    @State private var baseValue: CGFloat = 0

    var body: some View {
        VStack(spacing: 14) {
            Text(formatter(value))
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .frame(height: 70)

            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .fill(ForkiTheme.surface.opacity(0.7))
                        .frame(height: 4)

                    let t = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                    let xPos = t * geo.size.width
                    Circle()
                        .fill(ForkiTheme.actionOrange)
                        .frame(width: 32, height: 32)
                        .shadow(color: ForkiTheme.actionShadow, radius: 6, x: 0, y: 4)
                        .position(x: xPos.clamped(to: 16...(geo.size.width - 16)),
                                  y: geo.size.height / 2)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    let clampedX = g.location.x.clamped(to: 0...geo.size.width)
                                    let t = clampedX / geo.size.width
                                    let newVal = range.lowerBound + t * (range.upperBound - range.lowerBound)
                                    let stepped = (newVal / step).rounded() * step
                                    value = stepped.clamped(to: range)
                                    onChange(value)
                                }
                                .onEnded { _ in baseValue = value }
                        )
                }
                .onAppear { baseValue = value }
            }
            .frame(height: 60)
            .padding(.horizontal, 40)
        }
    }
}

// Helpers
func cmToFeetInches(cm: CGFloat) -> (Int, Int) {
    let inchesTotal = Int(round(cm / 2.54))
    let feet = inchesTotal / 12
    let inches = inchesTotal % 12
    return (feet, inches)
}
func kgToLbs(kg: CGFloat) -> Int { Int(round(kg * 2.20462)) }
func normalizeScale(_ raw: CGFloat) -> CGFloat { min(max(raw, 0.8), 1.2) }
extension Comparable { func clamped(to r: ClosedRange<Self>) -> Self { min(max(self, r.lowerBound), r.upperBound) } }

// MARK: - Preview

#Preview {
    BiometricsScreen(
        currentScreen: .constant(2),
        userData: .constant(UserData())
    )
}

