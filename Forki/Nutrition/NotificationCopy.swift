//
//  NotificationCopy.swift
//  Forki
//
//  Forki notification copywriting library - cute, warm, and motivating
//

import Foundation

enum ForkiCopy {
    
    // MARK: - Starving State
    static let starving = [
        "Energy's tanking ⚡ Need a quick bite?",
        "Hey—haven't fueled up in a while. Want something light?",
        "Running low 🔋 A small meal helps big.",
        "Quick reboot? 🍽 Even a snack works."
    ]
    
    // MARK: - Dead Revive
    static let dead = [
        "Everything's at zero 💀 Time to refuel.",
        "Out of power. Tap to recharge 🔋",
        "Hit reset with your next meal ⚡"
    ]
    
    // MARK: - Missed Lunch
    static func lunch(persona: Int) -> String {
        switch persona {
        case 1: return "Midday lift? 🍱 A little fuel goes far."
        case 3: return "Still no lunch? Grab something quick ⚡"
        case 9: return "Busy day? Go for a grab-and-go option 🚀"
        default: return "Past lunch already — log something easy?"
        }
    }
    
    // MARK: - Missed Dinner
    static let dinner = [
        "Evening check-in 🌙 Want to add dinner?",
        "Long day? A light meal keeps you steady 💫",
        "Before you crash—log something simple?"
    ]
    
    // MARK: - Persona Nudges
    static func persona(_ id: Int) -> String {
        switch id {
        case 1: return "Goal: 2–3 meals today ⚡ Easy win—want ideas?"
        case 4: return "Small choices add up 📈 Try a simple meal?"
        case 6: return "Fuel = performance 💪 Log when you can!"
        default: return "Need inspo? Forki's got options 🔍✨"
        }
    }
    
    // MARK: - Consistency Streaks
    static let streak3 = "3-day streak 🔥 Keep this momentum!"
    static let streak5 = "5 days strong ⚡ Check your pace?"
    static let streak7 = "Week unlocked ✨ See your progress?"
    
    // MARK: - Daily Challenges
    static let challenges = [
        "Today's target: log 2 meals 🎯 Easy start.",
        "Try something new today 🍳 Want a rec?",
        "Aim for 60% of your goal ⚡ Ready when you are."
    ]
    
    // MARK: - Meal Logged (optional)
    static let mealLogged = [
        "Logged ✔️ Strong move.",
        "Nice! Meal saved ⚡",
        "Added! Keep that flow going 🔥"
    ]
}

