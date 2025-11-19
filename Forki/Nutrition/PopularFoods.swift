//
//  PopularFoods.swift
//  Forki
//
//  Popular Foods with USDA Foundation Foods data
//  Data sourced from habitpet_foundation_foods_simplified.json (USDA FoodData Central)
//

import Foundation

struct PopularFoods {
    /// Helper to find USDA food from local database
    /// Returns the best matching food from USDA Foundation Foods database
    /// Prioritizes longer/more specific search terms for better matches
    private static func findUSDAFood(searchTerms: [String]) -> LocalFood? {
        let allFoods = LocalFoodStore.shared.foods
        
        // Sort search terms by length (longest first) to prioritize specific matches
        // e.g., "chicken breast grilled" should match before just "chicken"
        let sortedTerms = searchTerms.map { $0.lowercased() }.sorted { $0.count > $1.count }
        
        // Try exact match first (highest priority)
        for term in sortedTerms {
            if let exact = allFoods.first(where: { $0.name.lowercased() == term }) {
                return exact
            }
        }
        
        // Try prefix match (second priority - e.g., "chicken breast" matches "chicken breast grilled")
        for term in sortedTerms {
            if let prefixMatch = allFoods.first(where: { 
                let foodName = $0.name.lowercased()
                return foodName.hasPrefix(term) || term.hasPrefix(foodName)
            }) {
                return prefixMatch
            }
        }
        
        // Try contains match (third priority)
        for term in sortedTerms {
            if let match = allFoods.first(where: { $0.name.lowercased().contains(term) }) {
                return match
            }
        }
        
        return nil
    }
    
    /// Create FoodItem from USDA data or fallback estimate
    /// Uses USDA nutrition data but preserves the display name for consistency
    private static func createFoodItem(
        id: Int,
        name: String,
        category: String,
        searchTerms: [String],
        fallbackCalories: Int,
        fallbackProtein: Double,
        fallbackCarbs: Double,
        fallbackFats: Double
    ) -> FoodItem {
        if let usdaFood = findUSDAFood(searchTerms: searchTerms) {
            // Use USDA nutrition data but keep the original display name
            return FoodItem(
                id: usdaFood.fdcId,
                name: name, // Preserve original display name (e.g., "Grilled Chicken Breast")
                calories: Int(usdaFood.calories ?? Double(fallbackCalories)),
                protein: usdaFood.protein ?? fallbackProtein,
                carbs: usdaFood.carbs ?? fallbackCarbs,
                fats: usdaFood.fat ?? fallbackFats,
                category: usdaFood.category.isEmpty ? category : usdaFood.category,
                usdaFood: nil
            )
        } else {
            // Fallback to estimate if no USDA match found
            return FoodItem(
                id: id,
                name: name,
                calories: fallbackCalories,
                protein: fallbackProtein,
                carbs: fallbackCarbs,
                fats: fallbackFats,
                category: category,
                usdaFood: nil
            )
        }
    }
    
