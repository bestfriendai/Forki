//
//  RapidSearch.swift
//  Forki
//
//  Optimized local search with fuzzy ranking for ~500 foods
//

import Foundation
import Combine

// MARK: - RapidSearch

final class RapidSearch: ObservableObject {
    
    // MARK: - LocalFood model (matches habitpet_master_foods.json)
    
    struct LocalFood: Identifiable, Codable, Hashable {
        /// Stable string id (fdc_12345 or similar)
        let id: String?
        let name: String
        let searchKey: String?
        let category: String
        let fdcId: Int?
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        
        /// Primary key we search on (fallback to name)
        var primarySearchKey: String {
            searchKey?.isEmpty == false ? searchKey! : name
        }
    }
    
    // Expose LocalFood as a global alias if you want to use it directly in views
    // (FoodLoggerView is already using `LocalFood` unqualified)
    typealias Item = LocalFood
    
    // Singleton
    static let shared = RapidSearch()
    
    // All items loaded from JSON
    @Published private(set) var allItems: [LocalFood] = []
    
    // Internal indexed representation for fast scoring
    private struct IndexedFood {
        let item: LocalFood
        let normName: String
        let normKey: String
        let tokens: Set<String>
        let bigrams: Set<String>
    }
    
    private var indexed: [IndexedFood] = []
    
    // Serial queue for thread safety
    private let queue = DispatchQueue(label: "habitpet.rapidsearch.queue", qos: .userInitiated)
    
    private init() {}
    
    // MARK: - Public API
    
