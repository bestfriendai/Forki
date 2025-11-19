//
//  WellnessSnapshotCalculator.swift
//  Forki
//
//  Updated for cleaner Wellness Snapshot layout
//

import Foundation

// MARK: - Persona Profile Model
struct PersonaProfile {
    let personaName: String
    let personaDescription: String   // 1-sentence version
    let challenges: [String]
    let suggestedPattern: String     // short eating pattern text
    let petChallenge: String
    let personaType: Int
}

// MARK: - Wellness Snapshot Model
struct WellnessSnapshot {
    let persona: PersonaProfile
    let BMI: Double
    let bodyType: String
    let metabolism: String
    let recommendedCalories: Int
    let recommendedMacros: Macros
}

// MARK: - Macros Model
struct Macros {
    let protein: Int
    let carbs: Int
    let fats: Int
    let fiber: Int
}

// MARK: - Wellness Snapshot Calculator
class WellnessSnapshotCalculator {
    
    static func calculateSnapshot(from data: OnboardingData) -> WellnessSnapshot {
        // BMI
        let bmi = data.calculateBMI() ?? 22.0
        let bmiCategory = getBMICategory(bmi: bmi)

        // Weight/Height
        let weightKg = getWeightInKg(from: data)
        let heightCm = getHeightInCm(from: data)

        // BMR & TDEE
        let bmr = calculateBMR(
            weightKg: weightKg,
            heightCm: heightCm,
            age: Int(data.age) ?? 25,
            gender: data.gender
        )
        let tdee = calculateTDEE(bmr: bmr, activityLevel: data.activityLevel)

        // Goal-adjusted calories
        let targetCalories = adjustCaloriesForGoal(
            tdee: tdee,
            goals: data.primaryGoals,
            weightKg: weightKg,
            activityLevel: data.activityLevel
        )

        // Macros
        let macros = calculateMacros(
            calories: targetCalories,
            weightKg: weightKg,
            goals: data.primaryGoals
        )

        // Metabolism (shortened)
        let metabolism = getMetabolismText(bmi: bmi)

        // Persona (logic unchanged)
        let persona = assignPersona(from: data, bmi: bmi, bmiCategory: bmiCategory)

        return WellnessSnapshot(
            persona: persona,
            BMI: bmi,
            bodyType: bmiCategory,
            metabolism: metabolism,
            recommendedCalories: targetCalories,
            recommendedMacros: macros
        )
    }

