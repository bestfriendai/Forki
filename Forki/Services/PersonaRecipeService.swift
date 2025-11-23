//
//  PersonaRecipeService.swift
//  Forki
//
//  Created for persona-based dynamic recipes system
//

import Foundation

// MARK: - Shared Recipe IDs (for recipes that appear in multiple personas)
private let greekYogurtParfaitID = UUID()
private let turkeyWrapID = UUID()
private let turkeyHummusWrapID = UUID()
private let frozenVeggieBowlID = UUID()

// MARK: - Recipe Model
struct PersonaRecipe: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageName: String
    let timeMinutes: Int
    let calories: Int
    let protein: Int
    let ingredients: [String]
    let steps: [String]
    let tags: [RecipeTag]
    
    // Convert to existing Recipe model for compatibility
    func toRecipe() -> Recipe {
        // Map RecipeTag to RecipeCategory (use first tag as primary category)
        let category: RecipeCategory = {
            if tags.contains(.highProtein) { return .highProtein }
            if tags.contains(.quickMeals) { return .quickMeals }
            if tags.contains(.lightMeals) { return .lightMeals }
            if tags.contains(.breakfast) { return .breakfast }
            if tags.contains(.grabAndGo) { return .grabAndGo }
            if tags.contains(.higherCalorie) { return .higherCalorie }
            return .quickMeals // Default fallback
        }()
        
        return Recipe(
            id: id.uuidString,
            title: title,
            imageName: imageName,
            prepTime: "\(timeMinutes) min",
            calories: calories,
            protein: Double(protein),
            fat: Double(protein) * 0.3, // Estimate fat
            carbs: Double(calories - protein * 4 - Int(Double(protein) * 0.3) * 9) / 4, // Estimate carbs
            category: category,
            tags: tags.map { $0.rawValue } + [subtitle],
            description: subtitle,
            ingredients: ingredients,
            instructions: steps
        )
    }
}

// MARK: - Persona Recipe Service
class PersonaRecipeService {
    static let shared = PersonaRecipeService()
    
    private init() {}
    
    // MARK: - Master Recipe Library
    