    // Computed property to ensure all foods are created properly
    static var foods: [FoodItem] {
        return [
        // Row 1: Campus comfort foods
        // 1. Chicken Burrito Bowl (composite - using chicken, rice, beans from USDA)
        createFoodItem(
            id: 2001,
            name: "Chicken Burrito Bowl",
            category: "Meat & Grains",
            searchTerms: ["chicken burrito bowl", "chicken", "rice", "black beans"],
            fallbackCalories: 540,
            fallbackProtein: 40,
            fallbackCarbs: 45,
            fallbackFats: 18
        ),
        
        // 2. Pizza (using USDA pizza data)
        createFoodItem(
            id: 2002,
            name: "Pizza",
            category: "Fast Food",
            searchTerms: ["pizza", "pepperoni pizza", "margherita pizza"],
            fallbackCalories: 285,
            fallbackProtein: 12,
            fallbackCarbs: 36,
            fallbackFats: 10
        ),
        
        // 3. Hamburger (using USDA ground beef and bread data)
        createFoodItem(
            id: 2003,
            name: "Hamburger",
            category: "Fast Food",
            searchTerms: ["hamburger", "ground beef", "cheeseburger"],
            fallbackCalories: 354,
            fallbackProtein: 17,
            fallbackCarbs: 35,
            fallbackFats: 15
        ),
        
        // Row 2: Balanced lunch options
        // 4. Turkey Sandwich (using USDA turkey and bread data)
        createFoodItem(
            id: 2004,
            name: "Turkey Sandwich",
            category: "Sandwiches",
            searchTerms: ["turkey sandwich", "turkey", "wheat bread"],
            fallbackCalories: 350,
            fallbackProtein: 30,
            fallbackCarbs: 35,
            fallbackFats: 8
        ),
        
        // 5. Caesar Salad (using USDA romaine lettuce, chicken, dressing)
        createFoodItem(
            id: 2005,
            name: "Caesar Salad",
            category: "Salads",
            searchTerms: ["caesar salad", "romaine lettuce", "chicken caesar salad"],
            fallbackCalories: 250,
            fallbackProtein: 12,
            fallbackCarbs: 10,
            fallbackFats: 18
        ),
        
        // 6. Pasta with Tomato Sauce & Chicken (using USDA pasta, chicken, tomatoes)
        createFoodItem(
            id: 2006,
            name: "Pasta with Tomato Sauce & Chicken",
            category: "Pasta",
            searchTerms: ["pasta", "spaghetti", "chicken pasta", "pasta with tomato sauce"],
            fallbackCalories: 420,
            fallbackProtein: 32,
            fallbackCarbs: 55,
            fallbackFats: 8
        ),
        
        // Row 3: Health-conscious protein & grains
        // 7. Rice Bowl w/ Veg & Egg (using USDA rice, egg, vegetables)
        createFoodItem(
            id: 2007,
            name: "Rice Bowl w/ Veg & Egg",
            category: "Grains",
            searchTerms: ["rice bowl", "brown rice", "white rice", "fried rice"],
            fallbackCalories: 380,
            fallbackProtein: 15,
            fallbackCarbs: 50,
            fallbackFats: 12
        ),
        
        // 8. Grilled Chicken Breast (USDA has exact match)
        createFoodItem(
            id: 2008,
            name: "Grilled Chicken Breast",
            category: "Meat",
            searchTerms: ["chicken breast grilled", "chicken breast", "grilled chicken"],
            fallbackCalories: 165,
            fallbackProtein: 31,
            fallbackCarbs: 0,
            fallbackFats: 3.6
        ),
        
        // 9. Protein Smoothie (composite - using yogurt, fruit, protein powder estimates)
        createFoodItem(
            id: 2009,
            name: "Protein Smoothie",
            category: "Beverages",
            searchTerms: ["smoothie", "protein shake", "yogurt", "banana"],
            fallbackCalories: 260,
            fallbackProtein: 25,
            fallbackCarbs: 30,
            fallbackFats: 5
        ),
        
        // Row 4: Breakfast/snack comfort foods
        // 10. Greek Yogurt Parfait (using USDA yogurt and fruit data)
        createFoodItem(
            id: 2010,
            name: "Greek Yogurt Parfait",
            category: "Dairy",
            searchTerms: ["greek yogurt", "yogurt greek", "parfait", "yogurt plain"],
            fallbackCalories: 280,
            fallbackProtein: 20,
            fallbackCarbs: 35,
            fallbackFats: 8
        ),
        
        // 11. Oatmeal (USDA has exact match)
        createFoodItem(
            id: 2011,
            name: "Oatmeal",
            category: "Grains",
            searchTerms: ["oatmeal", "oats", "steel cut oats"],
            fallbackCalories: 320,
            fallbackProtein: 12,
            fallbackCarbs: 45,
            fallbackFats: 10
        ),
        
        // 12. Mac & Cheese (using USDA pasta and cheese data)
        createFoodItem(
            id: 2012,
            name: "Mac & Cheese",
            category: "Pasta",
            searchTerms: ["mac and cheese", "mac cheese", "macaroni and cheese", "macaroni"],
            fallbackCalories: 450,
            fallbackProtein: 18,
            fallbackCarbs: 55,
            fallbackFats: 16
        )
        ]
    }
}

