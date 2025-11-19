//
//  CharacterSelectionView.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI

struct CharacterSelectionView: View {
    @Binding var currentScreen: Int
    @Binding var userData: UserData
    @State private var selectedCharacter: CharacterType = .squirtle
    @State private var showPreview: Bool = false
    
    private let characters: [CharacterType] = CharacterType.allCases
    
    var body: some View {
        ZStack {
            ForkiTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 28) {
                        // Header
                        VStack(spacing: 16) {
                            Text("Choose Your Character!")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Select a companion for your health journey")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Character Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 18) {
                            ForEach(characters) { character in
                                CharacterCard(
                                    character: character,
                                    isSelected: selectedCharacter == character
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCharacter = character
                                    }
                                }
                            }
                        }
                        
                        // Character Preview
                        VStack(spacing: 16) {
                            Text("Preview")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                            
                            CharacterPreviewView(character: selectedCharacter)
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(ForkiTheme.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
                                        )
                                )
                                .shadow(color: ForkiTheme.borderPrimary.opacity(0.15), radius: 14, x: 0, y: 10)
                        }
                        
                        // Character Description
                        VStack(spacing: 12) {
                            Text(selectedCharacter.displayName)
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text(selectedCharacter.description)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .forkiPanel()
                    
                    VStack(spacing: 12) {
                        Button {
                            userData.selectedCharacter = selectedCharacter
                            withAnimation(.easeInOut) {
                                currentScreen += 1
                            }
                        } label: {
                            Text("Continue with \(selectedCharacter.displayName)")
                        }
                        .buttonStyle(ForkiPrimaryButtonStyle())
                        
                        Text("Your character will evolve based on your health progress!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(ForkiTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }
}

// MARK: - Character Card
struct CharacterCard: View {
    let character: CharacterType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Character Image (PNG)
                Image(character.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Character Name
                Text(character.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ForkiTheme.actionOrange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? ForkiTheme.surface : ForkiTheme.surface.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: 2)
                    )
            )
            .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.2 : 0.08), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Character Preview View
struct CharacterPreviewView: View {
    let character: CharacterType
    
    var body: some View {
        ZStack {
            // Character Image Preview
            Image(character.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 180)
                .padding(16)
            
            // Character info overlay
            VStack {
                Spacer()
                HStack {
                    Text(character.emoji)
                        .font(.system(size: 20))
                    Text(character.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(ForkiTheme.surface.opacity(0.85))
                        .overlay(
                            Capsule()
                                .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 1)
                        )
                )
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Button Style
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.03 : 1.0)
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

#Preview {
    CharacterSelectionView(
        currentScreen: .constant(0),
        userData: .constant(UserData())
    )
}
