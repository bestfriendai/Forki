//
//  SignInScreen.swift
//  Forki
//
//  Created by Janice C on 9/16/25.
//

import SwiftUI

struct SignInScreen: View {
    @Binding var currentScreen: Int
    @ObservedObject var userData: UserData
    var onSignInComplete: (() -> Void)? = nil
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showUsernameError: Bool = false
    @State private var showPasswordError: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, password
    }
    
    var body: some View {
        ZStack {
            // Background gradient (same as Home Screen)
            ForkiTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                            .padding(.top, -5)
                        formSection
                            .forkiPanel()
                        footerSection
                    }
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 24)
                    .padding(.top, 80)
                    .padding(.bottom, 36)
                }
                
                // Bottom buttons
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut) { currentScreen = 1 }
                        } label: {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(ForkiTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(ForkiTheme.surface)
                                .cornerRadius(12)
                                .shadow(color: ForkiTheme.borderPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        Button {
                            validateForm()
                        } label: {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [ForkiTheme.actionLogFood, ForkiTheme.actionLogFoodEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: ForkiTheme.borderPrimary.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    
                    // Separate text below Sign Up button (centered to Sign Up button width)
                    HStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Text("Don't have an account?")
                                .font(.system(size: 13, weight: .medium, design: .default))
                                .italic()
                                .tracking(-0.5)
                                .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Spacer for Sign In button area
                        Spacer()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back!")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }
    
    // MARK: Form
    private var formSection: some View {
        VStack(spacing: 20) {
            // Username Input
            VStack(alignment: .leading, spacing: 6) {
                SignInStyledTextField(
                    title: "Username",
                    placeholder: "Value",
                    text: $username,
                    isError: showUsernameError,
                    focusedField: $focusedField,
                    fieldType: .username
                )
                
                if showUsernameError {
                    errorMessage("Please fill out this field.")
                }
            }
            
            // Password Input
            VStack(alignment: .leading, spacing: 6) {
                SignInStyledTextField(
                    title: "Password",
                    placeholder: "Value",
                    text: $password,
                    isError: showPasswordError,
                    focusedField: $focusedField,
                    fieldType: .password,
                    isSecure: true
                )
                
                if showPasswordError {
                    errorMessage("Must be 6 or more characters and at least 1 special character")
                } else {
                    // Show requirements as helper text
                    Text("Must be 6 or more characters and at least 1 special character")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(ForkiTheme.textSecondary.opacity(0.7))
                        .padding(.top, 2)
                }
            }
        }
    }
    
    // MARK: Footer
    private var footerSection: some View {
        Text("By continuing, you agree to our Terms & Privacy Policy")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(ForkiTheme.textSecondary.opacity(0.8))
            .multilineTextAlignment(.center)
    }
    
    // MARK: Validation
    private func validateForm() {
        var isValid = true
        
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            showUsernameError = true
            isValid = false
        } else {
            showUsernameError = false
        }
        
        if !isValidPassword(password) {
            showPasswordError = true
            isValid = false
        } else {
            showPasswordError = false
        }
        
        if isValid {
            userData.email = username
            
            // Save signin info
            UserDefaults.standard.set(username, forKey: "hp_userEmail")
            if let savedName = UserDefaults.standard.string(forKey: "hp_userName") {
                userData.name = savedName
            }
            
            // Check if user has already onboarded
            if UserDefaults.standard.bool(forKey: "hp_hasOnboarded") {
                // Already onboarded, go to Home Screen
                UserDefaults.standard.set(true, forKey: "hp_isSignedIn")
                withAnimation(.easeInOut) { currentScreen = 6 }
            } else {
                // Not onboarded yet, start onboarding
                onSignInComplete?()
            }
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Must be 6 or more characters and at least 1 special character
        guard password.count >= 6 else { return false }
        let specialCharacterRegex = #"[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]"#
        return password.range(of: specialCharacterRegex, options: .regularExpression) != nil
    }
    
    // MARK: Error UI
    private func errorMessage(_ message: String) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(ForkiTheme.highlightText)
                .font(.system(size: 14))
            Text(message)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(ForkiTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 2)
    }
}

// MARK: - SignInStyledTextField
struct SignInStyledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isError: Bool
    @FocusState.Binding var focusedField: SignInScreen.Field?
    let fieldType: SignInScreen.Field
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(ForkiTheme.textPrimary)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(ForkiTheme.textSecondary.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($focusedField, equals: fieldType)
                    } else {
                        TextField("", text: $text)
                            .focused($focusedField, equals: fieldType)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(ForkiTheme.textPrimary)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .background(ForkiTheme.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isError ? ForkiTheme.highlightText :
                                (focusedField == fieldType ? ForkiTheme.borderPrimary : ForkiTheme.borderPrimary.opacity(0.3)),
                            lineWidth: isError ? 2 : 1.5
                        )
                )
                .accentColor(ForkiTheme.highlightText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            }
        }
    }
}

#Preview {
    SignInScreen(
        currentScreen: .constant(0),
        userData: UserData()
    )
}

