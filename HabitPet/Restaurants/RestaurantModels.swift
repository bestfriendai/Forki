//
//  RestaurantModels.swift
//  Forki
//
//  Restaurant data models for Explore page
//

import Foundation
import SwiftUI

// MARK: - Restaurant Models

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: String
    let distance: Double // in miles
    let rating: Double
    let image: String // image name in assets
    let isBuildYourOwn: Bool
    let menu: [RestaurantFoodItem]?
    let ingredients: [Ingredient]?
    
    init(
        id: String,
        name: String,
        cuisine: String,
        distance: Double,
        rating: Double,
        image: String,
        isBuildYourOwn: Bool = false,
        menu: [RestaurantFoodItem]? = nil,
        ingredients: [Ingredient]? = nil
    ) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.distance = distance
        self.rating = rating
        self.image = image
        self.isBuildYourOwn = isBuildYourOwn
        self.menu = menu
        self.ingredients = ingredients
    }
}

struct RestaurantFoodItem: Identifiable, Hashable {
    let id: String
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let category: String
    let image: String? // optional image URL or asset name
    
    init(
        id: String,
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        category: String,
        image: String? = nil
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.category = category
        self.image = image
    }
    
    // Convert to FoodItem for logging
    func toFoodItem() -> FoodItem {
        return FoodItem(
            id: Int(id.hashValue),
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fat,
            category: category,
            usdaFood: nil
        )
    }
}

struct Ingredient: Identifiable, Hashable {
    let id: String
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let category: String
    
    init(
        id: String,
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        category: String
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.category = category
    }
    
    // Convert to FoodItem for logging
    func toFoodItem() -> FoodItem {
        return FoodItem(
            id: Int(id.hashValue),
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fats: fat,
            category: category,
            usdaFood: nil
        )
    }
}

