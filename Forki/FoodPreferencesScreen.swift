//
//  FoodPreferencesScreen.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

struct FoodPreferencesScreen: View {
    @Binding var currentScreen: Int
    @Binding var userData: UserData
    
    @State private var selected: [String] = []
    @State private var droppedFoods: [FoodOption] = []
    @State private var bounceStates: [String: Bool] = [:]
    
    private let dietaryPreferences: [FoodOption] = [
        .init(id: "vegetarian", name: "Vegetarian", icon: "🌱"),
        .init(id: "high-protein", name: "High Protein", icon: "💪"),
        .init(id: "low-carb", name: "Low Carb", icon: "🥗"),
        .init(id: "keto", name: "Keto", icon: "🥑"),
        .init(id: "mediterranean", name: "Mediterranean", icon: "🫒"),
        .init(id: "gluten-free", name: "Gluten Free", icon: "🌾")
    ]
    
    private let foodCategories: [FoodOption] = [
        .init(id: "fruits", name: "Fruits", icon: "🍎"),
        .init(id: "veggies", name: "Veggies", icon: "🥦"),
        .init(id: "chicken", name: "Chicken", icon: "🍗"),
        .init(id: "beef", name: "Beef", icon: "🥩"),
        .init(id: "pork", name: "Pork", icon: "🥓"),
        .init(id: "fish", name: "Fish", icon: "🐟"),
        .init(id: "dairy", name: "Dairy", icon: "🧀"),
        .init(id: "dessert", name: "Dessert", icon: "🍰"),
        .init(id: "grains", name: "Grains", icon: "🍚"),
        .init(id: "nuts", name: "Nuts", icon: "🥜"),
        .init(id: "eggs", name: "Eggs", icon: "🥚"),
        .init(id: "pasta", name: "Pasta", icon: "🍝")
    ]
    
