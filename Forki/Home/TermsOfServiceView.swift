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
                        Button { onDismiss() } label: {
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
                        Color.clear.frame(width: 24, height: 24)
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                
                // CONTENT
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // CARD 1 — Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Last Updated: November 2025")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textSecondary)
                            
                            Text("""
By using Forki (the “App”), you agree to be bound by these Terms of Service and all applicable laws and regulations. If you do not agree with these terms, you may not use Forki.

The materials and content within Forki are protected by applicable copyright and trademark law.
""")
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
                            
                            Text("""
By accessing or using Forki, you agree to comply with and be bound by these Terms. If you do not agree, please discontinue use of the App.
""")
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
                            
                            Text("""
Forki grants you a limited, revocable, non-transferable license to use the App for personal, non-commercial purposes.

Under this license, you may not:
● Modify or copy any materials or content in the App.
● Use the App for commercial purposes or public display.
● Attempt to reverse engineer, decompile, or extract source code.
● Remove copyright or proprietary notices.
● Transfer your access or “mirror” the App elsewhere.

This license automatically terminates if you violate these terms. Upon termination, you must discontinue use of the App and delete any locally stored materials.
""")
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
                            
                            Text("""
Forki is provided on an “as is” and “as available” basis. We make no warranties, expressed or implied, including without limitation:

● Warranties of merchantability
● Fitness for a particular purpose
● Non-infringement

We do not guarantee the accuracy or reliability of nutrition estimates, insights, or any data provided by the App.

Forki is a general wellness tool and does not provide medical advice.
""")
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
                            
                            Text("""
In no event shall Forki or its suppliers be liable for any damages arising from the use or inability to use the App, including:

● Loss of data
● Loss of profits
● Device issues
● Business interruption

Even if Forki has been advised of the possibility of such damage.

Some jurisdictions do not allow certain liability limitations, so these restrictions may not apply to you.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 6 — Section 5: Revisions & Updates
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Revisions and Updates")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
The materials and features within Forki may include technical, typographical, or other errors. We do not guarantee that all information is accurate or current.

Forki may make changes, updates, or improvements at any time without notice.
""")
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
                            
                            Text("""
Forki may include links to third-party services (such as APIs used for food recognition).

We are not responsible for the content or practices of any external site or service.

Use of linked services is at your own risk.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 8 — Section 7: Modifications to Terms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Modifications to These Terms")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
Forki may revise these Terms of Service at any time without notice.

By continuing to use the App, you agree to the most current version.
""")
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
                            
                            Text("""
These Terms are governed by the laws of the State of California, without regard to its conflict-of-law rules.
""")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(panel)
                        .padding(.horizontal, 24)
                        
                        
                        // CARD 10 — Contact Us
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact Us")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                            
                            Text("""
For questions about these Terms, contact us at:
📧 janicechung@usc.edu
""")
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
    
    // Same panel style as Privacy Policy
    private var panel: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(ForkiTheme.surface.opacity(0.9))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ForkiTheme.borderPrimary.opacity(0.4), lineWidth: 2)
            )
    }
}

