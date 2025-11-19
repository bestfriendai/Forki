//
//  GoalSettingScreen.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

struct GoalSettingScreen: View {
    @Binding var currentScreen: Int
    @Binding var userData: UserData
    
    @State private var selectedGoal: String = ""
    @State private var goalDuration: Int = 3
    
    private let goals: [GoalOption] = [
        GoalOption(
            id: "Build healthier eating habits",
            title: "Build healthier eating habits",
            subtitle: "Improve your nutrition",
            avatar: "🌱",
            description: "Focus on building consistent, healthy eating patterns"
        ),
        GoalOption(
            id: "Lose weight",
            title: "Lose weight",
            subtitle: "Create a caloric deficit",
            avatar: "🏃‍♀️",
            description: "Focus on creating a caloric deficit for weight loss"
        ),
        GoalOption(
            id: "Maintain my weight",
            title: "Maintain my weight",
            subtitle: "Balance nutrition",
            avatar: "🧘‍♀️",
            description: "Maintain current weight with balanced nutrition"
        ),
        GoalOption(
            id: "Gain weight / build muscle",
            title: "Gain weight / build muscle",
            subtitle: "Build strength",
            avatar: "💪",
            description: "Build muscle with increased protein intake"
        ),
        GoalOption(
            id: "Boost energy & reduce stress",
            title: "Boost energy & reduce stress",
            subtitle: "Improve well-being",
            avatar: "⚡",
            description: "Enhance energy levels and reduce stress around food"
        )
    ]
    
    var body: some View {
        ZStack {
            ForkiTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 24) {
                        header
                        goalOptions
                        if !selectedGoal.isEmpty {
                            durationSelector
                        }
                    }
                    .forkiPanel()
                    
                    continueButton
                        .buttonStyle(ForkiPrimaryButtonStyle())
                        .disabled(selectedGoal.isEmpty)
                        .opacity(selectedGoal.isEmpty ? 0.6 : 1)
                }
                .frame(maxWidth: 460)
                .padding(.horizontal, 24)
                .padding(.vertical, 36)
            }
        }
    }
    
    // MARK: Sections
    private var header: some View {
        VStack(spacing: 8) {
            Text("What's your goal?")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .multilineTextAlignment(.center)
            Text("Choose the body you want to achieve")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var goalOptions: some View {
        VStack(spacing: 16) {
            ForEach(goals) { goal in
                Button {
                    selectedGoal = goal.id
                } label: {
                    GoalCard(goal: goal, isSelected: selectedGoal == goal.id)
                }
            }
        }
    }
    
    private var durationSelector: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("I want to reach this goal in:")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                Text("\(goalDuration) months")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(ForkiTheme.highlightText)
            }
            
            Slider(
                value: Binding(
                    get: { Double(goalDuration) },
                    set: { goalDuration = Int($0) }
                ),
                in: 1...12,
                step: 1
            )
            .tint(ForkiTheme.actionOrange)
            
            HStack {
                Text("1 month")
                Spacer()
                Text("12 months")
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
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
    }
    
    private var continueButton: some View {
        Button {
            guard !selectedGoal.isEmpty else { return }
            userData.goal = selectedGoal
            userData.goalDuration = goalDuration
            withAnimation(.easeInOut) { currentScreen += 1 }
        } label: {
            Text("Continue")
        }
    }
}

// MARK: - GoalCard
struct GoalCard: View {
    let goal: GoalOption
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(goal.avatar)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                Text(goal.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary)
                Text(goal.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? ForkiTheme.surface : ForkiTheme.surface.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.2 : 0.08), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Model
struct GoalOption: Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var avatar: String
    var description: String
}

#Preview {
    GoalSettingScreen(
        currentScreen: .constant(3),
        userData: .constant(UserData())
    )
}
