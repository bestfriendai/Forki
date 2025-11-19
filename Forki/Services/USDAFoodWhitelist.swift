//
//  USDAFoodWhitelist.swift
//  Forki
//
//  Created for Forki - 500-item curated food whitelist
//  This whitelist filters and prioritizes USDA search results to focus on
//  everyday foods, common grocery items, and college-student favorites.
//

import Foundation

/// Whitelist of 500 curated foods for USDA FoodData Central search
/// Normalized names for flexible matching against USDA database descriptions
struct USDAFoodWhitelist {
    
    /// Normalized food names (lowercased, stripped of punctuation)
    /// These will be matched against USDA food descriptions
    static let whitelistedFoods: Set<String> = [
        // 1. Poultry (40)
        "chicken breast grilled", "chicken breast baked", "chicken breast rotisserie",
        "chicken thigh", "chicken thigh roasted", "chicken drumstick", "chicken wings",
        "chicken tenders", "chicken nuggets frozen", "chicken patties frozen",
        "chicken sausage", "chicken meatballs", "ground chicken", "chicken stir fry strips",
        "dark meat chicken", "chicken liver", "chicken shawarma", "chicken tikka",
        "chicken curry", "chicken burrito bowl", "chicken teriyaki", "chicken enchilada",
        "chicken quesadilla", "chicken fried rice", "chicken salad deli", "chicken caesar salad",
        "chicken alfredo", "chicken pasta", "chicken noodle soup", "chicken pho",
        "chicken ramen", "chicken tortilla soup", "rotisserie chicken leg", "chicken kebab",
        "chicken pot pie", "chicken marsala", "chicken fajitas", "popcorn chicken",
        "sweet sour chicken", "nashville hot chicken",
        
        // 2. Beef, Pork & Red Meat (40)
        "ground beef 85", "ground beef 90", "beef steak", "beef ribeye", "beef sirloin",
        "beef brisket", "beef stew meat", "beef meatballs", "beef chili", "beef burrito",
        "beef taco", "cheeseburger patty", "hamburger patty", "meatloaf", "beef jerky",
        "carne asada", "korean bbq beef bulgogi", "pork chop", "pork tenderloin",
        "pork sausage", "italian sausage", "breakfast sausage", "pepperoni", "salami",
        "ham slices", "pulled pork", "pork carnitas", "bacon", "turkey bacon",
        "beef shawarma", "gyro beef strips", "meat lasagna", "beef ramen", "beef pho",
        "beef taco salad", "hot dog", "bratwurst", "pork fried rice", "pork dumplings",
        "bbq ribs",
        
        // 3. Seafood (25)
        "salmon fillet", "grilled salmon", "smoked salmon", "tuna canned", "tuna salad",
        "shrimp boiled", "shrimp stir fry", "shrimp fried rice", "shrimp scampi",
        "cod fillet", "tilapia", "sardines canned", "mackerel canned", "fish sticks",
        "fish tacos", "sushi salmon roll", "sushi tuna roll", "california roll",
        "poke bowl salmon", "poke bowl tuna", "clam chowder", "crab cakes", "mussels",
        "calamari", "tempura shrimp",
        
        // 4. Plant-Based Proteins (25)
        "tofu firm", "silken tofu", "tofu stir fry", "tempeh", "veggie burger patty",
        "lentils cooked", "chickpeas cooked", "hummus", "falafel", "edamame",
        "black beans", "pinto beans", "kidney beans", "refried beans", "impossible burger",
        "beyond burger", "vegan chicken strips", "soy curls", "seitan", "vegan meatballs",
        "vegan sausage", "veggie chili", "tofu scramble", "black bean soup", "lentil soup",
        
        // 5. Grains, Pasta & Starchy Foods (40)
        "white rice", "brown rice", "jasmine rice", "basmati rice", "fried rice",
        "quinoa", "couscous", "farro", "barley", "oatmeal", "overnight oats", "granola",
        "steel cut oats", "penne pasta", "spaghetti", "fettuccine", "macaroni",
        "whole wheat pasta", "gluten free pasta", "pasta with tomato sauce",
        "pasta with meat sauce", "alfredo pasta", "pesto pasta", "mac cheese",
        "lasagna", "ravioli", "gnocchi", "rice noodles", "ramen noodles", "soba noodles",
        "udon noodles", "tortillas flour", "tortillas corn", "pita bread", "naan",
        "bagels", "dinner roll", "white bread", "wheat bread", "sourdough bread",
        
        // 6. Vegetables (50)
        "broccoli", "cauliflower", "carrots", "celery", "spinach", "kale",
        "romaine lettuce", "spring mix", "mixed greens", "bell peppers", "tomatoes",
        "cherry tomatoes", "cucumbers", "avocado", "onions", "red onions", "green onions",
        "potatoes", "sweet potatoes", "zucchini", "squash", "mushrooms", "eggplant",
        "cabbage", "brussels sprouts", "kimchi", "sauerkraut", "green beans", "peas",
        "corn", "asparagus", "bok choy", "lettuce", "pickles", "jalapeno",
        "spinach salad", "mixed veggie stir fry", "vegetable soup", "roasted vegetables",
        "vegetable curry", "sweet corn", "salsa", "guacamole", "coleslaw", "artichokes",
        "seaweed", "beets", "radish", "pumpkin", "turnips",
        
        // 7. Fruits (40)
        "apples", "bananas", "oranges", "mandarins", "grapes", "strawberries",
        "blueberries", "raspberries", "blackberries", "mango", "pineapple", "watermelon",
        "cantaloupe", "honeydew", "kiwi", "peaches", "plums", "nectarines",
        "pomegranate seeds", "pears", "cherries", "guava", "papaya", "passion fruit",
        "fruit salad", "dried cranberries", "raisins", "dates", "figs", "dried mango",
        "dried blueberries", "apple slices", "banana chips", "frozen berries",
        "frozen mango", "fruit cup", "smoothie blend frozen", "lemon", "lime", "grapefruit",
        
        // 8. Dairy & Alternatives (35)
        "milk whole", "milk 2", "skim milk", "almond milk", "oat milk", "soy milk",
        "coconut milk", "heavy cream", "half and half", "yogurt plain", "yogurt greek",
        "vanilla yogurt", "strawberry yogurt", "parfait", "cottage cheese",
        "cheese cheddar", "cheese mozzarella", "cheese swiss", "cheese slices",
        "cream cheese", "sour cream", "butter", "margarine", "ice cream",
        "frozen yogurt", "ricotta", "parmesan", "feta cheese", "goat cheese",
        "almond milk yogurt", "soy yogurt", "protein yogurt", "kefir", "whipped cream",
        "cheese sticks",
        
        // 9. Breakfast & Eggs (25)
        "scrambled eggs", "fried eggs", "hard boiled eggs", "omelette", "egg whites",
        "breakfast burrito", "pancakes", "waffles", "french toast", "breakfast sandwich",
        "sausage scramble", "hash browns", "turkey bacon", "oatmeal bowl", "yogurt bowl",
        "chia pudding", "protein oats", "peanut butter toast", "avocado toast",
        "bagel with cream cheese", "breakfast tacos", "smoothie bowl", "cereal",
        "granola bowl", "protein pancakes",
        
        // 10. Sandwiches & Wraps (25)
        "turkey sandwich", "chicken sandwich", "ham sandwich", "tuna sandwich",
        "grilled cheese", "blt", "veggie sandwich", "egg salad sandwich",
        "roast beef sandwich", "chicken wrap", "turkey wrap", "tuna wrap",
        "falafel wrap", "shawarma wrap", "gyro wrap", "burrito chicken",
        "burrito beef", "breakfast burrito", "quesadilla", "tacos", "fish tacos",
        "veggie tacos", "pita sandwich", "avocado sandwich", "club sandwich",
        
        // 11. Ready-to-Eat Meals & Frozen Foods (35)
        "frozen pizza", "pepperoni pizza", "margherita pizza", "frozen burrito",
        "frozen lasagna", "frozen chicken nuggets", "frozen fried rice",
        "frozen dumplings", "frozen ramen", "frozen mac cheese", "frozen rice bowl",
        "frozen vegetable medley", "frozen salmon", "frozen chicken breast",
        "frozen vegetables", "frozen waffles", "frozen pancakes", "frozen pot pie",
        "frozen enchiladas", "frozen shepherds pie", "frozen curry",
        "frozen tikka masala", "frozen stir fry", "frozen noodle bowl",
        "frozen udon bowl", "frozen fruit", "bento box", "microwave meal",
        "heat and eat curry", "tv dinner",
        
        // 12. Snacks (30)
        "potato chips", "tortilla chips", "popcorn", "pretzels", "crackers",
        "cheese crackers", "protein bar", "granola bar", "trail mix", "nuts mixed",
        "almonds", "walnuts", "cashews", "pistachios", "peanut butter", "almond butter",
        "rice cakes", "beef jerky", "fruit snacks", "yogurt covered pretzels",
        "dark chocolate", "milk chocolate", "cookies", "brownies", "muffins",
        "banana bread", "protein chips", "edamame snack", "seaweed snacks", "veggie straws",
        
        // 13. Drinks (25)
        "water", "sparkling water", "coconut water", "soda", "diet soda", "coffee",
        "latte", "cappuccino", "black tea", "green tea", "lemonade", "iced tea",
        "smoothie", "protein shake", "sports drink", "energy drink", "juice orange",
        "juice apple", "juice cranberry", "juice grape", "kombucha", "chocolate milk",
        "milkshake", "chai latte", "matcha latte",
        
        // 14. Desserts (20)
        "chocolate cake", "vanilla cake", "cupcakes", "cookies", "brownies", "donuts",
        "ice cream sandwich", "frozen yogurt", "fruit sorbet", "cheesecake", "tiramisu",
        "apple pie", "pumpkin pie", "pudding", "rice pudding", "mochi ice cream",
        "churros", "cinnamon rolls", "banana split", "chocolate pudding",
        
        // 15. Salads (20)
        "caesar salad", "greek salad", "garden salad", "cobb salad", "tuna salad",
        "chicken salad", "quinoa salad", "lentil salad", "pasta salad", "fruit salad",
        "southwest salad", "asian chicken salad", "kale salad", "spinach salad",
        "avocado salad", "caprese salad", "chickpea salad", "poke bowl salad",
        "nicoise salad", "tofu salad",
        
        // 16. International & College Favorites (30)
        "pad thai", "pho", "ramen", "fried rice", "bibimbap", "kimchi fried rice",
        "sushi bowl", "chicken tikka masala", "butter chicken", "biryani",
        "curry chicken", "curry vegetables", "shawarma plate", "falafel plate",
        "gyro plate", "burrito bowl", "taco bowl", "poke bowl", "teriyaki chicken bowl",
        "katsu chicken", "katsu pork", "spring rolls", "dumplings", "gyoza", "poutine",
        "empanada", "tamales", "enchiladas", "arepas", "meatball sub"
    ]
    