    // ✅ Count only food categories
    private var foodSelectedCount: Int {
        selected.filter { id in
            foodCategories.contains(where: { $0.id == id })
        }.count
    }
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Dietary Preferences
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dietary Preferences")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(ForkiTheme.textPrimary)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(dietaryPreferences) { pref in
                                PreferenceButton(option: pref, isSelected: selected.contains(pref.id), compact: true) {
                                    toggle(pref.id)
                                }
                            }
                        }
                    }
                    
                    // Plate drop zone
                    ZStack {
                        Circle()
                            .fill(ForkiTheme.panelBackground)
                            .frame(width: 180, height: 180)
                            .overlay(
                                Circle()
                                    .stroke(ForkiTheme.borderPrimary, lineWidth: 3)
                            )
                            .overlay(
                                Text("🍽️")
                                    .font(.system(size: 52))
                                    .opacity(droppedFoods.isEmpty ? 0.3 : 0)
                            )
                            .shadow(color: ForkiTheme.borderPrimary.opacity(0.12), radius: 14, x: 0, y: 8)
                        
                        ForEach(Array(droppedFoods.enumerated()), id: \.offset) { index, food in
                            Text(food.icon)
                                .font(.system(size: 38))
                                .scaleEffect(bounceStates[food.id] == true ? 1.2 : 1.0)
                                .rotationEffect(bounceStates[food.id] == true ? .degrees(-8) : .degrees(0))
                                .offset(x: offsetForIndex(index).x, y: offsetForIndex(index).y)
                                .draggable(food.id) { // ✅ Clean emoji-only drag preview for removal
                                    Text(food.icon)
                                        .font(.system(size: 48))
                                        .background(Color.clear) // Remove any background
                                }
                        }
                    }
                    .frame(height: 200)
                    .dropDestination(for: String.self) { items, _ in
                        for id in items {
                            if let food = foodCategories.first(where: { $0.id == id }) {
                                if !selected.contains(id) {
                                    selected.append(id)
                                    droppedFoods.append(food)
                                    bounceOnce(id)
                                } else {
                                    bounceOnce(id)
                                }
                            }
                        }
                        return true
                    }
                    
                    // Food Categories
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food Categories")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(ForkiTheme.textPrimary)
                        Text("Drag your favorite foods into the plate above")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(ForkiTheme.textSecondary)
                            .padding(.bottom, 4)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(foodCategories) { food in
                                VStack(spacing: 2) {
                                    Text(food.icon)
                                        .font(.system(size: 28))
                                    Text(food.name)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(ForkiTheme.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selected.contains(food.id) ? ForkiTheme.surface.opacity(0.8) : ForkiTheme.surface.opacity(0.4))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(selected.contains(food.id) ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: selected.contains(food.id) ? 2 : 1.5)
                                )
                                .cornerRadius(12)
                                .draggable(food.id) { // ✅ Clean emoji-only drag preview
                                    Text(food.icon)
                                        .font(.system(size: 48))
                                        .background(Color.clear) // Remove any background
                                }
                                .onTapGesture {
                                    toggle(food.id)
                                }
                            }
                        }
                    }
                    
                    // Continue + Skip
                    VStack(spacing: 12) {
                        Button {
                            userData.foodPreferences = selected
                            withAnimation { currentScreen += 1 }
                        } label: {
                            Text("Continue (\(foodSelectedCount) selected)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(.white)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(ForkiTheme.actionLogFood)
                                )
                                .shadow(color: ForkiTheme.actionShadow, radius: 12, x: 0, y: 6)
                        }
                        
                        Button {
                            withAnimation { currentScreen += 1 }
                        } label: {
                            Text("Skip for now")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .underline()
                        }
                    }
                }
                .frame(maxWidth: 360)
                .padding(16)
            }
        }
        // ✅ Background drop zone for removal
        .background(
            Color.clear
                .dropDestination(for: String.self) { items, _ in
                    for id in items {
                        selected.removeAll { $0 == id }
                        droppedFoods.removeAll { $0.id == id }
                    }
                    return true
                }
        )
        .onAppear {
            selected = userData.foodPreferences
            droppedFoods = foodCategories.filter { selected.contains($0.id) }
        }
    }
    
    // MARK: - Helpers
    private func toggle(_ id: String) {
        if selected.contains(id) {
            selected.removeAll { $0 == id }
            droppedFoods.removeAll { $0.id == id }
        } else {
            selected.append(id)
            if let food = foodCategories.first(where: { $0.id == id }) {
                droppedFoods.append(food)
                bounceOnce(id)
            }
        }
    }
    
    private func bounceOnce(_ id: String) {
        bounceStates[id] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring()) { bounceStates[id] = false }
        }
    }
    
    private func offsetForIndex(_ i: Int) -> CGPoint {
        let totalItems = droppedFoods.count
        let plateRadius: CGFloat = 90 // Half of the 180px plate diameter
        
        // For 1-3 items: center them
        if totalItems <= 3 {
            let spacing: CGFloat = 40
            let startX = -spacing * CGFloat(totalItems - 1) / 2
            return CGPoint(x: startX + CGFloat(i) * spacing, y: 0)
        }
        
        // For 4-6 items: 2 rows
        if totalItems <= 6 {
            let cols = 3
            let spacing: CGFloat = 35
            let rowSpacing: CGFloat = 30
            let x = CGFloat(i % cols) * spacing - spacing
            let y = CGFloat(i / cols) * rowSpacing - rowSpacing / 2
            return CGPoint(x: x, y: y)
        }
        
        // For 7+ items: arrange in concentric circles
        if totalItems <= 9 {
            let cols = 3
            let spacing: CGFloat = 32
            let x = CGFloat(i % cols) * spacing - spacing
            let y = CGFloat(i / cols) * spacing - spacing
            return CGPoint(x: x, y: y)
        }
        
        // For 10+ items: use circular distribution
        let angle = (2 * .pi * CGFloat(i)) / CGFloat(totalItems)
        let radius = plateRadius * 0.7 // Use 70% of plate radius to keep items centered
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Option Model
struct FoodOption: Identifiable, Equatable {
    var id: String
    var name: String
    var icon: String
}

// MARK: - Preference Button
struct PreferenceButton: View {
    let option: FoodOption
    let isSelected: Bool
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(option.icon)
                Text(option.name)
                    .font(.system(size: compact ? 12 : 14, weight: .medium, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
            }
            .padding(compact ? 6 : 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? ForkiTheme.surface.opacity(0.8) : ForkiTheme.surface.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isSelected ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: isSelected ? 2 : 1.5)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    FoodPreferencesScreen(
        currentScreen: .constant(4),
        userData: .constant(UserData())
    )
}
