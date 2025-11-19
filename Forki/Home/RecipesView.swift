//
//  RecipesView.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI

struct RecipesView: View {
    @Binding var currentScreen: Int
    @Binding var loggedFoods: [LoggedFood]
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery: String = ""
    @State private var selectedFilter: RecipeCategory? = nil
    @State private var selectedTag: RecipeTag? = nil
    @State private var selectedRecipe: Recipe? = nil
    @State private var selectedTab: Int = 0 // 0 = recommended, 1 = all recipes
    
    // Navigation state
    @State private var showHome = false
    @State private var showStats = false
    @State private var showAICamera = false
    @State private var showProfile = false
    var onDismiss: (() -> Void)? = nil  // Callback to dismiss when shown via overlay
    var onHome: (() -> Void)? = nil
    var onExplore: (() -> Void)? = nil
    var onCamera: (() -> Void)? = nil
    var onProgress: (() -> Void)? = nil
    var onProfile: (() -> Void)? = nil
    
    // Callback for triggering feeding animations in parent view
    var onFoodLogged: ((LoggedFood) -> Void)? = nil
    
    // User data for navigation
    let userData: UserData?
    
    // Nutrition state for ProgressScreen
    @State private var nutrition = NutritionState()
    
    // MARK: - Computed Properties
    private var personaType: Int {
        nutrition.personaID > 0 ? nutrition.personaID : UserDefaults.standard.integer(forKey: "hp_personaID")
    }
    