    // MARK: - Persona Assignment
    static func assignPersona(from data: OnboardingData, bmi: Double, bmiCategory: String) -> PersonaProfile {

        let goals = data.primaryGoals
        let eatingHabits = data.eatingHabits
        let activityLevel = data.activityLevel
        let dietaryRestrictions = data.dietaryRestrictions
        let dietaryPreferences = data.dietaryPreferences

        // PERSONA 1 — Under-eater + Weight Gainer
        if (bmi < 18.5 || eatingHabits.contains("not_enough") || eatingHabits.contains("skip_meals"))
            && goals.contains("gain_weight") {

            return PersonaProfile(
                personaName: "The Under-eater + Weight Gainer",
                personaDescription: "We'll help you build strength with steady, simple meals.",
                challenges: ["Inconsistent meals", "Low appetite", "Busy schedule"],
                suggestedPattern: "3 meals + 1–2 snacks/day, calorie-dense but simple.",
                petChallenge: "Log 2 meals/day for 5 days.",
                personaType: 1
            )
        }

        // PERSONA 2 — Lean but Stressed Student
        if bmiCategory == "Normal"
            && eatingHabits.contains("stress_eat")
            && goals.contains("boost_energy") {

            return PersonaProfile(
                personaName: "The Lean but Stressed Student",
                personaDescription: "We'll help calm your routine and steady your energy.",
                challenges: ["Stress-driven appetite", "Energy swings"],
                suggestedPattern: "Structured meals + mindful snacking.",
                petChallenge: "Log 1 snack mindfully for 3 days.",
                personaType: 2
            )
        }

        // PERSONA 3 — Breakfast Skipper
        if eatingHabits.contains("skip_meals")
            && (bmiCategory == "Normal" || bmiCategory == "Underweight") {

            return PersonaProfile(
                personaName: "The Breakfast Skipper",
                personaDescription: "A morning meal will help stabilize your day.",
                challenges: ["Low morning appetite", "Night cravings"],
                suggestedPattern: "Add a morning snack or small meal.",
                petChallenge: "Log anything before noon 3× this week.",
                personaType: 3
            )
        }

        // PERSONA 4 — Weight-Loss Starter
        if goals.contains("lose_weight") && bmi >= 25 {

            return PersonaProfile(
                personaName: "The Weight-Loss Starter",
                personaDescription: "Small, steady changes will support healthy weight loss.",
                challenges: ["High-calorie meals", "Portions", "Low energy"],
                suggestedPattern: "Mild calorie deficit + higher protein foods.",
                petChallenge: "Hit your protein goal 3 days in a row.",
                personaType: 4
            )
        }

        // PERSONA 5 — Stress Snacker / Crammer
        if (eatingHabits.contains("late_night")
            || eatingHabits.contains("crave_snacks")
            || eatingHabits.contains("stress_eat"))
            && (goals.contains("improve_habits") || goals.contains("boost_energy")) {

            return PersonaProfile(
                personaName: "The Stress Snacker",
                personaDescription: "We'll help you balance stress-driven snacking.",
                challenges: ["Study snacking", "Cravings"],
                suggestedPattern: "3 meals + planned snack windows.",
                petChallenge: "Try avoiding late snacks 4 nights in a row.",
                personaType: 5
            )
        }

        // PERSONA 6 — Athletic Student
        if (activityLevel == "active" || activityLevel == "very_active")
            && (goals.contains("gain_weight") || goals.contains("boost_energy")) {

            return PersonaProfile(
                personaName: "The Athletic Student",
                personaDescription: "Fueling enough will boost strength and performance.",
                challenges: ["Underfueling", "Post-workout hunger"],
                suggestedPattern: "Higher carbs + protein-timed meals.",
                petChallenge: "Log a post-workout meal 3× this week.",
                personaType: 6
            )
        }

        // PERSONA 7 — Dorm Cook Beginner
        if goals.contains("improve_habits")
            && (eatingHabits.isEmpty || eatingHabits.contains("none"))
            && dietaryRestrictions.count <= 1 {

            return PersonaProfile(
                personaName: "The Dorm Cook Beginner",
                personaDescription: "We'll help you build habits with simple meals.",
                challenges: ["Limited setup", "Low meal confidence"],
                suggestedPattern: "10-minute or microwave-friendly recipes.",
                petChallenge: "Try 1 new easy recipe this week.",
                personaType: 7
            )
        }

        // PERSONA 8 — Food-Restricted Student
        if dietaryRestrictions.count > 0 {

            return PersonaProfile(
                personaName: "The Food-Restricted Student",
                personaDescription: "You can eat well while honoring your restrictions.",
                challenges: ["Limited options", "Dining out"],
                suggestedPattern: "Substitution-friendly, restriction-safe meals.",
                petChallenge: "Log 3 meals that match your restrictions.",
                personaType: 8
            )
        }

        // PERSONA 9 — Always-On-The-Go Student
        if eatingHabits.contains("skip_meals")
            && (activityLevel == "some_movement" || activityLevel == "active")
            && goals.contains("improve_habits") {

            return PersonaProfile(
                personaName: "The Always-On-The-Go Student",
                personaDescription: "We'll help you stay fueled with portable options.",
                challenges: ["Rushed days", "Forgotten meals"],
                suggestedPattern: "Grab-and-go breakfasts, portable snacks.",
                petChallenge: "Log lunch 5× this week.",
                personaType: 9
            )
        }

        // PERSONA 10 — Overeater
        if (eatingHabits.contains("stress_eat") || eatingHabits.contains("late_night"))
            && (bmiCategory == "Normal" || bmiCategory == "Overweight" || bmiCategory == "Obese")
            && (goals.contains("improve_habits") || goals.contains("lose_weight")) {

            return PersonaProfile(
                personaName: "The Overeater",
                personaDescription: "Balanced portions and timing will steady energy.",
                challenges: ["Portion size", "Late hunger"],
                suggestedPattern: "3 structured meals + early dinners.",
                petChallenge: "Log all meals before 9pm for 4 days.",
                personaType: 10
            )
        }

        // PERSONA 11 — Recipe Explorer
        if (dietaryPreferences.contains("flexible") || dietaryPreferences.contains("no_restrictions"))
            && goals.contains("improve_habits")
            && (eatingHabits.isEmpty || eatingHabits.contains("none")) {

            return PersonaProfile(
                personaName: "The Recipe Explorer",
                personaDescription: "We'll help you explore healthy, fun meals.",
                challenges: ["Random eating", "Staying consistent"],
                suggestedPattern: "Weekly recipe pack, new dish exploration.",
                petChallenge: "Try 2 new meals this week.",
                personaType: 11
            )
        }

        // PERSONA 12 — Minimal Effort Logger
        if (goals.contains("improve_habits") || goals.contains("boost_energy"))
            && (eatingHabits.isEmpty || eatingHabits.contains("none"))
            && (activityLevel == "mostly_sitting" || activityLevel == "some_movement") {

            return PersonaProfile(
                personaName: "The Minimal Effort Logger",
                personaDescription: "We'll help you stay consistent with low-effort habits.",
                challenges: ["Motivation dips", "Irregular routine"],
                suggestedPattern: "Light structure + easy meals.",
                petChallenge: "Check in once a day for 5 days.",
                personaType: 12
            )
        }

        // PERSONA 13 — Default
        return PersonaProfile(
            personaName: "The Balanced Starter",
            personaDescription: "You're off to a strong start — consistent habits will help you thrive.",
            challenges: ["Staying consistent", "Busy lifestyle"],
            suggestedPattern: "3 balanced meals/day + 1 flexible snack.",
            petChallenge: "Log 2 meals/day for 4 days.",
            personaType: 13
        )
    }