    /// Check if a food name matches the whitelist
    /// Uses flexible matching to handle variations in USDA descriptions
    /// Prioritizes exact phrase matches for multi-word items
    static func isWhitelisted(_ foodName: String) -> Bool {
        let normalized = normalize(foodName)
        
        // Check for exact match in whitelist
        if whitelistedFoods.contains(normalized) {
            return true
        }
        
        // Check if any whitelisted food is contained in the normalized name
        // This handles cases like "chicken thigh, roasted" matching "chicken thigh"
        for whitelistedFood in whitelistedFoods {
            // Check if whitelisted phrase appears as a contiguous sequence in the name
            if normalized.contains(whitelistedFood) {
                return true
            }
            // Check if the name is a prefix of whitelisted food (handles partial matches)
            if whitelistedFood.hasPrefix(normalized) && normalized.split(separator: " ").count >= 2 {
                return true
            }
        }
        
        // Check for phrase matches where all words appear in order
        // This ensures "chicken thigh" matches "chicken thigh, roasted" but prioritizes phrase order
        let nameWords = normalized.split(separator: " ").map(String.init)
        for whitelistedFood in whitelistedFoods {
            let whitelistedWords = whitelistedFood.split(separator: " ").map(String.init)
            
            // Skip single-word items for this check
            guard whitelistedWords.count >= 2 else { continue }
            
            // Check if all whitelisted words appear in order in the name
            var nameIndex = 0
            var matchedCount = 0
            
            for whitelistedWord in whitelistedWords {
                // Find the word in the remaining part of the name
                while nameIndex < nameWords.count {
                    if nameWords[nameIndex] == whitelistedWord || 
                       nameWords[nameIndex].contains(whitelistedWord) ||
                       whitelistedWord.contains(nameWords[nameIndex]) {
                        matchedCount += 1
                        nameIndex += 1
                        break
                    }
                    nameIndex += 1
                }
            }
            
            // If all words matched in order, it's a whitelisted item
            if matchedCount == whitelistedWords.count {
                return true
            }
        }
        
        // Fallback: Check for word overlap (for less strict matching)
        let nameWordSet = Set(normalized.split(separator: " ").map(String.init))
        for whitelistedFood in whitelistedFoods {
            let whitelistedWords = Set(whitelistedFood.split(separator: " ").map(String.init))
            let matchingWords = nameWordSet.intersection(whitelistedWords)
            // Require at least 60% of words to match, with minimum 2 words
            if matchingWords.count >= 2 && Double(matchingWords.count) / Double(whitelistedWords.count) >= 0.6 {
                return true
            }
        }
        
        return false
    }
    
