//
//  NotificationPreview.swift
//  Forki
//
//  Visual preview of Forki notifications - iOS notification style
//

import SwiftUI

struct NotificationPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Forki Notifications Preview")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Starving State
                NotificationCard(
                    title: "Forki",
                    message: "Energy's tanking ⚡ Need a quick bite?",
                    icon: "⚡",
                    color: .orange
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Running low 🔋 A small meal helps big.",
                    icon: "🔋",
                    color: .orange
                )
                
                // Dead/Revive State
                NotificationCard(
                    title: "Forki",
                    message: "Everything's at zero 💀 Time to refuel.",
                    icon: "💀",
                    color: .red
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Out of power. Tap to recharge 🔋",
                    icon: "🔋",
                    color: .red
                )
                
                // Missed Lunch
                NotificationCard(
                    title: "Forki",
                    message: "Midday lift? 🍱 A little fuel goes far.",
                    icon: "🍱",
                    color: .blue
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Past lunch already — log something easy?",
                    icon: "🍱",
                    color: .blue
                )
                
                // Missed Dinner
                NotificationCard(
                    title: "Forki",
                    message: "Evening check-in 🌙 Want to add dinner?",
                    icon: "🌙",
                    color: .purple
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Long day? A light meal keeps you steady 💫",
                    icon: "💫",
                    color: .purple
                )
                
                // Persona Nudges
                NotificationCard(
                    title: "Forki",
                    message: "Goal: 2–3 meals today ⚡ Easy win—want ideas?",
                    icon: "⚡",
                    color: .green
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Need inspo? Forki's got options 🔍✨",
                    icon: "✨",
                    color: .green
                )
                
                // Consistency Streaks
                NotificationCard(
                    title: "Forki",
                    message: "3-day streak 🔥 Keep this momentum!",
                    icon: "🔥",
                    color: .red
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Week unlocked ✨ See your progress?",
                    icon: "✨",
                    color: .purple
                )
                
                // Daily Challenges
                NotificationCard(
                    title: "Forki",
                    message: "Today's target: log 2 meals 🎯 Easy start.",
                    icon: "🎯",
                    color: .blue
                )
                
                NotificationCard(
                    title: "Forki",
                    message: "Try something new today 🍳 Want a rec?",
                    icon: "🍳",
                    color: .orange
                )
                
                // Meal Logged
                NotificationCard(
                    title: "Forki",
                    message: "Logged ✔️ Strong move.",
                    icon: "✔️",
                    color: .green
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - iOS Notification Card Component
struct NotificationCard: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // App Icon (simulated)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.6, green: 0.4, blue: 0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Text("🍴")
                    .font(.system(size: 24))
            }
            
            // Notification Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("now")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Notification Banner Style (Lock Screen Preview)
struct NotificationBannerPreview: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // App Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.8, blue: 0.6), Color(red: 0.6, green: 0.4, blue: 0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Text("🍴")
                        .font(.system(size: 18))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.85))
                .blur(radius: 20)
        )
    }
}

// MARK: - Lock Screen Notification Preview
struct LockScreenNotificationPreview: View {
    var body: some View {
        ZStack {
            // Simulated lock screen background
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Time
                Text("9:41")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundColor(.white)
                
                // Date
                Text("Monday, January 15")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // Notification Stack
                VStack(spacing: 8) {
                    NotificationBannerPreview(
                        title: "Forki",
                        message: "Energy's tanking ⚡ Need a quick bite?"
                    )
                    
                    NotificationBannerPreview(
                        title: "Forki",
                        message: "3-day streak 🔥 Keep this momentum!"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Preview Provider
struct NotificationPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Main preview (notification cards)
            NotificationPreview()
                .previewDisplayName("Notification Cards")
            
            // Lock screen preview
            LockScreenNotificationPreview()
                .previewDisplayName("Lock Screen")
                .preferredColorScheme(.dark)
        }
    }
}