    // MARK: - Metabolism (shorter)
    private static func getMetabolismText(bmi: Double) -> String {
        if bmi < 18.5 {
            return "Fast — you burn quickly and need steady fuel."
        } else if bmi >= 25 {
            return "Slower — steady meals and protein help."
        } else {
            return "Balanced — structure keeps energy steady."
        }
    }

    // MARK: - BMI Category
    private static func getBMICategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    // MARK: - Weight/Height Conversion
    private static func getWeightInKg(from data: OnboardingData) -> Double {
        if data.weightUnit == .lbs {
            return (Double(data.weightLbs) ?? 154.0) * 0.453592
        } else {
            return Double(data.weightKg) ?? 70.0
        }
    }

    private static func getHeightInCm(from data: OnboardingData) -> Double {
        if data.heightUnit == .feet {
            let feet = Double(data.heightFeet) ?? 5.0
            let inches = Double(data.heightInches) ?? 6.0
            return (feet * 12 + inches) * 2.54
        } else {
            return Double(data.heightCm) ?? 170.0
        }
    }

    // MARK: - BMR
    private static func calculateBMR(weightKg: Double, heightCm: Double, age: Int, gender: GenderChoice?) -> Double {
        let base = 10 * weightKg + 6.25 * heightCm - 5 * Double(age)

        switch gender {
        case .man: return base + 5
        case .woman: return base - 161
        case .nonBinary: return (base + 5 + base - 161) / 2
        case .none: return base - 78
        }
    }

    // MARK: - TDEE
    private static func calculateTDEE(bmr: Double, activityLevel: String) -> Double {
        let factor: Double
        switch activityLevel {
        case "mostly_sitting": factor = 1.2
        case "some_movement": factor = 1.35
        case "active": factor = 1.5
        case "very_active": factor = 1.65
        default: factor = 1.2
        }
        return bmr * factor
    }

    // MARK: - Goal Calorie Adjustment
    private static func adjustCaloriesForGoal(tdee: Double, goals: Set<String>, weightKg: Double, activityLevel: String) -> Int {
        if goals.contains("lose_weight") {
            let adj = weightKg < 70 || activityLevel == "mostly_sitting" ? 250.0 : 300.0
            return Int((tdee - adj).rounded())
        }
        if goals.contains("gain_weight") {
            let adj = (activityLevel == "active" || activityLevel == "very_active") ? 300.0 : 250.0
            return Int((tdee + adj).rounded())
        }
        return Int(tdee.rounded()) // maintain / habits / energy
    }

    // MARK: - Macros
    private static func calculateMacros(calories: Int, weightKg: Double, goals: Set<String>) -> Macros {
        let weightLbs = weightKg * 2.20462

        // Protein
        let protein = weightLbs * 0.8
        let proteinCal = protein * 4

        // Fats
        let fatCal = Double(calories) * 0.27
        let fats = fatCal / 9

        // Carbs
        let carbCal = Double(calories) - proteinCal - fatCal
        let carbs = carbCal / 4

        // Fiber (14g per 1000 kcal)
        let fiber = round(Double(calories) / 1000 * 14)

        return Macros(
            protein: Int(round(protein)),
            carbs: Int(round(carbs)),
            fats: Int(round(fats)),
            fiber: Int(fiber)
        )
    }
}

