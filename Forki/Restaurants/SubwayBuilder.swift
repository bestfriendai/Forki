//
//  SubwayBuilder.swift
//  Forki
//
//  Build-your-own component for Subway
//

import SwiftUI

struct SubwayBuilder: View {
    let ingredients: [Ingredient]
    let onLogMeal: (FoodItem) -> Void
    
    @State private var selectedIngredients: Set<String> = []
    
    private var categories: [String] {
        Array(Set(ingredients.map { $0.category })).sorted()
    }
    
    private var totals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let selected = ingredients.filter { selectedIngredients.contains($0.id) }
        return (
            calories: selected.reduce(0) { $0 + $1.calories },
            protein: selected.reduce(0) { $0 + $1.protein },
            carbs: selected.reduce(0) { $0 + $1.carbs },
            fat: selected.reduce(0) { $0 + $1.fat }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Build Your Own Subway")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1A2332"))
                Text("Customize your sub or wrap with fresh ingredients")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7280"))
            }
            
            // Totals card
            if !selectedIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Total Nutrition")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1A2332"))
                        Spacer()
                        Text("\(selectedIngredients.count) ingredients")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ForkiTheme.accentText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(ForkiTheme.borderPrimary.opacity(0.15))
                            )
                    }
                    
                    HStack(spacing: 16) {
                        NutritionSummary(label: "Calories", value: "\(totals.calories)")
                        NutritionSummary(label: "Protein", value: "\(Int(totals.protein))g")
                        NutritionSummary(label: "Carbs", value: "\(Int(totals.carbs))g")
                        NutritionSummary(label: "Fat", value: "\(Int(totals.fat))g")
                    }
                    
                    Button(action: {
                        let foodItem = FoodItem(
                            id: Int.random(in: 10000...99999),
                            name: "Custom Sandwich",
                            calories: totals.calories,
                            protein: totals.protein,
                            carbs: totals.carbs,
                            fats: totals.fat,
                            category: "Custom Meal",
                            usdaFood: nil
                        )
                        onLogMeal(foodItem)
                        selectedIngredients.removeAll()
                    }) {
                        Text("Log Custom Sandwich")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#8DD4D1"), Color(hex: "#6FB8B5")], // Mint gradient
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "#7AB8B5"), lineWidth: 2) // 2px border
                                    )
                            )
                            .shadow(color: ForkiTheme.actionShadow, radius: 12, x: 0, y: 6)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ForkiTheme.borderPrimary.opacity(0.2), lineWidth: 2)
                        )
                )
                .shadow(color: ForkiTheme.borderPrimary.opacity(0.12), radius: 12, x: 0, y: 4)
            }
            
            // Ingredients by category
            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 12) {
                    Text(category)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(ForkiTheme.borderPrimary)
                    
                    ForEach(ingredients.filter { $0.category == category }) { ingredient in
                        IngredientRow(
                            ingredient: ingredient,
                            isSelected: selectedIngredients.contains(ingredient.id)
                        ) {
                            if selectedIngredients.contains(ingredient.id) {
                                selectedIngredients.remove(ingredient.id)
                            } else {
                                selectedIngredients.insert(ingredient.id)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct NutritionSummary: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1A2332"))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#6B7280"))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct IngredientRow: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? ForkiTheme.actionLogFood : Color(hex: "#9CA3AF"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1A2332"))
                    
                    HStack(spacing: 12) {
                        Text("\(ingredient.calories) cal")
                        Text("P: \(Int(ingredient.protein))g")
                        Text("C: \(Int(ingredient.carbs))g")
                        Text("F: \(Int(ingredient.fat))g")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7280"))
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ForkiTheme.borderPrimary.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? ForkiTheme.borderPrimary.opacity(0.3) : ForkiTheme.borderPrimary.opacity(0.1), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