    // MARK: - Unified Filtering
    private func applyFilters(to recipes: [Recipe]) -> [Recipe] {
        var results = recipes
        
        // Tag filtering (category)
        if let selected = selectedFilter {
            results = results.filter { recipe in
                recipe.tags.contains(selected.rawValue)
            }
        }
        
        // Search
        if !searchQuery.isEmpty {
            results = results.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchQuery) ||
                recipe.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) })
            }
        }
        
        return results
    }
    
    private var recommendedRecipes: [Recipe] {
        applyFilters(to: PersonaRecipeService.shared.recipesForPersona(personaType).map { $0.toRecipe() })
    }
    
    private var weeklyPlanRecipes: [Recipe] {
        applyFilters(to: PersonaRecipeService.shared.weeklyPlan(for: personaType).map { $0.toRecipe() })
    }
    
    private var allPersonaRecipes: [Recipe] {
        applyFilters(to: PersonaRecipeService.shared.allRecipes.map { $0.toRecipe() })
    }
    
    init(currentScreen: Binding<Int>, loggedFoods: Binding<[LoggedFood]>, onFoodLogged: ((LoggedFood) -> Void)? = nil, userData: UserData? = nil, onDismiss: (() -> Void)? = nil, onHome: (() -> Void)? = nil, onExplore: (() -> Void)? = nil, onCamera: (() -> Void)? = nil, onProgress: (() -> Void)? = nil, onProfile: (() -> Void)? = nil) {
        self._currentScreen = currentScreen
        self._loggedFoods = loggedFoods
        self.onFoodLogged = onFoodLogged
        self.userData = userData
        self.onDismiss = onDismiss
        self.onHome = onHome
        self.onExplore = onExplore
        self.onCamera = onCamera
        self.onProgress = onProgress
        self.onProfile = onProfile
    }
    
    var filteredRecipes: [Recipe] {
        if selectedTab == 0 && searchQuery.isEmpty {
            return recommendedRecipes
        }
        return allPersonaRecipes
    }
    
    // MARK: - Logging Functions
    private func logMeal(_ recipe: Recipe, portion: Double = 1.0) {
        let foodItem = recipe.toFoodItem()
        let adjustedFoodItem = FoodItem(
            id: foodItem.id,
            name: foodItem.name,
            calories: Int(Double(foodItem.calories) * portion),
            protein: foodItem.protein * portion,
            carbs: foodItem.carbs * portion,
            fats: foodItem.fats * portion,
            category: foodItem.category,
            usdaFood: nil
        )
        let loggedFood = LoggedFood(food: adjustedFoodItem, portion: portion, timestamp: Date())
        
        // Trigger callback to add to nutrition state and trigger animation
        // This will call nutrition.add() which updates calories, macros, avatar state, and battery
        onFoodLogged?(loggedFood)
        
        // Don't auto-dismiss - let user see the animation on HomeScreen and close sheet manually
        // If shown via overlay, dismiss back to home
        if let onDismiss = onDismiss {
            onDismiss()
        } else if currentScreen < 6 {
            withAnimation(.easeInOut) {
                currentScreen = 6 // Home Screen
            }
        }
        // If currentScreen >= 6 and presented as sheet, don't auto-dismiss so user can see animation
    }
    
    private func handleRecipeLogging(_ recipe: Recipe, portion: Double) {
        logMeal(recipe, portion: portion)
    }
    
    // MARK: - View Components
    private var mainContent: some View {
        NavigationView {
            ZStack {
                ForkiTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        searchBarSection
                        tabControlSection
                        filterButtonsSection
                        recipesContentSection
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button {
                if let onDismiss = onDismiss {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onDismiss()
                    }
                } else if currentScreen >= 6 {
                    dismiss()
                } else {
                    withAnimation { currentScreen -= 1 }
                }
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(ForkiTheme.textPrimary)
            }
            
            Spacer()
            
            Text("Healthy Recipes")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            ZStack(alignment: .leading) {
                if searchQuery.isEmpty {
                    Text("Search recipes...")
                        .foregroundColor(.white.opacity(0.6))
                }
                TextField("", text: $searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .tint(.white)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ForkiTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ForkiTheme.borderPrimary.opacity(0.5), lineWidth: 2)
                )
        )
        .padding(.horizontal)
        .onChange(of: searchQuery) { newValue in
            // When user starts searching, switch to All Recipes tab
            if !newValue.isEmpty && selectedTab == 0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
        }
    }
    
    private var tabControlSection: some View {
        HStack(spacing: 0) {
            tabButton(title: "For You", isSelected: selectedTab == 0) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            tabButton(title: "All Recipes", isSelected: selectedTab == 1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ForkiTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary.opacity(0.5), lineWidth: 2)
                )
        )
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private func tabButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : ForkiTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(tabButtonBackground(isSelected: isSelected))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func tabButtonBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(ForkiTheme.navSelection.opacity(0.3))
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var filterButtonsSection: some View {
        if selectedTab == 1 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterButton(
                        title: "All",
                        icon: "square.grid.2x2.fill",
                        isSelected: selectedFilter == nil,
                        action: { selectedFilter = nil }
                    )
                    
                    ForEach(RecipeCategory.allCases, id: \.self) { category in
                        FilterButton(
                            title: category.displayName,
                            icon: category.iconName,
                            isSelected: selectedFilter == category,
                            action: { selectedFilter = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var recipesContentSection: some View {
        // When searching, always show All Recipes content (even if on For You tab)
        if !searchQuery.isEmpty {
            allRecipesContent
        } else if selectedTab == 0 {
            forYouContent
        } else {
            allRecipesContent
        }
    }
    
    private var forYouContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            weeklyPlanSection
        }
    }
    
    private var weeklyPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Weekly Meal Plan")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
                .padding(.horizontal)
            
            ForEach(Array(weeklyPlanRecipes.enumerated()), id: \.offset) { index, recipe in
                RecipeCard(recipe: recipe, onLogMeal: { logMeal(recipe) }, onTap: { selectedRecipe = recipe }, titleFontSize: 18, buttonTopPadding: 8)
                    .padding(.horizontal)
            }
        }
    }
    
    private var allRecipesContent: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], alignment: .center, spacing: 12) {
            ForEach(filteredRecipes) { recipe in
                RecipeCard(recipe: recipe, onLogMeal: { logMeal(recipe) }) {
                    selectedRecipe = recipe
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var homeOverlay: some View {
        if showHome {
            HomeScreen(loggedFoods: loggedFoods)
                .transition(.smoothTransition)
                .zIndex(2)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var statsOverlay: some View {
        if showStats, let userData = userData {
            ProgressScreen(userData: userData, nutrition: nutrition, onDismiss: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showStats = false
                }
            })
            .transition(.smoothTransition)
            .zIndex(2)
        } else {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe, currentScreen: $currentScreen, loggedFoods: $loggedFoods, onLogMeal: { portion in handleRecipeLogging(recipe, portion: portion) })
        }
        .overlay {
            homeOverlay
        }
        .overlay {
            statsOverlay
        }
        .sheet(isPresented: $showAICamera) {
            Text("AI Camera functionality coming soon")
        }
        .sheet(isPresented: $showProfile) {
            Text("Profile functionality coming soon")
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isSelected ? ForkiTheme.highlightText : ForkiTheme.textSecondary)
                        .shadow(color: ForkiTheme.highlightText.opacity(isSelected ? 0.7 : 0.0), radius: 6, x: 0, y: 0)
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? ForkiTheme.textPrimary : ForkiTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? ForkiTheme.panelBackground : ForkiTheme.surface.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(ForkiTheme.borderPrimary.opacity(isSelected ? 0.6 : 0.25), lineWidth: 1.5)
                    )
            )
            .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.18 : 0), radius: 6, x: 0, y: 3)
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: Recipe
    let onLogMeal: () -> Void
    let onTap: () -> Void
    var titleFontSize: CGFloat = 16 // Default size for All Recipes, can be overridden for For You
    var buttonTopPadding: CGFloat = 8 // Default padding above button for All Recipes, can be overridden for For You
    
    private var imageOverlay: some View {
        Group {
            if UIImage(named: recipe.imageName) == nil {
                Rectangle()
                    .fill(ForkiTheme.surface.opacity(0.5))
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(ForkiTheme.textSecondary)
                            Text(recipe.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    )
            }
        }
    }
    
    private var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(recipe.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(ForkiTheme.borderPrimary.opacity(0.2))
                        )
                }
                
                // Prep time badge
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(recipe.prepTime)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(ForkiTheme.textPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ForkiTheme.borderPrimary.opacity(0.2))
                )
                
                // Calories badge
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.system(size: 10))
                    Text("\(recipe.calories) cal")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(ForkiTheme.textPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(ForkiTheme.borderPrimary.opacity(0.2))
                )
            }
            .padding(.horizontal, 0)
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Recipe Image
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .overlay(imageOverlay)
                
                // Recipe Content
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.title)
                        .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    // Tags
                    tagsView
                    
                    // Nutrition Info
                    Text("Nutrition: \(Int(recipe.protein))g protein, \(Int(recipe.fat))g fat, \(Int(recipe.carbs))g carbs")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(ForkiTheme.textSecondary)
                        .lineLimit(1)
                    
                    // Log Button - Same style as FoodDetailView Log Food button
                    Button {
                        onLogMeal()
                    } label: {
                        Text("Log Food")
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
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, buttonTopPadding)
                    .padding(.bottom, 0)
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(ForkiTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary.opacity(0.5), lineWidth: 2)
                )
        )
        .shadow(color: ForkiTheme.borderPrimary.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @Binding var currentScreen: Int
    @Binding var loggedFoods: [LoggedFood]
    let onLogMeal: (Double) -> Void
    
    @State private var portion: Double = 1.0
    
    private var imageOverlay: some View {
        Group {
            if UIImage(named: recipe.imageName) == nil {
                Rectangle()
                    .fill(ForkiTheme.surface.opacity(0.5))
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(ForkiTheme.textSecondary)
                            Text(recipe.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient - Forki Theme
                ForkiTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Recipe Image
                        Image(recipe.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .clipped()
                            .overlay(imageOverlay)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // Title and Description
                            VStack(alignment: .leading, spacing: 12) {
                                Text(recipe.title)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                
                                Text(recipe.description)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(ForkiTheme.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 20) // Align with Nutrition Card
                            
                            // Nutrition Facts
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Nutrition (per portion)")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                
                                HStack(spacing: 16) {
                                    NutritionFact(label: "Calories", value: "\(Int(Double(recipe.calories) * portion))", isPrimary: true)
                                    NutritionFact(label: "Protein", value: "\(String(format: "%.1f", recipe.protein * portion))g")
                                }
                                
                                HStack(spacing: 16) {
                                    NutritionFact(label: "Carbs", value: "\(String(format: "%.1f", recipe.carbs * portion))g")
                                    NutritionFact(label: "Fats", value: "\(String(format: "%.1f", recipe.fat * portion))g")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ForkiTheme.panelBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(ForkiTheme.borderPrimary.opacity(0.5), lineWidth: 2)
                                    )
                            )
                            .padding(.horizontal, 20)
                            
                            // Portion Size - Same as FoodDetailView
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Portion Size")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(ForkiTheme.textPrimary)
                                    Spacer()
                                    Text("\(Int(portion * 100))%")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(ForkiTheme.highlightText)
                                }
                                .padding(.horizontal, 20)
                                Slider(value: $portion, in: 0.1...3.0, step: 0.1)
                                    .tint(ForkiTheme.highlightText)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 8)
                            
                            // Ingredients - with reduced spacing
                            VStack(alignment: .leading, spacing: 16) {
                                Text("🥘 Ingredients")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                                        HStack(alignment: .top, spacing: 12) {
                                            Circle()
                                                .fill(ForkiTheme.borderPrimary.opacity(0.6))
                                                .frame(width: 6, height: 6)
                                                .padding(.top, 6)
                                            Text(ingredient)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(ForkiTheme.textPrimary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 27) // Reduced from 30 to 27
                            
                            // Instructions - with reduced spacing
                            VStack(alignment: .leading, spacing: 16) {
                                Text("👨‍🍳 Instructions")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(ForkiTheme.textPrimary)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                                        HStack(alignment: .top, spacing: 12) {
                                            Text("\(index + 1)")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                                .frame(width: 28, height: 28)
                                                .background(
                                                    Circle()
                                                        .fill(ForkiTheme.borderPrimary)
                                                )
                                            Text(instruction)
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(ForkiTheme.textPrimary)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 27) // Reduced from 30 to 27
                            
                            // Log Food Button - Same styling from FoodDetailView
                            Button {
                                onLogMeal(portion)
                            } label: {
                                Text("Log Food")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
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
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary, lineWidth: 4)
                        .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ForkiTheme.navBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recipe Details")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ForkiTheme.navHighlight)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }
}

// MARK: - Nutrition Fact
struct NutritionFact: View {
    let label: String
    let value: String
    let isPrimary: Bool
    
    init(label: String, value: String, isPrimary: Bool = false) {
        self.label = label
        self.value = value
        self.isPrimary = isPrimary
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: isPrimary ? 24 : 20, weight: .bold, design: .rounded))
                .foregroundColor(isPrimary ? ForkiTheme.highlightText : ForkiTheme.textPrimary)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(ForkiTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let userData: UserData = {
        let data = UserData()
        data.name = "Preview User"
        data.email = "preview@example.com"
        return data
    }()
    
    return RecipesView(
        currentScreen: .constant(7), 
        loggedFoods: .constant([]),
        onFoodLogged: { _ in },
        userData: userData
    )
    .environmentObject(userData)
    .environmentObject(NutritionState(goal: 2000))
}

