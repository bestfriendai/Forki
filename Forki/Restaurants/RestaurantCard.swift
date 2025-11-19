//
//  RestaurantCard.swift
//  Forki
//
//  Restaurant card component for listing
//

import SwiftUI
import UIKit

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Restaurant logo
                Group {
                    if let uiImage = UIImage(named: restaurant.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                }
                .frame(width: 64, height: 64)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ForkiTheme.borderPrimary.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: ForkiTheme.borderPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Restaurant info
                VStack(alignment: .leading, spacing: 8) {
                    Text(restaurant.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1A2332"))
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ForkiTheme.legendCarbs)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                        
                        // Distance
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ForkiTheme.actionLogFood)
                            Text(String(format: "%.1f mi", restaurant.distance))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                    }
                    
                    // Cuisine badge
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
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ForkiTheme.borderPrimary)
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
        .buttonStyle(PlainButtonStyle())
    }
}

