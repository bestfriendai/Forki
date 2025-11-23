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
                        Button { onDismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                    } else { Spacer() }
                    
                    Spacer()
                    
                    Text("Privacy Policy")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(ForkiTheme.textPrimary)
                    
                    Spacer()
                    
                    if onDismiss != nil {
                        Color.clear.frame(width: 24, height: 24)
                    } else { Spacer() }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                
                // CONTENT
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // CARD 1 — INTRODUCTION
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Last Updated: November 2025")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                            
                            Text("""
Your privacy is important to us. This Privacy Policy explains how Forki (“we,” “us,” or “our”) collects, uses, and protects personal information. By using the Forki mobile application, you agree to the practices described below.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 2 — SECTION 1: INFORMATION WE COLLECT
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("1. Information We Collect")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We collect only the information necessary to provide the core features of Forki and improve the user experience. Before or at the time information is collected, we will identify the purposes for which it is being used.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            // Information You Provide
                            Text("Information You Provide")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
● Name (used to personalize the in-app experience)
● Age, gender, height, and weight (used to calculate BMI and create your Wellness Snapshot)
● Eating habits and lifestyle inputs (used to determine your persona and recommendations)
● Manually entered or logged meals
● Notes related to food entries

This information is used only to support functionality within the app.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            // Camera Access
                            Text("Camera Access")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
Forki requests camera access solely to allow you to capture photos of meals for calorie and nutrient estimation.

● Camera access is used only when you take a photo.
● Images are processed for analysis and are not stored or reused unless you explicitly save them.
● Forki does not access your camera in the background.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            
                            // Not Collected
                            Text("Information We Do Not Collect")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
Forki does not collect or access:

● Device location or GPS
● Contacts, messages, or personal files
● Photos or your photo library
● Payment or financial information
● Biometric identifiers
● HealthKit data
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 3 — USE OF INFORMATION
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("2. Use of Information")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We use the information you provide for the following purposes:

● Generating your Wellness Snapshot and recommendations
● Tracking meals, calories, and macronutrients
● Supporting habit-building features such as streaks and consistency tracking
● Powering the companion pet’s responses
● Improving the overall functionality of the app

Information will be used only for these purposes unless additional consent is obtained or required by law.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 4 — DATA RETENTION
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("3. Data Retention")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We retain personal information only as long as necessary to fulfill the purposes for which it was collected.

You may clear your information manually or delete all data by uninstalling the app.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 5 — DATA PROTECTION
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("4. Data Protection")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We use reasonable security safeguards to protect personal information against loss, theft, unauthorized access, disclosure, copying, use, or modification.

While we take appropriate precautions, no method of electronic storage or transmission is completely secure.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 6 — THIRD-PARTY SERVICES
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("5. Third-Party Services")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
Forki may use third-party services to process meal images for calorie estimation. These services are required to:

● Use the images only for processing your request
● Not store images
● Not use the images for advertising or unrelated model training

We do not sell or share your personal information with any third parties.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 7 — CHILDREN'S PRIVACY
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("6. Children's Privacy")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
Forki is intended for individuals aged 13 and older.

We do not knowingly collect information from children under 13.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 8 — TRANSPARENCY
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("7. Transparency")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We will make information about our privacy practices available to users upon request.

You may contact us at any time with questions regarding how your information is collected or used.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 9 — POLICY CHANGES
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("8. Policy Changes")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
We may update this Privacy Policy as needed.

Revisions will be posted within the app. By continuing to use Forki, you agree to the current version of the policy.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 10 — CONTACT INFORMATION
                        VStack(alignment: .leading, spacing: 16) {
                            
                            Text("9. Contact Information")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
For questions or concerns about this Privacy Policy, you may contact us at:
📧 janicechung@usc.edu
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                        }
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
    
    // Same panel styling as Terms of Service
    private var panel: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(ForkiTheme.surface.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
            )
    }
}