    /// Call this early (e.g. in `ForkiApp.init()`).
    /// Defaults to loading `habitpet_master_foods.json` from the main bundle.
    func load(fromBundleFileNamed fileName: String = "habitpet_master_foods",
              withExtension ext: String = "json") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("⚠️ RapidSearch: Could not find \(fileName).\(ext) in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let rawItems = try decoder.decode([LocalFood].self, from: data)
            
            let indexedItems: [IndexedFood] = rawItems.map { item in
                let normName = RapidSearch.normalize(item.name)
                let normKey  = RapidSearch.normalize(item.primarySearchKey)
                
                let tokenSource = normKey.isEmpty ? normName : "\(normKey) \(normName)"
                let tokens = RapidSearch.tokenSet(from: tokenSource)
                let bigrams = RapidSearch.bigrams(normKey.isEmpty ? normName : normKey)
                
                // Stable id: prefer fdcId if present
                let fixedId: String
                if let fdc = item.fdcId {
                    fixedId = "fdc_\(fdc)"
                } else if let rawId = item.id, !rawId.isEmpty {
                    fixedId = rawId
                } else {
                    // Last resort: normalized name (rare; mostly for manual items)
                    fixedId = normName.isEmpty ? item.name : normName
                }
                
                let fixedItem = LocalFood(
                    id: fixedId,
                    name: item.name,
                    searchKey: item.searchKey,
                    category: item.category,
                    fdcId: item.fdcId,
                    calories: item.calories,
                    protein: item.protein,
                    carbs: item.carbs,
                    fat: item.fat
                )
                
                return IndexedFood(
                    item: fixedItem,
                    normName: normName,
                    normKey: normKey,
                    tokens: tokens,
                    bigrams: bigrams
                )
            }
            
            queue.sync {
                self.allItems = indexedItems.map { $0.item }
                self.indexed = indexedItems
            }
            
            print("✅ RapidSearch: Loaded \(indexedItems.count) foods into index from \(fileName).\(ext).")
        } catch {
            print("❌ RapidSearch load error:", error)
        }
    }
    
    /// Main search function.
    /// Safe to call from the main thread; work is done on a small in-memory index.
    func search(_ rawQuery: String, limit: Int = 50) -> [LocalFood] {
        let query = Self.normalize(rawQuery)
        if query.isEmpty {
            // For empty query, we let the UI show popular foods instead
            return []
        }
        
        let qTokens  = Set(query.split(separator: " ").map { String($0) }.filter { !$0.isEmpty })
        let qBigrams = Self.bigrams(query)
        
        // Score synchronously – 500-ish items is tiny
        let scored: [(IndexedFood, Int)] = queue.sync {
            indexed.compactMap { food in
                let score = Self.score(food: food,
                                       query: query,
                                       qTokens: qTokens,
                                       qBigrams: qBigrams)
                return score > 0 ? (food, score) : nil
            }
        }
        
        let sorted = scored
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 {
                    return lhs.1 > rhs.1 // higher score first
                }
                return lhs.0.item.name < rhs.0.item.name // tie-break alphabetically
            }
            .prefix(limit)
            .map { $0.0.item }
        
        return sorted
    }
    
    // MARK: - Scoring
    
    private static func score(food: IndexedFood,
                              query: String,
                              qTokens: Set<String>,
                              qBigrams: Set<String>) -> Int {
        var score = 0
        if query.isEmpty { return 0 }
        
        let normName = food.normName
        let normKey  = food.normKey
        
        // 1) Very strong: exact match on key or name
        if normKey == query || normName == query {
            score += 1000
        }
        
        // 2) Strong: starts-with on key or name
        if normKey.hasPrefix(query) || normName.hasPrefix(query) {
            score += 500
        }
        
        // 3) Whole-word match: if any token equals the query
        if food.tokens.contains(query) {
            score += 350
        }
        
        // 4) Basic substring boost (lighter so it doesn’t dominate)
        if normName.contains(query) || normKey.contains(query) {
            score += 120
        }
        
        // 5) Token overlap: helps multi-word queries like "chicken fried rice"
        let overlapCount = qTokens.intersection(food.tokens).count
        if overlapCount > 0 {
            score += overlapCount * 80
        }
        
        // 6) Fuzzy similarity via bigram Dice coefficient (0…1 -> up to +150)
        if !qBigrams.isEmpty && !food.bigrams.isEmpty {
            let intersect = qBigrams.intersection(food.bigrams).count
            let denom = qBigrams.count + food.bigrams.count
            if denom > 0 {
                let dice = (2.0 * Double(intersect)) / Double(denom)
                score += Int(dice * 150.0)
            }
        }
        
        // 7) Category hints (semantic nudges)
        let cat = food.item.category.lowercased()
        if query.contains("soup") && cat.contains("soup") {
            score += 100
        }
        if query.contains("coffee") && cat.contains("beverage") {
            score += 100
        }
        if query.contains("breakfast") && cat.contains("breakfast") {
            score += 100
        }
        
        // 8) Macro / nutrition aware hints (simple but helpful)
        let qLower = query.lowercased()
        let item = food.item
        
        // High-protein queries
        if qLower.contains("high protein") || qLower.contains("protein") {
            if item.protein >= 25 {
                score += 120
            } else if item.protein >= 15 {
                score += 60
            }
        }
        
        // Low-carb / keto queries
        if qLower.contains("low carb") || qLower.contains("keto") {
            if item.carbs <= 15 {
                score += 100
            } else if item.carbs <= 25 {
                score += 50
            }
        }
        
        // Light / low-calorie queries
        if qLower.contains("light") || qLower.contains("low calorie") || qLower.contains("diet") {
            if item.calories <= 250 {
                score += 90
            } else if item.calories <= 350 {
                score += 45
            }
        }
        
        return score
    }
    
    // MARK: - Normalization helpers
    
    /// Lowercase, remove diacritics, keep only letters/digits/spaces, collapse whitespace.
    private static func normalize(_ text: String) -> String {
        guard !text.isEmpty else { return "" }
        
        let lower = text.lowercased()
        let folded = lower.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        var scalarView = String.UnicodeScalarView()
        let spaceScalar = UnicodeScalar(0x20)! // Space character
        for scalar in folded.unicodeScalars {
            if allowed.contains(scalar) {
                scalarView.append(scalar)
            } else {
                // Replace punctuation etc. with space so words stay separated
                scalarView.append(spaceScalar)
            }
        }
        let cleaned = String(scalarView)
        
        // Collapse multiple spaces
        let tokens = cleaned.split(whereSeparator: { $0.isWhitespace })
        return tokens.joined(separator: " ")
    }
    
    /// Bigram set for fuzzy Dice similarity.
    private static func bigrams(_ text: String) -> Set<String> {
        let s = text.replacingOccurrences(of: " ", with: "")
        guard s.count >= 2 else { return [] }
        var result = Set<String>()
        let chars = Array(s)
        for i in 0..<(chars.count - 1) {
            let bg = String([chars[i], chars[i + 1]])
            result.insert(bg)
        }
        return result
    }
    
    /// Tokenize and remove generic / noisy words to avoid bad matches.
    private static func tokenSet(from text: String) -> Set<String> {
        if text.isEmpty { return [] }
        let rawTokens = text
            .split(separator: " ")
            .map { String($0) }
        
        let stopWords: Set<String> = [
            "with", "and", "or", "of", "in", "on", "the", "a", "an",
            "mixed", "dish", "dishes", "bowl", "bowls", "style", "type",
            "prepared", "cooked", "generic", "brand", "regular",
            "low", "fat", "nonfat", "reduced", "sodium",
            "unspecified", "nfs", "ns"
        ]
        
        let filtered = rawTokens.compactMap { token -> String? in
            let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty { return nil }
            if stopWords.contains(t) { return nil }
            if t.count <= 1 { return nil } // ignore 1-char tokens
            return t
        }
        
        return Set(filtered)
    }
}

// MARK: - RapidSearch.LocalFood -> FoodItem conversion

extension RapidSearch.LocalFood {
    /// Convert search item into your app's `FoodItem` model.
    func toFoodItem() -> FoodItem {
        // Prefer explicit fdcId, otherwise try to parse from "fdc_<id>" string,
        // otherwise fall back to 0 (or a generated stable id if you prefer).
        let numericId: Int = {
            if let fdc = fdcId {
                return fdc
            }
            if let id = id, id.hasPrefix("fdc_") {
                return Int(id.replacingOccurrences(of: "fdc_", with: "")) ?? 0
            }
            return 0
        }()
        
        return FoodItem(
            id: numericId,
            name: name,
            calories: Int(calories),
            protein: protein,
            carbs: carbs,
            fats: fat,
            category: category,
            usdaFood: nil
        )
    }
}

