//
//  UniversalNavigationBar.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI

// MARK: - Universal Navigation Bar
struct UniversalNavigationBar: View {
    let onHome: () -> Void
    let onExplore: () -> Void
    let onCamera: () -> Void
    let onProgress: () -> Void
    let onProfile: () -> Void
    let currentScreen: NavigationScreen
    
    var body: some View {
        HStack(spacing: 0) {
            navItem(icon: "house.fill", title: "Home", action: onHome, isSelected: currentScreen == .home)
            navItem(icon: "location.circle.fill", title: "Explore", action: onExplore, isSelected: currentScreen == .explore)
            
            Button(action: onCamera) {
                ZStack {
                    // Special camera button - Bold purple gradient
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#8B5CF6"), // Vibrant purple
                                    Color(hex: "#A78BFA")  // Lighter vibrant purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color(hex: "#7B68C4"), lineWidth: 4) // Purple border matching theme
                        )
                        .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 16, x: 0, y: 8)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
                }
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(PlainButtonStyle())
            .offset(y: -24)
            .accessibilityLabel("AI Camera")
            
            navItem(icon: "chart.bar.fill", title: "Progress", action: onProgress, isSelected: currentScreen == .progress)
            navItem(icon: "person.crop.circle", title: "Profile", action: onProfile, isSelected: currentScreen == .profile)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            // FORKI_Game navigation bar gradient
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ForkiTheme.navGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary, lineWidth: 3) // Reduced border for better fit
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }

    private func navItem(icon: String, title: String, action: @escaping () -> Void, isSelected: Bool) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.large)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isSelected ? .white : ForkiTheme.navText)
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : ForkiTheme.navText)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? ForkiTheme.navSelection.opacity(0.3) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Screen Enum
enum NavigationScreen {
    case home, explore, camera, progress, profile
    
    static var allCases: [NavigationScreen] {
        return [.home, .explore, .camera, .progress, .profile]
    }
}

// MARK: - Theme
// Note: Using ForkiTheme from ForkiTheme.swift for FORKI_Game styling

// MARK: - Preview

struct UniversalNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        UniversalNavigationBar(
            onHome: {},
            onExplore: {},
            onCamera: {},
            onProgress: {},
            onProfile: {},
            currentScreen: .home
        )
        .padding()
        .background(Color(hex: "#f6e6c9"))
        .previewLayout(.sizeThatFits)
    }
}
