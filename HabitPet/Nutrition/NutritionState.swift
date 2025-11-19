import Foundation
import SwiftUI

final class NutritionState: ObservableObject {
    // Source of truth
    @Published var loggedMeals: [LoggedFood] = []
    @Published var caloriesCurrent: Int = 0
    @Published var caloriesGoal: Int
    @Published var proteinCurrent: Double = 0
    @Published var carbsCurrent: Double   = 0
    @Published var fatsCurrent: Double    = 0
    @Published var avatarState: AvatarState = .neutral  // ✅ default on sign up

    // Defaults: Level 1; you can wire up a real level system later
    @Published var level: Int = 1
    
    // New state variables for avatar logic
    @Published var lastMealDate: Date?
    @Published var daysWithoutMeals: Int = 0
    @Published var consistencyScore: Int = 0   // days per week with >= 2 meals
    @Published var personaID: Int = 13         // default persona

    init(goal: Int = 2000) {
        self.caloriesGoal = goal
        // Nothing logged yet → neutral pet, 0%
        recomputeFromMeals() // This calls updateMealHistory() internally
    }

    // Derived
    var mealsLoggedToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return loggedMeals.filter {
            calendar.startOfDay(for: $0.timestamp) == today
        }.count
    }
    var progressPercent: Int {
        let pct = Double(caloriesCurrent) / Double(max(1, caloriesGoal)) * 100
        return Int(min(pct, 100).rounded())
    }
    
    // Avatar energy percentage (0-150) - integrates calories, avatar state, and consistency
    // Allows >100% for overfull/bloated states to show purple battery color
    var avatarEnergyPercentage: Int {
        // BASE: calorie progress
        let ratio = Double(caloriesCurrent) / Double(max(1, caloriesGoal))
        var base = ratio * 100
        
        // FLOOR & CEILING
        base = max(0, min(base, 150))  // cap at 150% before adjustments
        
        // ADJUSTMENTS:
        // Lower if starving or sad (but NOT for overfull/bloated - those should show >100%)
        switch avatarState {
        case .starving: base -= 40
        case .sad:      base -= 20
        case .bloated, .overfull: break  // Don't reduce - allow to show >100% with purple
        case .dead:     base = 0
        default: break
        }
        
        // Boost for good weekly consistency
        if consistencyScore >= 6 { base += 10 }
        if consistencyScore == 7 { base += 15 }
        
        // For overfull/bloated states, ensure we can show >100% (purple battery)
        // Don't cap at 100% if avatar is in overfull or bloated state
        if avatarState == .overfull || avatarState == .bloated {
            return Int(max(0, min(base, 150)))  // Allow up to 150% for visual
        }
        
        return Int(max(0, min(base, 100)))  // Otherwise cap at 100%
    }
    
    // Pet message based on avatar state and persona
    var petMessage: String {
        switch avatarState {
        case .dead:
            return "Your pet needs nourishment."
            
        case .starving:
            switch personaID {
            case 1:  return "I really need some fuel!"
            case 3:  return "Breakfast would help!"
            case 9:  return "Did we miss lunch?"
            default: return "I'm really hungry!"
            }
            
        case .sad:
            switch personaID {
            case 1: return "A meal would boost me!"
            case 5: return "Feeling low… let's reset."
            default: return "I could use a bite."
            }
            
        case .neutral:
            switch personaID {
            case 11: return "What should we try?"
            case 7:  return "Easy meals sound good."
            default: return "Hi there!"
            }
            
        case .happy:
            switch personaID {
            case 6: return "Nice fuel! Ready!"
            case 11: return "That was tasty!"
            default: return "Feeling good!"
            }
            
        case .strong:
            switch personaID {
            case 6: return "Power mode on!"
            default: return "Powered up!"
            }
            
        case .overfull:
            return "I'm stuffed!"
            
        case .bloated:
            return "We overdid it…"
        }
    }

    // Public ops
    func add(_ lf: LoggedFood) {
        loggedMeals.append(lf)
        lastMealDate = lf.timestamp
        
        // Ensure correct revival behavior
        if avatarState == .dead {
            reviveAvatar()
        }
        
        recomputeFromMeals()
        updateMealHistory()
        updateAvatarState()
        
        // Always trigger normal sparkle on log
        SparkleEventBus.shared.sparklePublisher.send(.normalSparkle)
        
        // Check milestone celebrations
        checkForSparkleAchievements()
    }
    
    func remove(_ id: UUID) {
        loggedMeals.removeAll { $0.id == id }
        recomputeFromMeals()
        updateMealHistory()
    }
    
    func update(_ id: UUID, with loggedFood: LoggedFood) {
        guard let index = loggedMeals.firstIndex(where: { $0.id == id }) else { return }
        // Preserve the original ID and timestamp when updating
        let originalMeal = loggedMeals[index]
        let updatedFood = LoggedFood(
            id: id,
            food: loggedFood.food,
            portion: loggedFood.portion,
            timestamp: originalMeal.timestamp // Keep original timestamp
        )
        loggedMeals[index] = updatedFood
        recomputeFromMeals()
        updateMealHistory()
    }

    func replaceAll(with foods: [LoggedFood]) {
        loggedMeals = foods
        recomputeFromMeals()
        updateMealHistory()
    }

    func setGoal(_ newGoal: Int) {
        caloriesGoal = newGoal
        updateAvatarState()
        objectWillChange.send()
    }
    
    // Revive avatar from death state
    func reviveAvatar() {
        if avatarState == .dead {
            avatarState = .starving
            daysWithoutMeals = 0
            lastMealDate = Date()
            // Do NOT instantly recompute & override starving state
        }
    }
    
    // Initialize avatar from wellness snapshot after onboarding
    func initializeFromSnapshot(personaID: Int, recommendedCalories: Int) {
        self.personaID = personaID
        self.caloriesGoal = recommendedCalories
        
        // Reset logs for a clean Day 1 start
        self.loggedMeals = []
        self.caloriesCurrent = 0
        self.lastMealDate = nil
        self.daysWithoutMeals = 0
        
        // Persona-based default mood
        self.avatarState = initialAvatarState(for: personaID)
        
        // Update meal history (will set consistency score to 0)
        updateMealHistory()
    }
    
    // Get initial avatar state based on persona
    private func initialAvatarState(for persona: Int) -> AvatarState {
        switch persona {
        case 1:  // Under-eater
            return .sad
        case 2:  // Lean but stressed
            return .neutral
        case 3:  // Breakfast Skipper
            return .sad
        case 4:  // Weight-loss starter
            return .neutral
        case 5:  // Stress snacker
            return .neutral
        case 6:  // Athletic student
            return .happy
        case 7:  // Dorm cook beginner
            return .neutral
        case 8:  // Food-restricted
            return .neutral
        case 9:  // On-the-go student
            return .sad
        case 10: // Overeater
            return .neutral
        case 11: // Recipe Explorer
            return .happy
        case 12: // Minimal effort logger
            return .neutral
        case 13: // Balanced starter (default)
            return .neutral
        default:
            return .neutral
        }
    }

    // Internals
    private func recomputeFromMeals() {
        caloriesCurrent = 0
        proteinCurrent = 0
        carbsCurrent   = 0
        fatsCurrent    = 0

        for f in loggedMeals {
            caloriesCurrent += Int(Double(f.food.calories) * f.portion)
            proteinCurrent  += f.food.protein * f.portion
            carbsCurrent    += f.food.carbs   * f.portion
            fatsCurrent     += f.food.fats    * f.portion
        }
        updateMealHistory()
        updateAvatarState()
    }
    
    // Update meal history tracking
    private func updateMealHistory() {
        // Update lastMealDate if we have meals
        if let mostRecentMeal = loggedMeals.max(by: { $0.timestamp < $1.timestamp }) {
            lastMealDate = mostRecentMeal.timestamp
        }
        
        // Calculate days without meals
        if let last = lastMealDate {
            let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            daysWithoutMeals = days
        } else {
            // First-time user: avatar should NOT start dead
            daysWithoutMeals = 0
        }
        
        // Update consistency score
        updateConsistencyScore()
    }
    
    // Update consistency score (days per week with >= 2 meals)
    private func updateConsistencyScore() {
        let calendar = Calendar.current
        let now = Date()
        var daysWithMeals = 0
        
        // Check last 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let mealsOnDay = loggedMeals.filter { meal in
                meal.timestamp >= startOfDay && meal.timestamp < endOfDay
            }
            
            if mealsOnDay.count >= 2 {
                daysWithMeals += 1
            }
        }
        
        consistencyScore = daysWithMeals
    }
    
    // Check if lunch is missing (11am-2pm)
    private func isLunchMissing() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        // Only check if it's after 2pm
        guard hour >= 14 else { return false }
        
        let today = calendar.startOfDay(for: now)
        let lunchStart = calendar.date(byAdding: .hour, value: 11, to: today) ?? today
        let lunchEnd = calendar.date(byAdding: .hour, value: 14, to: today) ?? today
        
        let hasLunch = loggedMeals.contains { meal in
            meal.timestamp >= lunchStart && meal.timestamp <= lunchEnd
        }
        
        return !hasLunch
    }
    
    // Apply persona-specific overrides
    private func applyPersonaOverrides(base state: AvatarState) -> AvatarState {
        switch personaID {
        case 1: // Under-eater
            if mealsLoggedToday >= 2 {
                return .happy
            }
            return state
        case 4: // Weight-loss starter
            if Double(caloriesCurrent) > Double(caloriesGoal) * 1.1 {
                return .overfull
            }
            return state
        case 9: // On-the-go student
            if isLunchMissing() {
                return .sad
            }
            return state
        case 12: // Minimal effort logger
            // Restrict to simpler states
            if state == .overfull || state == .bloated {
                return .happy
            }
            return state
        default:
            return state
        }
    }

    private func updateAvatarState() {
        // 1. Death check
        if daysWithoutMeals >= 3 {
            avatarState = .dead
            return
        }
        
        // 2. Time-of-day starving check (but only if no meals at all today)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 && caloriesCurrent == 0 && mealsLoggedToday == 0 {
            avatarState = .starving
            return
        }
        
        // 3. Calorie ratio logic
        let ratio = Double(caloriesCurrent) / Double(max(1, caloriesGoal))
        var state: AvatarState
        
        switch ratio {
        case ..<0.2:
            state = .starving
        case ..<0.4:
            state = .sad
        case ..<0.7:
            state = .neutral
        case ..<0.9:
            state = .happy
        case ..<1.1:
            state = .strong
        case ..<1.3:
            state = .overfull
        default:
            state = .bloated
        }
        
        // 4. Persona-specific overrides
        state = applyPersonaOverrides(base: state)
        
        // 5. Consistency boosts
        if consistencyScore >= 6 && state == .neutral {
            state = .happy
        }
        
        avatarState = state
    }
    
    // Check for milestone celebrations and trigger purple confetti
    private func checkForSparkleAchievements() {
        let ratio = Double(caloriesCurrent) / Double(max(1, caloriesGoal))
        
        // 🎉 1. Hit 100% of calorie goal (but not yet bloated)
        if ratio >= 1.0 && ratio < 1.05 && avatarState != .overfull {
            SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
        }
        
        // 🎉 2. Logged 3 meals today
        if mealsLoggedToday == 3 {
            SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
        }
        
        // 🎉 3. Weekly consistency achievement
        if consistencyScore >= 5 && consistencyScore <= 7 {
            SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
        }
    }
}
