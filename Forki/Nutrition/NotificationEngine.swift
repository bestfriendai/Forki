//
//  NotificationEngine.swift
//  Forki
//
//  Intelligent notification system for persona-based health journey
//

import Foundation
import UserNotifications

// MARK: - Notification Types
enum NotificationType {
    case morningKickoff
    case mealReminder
    case lunchMissed
    case dinnerMissed
    case starvingState
    case deadPetRevive
    case personaNudge
    case streakCelebration
    case petChallenge
}

// MARK: - Notification Engine
final class NotificationEngine {
    static let shared = NotificationEngine()
    
    private let center = UNUserNotificationCenter.current()
    
    // Avoid spamming — store last trigger timestamps
    private var lastTriggered: [NotificationType: Date] = [:]
    
    private init() {
        // Don't request permissions automatically - only when user explicitly enables
    }
    
    // MARK: - Cooldown Management
    private func cooldownPassed(for type: NotificationType, hours: Double) -> Bool {
        guard let last = lastTriggered[type] else { return true }
        return Date().timeIntervalSince(last) > hours * 3600
    }
    
    private func markTriggered(_ type: NotificationType) {
        lastTriggered[type] = Date()
    }
    
    // MARK: - Authorization
    private func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        print("✅ Notification permissions granted")
                    }
                }
            }
        }
    }
    
    // MARK: - Unified Schedule Method
    private func scheduleForki(_ message: String, type: NotificationType) {
        let content = UNMutableNotificationContent()
        content.title = "Forki"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id = "forki_\(type)_\(UUID().uuidString)"
        
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger)) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled notification: \(message)")
            }
        }
        
        markTriggered(type)
    }
    
    // MARK: - Evaluation Methods
    
    /// Called after a meal is logged
    func evaluatePostMealState(_ ns: NutritionState) {
        // Check for streak celebrations
        evaluateStreakCelebrations(ns)
    }
    
    /// Called when avatar state is updated
    func evaluateAvatarState(_ ns: NutritionState) {
        // Starving state (high priority, max 1/day)
        if ns.avatarState == .starving && cooldownPassed(for: .starvingState, hours: 6) {
            scheduleForki(ForkiCopy.starving.randomElement()!, type: .starvingState)
        }
        
        // Dead pet revive (max 1/day)
        if ns.avatarState == .dead && cooldownPassed(for: .deadPetRevive, hours: 24) {
            scheduleForki(ForkiCopy.dead.randomElement()!, type: .deadPetRevive)
        }
    }
    
    /// Called when meal history is updated
    func evaluateDailyMealPatterns(_ ns: NutritionState) {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Lunch missed (after 2pm)
        if hour >= 14 && isLunchMissing(for: ns) && cooldownPassed(for: .lunchMissed, hours: 4) {
            scheduleForki(ForkiCopy.lunch(persona: ns.personaID), type: .lunchMissed)
        }
        
        // Dinner missed (after 7pm)
        if hour >= 19 && ns.caloriesCurrent < Int(Double(ns.caloriesGoal) * 0.4) && cooldownPassed(for: .dinnerMissed, hours: 4) {
            scheduleForki(ForkiCopy.dinner.randomElement()!, type: .dinnerMissed)
        }
        
        // Persona-based nudges (smart + infrequent, max every 48 hours)
        if cooldownPassed(for: .personaNudge, hours: 48) {
            scheduleForki(ForkiCopy.persona(ns.personaID), type: .personaNudge)
        }
    }
    
    /// Check for consistency streak celebrations
    private func evaluateStreakCelebrations(_ ns: NutritionState) {
        // Only celebrate once per milestone
        let previousScore = UserDefaults.standard.integer(forKey: "forki_lastCelebratedConsistency")
        
        if ns.consistencyScore == 3 && previousScore < 3 {
            scheduleForki(ForkiCopy.streak3, type: .streakCelebration)
            UserDefaults.standard.set(3, forKey: "forki_lastCelebratedConsistency")
        } else if ns.consistencyScore == 5 && previousScore < 5 {
            scheduleForki(ForkiCopy.streak5, type: .streakCelebration)
            UserDefaults.standard.set(5, forKey: "forki_lastCelebratedConsistency")
        } else if ns.consistencyScore == 7 && previousScore < 7 {
            scheduleForki(ForkiCopy.streak7, type: .streakCelebration)
            UserDefaults.standard.set(7, forKey: "forki_lastCelebratedConsistency")
        }
        
        // Reset if consistency drops below last celebrated
        if ns.consistencyScore < previousScore {
            UserDefaults.standard.set(ns.consistencyScore, forKey: "forki_lastCelebratedConsistency")
        }
    }
    
    /// Send daily challenge notification if needed (called from app launch or morning refresh)
    func sendDailyChallengeIfNeeded() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        guard hour >= 7 && hour <= 10 else { return }
        guard cooldownPassed(for: .petChallenge, hours: 24) else { return }
        
        scheduleForki(ForkiCopy.challenges.randomElement()!, type: .petChallenge)
    }
    
    // MARK: - Helper Methods
    
    /// Check if lunch is missing (11am-2pm window)
    private func isLunchMissing(for ns: NutritionState) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        // Only check if it's after 2pm
        guard hour >= 14 else { return false }
        
        let today = calendar.startOfDay(for: now)
        let lunchStart = calendar.date(byAdding: .hour, value: 11, to: today) ?? today
        let lunchEnd = calendar.date(byAdding: .hour, value: 14, to: today) ?? today
        
        let hasLunch = ns.loggedMeals.contains { meal in
            meal.timestamp >= lunchStart && meal.timestamp <= lunchEnd
        }
        
        return !hasLunch
    }
    
}

