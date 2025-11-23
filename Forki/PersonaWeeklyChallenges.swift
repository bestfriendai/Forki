//
//  PersonaWeeklyChallenges.swift
//  Forki
//
//  Weekly persona-specific pet challenges for 6 weeks.
//  Uses onboarding date + personaID to decide current challenge.
//

import Foundation

struct PersonaWeeklyChallenge {
    let week: Int
    let message: String
}

enum PersonaChallengeLibrary {
    static let maxWeeks = 6
    private static let onboardingKey = "hp_onboardingStartDate"

    // MARK: - Onboarding Start

    /// Returns the stored onboarding date, or sets "now" if missing.
    static func onboardingStartDate() -> Date {
        if let timestamp = UserDefaults.standard.object(forKey: onboardingKey) as? TimeInterval {
            return Date(timeIntervalSince1970: timestamp)
        }
        // Fallback: assume onboarding = now, and persist it
        let now = Date()
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: onboardingKey)
        return now
    }

    /// Current week since onboarding, 1–6. Each week = 7 days.
    static func currentWeek() -> Int {
        let start = onboardingStartDate()
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        let week = (days / 7) + 1
        return min(max(week, 1), maxWeeks)
    }

    /// Public helper: returns the current challenge for a persona.
    static func currentChallenge(for personaID: Int) -> PersonaWeeklyChallenge {
        let week = currentWeek()
        let message = message(for: personaID, week: week)
        return PersonaWeeklyChallenge(week: week, message: message)
    }

    /// Public helper: returns a specific week's challenge (used if needed).
    static func challenge(for personaID: Int, week: Int) -> PersonaWeeklyChallenge {
        let clampedWeek = min(max(week, 1), maxWeeks)
        let message = message(for: personaID, week: clampedWeek)
        return PersonaWeeklyChallenge(week: clampedWeek, message: message)
    }

    // MARK: - Persona + Week → Message

    private static func message(for personaID: Int, week: Int) -> String {
        switch personaID {
        case 1:  return persona1(week: week)
        case 2:  return persona2(week: week)
        case 3:  return persona3(week: week)
        case 4:  return persona4(week: week)
        case 5:  return persona5(week: week)
        case 6:  return persona6(week: week)
        case 7:  return persona7(week: week)
        case 8:  return persona8(week: week)
        case 9:  return persona9(week: week)
        case 10: return persona10(week: week)
        case 11: return persona11(week: week)
        case 12: return persona12(week: week)
        case 13: return persona13(week: week)
        default: return persona13(week: week)  // Fallback = Balanced Starter
        }
    }

    // MARK: - Persona 1 — Under-eater + Weight Gainer

    private static func persona1(week: Int) -> String {
        switch week {
        case 1: return "Log 2 meals/day for 5 days."                    // ✅ existing Week 1
        case 2: return "Add 1 snack to 3 days this week."
        case 3: return "Eat 3 meals in a day twice this week."
        case 4: return "Log breakfast 3 times this week."
        case 5: return "Hit your calorie goal 3 days this week."
        case 6: return "Log 2+ meals/day for 6 days."
        default: return "Log 2 meals/day for 5 days."
        }
    }

    // MARK: - Persona 2 — Lean but Stressed Student

    private static func persona2(week: Int) -> String {
        switch week {
        case 1: return "Log 1 snack mindfully for 3 days."              // ✅ existing Week 1
        case 2: return "Log 3 full meals in one day twice this week."
        case 3: return "Add a slow, seated meal 3 times this week."
        case 4: return "Swap one stress snack for a meal 3 days this week."
        case 5: return "Stop logging food after 10pm for 4 nights."
        case 6: return "Log 3 balanced meals/day for 3 days."
        default: return "Log 1 snack mindfully for 3 days."
        }
    }

    // MARK: - Persona 3 — Breakfast Skipper

    private static func persona3(week: Int) -> String {
        switch week {
        case 1: return "Log anything before noon 3× this week."         // ✅ existing Week 1
        case 2: return "Have breakfast before 11am on 3 days."
        case 3: return "Log 3 meals in a day once this week."
        case 4: return "Pick a go-to breakfast and log it 3×."
        case 5: return "Avoid skipping breakfast 4 days this week."
        case 6: return "Log a morning meal 5 days this week."
        default: return "Log anything before noon 3× this week."
        }
    }

    // MARK: - Persona 4 — Weight-Loss Starter

    private static func persona4(week: Int) -> String {
        switch week {
        case 1: return "Hit your protein goal 3 days in a row."         // ✅ existing Week 1
        case 2: return "Log all meals before 9pm for 4 days."
        case 3: return "Stay within your calorie goal 3 days this week."
        case 4: return "Swap one high-calorie snack for fruit 3 days."
        case 5: return "Log 3 meals/day for 4 days."
        case 6: return "Hit both calorie and protein goals 3 days."
        default: return "Hit your protein goal 3 days in a row."
        }
    }

    // MARK: - Persona 5 — Stress Snacker / Crammer

    private static func persona5(week: Int) -> String {
        switch week {
        case 1: return "Try avoiding late snacks 4 nights in a row."    // ✅ existing Week 1
        case 2: return "Log a planned snack instead of a random one 3 days."
        case 3: return "Keep snacks to 2 per day for 4 days."
        case 4: return "Log all snacks after 6pm for 5 days."
        case 5: return "Swap one late snack for tea or water 3 nights."
        case 6: return "Finish eating 2 hours before bed 4 nights."
        default: return "Try avoiding late snacks 4 nights in a row."
        }
    }

    // MARK: - Persona 6 — Athletic Student

    private static func persona6(week: Int) -> String {
        switch week {
        case 1: return "Log a post-workout meal 3× this week."          // ✅ existing Week 1
        case 2: return "Hit your protein goal 4 days this week."
        case 3: return "Log 3 meals + 1 snack for 3 days."
        case 4: return "Log a carb source in 2 meals/day for 4 days."
        case 5: return "Stay within 90–110% of calories 3 days."
        case 6: return "Log every workout-day meal for 5 days."
        default: return "Log a post-workout meal 3× this week."
        }
    }

    // MARK: - Persona 7 — Dorm Cook Beginner

    private static func persona7(week: Int) -> String {
        switch week {
        case 1: return "Try 1 new easy recipe this week."                // ✅ existing Week 1
        case 2: return "Log 2 home-made or dorm meals this week."
        case 3: return "Cook or assemble a 10-minute meal 3×."
        case 4: return "Repeat your favorite simple recipe 2×."
        case 5: return "Log 3 dinners that are not takeout."
        case 6: return "Plan and log 1 batch-style meal this week."
        default: return "Try 1 new easy recipe this week."
        }
    }

    // MARK: - Persona 8 — Food-Restricted Student

    private static func persona8(week: Int) -> String {
        switch week {
        case 1: return "Log 3 meals that match your restrictions."       // ✅ existing Week 1
        case 2: return "Save 2 'safe' go-to meals and log them."
        case 3: return "Log 2 safe options when eating out or on campus."
        case 4: return "Try 1 new recipe that fits your restrictions."
        case 5: return "Log 4 days fully on-plan with your restrictions."
        case 6: return "Build 1 full day of meals that all match your needs."
        default: return "Log 3 meals that match your restrictions."
        }
    }

    // MARK: - Persona 9 — Always-On-The-Go Student

    private static func persona9(week: Int) -> String {
        switch week {
        case 1: return "Log lunch 5× this week."                          // ✅ existing Week 1
        case 2: return "Pack or pick a grab-and-go breakfast 3×."
        case 3: return "Log 3 meals in a day 2 times this week."
        case 4: return "Keep a portable snack logged 4 days."
        case 5: return "Avoid skipping both breakfast and lunch for 4 days."
        case 6: return "Log something within 3 hours of waking for 5 days."
        default: return "Log lunch 5× this week."
        }
    }

    // MARK: - Persona 10 — Overeater

    private static func persona10(week: Int) -> String {
        switch week {
        case 1: return "Log all meals before 9pm for 4 days."            // ✅ existing Week 1
        case 2: return "Keep to 3 meals + 1 snack for 4 days."
        case 3: return "Stay within your calorie goal 3 days."
        case 4: return "Stop eating 2 hours before bed 4 nights."
        case 5: return "Log portions for 3 dinners this week."
        case 6: return "Have at least 2 light dinners this week and log them."
        default: return "Log all meals before 9pm for 4 days."
        }
    }

    // MARK: - Persona 11 — Recipe Explorer

    private static func persona11(week: Int) -> String {
        switch week {
        case 1: return "Try 2 new meals this week."                       // ✅ existing Week 1
        case 2: return "Log 1 new breakfast and 1 new dinner."
        case 3: return "Repeat your favorite new recipe 2×."
        case 4: return "Log 3 colorful (3+ colors) meals."
        case 5: return "Log 4 home-cooked or assembled meals."
        case 6: return "Try 1 higher-protein version of a favorite meal."
        default: return "Try 2 new meals this week."
        }
    }

    // MARK: - Persona 12 — Minimal Effort Logger

    private static func persona12(week: Int) -> String {
        switch week {
        case 1: return "Check in once a day for 5 days."                 // ✅ existing Week 1
        case 2: return "Log at least 1 meal for 6 days."
        case 3: return "Log 2 meals/day for 3 days."
        case 4: return "Use the camera to log food 3×."
        case 5: return "Log something before 3pm 4 days."
        case 6: return "Log 2+ meals/day for 4 days."
        default: return "Check in once a day for 5 days."
        }
    }

    // MARK: - Persona 13 — Balanced Starter (Default)

    private static func persona13(week: Int) -> String {
        switch week {
        case 1: return "Log 2 meals/day for 4 days."                     // ✅ existing Week 1
        case 2: return "Hit your calorie goal 3 days this week."
        case 3: return "Log 3 meals/day for 3 days."
        case 4: return "Add 1 fruit or veggie to 4 meals."
        case 5: return "Stay within 90–110% of calories 4 days."
        case 6: return "Log food every day this week."
        default: return "Log 2 meals/day for 4 days."
        }
    }
}