    private let allPersonaRecipes: [Int: [PersonaRecipe]] = [
        1: [
            PersonaRecipe(
                id: UUID(),
                title: "Peanut Butter Banana Overnight Oats",
                subtitle: "High-calorie breakfast to fuel your day",
                imageName: "Peanut Butter Banana Overnight Oats",
                timeMinutes: 5,
                calories: 450,
                protein: 18,
                ingredients: ["Rolled oats", "Greek yogurt", "Peanut butter", "Banana", "Honey", "Chia seeds"],
                steps: ["Mix oats with yogurt", "Stir in peanut butter", "Slice banana on top", "Drizzle honey", "Refrigerate overnight"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Alfredo Cup",
                subtitle: "Creamy protein-packed meal",
                imageName: "Chicken Alfredo Cup",
                timeMinutes: 12,
                calories: 520,
                protein: 35,
                ingredients: ["Pre-cooked chicken", "Pasta", "Alfredo sauce", "Parmesan cheese", "Broccoli"],
                steps: ["Cook pasta", "Heat chicken", "Warm sauce", "Combine in bowl", "Top with cheese"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Avocado Chicken Wrap",
                subtitle: "Nutrient-dense portable meal",
                imageName: "Avocado Chicken Wrap",
                timeMinutes: 10,
                calories: 480,
                protein: 32,
                ingredients: ["Tortilla", "Grilled chicken", "Avocado", "Lettuce", "Tomato", "Mayo"],
                steps: ["Slice avocado", "Warm tortilla", "Layer chicken", "Add vegetables", "Roll tightly"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Greek Yogurt & Granola Bowl",
                subtitle: "Protein-rich breakfast or snack",
                imageName: "Greek Yogurt & Granola Bowl",
                timeMinutes: 3,
                calories: 380,
                protein: 22,
                ingredients: ["Greek yogurt", "Granola", "Berries", "Honey", "Nuts"],
                steps: ["Scoop yogurt", "Add granola", "Top with berries", "Drizzle honey", "Sprinkle nuts"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Salmon Rice Bowl",
                subtitle: "Omega-3 rich balanced meal",
                imageName: "Salmon Rice Bowl",
                timeMinutes: 15,
                calories: 550,
                protein: 38,
                ingredients: ["Salmon fillet", "Brown rice", "Broccoli", "Soy sauce", "Sesame seeds"],
                steps: ["Cook rice", "Pan-sear salmon", "Steam broccoli", "Arrange in bowl", "Drizzle sauce"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Bagel + Egg + Cheese Sandwich",
                subtitle: "Classic high-calorie breakfast",
                imageName: "Bagel + Egg + Cheese Sandwich",
                timeMinutes: 8,
                calories: 420,
                protein: 20,
                ingredients: ["Bagel", "Eggs", "Cheese", "Butter", "Salt", "Pepper"],
                steps: ["Toast bagel", "Scramble eggs", "Melt cheese", "Assemble sandwich", "Serve warm"],
                tags: [.higherCalorie, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chocolate Banana Protein Shake",
                subtitle: "Quick calorie boost",
                imageName: "Chocolate Banana Protein Shake",
                timeMinutes: 5,
                calories: 400,
                protein: 25,
                ingredients: ["Protein powder", "Banana", "Chocolate milk", "Peanut butter", "Ice"],
                steps: ["Blend banana", "Add protein powder", "Pour milk", "Add peanut butter", "Blend until smooth"],
                tags: [.higherCalorie, .highProtein]
            )
        ],
        2: [
            PersonaRecipe(
                id: turkeyHummusWrapID,
                title: "Turkey Hummus Wrap",
                subtitle: "Lean protein with healthy fats",
                imageName: "Turkey Hummus Wrap",
                timeMinutes: 8,
                calories: 340,
                protein: 28,
                ingredients: ["Whole wheat tortilla", "Turkey slices", "Hummus", "Lettuce", "Tomato"],
                steps: ["Spread hummus", "Layer turkey", "Add vegetables", "Roll tightly", "Cut in half"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Veggie Stir-Fry (5-min)",
                subtitle: "5-minute quick meal",
                imageName: "Veggie Stir-Fry (5-min)",
                timeMinutes: 5,
                calories: 280,
                protein: 12,
                ingredients: ["Mixed vegetables", "Soy sauce", "Garlic", "Ginger", "Olive oil"],
                steps: ["Heat oil", "Add garlic", "Stir-fry vegetables", "Season with soy sauce", "Serve hot"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Avocado Toast + Egg",
                subtitle: "Simple balanced breakfast",
                imageName: "Avocado Toast + Egg",
                timeMinutes: 10,
                calories: 350,
                protein: 15,
                ingredients: ["Whole grain bread", "Avocado", "Egg", "Lemon", "Salt"],
                steps: ["Toast bread", "Mash avocado", "Fry egg", "Assemble", "Season"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Tuna Rice Bowl",
                subtitle: "Quick protein-packed meal",
                imageName: "Tuna Rice Bowl",
                timeMinutes: 10,
                calories: 380,
                protein: 32,
                ingredients: ["Canned tuna", "Rice", "Cucumber", "Soy sauce", "Sesame seeds"],
                steps: ["Cook rice", "Drain tuna", "Slice cucumber", "Arrange in bowl", "Drizzle sauce"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Pita Pocket",
                subtitle: "Portable balanced meal",
                imageName: "Chicken Pita Pocket",
                timeMinutes: 12,
                calories: 360,
                protein: 30,
                ingredients: ["Pita bread", "Grilled chicken", "Lettuce", "Tomato", "Tzatziki"],
                steps: ["Warm pita", "Slice chicken", "Fill with vegetables", "Add sauce", "Fold"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Veggie Egg Scramble",
                subtitle: "Protein-rich breakfast",
                imageName: "Veggie Egg Scramble",
                timeMinutes: 8,
                calories: 260,
                protein: 18,
                ingredients: ["Eggs", "Spinach", "Bell peppers", "Onion", "Cheese"],
                steps: ["Sauté vegetables", "Beat eggs", "Scramble together", "Add cheese", "Serve"],
                tags: [.quickMeals, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Simple Smoothie Bowl",
                subtitle: "Refreshing nutrient boost",
                imageName: "Simple Smoothie Bowl",
                timeMinutes: 5,
                calories: 320,
                protein: 20,
                ingredients: ["Frozen berries", "Banana", "Yogurt", "Granola", "Honey"],
                steps: ["Blend fruits", "Add yogurt", "Pour in bowl", "Top with granola", "Drizzle honey"],
                tags: [.quickMeals, .lightMeals]
            )
        ],
        3: [
            PersonaRecipe(
                id: greekYogurtParfaitID,
                title: "Greek Yogurt Parfait",
                subtitle: "Quick protein breakfast",
                imageName: "Greek Yogurt Parfait",
                timeMinutes: 5,
                calories: 280,
                protein: 20,
                ingredients: ["Greek yogurt", "Berries", "Granola", "Honey"],
                steps: ["Layer yogurt", "Add berries", "Top with granola", "Drizzle honey"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Scrambled Eggs & Spinach",
                subtitle: "Protein-packed morning meal",
                imageName: "Scrambled Eggs & Spinach",
                timeMinutes: 10,
                calories: 260,
                protein: 18,
                ingredients: ["Eggs", "Spinach", "Butter", "Salt", "Pepper"],
                steps: ["Heat pan", "Sauté spinach", "Beat eggs", "Scramble gently", "Season"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Avocado Toast",
                subtitle: "Healthy fats to start your day",
                imageName: "Avocado Toast",
                timeMinutes: 5,
                calories: 320,
                protein: 10,
                ingredients: ["Whole grain bread", "Avocado", "Lemon", "Salt", "Red pepper flakes"],
                steps: ["Toast bread", "Mash avocado", "Spread on toast", "Season", "Serve"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Protein Smoothie",
                subtitle: "On-the-go breakfast",
                imageName: "Protein Smoothie",
                timeMinutes: 5,
                calories: 300,
                protein: 25,
                ingredients: ["Protein powder", "Banana", "Milk", "Spinach", "Ice"],
                steps: ["Blend banana", "Add protein", "Pour milk", "Add spinach", "Blend until smooth"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Overnight Oats",
                subtitle: "Make-ahead breakfast",
                imageName: "Overnight Oats",
                timeMinutes: 5,
                calories: 310,
                protein: 14,
                ingredients: ["Rolled oats", "Greek yogurt", "Milk", "Chia seeds", "Berries"],
                steps: ["Mix ingredients", "Refrigerate overnight", "Top with berries", "Serve cold"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Fruit & Cottage Cheese",
                subtitle: "Light protein breakfast",
                imageName: "Fruit & Cottage Cheese",
                timeMinutes: 3,
                calories: 240,
                protein: 20,
                ingredients: ["Cottage cheese", "Berries", "Peach", "Honey"],
                steps: ["Scoop cottage cheese", "Add fruit", "Drizzle honey", "Serve"],
                tags: [.breakfast, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "PB Toast + Banana",
                subtitle: "Quick energy boost",
                imageName: "PB Toast + Banana",
                timeMinutes: 5,
                calories: 350,
                protein: 12,
                ingredients: ["Whole grain bread", "Peanut butter", "Banana", "Honey"],
                steps: ["Toast bread", "Spread peanut butter", "Slice banana", "Drizzle honey", "Serve"],
                tags: [.breakfast, .quickMeals]
            )
        ],
        4: [
            PersonaRecipe(
                id: UUID(),
                title: "Chicken & Sweet Potato",
                subtitle: "Balanced weight-loss meal",
                imageName: "Chicken & Sweet Potato",
                timeMinutes: 40,
                calories: 380,
                protein: 35,
                ingredients: ["Chicken breast", "Sweet potato", "Olive oil", "Herbs", "Salt"],
                steps: ["Preheat oven", "Season chicken", "Cut sweet potato", "Roast together", "Serve"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Mediterranean Tuna Salad",
                subtitle: "Light protein-packed meal",
                imageName: "Mediterranean Tuna Salad",
                timeMinutes: 12,
                calories: 310,
                protein: 28,
                ingredients: ["Tuna", "Tomatoes", "Cucumber", "Olives", "Feta cheese"],
                steps: ["Drain tuna", "Chop vegetables", "Mix ingredients", "Add dressing", "Serve"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Veggie Egg White Scramble",
                subtitle: "Low-calorie high-protein",
                imageName: "Veggie Egg White Scramble",
                timeMinutes: 10,
                calories: 180,
                protein: 20,
                ingredients: ["Egg whites", "Spinach", "Mushrooms", "Bell peppers", "Onion"],
                steps: ["Sauté vegetables", "Add egg whites", "Scramble", "Season", "Serve"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Zucchini Noodle Bowl",
                subtitle: "Low-carb vegetable meal",
                imageName: "Zucchini Noodle Bowl",
                timeMinutes: 15,
                calories: 220,
                protein: 15,
                ingredients: ["Zucchini", "Tomato sauce", "Turkey", "Parmesan", "Basil"],
                steps: ["Spiralize zucchini", "Sauté turkey", "Add sauce", "Toss noodles", "Top with cheese"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Cauliflower Rice Stir-Fry",
                subtitle: "Low-calorie vegetable base",
                imageName: "Cauliflower Rice Stir-Fry",
                timeMinutes: 12,
                calories: 200,
                protein: 18,
                ingredients: ["Cauliflower rice", "Chicken", "Vegetables", "Soy sauce", "Ginger"],
                steps: ["Heat pan", "Cook chicken", "Add cauliflower rice", "Stir-fry vegetables", "Season"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Shrimp Lettuce Cups",
                subtitle: "Light protein meal",
                imageName: "Shrimp Lettuce Cups",
                timeMinutes: 15,
                calories: 250,
                protein: 28,
                ingredients: ["Shrimp", "Lettuce leaves", "Carrots", "Cucumber", "Soy sauce"],
                steps: ["Cook shrimp", "Prepare lettuce", "Slice vegetables", "Fill cups", "Drizzle sauce"],
                tags: [.lightMeals, .highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Grilled Chicken Wrap",
                subtitle: "Lean protein portable meal",
                imageName: "Grilled Chicken Wrap",
                timeMinutes: 12,
                calories: 320,
                protein: 30,
                ingredients: ["Tortilla", "Grilled chicken", "Lettuce", "Tomato", "Light dressing"],
                steps: ["Grill chicken", "Warm tortilla", "Layer ingredients", "Roll tightly", "Serve"],
                tags: [.lightMeals, .highProtein]
            )
        ],
        5: [
            PersonaRecipe(
                id: UUID(),
                title: "Buddha Bowl",
                subtitle: "Balanced stress-busting meal",
                imageName: "Buddha Bowl",
                timeMinutes: 25,
                calories: 410,
                protein: 16,
                ingredients: ["Quinoa", "Chickpeas", "Sweet potato", "Kale", "Tahini"],
                steps: ["Cook quinoa", "Roast vegetables", "Prepare tahini sauce", "Assemble bowl", "Drizzle sauce"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: turkeyWrapID,
                title: "Turkey Wrap",
                subtitle: "Portable protein snack",
                imageName: "Turkey Wrap",
                timeMinutes: 8,
                calories: 340,
                protein: 28,
                ingredients: ["Whole wheat tortilla", "Turkey slices", "Lettuce", "Tomato", "Mayo"],
                steps: ["Warm tortilla", "Layer turkey", "Add vegetables", "Roll tightly", "Cut"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Protein Snack Box",
                subtitle: "Portable balanced snack",
                imageName: "Protein Snack Box",
                timeMinutes: 5,
                calories: 280,
                protein: 20,
                ingredients: ["Hard-boiled eggs", "Cheese", "Nuts", "Apple", "Crackers"],
                steps: ["Slice eggs", "Cut cheese", "Arrange in container", "Add nuts", "Pack apple"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Apple PB Pack",
                subtitle: "Satisfying protein snack",
                imageName: "Apple PB Pack",
                timeMinutes: 3,
                calories: 240,
                protein: 8,
                ingredients: ["Apple", "Peanut butter", "Almonds"],
                steps: ["Slice apple", "Scoop peanut butter", "Arrange almonds", "Serve"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken & Rice Bento",
                subtitle: "Portable balanced meal",
                imageName: "Chicken & Rice Bento",
                timeMinutes: 15,
                calories: 420,
                protein: 32,
                ingredients: ["Chicken", "Rice", "Broccoli", "Carrots", "Soy sauce"],
                steps: ["Cook rice", "Prepare chicken", "Steam vegetables", "Arrange in box", "Pack"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Veggie Quesadilla",
                subtitle: "Light cheesy snack",
                imageName: "Veggie Quesadilla (Light)",
                timeMinutes: 10,
                calories: 320,
                protein: 15,
                ingredients: ["Tortilla", "Cheese", "Bell peppers", "Onion", "Salsa"],
                steps: ["Fill tortilla", "Add vegetables", "Top with cheese", "Cook in pan", "Serve"],
                tags: [.grabAndGo, .lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Cottage Cheese & Fruit",
                subtitle: "Light protein snack",
                imageName: "Cottage Cheese & Fruit",
                timeMinutes: 3,
                calories: 240,
                protein: 20,
                ingredients: ["Cottage cheese", "Berries", "Peach", "Honey"],
                steps: ["Scoop cottage cheese", "Add fruit", "Drizzle honey", "Serve"],
                tags: [.grabAndGo, .lightMeals]
            )
        ],
        6: [
            PersonaRecipe(
                id: UUID(),
                title: "Salmon + Broccoli + Rice",
                subtitle: "High-protein athletic meal",
                imageName: "Salmon + Broccoli + Rice",
                timeMinutes: 20,
                calories: 520,
                protein: 45,
                ingredients: ["Salmon fillet", "Broccoli", "Brown rice", "Garlic", "Olive oil"],
                steps: ["Cook rice", "Pan-sear salmon", "Steam broccoli", "Arrange plate", "Serve"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Turkey Pasta Marinara",
                subtitle: "Protein-packed recovery meal",
                imageName: "Turkey Pasta Marinara",
                timeMinutes: 25,
                calories: 480,
                protein: 32,
                ingredients: ["Ground turkey", "Whole wheat pasta", "Marinara sauce", "Onion", "Garlic"],
                steps: ["Cook pasta", "Brown turkey", "Add sauce", "Simmer", "Serve over pasta"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Protein-packed Smoothie",
                subtitle: "Post-workout recovery drink",
                imageName: "Protein-packed Smoothie",
                timeMinutes: 5,
                calories: 380,
                protein: 35,
                ingredients: ["Protein powder", "Banana", "Greek yogurt", "Milk", "Berries"],
                steps: ["Blend banana", "Add protein", "Add yogurt", "Pour milk", "Blend until smooth"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Steak & Veg Meal Prep Bowl",
                subtitle: "High-protein meal prep",
                imageName: "Steak & Veg Meal Prep Bowl",
                timeMinutes: 30,
                calories: 550,
                protein: 42,
                ingredients: ["Steak", "Sweet potato", "Broccoli", "Quinoa", "Olive oil"],
                steps: ["Cook steak", "Roast vegetables", "Cook quinoa", "Arrange in bowl", "Meal prep"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Burrito Bowl",
                subtitle: "Balanced high-protein meal",
                imageName: "Chicken Burrito Bowl",
                timeMinutes: 20,
                calories: 480,
                protein: 38,
                ingredients: ["Chicken", "Rice", "Black beans", "Corn", "Salsa", "Avocado"],
                steps: ["Cook chicken", "Prepare rice", "Heat beans", "Arrange in bowl", "Top with salsa"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Egg & Potato Scramble",
                subtitle: "Protein and carbs for energy",
                imageName: "Egg & Potato Scramble",
                timeMinutes: 15,
                calories: 420,
                protein: 22,
                ingredients: ["Eggs", "Potatoes", "Bell peppers", "Onion", "Cheese"],
                steps: ["Cook potatoes", "Sauté vegetables", "Add eggs", "Scramble", "Top with cheese"],
                tags: [.highProtein, .higherCalorie]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Tuna High-Protein Wrap",
                subtitle: "Portable protein boost",
                imageName: "Tuna High-Protein Wrap",
                timeMinutes: 10,
                calories: 380,
                protein: 35,
                ingredients: ["Tortilla", "Canned tuna", "Greek yogurt", "Lettuce", "Tomato"],
                steps: ["Mix tuna with yogurt", "Warm tortilla", "Layer ingredients", "Roll tightly", "Serve"],
                tags: [.highProtein, .higherCalorie]
            )
        ],
        7: [
            PersonaRecipe(
                id: UUID(),
                title: "Microwave Scrambled Eggs",
                subtitle: "Dorm-friendly protein breakfast",
                imageName: "Microwave Scrambled Eggs",
                timeMinutes: 3,
                calories: 240,
                protein: 18,
                ingredients: ["Eggs", "Butter", "Salt", "Pepper", "Cheese"],
                steps: ["Beat eggs", "Microwave 1 min", "Stir", "Microwave 30 sec", "Add cheese"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Microwave Rice + Chicken Cup",
                subtitle: "One-cup dorm meal",
                imageName: "Microwave Rice + Chicken Cup",
                timeMinutes: 5,
                calories: 420,
                protein: 32,
                ingredients: ["Microwave rice", "Pre-cooked chicken", "Soy sauce", "Frozen vegetables"],
                steps: ["Heat rice", "Add chicken", "Microwave vegetables", "Combine", "Season"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: frozenVeggieBowlID,
                title: "Frozen Veggie Bowl",
                subtitle: "Microwave-friendly vegetables",
                imageName: "Frozen Veggie Bowl",
                timeMinutes: 4,
                calories: 180,
                protein: 8,
                ingredients: ["Frozen vegetables", "Butter", "Salt", "Pepper"],
                steps: ["Microwave vegetables", "Add butter", "Season", "Serve"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Instant Ramen (Healthy Mod)",
                subtitle: "Upgraded dorm classic",
                imageName: "Instant Ramen (Healthy Mod)",
                timeMinutes: 5,
                calories: 380,
                protein: 18,
                ingredients: ["Instant ramen", "Egg", "Frozen vegetables", "Soy sauce"],
                steps: ["Cook ramen", "Add vegetables", "Poach egg", "Season", "Serve"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Microwave Pasta Cup",
                subtitle: "Quick dorm pasta",
                imageName: "Microwave Pasta Cup",
                timeMinutes: 6,
                calories: 350,
                protein: 12,
                ingredients: ["Pasta", "Pasta sauce", "Cheese", "Water"],
                steps: ["Add pasta and water", "Microwave 4 min", "Stir", "Add sauce", "Top with cheese"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Basic Overnight Oats",
                subtitle: "No-cook breakfast",
                imageName: "Basic Overnight Oats",
                timeMinutes: 5,
                calories: 310,
                protein: 14,
                ingredients: ["Rolled oats", "Milk", "Honey", "Banana"],
                steps: ["Mix oats with milk", "Add honey", "Slice banana", "Refrigerate overnight"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Frozen Turkey Burger Bowl",
                subtitle: "Microwave protein meal",
                imageName: "Frozen Turkey Burger Bowl",
                timeMinutes: 8,
                calories: 380,
                protein: 30,
                ingredients: ["Frozen turkey burger", "Rice", "Lettuce", "Tomato", "Mayo"],
                steps: ["Microwave burger", "Heat rice", "Prepare vegetables", "Assemble bowl", "Serve"],
                tags: [.quickMeals]
            )
        ],
        8: [
            PersonaRecipe(
                id: UUID(),
                title: "Vegan Stir-Fry",
                subtitle: "Plant-based protein meal",
                imageName: "Vegan Stir-Fry",
                timeMinutes: 15,
                calories: 320,
                protein: 18,
                ingredients: ["Tofu", "Mixed vegetables", "Soy sauce", "Ginger", "Garlic"],
                steps: ["Press tofu", "Cut vegetables", "Stir-fry tofu", "Add vegetables", "Season"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Quinoa Chickpea Bowl",
                subtitle: "Complete plant protein",
                imageName: "Quinoa Chickpea Bowl",
                timeMinutes: 20,
                calories: 380,
                protein: 16,
                ingredients: ["Quinoa", "Chickpeas", "Sweet potato", "Kale", "Tahini"],
                steps: ["Cook quinoa", "Roast vegetables", "Prepare tahini sauce", "Assemble bowl", "Drizzle"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Dairy-Free Smoothie",
                subtitle: "Plant-based protein drink",
                imageName: "Dairy-Free Smoothie",
                timeMinutes: 5,
                calories: 300,
                protein: 20,
                ingredients: ["Plant protein powder", "Banana", "Almond milk", "Berries", "Spinach"],
                steps: ["Blend banana", "Add protein", "Pour milk", "Add berries", "Blend until smooth"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Gluten-free Turkey Bowl",
                subtitle: "GF protein meal",
                imageName: "Gluten-free Turkey Bowl",
                timeMinutes: 15,
                calories: 360,
                protein: 30,
                ingredients: ["Turkey", "Quinoa", "Vegetables", "Olive oil", "Herbs"],
                steps: ["Cook turkey", "Prepare quinoa", "Steam vegetables", "Arrange in bowl", "Season"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Lentil Soup Cup",
                subtitle: "Plant protein soup",
                imageName: "Lentil Soup Cup",
                timeMinutes: 10,
                calories: 280,
                protein: 18,
                ingredients: ["Canned lentil soup", "Vegetables", "Herbs", "Bread"],
                steps: ["Heat soup", "Add vegetables", "Season", "Serve with bread"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Spinach Berry Salad",
                subtitle: "Fresh plant-based meal",
                imageName: "Spinach Berry Salad",
                timeMinutes: 12,
                calories: 295,
                protein: 12,
                ingredients: ["Spinach", "Mixed berries", "Nuts", "Balsamic", "Olive oil"],
                steps: ["Wash spinach", "Prepare berries", "Make dressing", "Toss salad", "Serve"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Oatmeal + Fruit",
                subtitle: "Simple GF breakfast",
                imageName: "Oatmeal + Fruit",
                timeMinutes: 8,
                calories: 320,
                protein: 10,
                ingredients: ["Oats", "Almond milk", "Berries", "Banana", "Nuts"],
                steps: ["Cook oats", "Add milk", "Top with fruit", "Sprinkle nuts", "Serve"],
                tags: [.lightMeals]
            )
        ],
        9: [
            PersonaRecipe(
                id: turkeyWrapID,
                title: "Turkey Wrap",
                subtitle: "Grab-and-go protein",
                imageName: "Turkey Wrap",
                timeMinutes: 5,
                calories: 340,
                protein: 28,
                ingredients: ["Tortilla", "Turkey slices", "Lettuce", "Tomato", "Mayo"],
                steps: ["Warm tortilla", "Layer turkey", "Add vegetables", "Roll", "Pack"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Tuna Snack Pack",
                subtitle: "Portable protein",
                imageName: "Tuna Snack Pack",
                timeMinutes: 3,
                calories: 280,
                protein: 24,
                ingredients: ["Canned tuna", "Crackers", "Mayo", "Celery"],
                steps: ["Mix tuna", "Pack crackers", "Add celery", "Assemble", "Ready to go"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Protein Snack Box",
                subtitle: "Portable balanced snack",
                imageName: "Protein Snack Box",
                timeMinutes: 5,
                calories: 280,
                protein: 20,
                ingredients: ["Hard-boiled eggs", "Cheese", "Nuts", "Apple", "Crackers"],
                steps: ["Slice eggs", "Cut cheese", "Arrange in container", "Add nuts", "Pack"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Caesar Wrap",
                subtitle: "Classic portable meal",
                imageName: "Chicken Caesar Wrap",
                timeMinutes: 8,
                calories: 380,
                protein: 32,
                ingredients: ["Tortilla", "Grilled chicken", "Romaine", "Caesar dressing", "Parmesan"],
                steps: ["Grill chicken", "Warm tortilla", "Layer ingredients", "Roll", "Pack"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Grab & Go Parfait",
                subtitle: "Portable breakfast",
                imageName: "Grab & Go Parfait",
                timeMinutes: 3,
                calories: 280,
                protein: 20,
                ingredients: ["Greek yogurt", "Granola", "Berries", "Honey"],
                steps: ["Layer in container", "Add granola", "Top with berries", "Drizzle honey", "Pack"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Bento Box",
                subtitle: "Portable balanced meal",
                imageName: "Bento Box",
                timeMinutes: 10,
                calories: 420,
                protein: 32,
                ingredients: ["Chicken", "Rice", "Vegetables", "Fruit", "Nuts"],
                steps: ["Prepare chicken", "Cook rice", "Pack vegetables", "Add fruit", "Assemble"],
                tags: [.grabAndGo, .quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "PB+J with Protein Shake",
                subtitle: "Quick energy combo",
                imageName: "PB+J with Protein Shake",
                timeMinutes: 5,
                calories: 480,
                protein: 28,
                ingredients: ["Bread", "Peanut butter", "Jelly", "Protein powder", "Milk"],
                steps: ["Make sandwich", "Blend protein shake", "Pack both", "Ready to go"],
                tags: [.grabAndGo, .quickMeals]
            )
        ],
        10: [
            PersonaRecipe(
                id: UUID(),
                title: "Baked Chicken + Veg",
                subtitle: "Balanced portion control",
                imageName: "Baked Chicken + Veg",
                timeMinutes: 35,
                calories: 380,
                protein: 35,
                ingredients: ["Chicken breast", "Broccoli", "Carrots", "Olive oil", "Herbs"],
                steps: ["Preheat oven", "Season chicken", "Prepare vegetables", "Roast together", "Serve"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Light Tuna Salad",
                subtitle: "Low-calorie protein meal",
                imageName: "Light Tuna Salad",
                timeMinutes: 10,
                calories: 280,
                protein: 26,
                ingredients: ["Tuna", "Lettuce", "Tomato", "Cucumber", "Light dressing"],
                steps: ["Drain tuna", "Prepare vegetables", "Mix ingredients", "Add dressing", "Serve"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Morning Smoothie",
                subtitle: "Early nutrition boost",
                imageName: "Morning Smoothie",
                timeMinutes: 5,
                calories: 300,
                protein: 20,
                ingredients: ["Protein powder", "Banana", "Spinach", "Milk", "Berries"],
                steps: ["Blend banana", "Add protein", "Add spinach", "Pour milk", "Blend"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Early Dinner Bowl",
                subtitle: "Timed balanced meal",
                imageName: "Early Dinner Bowl",
                timeMinutes: 15,
                calories: 400,
                protein: 32,
                ingredients: ["Chicken", "Quinoa", "Vegetables", "Olive oil", "Herbs"],
                steps: ["Cook chicken", "Prepare quinoa", "Steam vegetables", "Arrange in bowl", "Serve"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Balanced Stir-Fry",
                subtitle: "Portion-controlled meal",
                imageName: "Balanced Stir-Fry",
                timeMinutes: 12,
                calories: 320,
                protein: 25,
                ingredients: ["Chicken", "Mixed vegetables", "Soy sauce", "Ginger", "Brown rice"],
                steps: ["Cook chicken", "Stir-fry vegetables", "Add sauce", "Serve over rice"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Low-Cal Wrap",
                subtitle: "Light portable meal",
                imageName: "Low-Cal Wrap",
                timeMinutes: 10,
                calories: 300,
                protein: 28,
                ingredients: ["Tortilla", "Turkey", "Lettuce", "Tomato", "Light mayo"],
                steps: ["Warm tortilla", "Layer turkey", "Add vegetables", "Roll", "Serve"],
                tags: [.lightMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Greek Yogurt + Blueberries",
                subtitle: "Light evening snack",
                imageName: "Greek Yogurt + Blueberries",
                timeMinutes: 3,
                calories: 200,
                protein: 18,
                ingredients: ["Greek yogurt", "Blueberries", "Honey"],
                steps: ["Scoop yogurt", "Add blueberries", "Drizzle honey", "Serve"],
                tags: [.lightMeals]
            )
        ],
        11: [
            PersonaRecipe(
                id: UUID(),
                title: "Shrimp Tacos",
                subtitle: "Flavorful protein meal",
                imageName: "Shrimp Tacos",
                timeMinutes: 20,
                calories: 420,
                protein: 32,
                ingredients: ["Shrimp", "Corn tortillas", "Cabbage", "Lime", "Cilantro", "Salsa"],
                steps: ["Cook shrimp", "Warm tortillas", "Prepare vegetables", "Assemble tacos", "Garnish"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Buddha Bowl (Customizable)",
                subtitle: "Build-your-own balanced meal",
                imageName: "Buddha Bowl (Customizable)",
                timeMinutes: 25,
                calories: 410,
                protein: 16,
                ingredients: ["Quinoa", "Chickpeas", "Sweet potato", "Kale", "Tahini", "Custom toppings"],
                steps: ["Cook base", "Roast vegetables", "Prepare sauce", "Assemble bowl", "Customize"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Gyro Wrap",
                subtitle: "Mediterranean flavors",
                imageName: "Chicken Gyro Wrap",
                timeMinutes: 18,
                calories: 440,
                protein: 34,
                ingredients: ["Chicken", "Pita", "Tzatziki", "Tomato", "Onion", "Lettuce"],
                steps: ["Cook chicken", "Warm pita", "Prepare vegetables", "Assemble wrap", "Serve"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Pesto Pasta Bowl",
                subtitle: "Herb-rich pasta meal",
                imageName: "Pesto Pasta Bowl",
                timeMinutes: 15,
                calories: 480,
                protein: 18,
                ingredients: ["Pasta", "Pesto", "Chicken", "Parmesan", "Pine nuts"],
                steps: ["Cook pasta", "Heat pesto", "Add chicken", "Toss together", "Top with cheese"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Protein Smoothie Bowl",
                subtitle: "Customizable breakfast bowl",
                imageName: "Protein Smoothie Bowl",
                timeMinutes: 8,
                calories: 320,
                protein: 22,
                ingredients: ["Protein powder", "Banana", "Berries", "Granola", "Custom toppings"],
                steps: ["Blend smoothie", "Pour in bowl", "Add toppings", "Customize", "Serve"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Loaded Veggie Quesadilla",
                subtitle: "Customizable cheesy meal",
                imageName: "Loaded Veggie Quesadilla",
                timeMinutes: 12,
                calories: 380,
                protein: 18,
                ingredients: ["Tortilla", "Cheese", "Bell peppers", "Onion", "Mushrooms", "Salsa"],
                steps: ["Sauté vegetables", "Fill tortilla", "Add cheese", "Cook in pan", "Serve"],
                tags: [.highProtein]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chipotle-style Bowl",
                subtitle: "Build-your-own bowl",
                imageName: "Chipotle-style Bowl",
                timeMinutes: 20,
                calories: 480,
                protein: 38,
                ingredients: ["Rice", "Chicken", "Black beans", "Corn", "Salsa", "Custom toppings"],
                steps: ["Prepare base", "Cook protein", "Heat beans", "Arrange in bowl", "Customize"],
                tags: [.highProtein]
            )
        ],
        12: [
            PersonaRecipe(
                id: UUID(),
                title: "Yogurt Parfait",
                subtitle: "3-ingredient breakfast",
                imageName: "Yogurt Parfait",
                timeMinutes: 3,
                calories: 280,
                protein: 20,
                ingredients: ["Greek yogurt", "Granola", "Berries"],
                steps: ["Layer yogurt", "Add granola", "Top with berries"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Rice Cup",
                subtitle: "Microwave-ready meal",
                imageName: "Chicken Rice Cup",
                timeMinutes: 5,
                calories: 420,
                protein: 32,
                ingredients: ["Microwave rice", "Pre-cooked chicken", "Soy sauce"],
                steps: ["Heat rice", "Add chicken", "Season"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Avocado Toast",
                subtitle: "Simple 3-ingredient meal",
                imageName: "Avocado Toast",
                timeMinutes: 5,
                calories: 320,
                protein: 10,
                ingredients: ["Bread", "Avocado", "Salt"],
                steps: ["Toast bread", "Mash avocado", "Season"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "3-Ingredient Pasta",
                subtitle: "Minimal effort meal",
                imageName: "3-Ingredient Pasta",
                timeMinutes: 8,
                calories: 350,
                protein: 12,
                ingredients: ["Pasta", "Pasta sauce", "Cheese"],
                steps: ["Cook pasta", "Add sauce", "Top with cheese"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Tuna Crackers",
                subtitle: "2-ingredient snack",
                imageName: "Tuna Crackers",
                timeMinutes: 2,
                calories: 240,
                protein: 20,
                ingredients: ["Canned tuna", "Crackers"],
                steps: ["Open tuna", "Serve with crackers"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: frozenVeggieBowlID,
                title: "Frozen Veggie Bowl",
                subtitle: "Microwave vegetables",
                imageName: "Frozen Veggie Bowl",
                timeMinutes: 4,
                calories: 180,
                protein: 8,
                ingredients: ["Frozen vegetables", "Butter"],
                steps: ["Microwave vegetables", "Add butter"],
                tags: [.quickMeals]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Microwave Egg Scramble",
                subtitle: "Quick protein breakfast",
                imageName: "Microwave Egg Scramble",
                timeMinutes: 3,
                calories: 240,
                protein: 18,
                ingredients: ["Eggs", "Butter", "Salt"],
                steps: ["Beat eggs", "Microwave 1 min", "Stir and serve"],
                tags: [.quickMeals]
            )
        ],
        13: [
            PersonaRecipe(
                id: UUID(),
                title: "Chicken + Quinoa",
                subtitle: "Balanced protein meal",
                imageName: "Chicken + Quinoa",
                timeMinutes: 25,
                calories: 425,
                protein: 42,
                ingredients: ["Chicken breast", "Quinoa", "Olive oil", "Lemon", "Herbs"],
                steps: ["Season chicken", "Grill for 6-7 min per side", "Cook quinoa", "Serve together"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Veggie Stir-Fry",
                subtitle: "Quick balanced meal",
                imageName: "Veggie Stir-Fry",
                timeMinutes: 12,
                calories: 320,
                protein: 18,
                ingredients: ["Mixed vegetables", "Tofu", "Soy sauce", "Ginger", "Garlic"],
                steps: ["Heat oil", "Stir-fry vegetables", "Add tofu", "Season", "Serve"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: greekYogurtParfaitID,
                title: "Greek Yogurt Parfait",
                subtitle: "Balanced breakfast",
                imageName: "Greek Yogurt Parfait",
                timeMinutes: 5,
                calories: 280,
                protein: 20,
                ingredients: ["Greek yogurt", "Berries", "Granola", "Honey"],
                steps: ["Layer yogurt", "Add berries", "Top with granola", "Drizzle honey"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: turkeyHummusWrapID,
                title: "Turkey Hummus Wrap",
                subtitle: "Portable balanced meal",
                imageName: "Turkey Hummus Wrap",
                timeMinutes: 8,
                calories: 340,
                protein: 28,
                ingredients: ["Whole wheat tortilla", "Turkey slices", "Hummus", "Vegetables"],
                steps: ["Spread hummus", "Add turkey", "Layer vegetables", "Roll tightly"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Simple Smoothie",
                subtitle: "Quick nutrient boost",
                imageName: "Simple Smoothie",
                timeMinutes: 5,
                calories: 300,
                protein: 20,
                ingredients: ["Banana", "Berries", "Yogurt", "Milk", "Honey"],
                steps: ["Blend fruits", "Add yogurt", "Pour milk", "Blend until smooth"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Egg Scramble",
                subtitle: "Protein-rich breakfast",
                imageName: "Egg Scramble",
                timeMinutes: 10,
                calories: 260,
                protein: 18,
                ingredients: ["Eggs", "Spinach", "Butter", "Salt", "Pepper"],
                steps: ["Heat pan", "Sauté spinach", "Beat eggs", "Scramble gently", "Season"],
                tags: [.highProtein, .breakfast]
            ),
            PersonaRecipe(
                id: UUID(),
                title: "Chicken Rice Bowl",
                subtitle: "Simple balanced meal",
                imageName: "Chicken Rice Bowl",
                timeMinutes: 15,
                calories: 420,
                protein: 32,
                ingredients: ["Chicken", "Rice", "Broccoli", "Soy sauce"],
                steps: ["Cook chicken", "Prepare rice", "Steam broccoli", "Arrange in bowl", "Season"],
                tags: [.highProtein, .breakfast]
            )
        ]
    ]
    
    // MARK: - Public Functions
    
    func recipesForPersona(_ persona: Int) -> [PersonaRecipe] {
        let validPersona = (persona >= 1 && persona <= 13) ? persona : 13
        return allPersonaRecipes[validPersona] ?? allPersonaRecipes[13]!
    }
    
    func weeklyPlan(for persona: Int) -> [PersonaRecipe] {
        let recipes = recipesForPersona(persona)
        guard recipes.count >= 7 else { return recipes }
        
        // Calculate current week number for weekly rotation
        // Uses the same calculation as notifications/challenges for consistency
        // Week calculation: days since signup / 7 (matching NutritionState and PersonaWeeklyChallenges)
        let calendar = Calendar.current
        let now = Date()
        
        // Try to get signup date (stored as Date) - matches NutritionState
        var signupDate: Date?
        if let signup = UserDefaults.standard.object(forKey: "hp_signupDate") as? Date {
            signupDate = signup
        } else if let onboardingTimestamp = UserDefaults.standard.object(forKey: "hp_onboardingStartDate") as? TimeInterval {
            // hp_onboardingStartDate is stored as TimeInterval - matches PersonaWeeklyChallenges
            signupDate = Date(timeIntervalSince1970: onboardingTimestamp)
        }
        
        // Use signup date or current date as fallback
        let referenceDate = signupDate ?? now
        
        // Calculate weeks since signup using same method as notifications (days / 7)
        // This ensures weekly meal plans rotate in sync with weekly challenges/notifications
        let daysSinceSignup = calendar.dateComponents([.day], from: referenceDate, to: now).day ?? 0
        let weekNumber = max(0, daysSinceSignup / 7) // 0-based week number (0 = first week, 1 = second week, etc.)
        let weekSeed = UInt64(weekNumber) // Use week number as seed for deterministic but weekly-changing selection
        
        // Day 1: Fast breakfast-friendly option
        // Day 2: Protein-dense
        // Day 3: Balanced bowl
        // Day 4: One quick meal for busy day
        // Day 5: A higher protein dinner
        // Day 6: Snack-focused option
        // Day 7: Reset meal (light + nourishing)
        
        var plan: [PersonaRecipe] = []
        var usedIds: Set<UUID> = []
        
        // Shuffle recipes based on week number for variety
        var shuffledRecipes = recipes
        var generator = SeededRandomNumberGenerator(seed: weekSeed)
        shuffledRecipes.shuffle(using: &generator)
        
        // Helper to add recipe if not already used
        func addIfNotUsed(_ recipe: PersonaRecipe?) {
            if let recipe = recipe, !usedIds.contains(recipe.id) {
                plan.append(recipe)
                usedIds.insert(recipe.id)
            }
        }
        
        // Find breakfast-friendly (usually first few recipes) - use shuffled recipes
        let breakfast = shuffledRecipes.first(where: { recipe in
            !usedIds.contains(recipe.id) && (
                recipe.title.lowercased().contains("oat") ||
                recipe.title.lowercased().contains("yogurt") ||
                recipe.title.lowercased().contains("egg") ||
                recipe.title.lowercased().contains("toast") ||
                recipe.title.lowercased().contains("smoothie")
            )
        })
        addIfNotUsed(breakfast ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find protein-dense (highest protein, not used) - use shuffled recipes
        let proteinDense = shuffledRecipes.filter { !usedIds.contains($0.id) }.max(by: { $0.protein < $1.protein })
        addIfNotUsed(proteinDense ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find balanced bowl - use shuffled recipes
        let bowl = shuffledRecipes.first(where: { recipe in
            !usedIds.contains(recipe.id) && (
                recipe.title.lowercased().contains("bowl") ||
                recipe.title.lowercased().contains("bento")
            )
        })
        addIfNotUsed(bowl ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find quick meal (lowest time, not used) - use shuffled recipes
        let quick = shuffledRecipes.filter { !usedIds.contains($0.id) }.min(by: { $0.timeMinutes > $1.timeMinutes })
        addIfNotUsed(quick ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find higher protein dinner - use shuffled recipes
        let dinnerOptions = shuffledRecipes.filter { !usedIds.contains($0.id) && $0.protein >= 30 }
        let dinner = dinnerOptions.max(by: { $0.protein < $1.protein })
        addIfNotUsed(dinner ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find snack-focused (usually lower calories) - use shuffled recipes
        let snack = shuffledRecipes.first(where: { recipe in
            !usedIds.contains(recipe.id) && (
                recipe.title.lowercased().contains("snack") ||
                recipe.title.lowercased().contains("wrap") ||
                recipe.calories < 300
            )
        })
        addIfNotUsed(snack ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Find reset meal (light + nourishing, usually lower calories) - use shuffled recipes
        let reset = shuffledRecipes.first(where: { recipe in
            !usedIds.contains(recipe.id) && (
                recipe.title.lowercased().contains("salad") ||
                recipe.title.lowercased().contains("soup") ||
                (recipe.calories < 300 && recipe.protein >= 15)
            )
        })
        addIfNotUsed(reset ?? shuffledRecipes.first(where: { !usedIds.contains($0.id) }))
        
        // Fill remaining slots if needed - use shuffled recipes
        while plan.count < 7 && plan.count < shuffledRecipes.count {
            if let next = shuffledRecipes.first(where: { !usedIds.contains($0.id) }) {
                plan.append(next)
                usedIds.insert(next.id)
            } else {
                break
            }
        }
        
        return plan
    }
    
    // All recipes flattened for "All Recipes" tab
    var allRecipes: [PersonaRecipe] {
        return allPersonaRecipes.values.flatMap { $0 }
    }
}

// MARK: - Seeded Random Number Generator
// For deterministic shuffling based on week number
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}

