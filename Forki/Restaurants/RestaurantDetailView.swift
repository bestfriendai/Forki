//
//  RestaurantDetailView.swift
//  Forki
//
//  Individual restaurant detail page
//

import SwiftUI
import UIKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    let onDismiss: () -> Void
    let onLogFood: (FoodItem) -> Void
    
    @State private var selectedTab: RestaurantTab = .menu
    @State private var showFoodLogger = false
    @State private var selectedFoodItem: FoodItem?
    
    // For direct logging without FoodLoggerView
    @State private var showLogConfirmation = false
    
    enum RestaurantTab {
        case menu
        case build
    }
    
    // MARK: - Computed Properties
    
    /// Whether to show build-your-own view
    /// Shows for restaurants that have ingredients but no menu (Chipotle, CAVA, Little Pan)
    private var shouldShowBuildYourOwnView: Bool {
        return restaurant.isBuildYourOwn && restaurant.menu == nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(hex: "#F5F7FA"),
                        Color(hex: "#E8ECF1")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Group {
                            if let uiImage = UIImage(named: restaurant.image) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "fork.knife.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "#9CA3AF"))
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ForkiTheme.borderPrimary.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: ForkiTheme.borderPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Text(restaurant.name)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1A2332"))
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(ForkiTheme.legendCarbs)
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B7280"))
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(ForkiTheme.actionLogFood)
                                Text(String(format: "%.1f mi", restaurant.distance))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B7280"))
                            }
                            
                            Text(restaurant.cuisine)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ForkiTheme.accentText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(ForkiTheme.borderPrimary.opacity(0.15))
                                )
                        }
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.9))
                    
                    // Content
                    ScrollView {
                        if shouldShowBuildYourOwnView {
                            buildYourOwnView
                        } else {
                            menuView
                        }
                    }
                }
                .overlay(
                    // Purple outline around the container
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary, lineWidth: 4)
                        .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white.opacity(0.95), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(ForkiTheme.borderPrimary)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showFoodLogger) {
            if let foodItem = selectedFoodItem {
                FoodLoggerView(
                    prefill: foodItem,
                    loggedMeals: [],
                    onSave: { loggedFood in
                        // Dismiss FoodLoggerView first
                        showFoodLogger = false
                        selectedFoodItem = nil
                        
                        // Log food and dismiss this view to return to Home Screen
                        onLogFood(loggedFood.food)
                        onDismiss() // Dismiss RestaurantDetailView sheet
                    },
                    onClose: {
                        showFoodLogger = false
                        selectedFoodItem = nil
                    },
                    onDeleteFromHistory: { _ in }
                )
                .presentationDetents([.fraction(0.6), .large])
                .presentationDragIndicator(.visible)
            }
        }
        .alert("Log Food", isPresented: $showLogConfirmation) {
            Button("Cancel", role: .cancel) {
                selectedFoodItem = nil
            }
            Button("Log") {
                if let foodItem = selectedFoodItem {
                    onLogFood(foodItem)
                    selectedFoodItem = nil
                }
            }
        } message: {
            if let foodItem = selectedFoodItem {
                Text("Log \(foodItem.name)?")
            }
        }
    }
    
    private var menuView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let menu = restaurant.menu {
                let categories = Dictionary(grouping: menu) { $0.category }
                let sortedCategories = sortCategories(Array(categories.keys), for: restaurant)
                
                ForEach(sortedCategories, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(category)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1A2332"))
                            .padding(.horizontal, 16)
                        
                        ForEach(categories[category] ?? []) { item in
                            FoodItemCard(item: item) {
                                selectedFoodItem = item.toFoodItem()
                                // Show FoodLoggerView for portion control
                                showFoodLogger = true
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            } else {
                Text("No menu available")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7280"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Category Sorting
    
    /// Sorts menu categories with beverages always at the end, using restaurant-specific ordering
    private func sortCategories(_ categories: [String], for restaurant: Restaurant) -> [String] {
        // Identify beverage categories (case-insensitive)
        let beverageKeywords = ["beverage", "drink", "coffee", "mccafé"]
        let isBeverage: (String) -> Bool = { category in
            let lowercased = category.lowercased()
            return beverageKeywords.contains { keyword in
                lowercased.contains(keyword)
            }
        }
        
        // Separate beverages from food categories
        let foodCategories = categories.filter { !isBeverage($0) }
        let beverages = categories.filter { isBeverage($0) }
        
        // Get restaurant-specific sort order
        let sortedFoodCategories = sortFoodCategories(foodCategories, for: restaurant)
        
        // Always put beverages at the end
        return sortedFoodCategories + beverages.sorted()
    }
    
    /// Sorts food categories based on restaurant-specific ordering
    private func sortFoodCategories(_ categories: [String], for restaurant: Restaurant) -> [String] {
        // Define restaurant-specific category orders
        let order: [String]
        
        switch restaurant.id {
        case "sweetgreen":
            // Bowls > Protein Plates > Salads > Sides > Beverages
            order = ["Bowls", "Protein Plates", "Salads", "Sides"]
            
        case "chick-fil-a":
            // Entrees > Salads > Breakfast > Wraps > Sides > Treats > Beverages
            order = ["Entrees", "Salads", "Breakfast", "Wraps", "Sides", "Treats"]
            
        case "dominos":
            // Pizzas > Sandwiches > Sides > Desserts > Beverages
            order = ["Pizzas", "Sandwiches", "Sides", "Desserts"]
            
        case "pizzahut":
            // Pizzas > Melts > Wings > Sides > Desserts > Beverages
            order = ["Pizzas", "Melts", "Wings", "Sides", "Desserts"]
            
        case "softies":
            // Burgers > Sandwiches > Salads > Sides > Sauces > Beverages
            order = ["Burgers", "Sandwiches", "Salads", "Sides", "Sauces"]
            
        case "panda-express":
            // All food categories > Sides > Desserts > Beverages
            // Order: Chicken, Chicken Breast, Beef, Seafood, Vegetables, Specialty, Appetizers, Soup, Sides, Desserts
            order = ["Chicken", "Chicken Breast", "Beef", "Seafood", "Vegetables", "Specialty", "Appetizers", "Soup", "Sides", "Desserts"]
            
        case "subway":
            // Cheesesteaks > Deli Heroes > Italians > Chicken > Clubs > Wraps > Beverages
            order = ["Cheesesteaks", "Deli Heroes", "Italians", "Chicken", "Clubs", "Wraps"]
            
        default:
            // For other restaurants: all food categories first, then Sides, then Beverages
            order = []
        }
        
        // If we have a specific order for this restaurant
        if !order.isEmpty {
            // Sort according to restaurant-specific order
            var sorted: [String] = []
            var remaining = Set(categories)
            
            // Add categories in the specified order
            for categoryName in order {
                if remaining.contains(categoryName) {
                    sorted.append(categoryName)
                    remaining.remove(categoryName)
                }
            }
            
            // Add any remaining categories alphabetically (but before beverages)
            sorted.append(contentsOf: remaining.sorted())
            
            return sorted
        } else {
            // Default: sort all food categories alphabetically, but put "Sides" before beverages
            let sides = categories.filter { $0 == "Sides" }
            let otherFood = categories.filter { $0 != "Sides" }
            return otherFood.sorted() + sides
        }
    }
    
    private var buildYourOwnView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let ingredients = restaurant.ingredients {
                // Show appropriate builder based on restaurant
                if restaurant.id == "chipotle" {
                    ChipotleBuilder(
                        ingredients: ingredients,
                        onLogMeal: { foodItem in
                            selectedFoodItem = foodItem
                            showFoodLogger = true
                        }
                    )
                } else if restaurant.id == "subway" {
                    SubwayBuilder(
                        ingredients: ingredients,
                        onLogMeal: { foodItem in
                            selectedFoodItem = foodItem
                            showFoodLogger = true
                        }
                    )
                } else if restaurant.id == "cava" {
                    MediterraneanBuilder(
                        ingredients: ingredients,
                        onLogMeal: { foodItem in
                            selectedFoodItem = foodItem
                            showFoodLogger = true
                        }
                    )
                } else {
                    GenericBuilder(
                        restaurantId: restaurant.id,
                        ingredients: ingredients,
                        onLogMeal: { foodItem in
                            selectedFoodItem = foodItem
                            showFoodLogger = true
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? ForkiTheme.borderPrimary : Color(hex: "#6B7280"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? ForkiTheme.borderPrimary.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? ForkiTheme.borderPrimary.opacity(0.3) : Color.clear, lineWidth: 2)
                )
        }
    }
}

