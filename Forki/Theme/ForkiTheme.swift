//
//  ForkiTheme.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI

enum ForkiTheme {
    // Core palette - Midnight/Navy gamified theme
    static let background = Color(hex: "#0A1128") // Deep midnight blue
    static let surface = Color(hex: "#1A2332")
    static let panelBackground = Color(hex: "#1E2742").opacity(0.85) // Translucent navy
    static let borderPrimary = Color(hex: "#7B68C4") // Purple border (glowing accent)
    
    static let textPrimary = Color(hex: "#E8E8F0") // Light text for dark background
    static let textSecondary = Color(hex: "#B8B8C8") // Muted light gray
    static let highlightText = Color(hex: "#8DD4D1") // Mint accent
    static let accentText = Color(hex: "#7B68C4") // Purple accent
    
    // Action buttons - FORKI_Game colors
    static let actionLogFood = Color(hex: "#8DD4D1") // Mint cyan (Log Food)
    static let actionLogFoodEnd = Color(hex: "#6FB8B5") // Darker mint
    static let actionRecipes = Color(hex: "#F5C9E0") // Pink (Recipes)
    static let actionRecipesEnd = Color(hex: "#E8B3D4") // Darker pink
    static let actionOrange = Color(hex: "#F5C9E0") // Alias for backward compatibility (pink from FORKI_Game)
    static let actionYellow = Color(hex: "#8DD4D1") // Alias for backward compatibility (mint from FORKI_Game)
    static let actionShadow = Color.black.opacity(0.2)
    
    // Legend/Nutrient colors - FORKI_Game retro colors
    static let legendProtein = Color(hex: "#8DD4D1") // Mint
    static let legendProteinEnd = Color(hex: "#A0DDD9") // Lighter mint
    static let legendCarbs = Color(hex: "#FFE8A3") // Yellow
    static let legendCarbsEnd = Color(hex: "#FFF2C8") // Lighter yellow
    static let legendFats = Color(hex: "#9B7FBF") // Purple
    static let legendFatsEnd = Color(hex: "#B399D1") // Lighter purple
    static let legendFiber = Color(hex: "#D4C4B0") // Warm beige
    static let legendFiberEnd = Color(hex: "#E4D4C0") // Lighter beige
    
    static let progressTrack = Color(hex: "#2A3441") // Dark navy track
    static let progressFillBackground = Color(hex: "#3A4451").opacity(0.6) // Translucent fill
    
    static let logo = Color(hex: "#8DD4D1") // Mint cyan
    static let logoShadow = Color(hex: "#7AB8B5") // Darker mint shadow
    
    static let bubbleBackground = Color(hex: "#FFB74D") // Amber for speech bubble
    static let bubbleText = Color.white
    
    static let avatarStageBackground = Color(hex: "#2C3E7F") // Dark blue
    static let avatarStageCheckA = Color(hex: "#2C3E7F") // Dark blue
    static let avatarStageCheckB = Color(hex: "#3C4E8F") // Slightly lighter blue
    static let avatarRing = Color(hex: "#F0D8E8") // Soft pink ring
    
    static let batteryTrack = Color(hex: "#2A3441") // Dark navy
    static let batteryFillHigh = Color(hex: "#8DD4D1") // Mint (>60%)
    static let batteryFillMedium = Color(hex: "#FFE8A3") // Amber (30-60%)
    static let batteryFillLow = Color(hex: "#FF9999") // Red (<30%)
    static let batteryFillOver = Color(hex: "#C7A0EB") // Purple (overfull/bloated >100%)
    
    static let navBackground = Color(hex: "#2A3441").opacity(0.90) // Translucent dark
    static let navBackgroundEnd = Color(hex: "#1E2742").opacity(0.85) // Translucent navy
    static let navSelection = Color(hex: "#7B68C4") // Purple
    static let navText = Color(hex: "#B8B8C8") // Light gray for dark background
    static let navHighlight = Color(hex: "#8DD4D1") // Mint accent
    
    // Gradients - Midnight/Navy gamified theme
    static var onboardingBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0A1128"), // Deep midnight
                Color(hex: "#1A2332"), // Darker navy
                Color(hex: "#2A3441")  // Slightly lighter navy
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Background gradient for main screen (midnight)
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#0A1128"), // Deep midnight
                Color(hex: "#1A2332"), // Darker navy
                Color(hex: "#2A3441")  // Slightly lighter navy
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Main container gradient (translucent midnight board)
    static var containerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#1E2742").opacity(0.85), // Translucent navy
                Color(hex: "#2A3441").opacity(0.80), // More translucent
                Color(hex: "#1E2742").opacity(0.85)  // Back to navy
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Navigation bar gradient (midnight)
    static var navGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#2A3441").opacity(0.90), // Translucent dark
                Color(hex: "#1E2742").opacity(0.85)  // Translucent navy
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var cardStroke: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(borderPrimary, lineWidth: 3)
    }
    
    static func capsuleButtonBackground(_ color: Color = actionOrange) -> some View {
        Capsule(style: .continuous)
            .fill(color)
            .shadow(color: actionShadow, radius: 12, x: 0, y: 6)
    }
}

// MARK: - Shared Button Style

struct ForkiPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(ForkiTheme.actionOrange.opacity(configuration.isPressed ? 0.85 : 1))
                    .shadow(color: ForkiTheme.actionShadow, radius: configuration.isPressed ? 6 : 12, x: 0, y: configuration.isPressed ? 3 : 6)
            )
            .foregroundColor(ForkiTheme.borderPrimary) // Purple text (same as status bubble) for pink buttons
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct ForkiSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ForkiTheme.surface.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
                    )
            )
            .foregroundColor(ForkiTheme.textPrimary)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

// MARK: - View Helpers

extension View {
    func forkiPanel(cornerRadius: CGFloat = 28, padding: CGFloat = 24) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ForkiTheme.panelBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
            )
            .shadow(color: ForkiTheme.borderPrimary.opacity(0.12), radius: 14, x: 0, y: 8)
    }
}


