//
//  USDAFoodService.swift
//  Forki
//
//  Clean local-search version (recommended for production)
//

import Foundation
import Combine

// MARK: - Local Food Model

struct LocalFood: Codable, Identifiable, Equatable {
    var id: Int { fdcId }
    let fdcId: Int
    let name: String
    let category: String
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    
    // Equatable conformance - compare by fdcId (unique identifier)
    static func == (lhs: LocalFood, rhs: LocalFood) -> Bool {
        return lhs.fdcId == rhs.fdcId
    }
}

// MARK: - LocalFood to FoodItem conversion
extension LocalFood {
    func toFoodItem() -> FoodItem {
        return FoodItem(
            id: fdcId,
            name: name,
            calories: Int(calories ?? 0),
            protein: protein ?? 0.0,
            carbs: carbs ?? 0.0,
            fats: fat ?? 0.0,
            category: category,
            usdaFood: nil
        )
    }
}

// MARK: - Local Food Store (loads JSON once)

final class LocalFoodStore {
    static let shared = LocalFoodStore()

    let foods: [LocalFood]

    private init() {

        guard let url = Bundle.main.url(
            forResource: "habitpet_master_foods",
            withExtension: "json"
        ) else {
            print("❌ ERROR: habitpet_master_foods.json missing from bundle")
            foods = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            foods = try JSONDecoder().decode([LocalFood].self, from: data)
        } catch {
            print("❌ ERROR decoding habitpet_master_foods.json:", error)
            foods = []
        }
    }
}

// MARK: - USDA Food Service

final class USDAFoodService: ObservableObject {
    static let shared = USDAFoodService()

    private let apiKey = "<YOUR_USDA_API_KEY>"    // still used for details only
    private let session = URLSession.shared

    private init() {}

    // MARK: - 🔍 1. NEW — Local-only search (no API calls)

    func searchFoodsLocally(query: String) -> [LocalFood] {
        let q = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !q.isEmpty else { return [] }

        let allFoods = LocalFoodStore.shared.foods

        // Simple, precise, instant search
        let results = allFoods
            .filter { $0.name.lowercased().contains(q) }
            .sorted { a, b in
                let an = a.name.lowercased()
                let bn = b.name.lowercased()

                // Prioritize prefix matches
                if an.hasPrefix(q) != bn.hasPrefix(q) {
                    return an.hasPrefix(q)
                }
                // Otherwise alphabetical
                return an < bn
            }

        return results
    }

    // MARK: - 🥣 2. USDA Details (Optional — used when user taps item)

    struct USDAFoodDetails: Codable {
        struct Nutrient: Codable {
            let name: String
            let number: String
            let unitName: String
            let amount: Double?
        }

        let description: String
        let fdcId: Int
        let foodNutrients: [Nutrient]
    }

    func fetchDetails(for fdcId: Int) -> AnyPublisher<USDAFoodDetails, Error> {
        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/food/\(fdcId)")!
        components.queryItems = [ URLQueryItem(name: "api_key", value: apiKey) ]

        let request = URLRequest(url: components.url!)

        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: USDAFoodDetails.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

