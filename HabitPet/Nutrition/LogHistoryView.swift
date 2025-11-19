//
//  LogHistoryView.swift
//  Forki
//

import SwiftUI

// Helper struct for sheet item binding
private struct EditingFood: Identifiable {
    let id: UUID
    let editId: UUID
    let food: FoodItem
    
    init(editId: UUID, food: FoodItem) {
        self.id = editId
        self.editId = editId
        self.food = food
    }
}

struct LogHistoryView: View {
    let loggedMeals: [LoggedFood]
    let onDelete: (UUID) -> Void
    let onSelect: (LoggedFood) -> Void
    let onClose: () -> Void
    let onUpdate: ((UUID, LoggedFood) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var editingFoodItem: EditingFood?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
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
                
                ScrollView {
                    if loggedMeals.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 64))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            Text("No Log History")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1A2332"))
                            Text("Foods you log will appear here for quick access")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#6B7280"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 80)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(sortedMeals) { loggedFood in
                                LogHistoryRow(loggedFood: loggedFood) {
                                    onDelete(loggedFood.id)
                                } onEdit: {
                                    // Pass the full food item with all saved data (name, calories, macros)
                                    editingFoodItem = EditingFood(editId: loggedFood.id, food: loggedFood.food)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                .overlay(
                    // Purple outline around the container
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .stroke(ForkiTheme.borderPrimary, lineWidth: 4)
                        .ignoresSafeArea()
                )
            }
            .navigationTitle("Log History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white.opacity(0.95), for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onClose()
                        dismiss()
                    }
                    .foregroundColor(ForkiTheme.borderPrimary)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .sheet(item: $editingFoodItem) { editing in
                FoodLoggerView(
                    prefill: editing.food,
                    loggedMeals: loggedMeals,
                    onSave: { loggedFood in
                        // In edit mode, this should call onUpdate
                        if let onUpdate = onUpdate {
                            onUpdate(editing.editId, loggedFood)
                        }
                        editingFoodItem = nil
                    },
                    onClose: {
                        editingFoodItem = nil
                    },
                    onDeleteFromHistory: { _ in }, // Not used when editing
                    editId: editing.editId,
                    onUpdate: { id, loggedFood in
                        onUpdate?(id, loggedFood)
                        editingFoodItem = nil
                    }
                )
                .presentationDetents([.fraction(0.6), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var sortedMeals: [LoggedFood] {
        loggedMeals.sorted { $0.timestamp > $1.timestamp }
    }
}

struct LogHistoryRow: View {
    let loggedFood: LoggedFood
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(loggedFood.food.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1A2332"))
                    .lineLimit(2)
                
                Text(formatDate(loggedFood.timestamp))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#6B7280"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(loggedFood.food.calories) cal")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(ForkiTheme.borderPrimary)
                
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(ForkiTheme.actionLogFood)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ForkiTheme.borderPrimary.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(ForkiTheme.borderPrimary.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#EF4444"))
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "#EF4444").opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "#EF4444").opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                    }
                }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    LogHistoryView(
        loggedMeals: [
            LoggedFood(
                food: FoodItem(id: 1, name: "Grilled Chicken Breast", calories: 165, protein: 31, carbs: 0, fats: 3.6, category: "Meat"),
                portion: 1.0,
                timestamp: Date()
            ),
            LoggedFood(
                food: FoodItem(id: 2, name: "Rice Bowl with Mixed Vegetables", calories: 250, protein: 8, carbs: 45, fats: 5, category: "Grains"),
                portion: 1.0,
                timestamp: Date().addingTimeInterval(-3600)
            )
        ],
        onDelete: { _ in },
        onSelect: { _ in },
        onClose: {},
        onUpdate: { _, _ in }
    )
}

