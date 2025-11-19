//
//  TermsOfServiceView.swift
//  Forki
//
//  Created by Janice C on 9/23/25.
//

import SwiftUI

struct TermsOfServiceView: View {
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
                    
                    Text("Terms of Service")
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
                            
                            Text("Forki (\"we,\" \"us,\" or \"our\") provides a mobile application designed to help users build healthier eating habits through simple meal logging, personalized guidance, and a companion virtual pet. By using Forki, you agree to the terms described in this document.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 2 — Section 1: Acceptance of Terms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Acceptance of Terms")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("By accessing or using Forki, you agree to comply with and be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with these Terms, you may not use the App.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 3 — Section 2: Use License
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. Use License")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki grants you a limited, revocable, non-transferable license to use the App for personal, non-commercial purposes.\n\nUnder this license, you may NOT:\n\n• Modify or copy any materials in the App\n• Use the App for commercial or public display purposes\n• Attempt to reverse engineer or decompile the App\n• Remove copyright or proprietary notices\n• Transfer your access or \"mirror\" the App elsewhere\n\nThis license terminates automatically if you violate these restrictions. Upon termination, you must discontinue use and delete any stored materials.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 4 — Section 3: Disclaimer
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. Disclaimer")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki is provided \"as is\" and \"as available.\"\n\nForki makes no warranties, expressed or implied, including:\n\n• Non-infringement\n• Fitness for a particular purpose\n• Accuracy or reliability of nutrition estimates\n\nForki is a general wellness tool and does NOT provide medical advice.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 5 — Section 4: Limitations of Liability
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. Limitations of Liability")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("In no event shall Forki or its suppliers be liable for any damages arising from the use or inability to use the App, including:\n\n• Loss of data\n• Loss of profits\n• Device issues\n• Business interruption\n\nEven if Forki has been notified of the possibility of such damage.\n\nSome jurisdictions do not allow certain limitations, so these restrictions may not apply to you.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 6 — Section 5: Revisions and Updates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Revisions and Updates")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki may include technical, typographical, or content errors. We do not guarantee that all information is accurate or current.\n\nForki may update, remove, or adjust features at any time without notice.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 7 — Section 6: External Links
                        VStack(alignment: .leading, spacing: 12) {
                            Text("6. External Links")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki may contain links to third-party services (including food-recognition APIs).\n\nForki is not responsible for the content or practices of external sites.\n\nUse of linked third-party services is at your own risk.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 8 — Section 7: Modifications to Terms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Modifications to Terms")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("Forki may revise these Terms at any time without notice. By continuing to use the App, you agree to the latest version of the Terms of Service.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 9 — Section 8: Governing Law
                        VStack(alignment: .leading, spacing: 12) {
                            Text("8. Governing Law")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("These Terms are governed by the laws of the State of California, without regard to conflict-of-law principles.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        // CARD 10 — Section 9: Contact Us
                        VStack(alignment: .leading, spacing: 12) {
                            Text("9. Contact Us")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("For questions regarding these Terms of Service, contact us at:\njanicechung@usc.edu")
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

