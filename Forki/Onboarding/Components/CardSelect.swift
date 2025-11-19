//
//  CardSelect.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import SwiftUI

struct CardSelect: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(ForkiTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? ForkiTheme.surface.opacity(0.9) : ForkiTheme.surface.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3), lineWidth: isSelected ? 3 : 2)
            )
            .shadow(color: ForkiTheme.borderPrimary.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 16) {
        CardSelect(title: "Build healthier eating habits", subtitle: "For students who want to improve their nutrition", isSelected: true) {}
        CardSelect(title: "Lose weight", isSelected: false) {}
    }
    .padding()
    .background(ForkiTheme.backgroundGradient)
}