    /// Calculate a whitelist match score (higher = better match)
    /// Returns 0 if not whitelisted, or a score indicating match quality
    /// Prioritizes exact phrase matches for multi-word items
    static func whitelistScore(_ foodName: String) -> Int {
        let normalized = normalize(foodName)
        
        // Exact match gets highest score
        if whitelistedFoods.contains(normalized) {
            return 1000
        }
        
        var maxScore = 0
        
        // Check for contained phrase matches (highest priority after exact)
        // This handles "chicken thigh, roasted" matching "chicken thigh"
        for whitelistedFood in whitelistedFoods {
            if normalized.contains(whitelistedFood) {
                // Multi-word phrases get higher scores
                let wordCount = whitelistedFood.split(separator: " ").count
                let baseScore = wordCount >= 2 ? 900 : 800
                // Longer matches are better
                let lengthBonus = min(whitelistedFood.count * 2, 99)
                maxScore = max(maxScore, baseScore + lengthBonus)
            }
        }
        
        // Check for phrase matches where all words appear in order
        // This ensures "chicken thigh" gets high score when matching "chicken thigh, roasted"
        let nameWords = normalized.split(separator: " ").map(String.init)
        for whitelistedFood in whitelistedFoods {
            let whitelistedWords = whitelistedFood.split(separator: " ").map(String.init)
            
            // Only check multi-word phrases
            guard whitelistedWords.count >= 2 else { continue }
            
            // Check if all whitelisted words appear in order
            var nameIndex = 0
            var matchedCount = 0
            var consecutiveMatches = 0
            var maxConsecutive = 0
            var previousMatchIndex = -1
            
            for whitelistedWord in whitelistedWords {
                var found = false
                var currentMatchIndex = -1
                
                while nameIndex < nameWords.count {
                    if nameWords[nameIndex] == whitelistedWord ||
                       nameWords[nameIndex].contains(whitelistedWord) ||
                       whitelistedWord.contains(nameWords[nameIndex]) {
                        matchedCount += 1
                        currentMatchIndex = nameIndex
                        
                        // Track consecutive matches
                        if previousMatchIndex >= 0 && nameIndex == previousMatchIndex + 1 {
                            consecutiveMatches += 1
                        } else {
                            consecutiveMatches = 1
                        }
                        maxConsecutive = max(maxConsecutive, consecutiveMatches)
                        
                        nameIndex += 1
                        found = true
                        break
                    }
                    nameIndex += 1
                }
                
                if found {
                    previousMatchIndex = currentMatchIndex
                } else {
                    consecutiveMatches = 0
                    previousMatchIndex = -1
                }
            }
            
            // If all words matched in order, calculate score
            if matchedCount == whitelistedWords.count {
                // Perfect phrase match in order gets very high score
                let baseScore = maxConsecutive == whitelistedWords.count ? 850 : 750
                let wordBonus = whitelistedWords.count * 30
                let consecutiveBonus = maxConsecutive * 20
                maxScore = max(maxScore, baseScore + wordBonus + consecutiveBonus)
            } else if matchedCount >= 2 {
                // Partial phrase match
                let ratio = Double(matchedCount) / Double(whitelistedWords.count)
                maxScore = max(maxScore, Int(ratio * 700) + (matchedCount * 15))
            }
        }
        
        // Fallback: Check for word overlap (lower priority)
        if maxScore < 700 {
            let nameWordSet = Set(normalized.split(separator: " ").map(String.init))
            for whitelistedFood in whitelistedFoods {
                let whitelistedWords = Set(whitelistedFood.split(separator: " ").map(String.init))
                let matchingWords = nameWordSet.intersection(whitelistedWords)
                if matchingWords.count >= 2 {
                    let overlapRatio = Double(matchingWords.count) / Double(whitelistedWords.count)
                    let score = Int(overlapRatio * 600) + (matchingWords.count * 20)
                    maxScore = max(maxScore, score)
                }
            }
        }
        
        return maxScore
    }
    
    /// Normalize a food name for comparison
    /// Lowercases, removes punctuation, and normalizes whitespace
    private static func normalize(_ s: String) -> String {
        let lowered = s.lowercased()
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        let filtered = lowered.unicodeScalars.map { allowed.contains($0) ? Character($0) : " " }
        let joined = String(filtered)
        return joined.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

