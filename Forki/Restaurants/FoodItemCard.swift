//
//  FoodItemCard.swift
//  Forki
//
//  Food item card component for restaurant menus
//

import SwiftUI

struct FoodItemCard: View {
    let item: RestaurantFoodItem
    let onLog: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Optional image
            if let imageName = item.image {
                AsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(ForkiTheme.borderPrimary.opacity(0.1))
                }
                .frame(height: 120)
                .clipped()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#1A2332"))
                            .lineLimit(2)
                        
                        Text(item.category)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#6B7280"))
                    }
                    
                    Spacer()
                    
                    // Log button
                    Button(action: onLog) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#8DD4D1"), Color(hex: "#6FB8B5")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color(hex: "#7AB8B5"), lineWidth: 4)
                                    )
                            )
                            .shadow(color: ForkiTheme.actionShadow, radius: 10, x: 0, y: 6)
                    }
                }
                
                // Nutrition grid
                HStack(spacing: 8) {
                    NutritionBadge(label: "\(item.calories)", unit: "cal", isPrimary: true)
                    NutritionBadge(label: "\(Int(item.protein))", unit: "P")
                    NutritionBadge(label: "\(Int(item.carbs))", unit: "C")
                    NutritionBadge(label: "\(Int(item.fat))", unit: "F")
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ForkiTheme.borderPrimary.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: ForkiTheme.borderPrimary.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

private struct NutritionBadge: View {
    let label: String
    let unit: String
    var isPrimary: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: isPrimary ? 18 : 14, weight: .bold, design: .rounded))
                .foregroundColor(isPrimary ? ForkiTheme.borderPrimary : Color(hex: "#1A2332"))
            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(hex: "#6B7280"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isPrimary ? ForkiTheme.borderPrimary.opacity(0.1) : ForkiTheme.borderPrimary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isPrimary ? ForkiTheme.borderPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

