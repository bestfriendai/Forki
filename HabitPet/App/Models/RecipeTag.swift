//
//  RecipeTag.swift
//  Forki
//
//  Created for recipe tagging system
//

import Foundation
import SwiftUI

enum RecipeTag: String, Codable, CaseIterable, Identifiable {
    case quickMeals = "Quick Meals"
    case highProtein = "High-Protein"
    case higherCalorie = "Higher-Calorie"
    case lightMeals = "Light Meals"
    case grabAndGo = "Grab & Go"
    case breakfast = "Breakfast"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .quickMeals: return "bolt.fill"
        case .highProtein: return "dumbbell.fill"
        case .higherCalorie: return "flame.fill"
        case .lightMeals: return "leaf.fill"
        case .grabAndGo: return "bag.fill"
        case .breakfast: return "sunrise.fill"
        }
    }

    var color: Color {
        switch self {
        case .quickMeals: return Color.yellow
        case .highProtein: return Color.blue
        case .higherCalorie: return Color.orange
        case .lightMeals: return Color.green
        case .grabAndGo: return Color.pink
        case .breakfast: return Color.purple
        }
    }
}

