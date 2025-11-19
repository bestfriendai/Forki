//
//  PrivacyPolicyView.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    if let onDismiss = onDismiss {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                    } else {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text("Privacy Policy")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                    
                    Spacer()
                    
                    if onDismiss != nil {
                        Color.clear
                            .frame(width: 24, height: 24)
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // CARD 1 — Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last Updated: November 2025")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                            
                            Text("Forki is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect personal information. By using the Forki mobile application, you agree to the practices described below.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 2 — Section 1: Information We Collect
                        VStack(alignment: .leading, spacing: 16) {
                            Text("1. Information We Collect")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Information You Provide")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("We may collect the following information directly from you to personalize your experience and generate your Wellness Snapshot:\n\n• Name (used to personalize the app experience)\n• Age, gender, height, and weight (used to calculate BMI and provide recommendations)\n• Eating habits and lifestyle inputs (used to determine your persona)\n• Meal logs, notes, and manually entered foods (used to track progress)\n\nForki collects only the information necessary to support app functionality.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Camera Access (AI Food Logging)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .padding(.top, 8)
                            
                            Text("Forki requests camera access only so you can take photos of meals for calorie and nutrient estimation.\n\n• The camera is used only when you take a photo.\n• Images are analyzed and not stored or reused unless you save them.\n• Forki never accesses the camera in the background.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Information We Do Not Collect")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .padding(.top, 8)
                            
                            Text("Forki does not collect:\n\n• GPS or device location\n• Contacts or messages\n• Photo library (unless you choose an image)\n• HealthKit data\n• Payment information\n• Biometric identifiers")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 3 — Section 2: Use of Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. Use of Information")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("We use your information to:\n\n• Generate your Wellness Snapshot\n• Track calories, meals, and progress\n• Support habit-building features like streaks\n• Personalize Forki's animations and responses\n• Improve app functionality\n\nInformation is used solely for these purposes.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 4 — Section 3: Data Retention
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. Data Retention")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("We retain your information only as long as needed for app features. You may delete your data manually or by uninstalling the app.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 5 — Section 4: Data Security
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. Data Security")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("We use reasonable security measures to protect your data from unauthorized access, loss, or misuse. However, no system is completely secure.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 6 — Section 5: Third-Party Services
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Third-Party Services")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki may use trusted third-party services to analyze meal images. They may not store images or use them for advertising or unrelated AI training.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 7 — Section 6: Children's Privacy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("6. Children's Privacy")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki is intended for users 13 and older. We do not knowingly collect information from children under 13.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 8 — Section 7: Contact Us
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Contact Us")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("If you have questions about this Privacy Policy, contact us at:\njanicechung@usc.edu")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var panel: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(ForkiTheme.surface.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
            )
    }
}
