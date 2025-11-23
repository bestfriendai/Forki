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
    
    // Weekly challenge tracking (6-week plan)
    @Published var currentChallengeWeek: Int = 1        // 1–6
    @Published var lastCelebratedWeek: Int = 0          // last week we fired confetti

    init(goal: Int = 2000) {
        self.caloriesGoal = goal
        // Nothing logged yet → neutral pet, 0%
        recomputeFromMeals() // This calls updateMealHistory() internally
        
        // Initialize challenge week based on signup date if available
        updateCurrentChallengeWeek()
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
        
        // Save meal log to Supabase
        saveMealLogToSupabase(mealLog: MealLog(from: lf))
        
        // Save avatar state
        saveAvatarState()
        
        // Always trigger normal sparkle on log
        SparkleEventBus.shared.sparklePublisher.send(.normalSparkle)
        
        // Check milestone celebrations
        checkForSparkleAchievements()
        
        // Evaluate notifications after meal is logged
        NotificationEngine.shared.evaluatePostMealState(self)
    }
    
    func remove(_ id: UUID) {
        // Delete meal log from Supabase
        deleteMealLogFromSupabase(mealLogId: id)
        
        loggedMeals.removeAll { $0.id == id }
        recomputeFromMeals()
        updateMealHistory()
        updateAvatarState()
        
        // Save avatar state
        saveAvatarState()
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
        updateAvatarState()
        
        // Update meal log in Supabase
        updateMealLogInSupabase(mealLog: MealLog(from: updatedFood))
        
        // Save avatar state
        saveAvatarState()
    }

    func replaceAll(with foods: [LoggedFood]) {
        loggedMeals = foods
        recomputeFromMeals() // This calculates calories, macros from meals
        updateMealHistory() // This updates consistency score, days without meals, etc.
        // Note: updateAvatarState() is called separately after this to ensure correct state
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
    // NOTE: This is called when user signs in or completes onboarding
    // clearMeals: true = new user (first-time onboarding), false = existing user (sign-in)
    func initializeFromSnapshot(personaID: Int, recommendedCalories: Int, clearMeals: Bool = false) {
        self.personaID = personaID
        self.caloriesGoal = recommendedCalories
        
        // For new users (first-time onboarding), clear everything for a fresh start
        if clearMeals {
            // Clear all meal logs
            self.loggedMeals = []
            self.caloriesCurrent = 0
            self.proteinCurrent = 0
            self.carbsCurrent = 0
            self.fatsCurrent = 0
            self.lastMealDate = nil
            self.daysWithoutMeals = 0
            self.consistencyScore = 0
            self.currentChallengeWeek = 1
            self.lastCelebratedWeek = 0
            
            // Clear all nutrition-related UserDefaults to ensure clean slate
            UserDefaults.standard.removeObject(forKey: "hp_avatarState")
            UserDefaults.standard.removeObject(forKey: "hp_caloriesCurrent")
            UserDefaults.standard.removeObject(forKey: "hp_caloriesGoal")
            UserDefaults.standard.removeObject(forKey: "hp_proteinCurrent")
            UserDefaults.standard.removeObject(forKey: "hp_carbsCurrent")
            UserDefaults.standard.removeObject(forKey: "hp_fatsCurrent")
            UserDefaults.standard.removeObject(forKey: "hp_lastMealDate")
            UserDefaults.standard.removeObject(forKey: "hp_daysWithoutMeals")
            UserDefaults.standard.removeObject(forKey: "hp_consistencyScore")
            UserDefaults.standard.removeObject(forKey: "hp_currentChallengeWeek")
            UserDefaults.standard.removeObject(forKey: "hp_lastCelebratedWeek")
            
            NSLog("🆕 [NutritionState] New user initialization - cleared all meal logs and state")
        }
        
        // Update meal history first (will recalculate consistency score)
        updateMealHistory()
        
        // Persona-based default mood, but then update based on current state
        // This ensures avatar state is correct even if there are existing meals
        self.avatarState = initialAvatarState(for: personaID)
        
        // Recalculate avatar state based on current nutrition data
        updateAvatarState()
        
        // Save avatar state after initialization
        saveAvatarState()
        
        NSLog("✅ [NutritionState] Initialized from snapshot - persona: \(personaID), calories: \(recommendedCalories), clearMeals: \(clearMeals), meals: \(loggedMeals.count)")
    }
    
    // Public method to refresh avatar state - useful when screen appears
    // This ensures avatar state is correct based on current time, meals, and nutrition data
    func updateAvatarStateIfNeeded() {
        // Always update meal history first (may affect daysWithoutMeals, consistency, etc.)
        updateMealHistory()
        
        // Then update avatar state based on current conditions
        // This handles time-based checks (e.g., 6pm starving) and current nutrition
        updateAvatarState()
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
        
        // Evaluate daily meal patterns for notifications
        NotificationEngine.shared.evaluateDailyMealPatterns(self)
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

    func updateAvatarState() {
        let previousState = avatarState
        
        // 1. Death check
        if daysWithoutMeals >= 3 {
            avatarState = .dead
            if previousState != .dead {
                NSLog("🎭 [NutritionState] Avatar state changed: \(previousState.rawValue) → \(avatarState.rawValue) (3+ days without meals)")
            }
            return
        }
        
        // 2. Time-of-day starving check (but only if no meals at all today)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 && caloriesCurrent == 0 && mealsLoggedToday == 0 {
            avatarState = .starving
            if previousState != .starving {
                NSLog("🎭 [NutritionState] Avatar state changed: \(previousState.rawValue) → \(avatarState.rawValue) (6pm, no meals today)")
            }
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
        
        // Log state change if different
        if previousState != avatarState {
            NSLog("🎭 [NutritionState] Avatar state changed: \(previousState.rawValue) → \(avatarState.rawValue) (ratio: \(String(format: "%.2f", ratio)), calories: \(caloriesCurrent)/\(caloriesGoal), persona: \(personaID))")
            // Save avatar state when it changes
            saveAvatarState()
        }
        
        // Evaluate avatar state for notifications
        NotificationEngine.shared.evaluateAvatarState(self)
    }
    
    // MARK: - Persistence Methods
    
    // Save avatar state to UserDefaults (for local persistence)
    private func saveAvatarState() {
        UserDefaults.standard.set(avatarState.rawValue, forKey: "hp_avatarState")
        UserDefaults.standard.set(caloriesCurrent, forKey: "hp_caloriesCurrent")
        UserDefaults.standard.set(caloriesGoal, forKey: "hp_caloriesGoal")
        UserDefaults.standard.set(proteinCurrent, forKey: "hp_proteinCurrent")
        UserDefaults.standard.set(carbsCurrent, forKey: "hp_carbsCurrent")
        UserDefaults.standard.set(fatsCurrent, forKey: "hp_fatsCurrent")
        
        if let lastMeal = lastMealDate {
            UserDefaults.standard.set(lastMeal, forKey: "hp_lastMealDate")
        }
        UserDefaults.standard.set(daysWithoutMeals, forKey: "hp_daysWithoutMeals")
        UserDefaults.standard.set(consistencyScore, forKey: "hp_consistencyScore")
        
        NSLog("💾 [NutritionState] Saved avatar state: \(avatarState.rawValue), calories: \(caloriesCurrent)/\(caloriesGoal)")
    }
    
    // Load avatar state from UserDefaults
    func loadAvatarState() {
        if let savedState = UserDefaults.standard.string(forKey: "hp_avatarState"),
           let state = AvatarState(rawValue: savedState) {
            avatarState = state
            NSLog("📥 [NutritionState] Loaded avatar state: \(avatarState.rawValue)")
        }
        
        caloriesCurrent = UserDefaults.standard.integer(forKey: "hp_caloriesCurrent")
        caloriesGoal = UserDefaults.standard.integer(forKey: "hp_caloriesGoal")
        if caloriesGoal == 0 { caloriesGoal = 2000 } // Default
        
        proteinCurrent = UserDefaults.standard.double(forKey: "hp_proteinCurrent")
        carbsCurrent = UserDefaults.standard.double(forKey: "hp_carbsCurrent")
        fatsCurrent = UserDefaults.standard.double(forKey: "hp_fatsCurrent")
        
        if let savedDate = UserDefaults.standard.object(forKey: "hp_lastMealDate") as? Date {
            lastMealDate = savedDate
        }
        daysWithoutMeals = UserDefaults.standard.integer(forKey: "hp_daysWithoutMeals")
        consistencyScore = UserDefaults.standard.integer(forKey: "hp_consistencyScore")
    }
    
    // Save meal log to Supabase (async, fire-and-forget)
    private func saveMealLogToSupabase(mealLog: MealLog) {
        guard let userId = UserDefaults.standard.string(forKey: "supabase_user_id") else {
            NSLog("⚠️ [NutritionState] No user ID for saving meal log")
            return
        }
        
        Task {
            do {
                let session = SupabaseAuthService.shared.getCurrentSession()
                try await SupabaseAuthService.shared.saveMealLog(
                    userId: userId,
                    mealLog: mealLog,
                    accessToken: session?.accessToken
                )
                NSLog("✅ [NutritionState] Saved meal log to Supabase: \(mealLog.food.name)")
            } catch {
                NSLog("❌ [NutritionState] Failed to save meal log: \(error.localizedDescription)")
            }
        }
    }
    
    // Update meal log in Supabase (async, fire-and-forget)
    private func updateMealLogInSupabase(mealLog: MealLog) {
        guard let userId = UserDefaults.standard.string(forKey: "supabase_user_id") else {
            return
        }
        
        Task {
            do {
                let session = SupabaseAuthService.shared.getCurrentSession()
                try await SupabaseAuthService.shared.updateMealLog(
                    userId: userId,
                    mealLog: mealLog,
                    accessToken: session?.accessToken
                )
                NSLog("✅ [NutritionState] Updated meal log in Supabase: \(mealLog.food.name)")
            } catch {
                NSLog("❌ [NutritionState] Failed to update meal log: \(error.localizedDescription)")
            }
        }
    }
    
    // Delete meal log from Supabase (async, fire-and-forget)
    private func deleteMealLogFromSupabase(mealLogId: UUID) {
        Task {
            do {
                let session = SupabaseAuthService.shared.getCurrentSession()
                try await SupabaseAuthService.shared.deleteMealLog(
                    mealLogId: mealLogId,
                    accessToken: session?.accessToken
                )
                NSLog("✅ [NutritionState] Deleted meal log from Supabase: \(mealLogId)")
            } catch {
                NSLog("❌ [NutritionState] Failed to delete meal log: \(error.localizedDescription)")
            }
        }
    }
    
    // Load meal logs from Supabase
    func loadMealLogsFromSupabase() async {
        guard let userId = UserDefaults.standard.string(forKey: "supabase_user_id") else {
            NSLog("⚠️ [NutritionState] No user ID for loading meal logs")
            return
        }
        
        do {
            let session = SupabaseAuthService.shared.getCurrentSession()
            let mealLogs = try await SupabaseAuthService.shared.loadMealLogs(
                userId: userId,
                accessToken: session?.accessToken
            )
            
            await MainActor.run {
                let loggedFoods = mealLogs.map { $0.toLoggedFood() }
                self.replaceAll(with: loggedFoods)
                self.updateMealHistory()
                // Calculate avatar state from loaded meal logs (don't load from UserDefaults)
                self.updateAvatarState()
                // Save the calculated state to UserDefaults for future use
                self.saveAvatarState()
                NSLog("✅ [NutritionState] Loaded \(mealLogs.count) meal logs from Supabase, calories: \(self.caloriesCurrent)/\(self.caloriesGoal), avatar: \(self.avatarState.rawValue)")
            }
        } catch {
            NSLog("❌ [NutritionState] Failed to load meal logs: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Weekly Challenge Week Calculation (6-week plan)
    private func updateCurrentChallengeWeek() {
        // If we have a stored week, start from that but recompute from signup date if available
        let storedWeek = UserDefaults.standard.integer(forKey: "hp_currentChallengeWeek")
        
        if let signupDate = UserDefaults.standard.object(forKey: "hp_signupDate") as? Date {
            let calendar = Calendar.current
            let daysSinceSignup = calendar.dateComponents([.day], from: signupDate, to: Date()).day ?? 0
            // Week is 1-based, each week = 7 days
            var week = daysSinceSignup / 7 + 1
            week = max(1, min(week, 6)) // clamp to 1...6
            
            currentChallengeWeek = week
            UserDefaults.standard.set(week, forKey: "hp_currentChallengeWeek")
        } else {
            // Fallback to stored value or Week 1
            currentChallengeWeek = storedWeek > 0 ? storedWeek : 1
            UserDefaults.standard.set(currentChallengeWeek, forKey: "hp_currentChallengeWeek")
        }
        
        // Load last celebrated week
        lastCelebratedWeek = UserDefaults.standard.integer(forKey: "hp_lastCelebratedWeek")
    }
    
    // MARK: - Weekly Challenge Completion Logic
    /// Simple, user-friendly 6-week ramp using existing metrics:
    /// - consistencyScore = days in last 7 days with >= 2 meals
    /// - ratio = today's caloriesCurrent / caloriesGoal
    private func checkWeeklyChallengeCompletion() {
        // Make sure week index is up to date (1...6)
        updateCurrentChallengeWeek()
        
        // Avoid double-celebrating the same week
        guard currentChallengeWeek != lastCelebratedWeek else { return }
        
        let ratio = Double(caloriesCurrent) / Double(max(1, caloriesGoal))
        var completed = false
        
        switch currentChallengeWeek {
        case 1:
            // Week 1: "Just show up" — reach 3+ days with >= 2 meals
            completed = consistencyScore >= 3
        case 2:
            // Week 2: "Get more consistent" — 4+ days
            completed = consistencyScore >= 4
        case 3:
            // Week 3: "Hit your pattern most days" — 5+ days
            completed = consistencyScore >= 5
        case 4:
            // Week 4: "Fuel close to your goal" — decent consistency + near goal
            completed = consistencyScore >= 5 && ratio >= 0.85 && ratio <= 1.15
        case 5:
            // Week 5: "Feed your pet well" — strong consistency + at least ~75% of calories
            completed = consistencyScore >= 5 && ratio >= 0.75
        case 6:
            // Week 6: "Boss level consistency" — 6–7 days
            completed = consistencyScore >= 6
        default:
            completed = false
        }
        
        if completed {
            lastCelebratedWeek = currentChallengeWeek
            UserDefaults.standard.set(lastCelebratedWeek, forKey: "hp_lastCelebratedWeek")
            
            // 🎉 Fire purple confetti once for this week's challenge
            SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
        }
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
        
        // (Optional) You can remove this if you only want weekly challenges to handle "weekly" wins.
        // 🎉 3. Weekly consistency achievement
        if consistencyScore >= 5 && consistencyScore <= 7 {
            SparkleEventBus.shared.sparklePublisher.send(.purpleConfetti)
        }
        
        // 🎉 4. Weekly Pet Challenge completion (6-week plan)
        checkWeeklyChallengeCompletion()
    }
}
