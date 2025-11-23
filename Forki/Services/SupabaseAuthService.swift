//
//  SupabaseAuthService.swift
//  Forki
//
//  Created by Cursor AI on 11/11/25.
//

import Foundation

// MARK: - Supabase Auth Service
class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    
    private let supabaseURL = "https://uisjdlxdqfovuwurmdop.supabase.co"
    private let supabaseAPIKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpc2pkbHhkcWZvdnV3dXJtZG9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5MDkyODYsImV4cCI6MjA3NDQ4NTI4Nn0.WaACHNXUWh5ZXKu5aZf1EjolXvWdD7R5mbNqBebnIuI"
    
    private init() {}
    
    // MARK: - Authentication Errors
    enum AuthError: LocalizedError {
        case invalidCredentials
        case userNotFound
        case emailAlreadyExists
        case networkError(String)
        case unknownError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Incorrect password. Try again?"
            case .userNotFound:
                return "No account found with this email. Want to sign up?"
            case .emailAlreadyExists:
                return "This email is already registered. Log in instead?"
            case .networkError(let message):
                return "Network error: \(message)"
            case .unknownError(let message):
                return "Error: \(message)"
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(username: String, password: String, name: String) async throws -> (userId: String, session: AuthSession) {
        // TEMPORARILY: Use email as-is (no normalization) to test if normalization is causing issues
        // Just trim whitespace for safety
        let emailToUse = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🔍 Attempting signup with email: \(emailToUse)")
        
        // Validate email format
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard emailToUse.range(of: emailRegex, options: .regularExpression) != nil else {
            throw AuthError.unknownError("Please enter a valid email address.")
        }
        
        // Check our users table for duplicate emails
        // Note: We only check public.users (not auth.users) to avoid validation issues
        // Supabase will also catch duplicates during signup, but checking first gives better UX
        if try await checkUserExistsInTable(email: emailToUse) {
            print("⚠️ User exists in users table - email already registered")
            throw AuthError.emailAlreadyExists
        }
        
        print("✅ Email not found in users table - proceeding with signup")
        
        // Construct the signup URL
        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        print("🔗 Signup URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        
        // Use email as-is for signup (temporarily without normalization)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let body: [String: Any] = [
            "email": emailToUse,
            "password": password,
            "data": [
                "name": trimmedName
            ]
        ]
        
        // Log the request body for debugging
        if let jsonData = try? JSONSerialization.data(withJSONObject: body),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Signup request body: \(jsonString)")
            print("📤 Email being sent: '\(emailToUse)' (length: \(emailToUse.count))")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Log the raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("✅ Supabase Sign Up Response: \(responseString)")
                }
                
                // Supabase signup response can be either:
                // 1. Direct user object: {"id":"...","email":"...",...}
                // 2. Wrapped in AuthResponse: {"user":{...},"session":{...}}
                // Try to decode as direct user first
                do {
                    let user = try JSONDecoder().decode(AuthUser.self, from: data)
                    // Successfully decoded as direct user object
                    print("✅ User created successfully: \(user.id)")
                    
                    // No session in signup response - this is normal
                    // Create a minimal session object for the function signature
                    let minimalSession = AuthSession(
                        accessToken: "pending", // Placeholder - not a real token
                        refreshToken: "pending",
                        expiresAt: "",
                        user: user
                    )
                    return (user.id, minimalSession)
                } catch {
                    // Try to decode as AuthResponse (wrapped format)
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        
                        if let user = authResponse.user {
                            // Session might be nil if email confirmation is required or other conditions
                            if let session = authResponse.session {
                                return (user.id, session)
                            } else {
                                print("⚠️ Signup successful but no session returned. User ID: \(user.id)")
                                let minimalSession = AuthSession(
                                    accessToken: "pending",
                                    refreshToken: "pending",
                                    expiresAt: "",
                                    user: user
                                )
                                return (user.id, minimalSession)
                            }
                        } else {
                            throw AuthError.unknownError("Failed to create user account")
                        }
                    } catch {
                        print("❌ Failed to decode signup response: \(error)")
                        throw AuthError.unknownError("Failed to parse signup response")
                    }
                }
            } else {
                let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let errorMessage = errorData?["message"] as? String ?? errorData?["error_description"] as? String ?? errorData?["msg"] as? String ?? "Unknown error"
                let errorCode = errorData?["error_code"] as? String ?? errorData?["code"] as? String ?? ""
                
                // Log the actual error for debugging
                print("❌ Supabase Sign Up Error [\(httpResponse.statusCode)]: \(errorMessage)")
                if let fullError = errorData {
                    print("Full error data: \(fullError)")
                }
                
                // Check for email validation errors
                if (errorMessage.lowercased().contains("invalid") && errorMessage.lowercased().contains("email")) ||
                   errorCode == "email_address_invalid" {
                    print("⚠️ Email validation error from Supabase: \(errorMessage) (code: \(errorCode))")
                    throw AuthError.unknownError("Please enter a valid email address. Make sure it's formatted correctly (e.g., yourname@example.com).")
                }
                    
                    // Check for email already registered
                    // Supabase might return different error codes/messages for duplicate emails
                    if errorMessage.lowercased().contains("already registered") ||
                       errorMessage.lowercased().contains("already exists") ||
                       errorMessage.lowercased().contains("user already registered") ||
                       errorMessage.lowercased().contains("email address is already registered") ||
                       errorMessage.lowercased().contains("duplicate key") ||
                       errorMessage.lowercased().contains("unique constraint") ||
                       errorMessage.lowercased().contains("email already") ||
                       httpResponse.statusCode == 422 ||
                       httpResponse.statusCode == 409 {
                        print("⚠️ Duplicate email detected in signup response")
                        throw AuthError.emailAlreadyExists
                    }
                    
                    // Check for weak password error
                    if errorMessage.contains("weak") || 
                       errorMessage.contains("WEAK_PASSWORD") ||
                       errorMessage.contains("password") && errorMessage.contains("requirement") {
                        throw AuthError.unknownError("Password does not meet requirements. Please use a stronger password with uppercase, lowercase, numbers, and special characters.")
                    }
                    
                    throw AuthError.unknownError(errorMessage)
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Sign In
    func signIn(username: String, password: String) async throws -> (userId: String, session: AuthSession) {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "email": username,
            "password": password
        ]
        
        // Log sign in attempt for debugging
        print("🔐 Attempting sign in for: \(username)")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode == 200 {
                // Log the raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("✅ Supabase Sign In Response: \(responseString)")
                }
                
                // Supabase sign in response format:
                // {"access_token":"...","refresh_token":"...","expires_at":123,"user":{...}}
                // We need to parse this manually
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    guard let accessToken = json?["access_token"] as? String,
                          let refreshToken = json?["refresh_token"] as? String,
                          let userDict = json?["user"] as? [String: Any],
                          let userId = userDict["id"] as? String else {
                        throw AuthError.unknownError("Failed to parse sign in response")
                    }
                    
                    // Get expires_at (can be number or string)
                    let expiresAt: String
                    if let expiresAtNum = json?["expires_at"] as? Int {
                        expiresAt = String(expiresAtNum)
                    } else if let expiresAtStr = json?["expires_at"] as? String {
                        expiresAt = expiresAtStr
                    } else {
                        // Calculate from expires_in if available
                        if let expiresIn = json?["expires_in"] as? Int {
                            let expirationTime = Int(Date().timeIntervalSince1970) + expiresIn
                            expiresAt = String(expirationTime)
                        } else {
                            expiresAt = ""
                        }
                    }
                    
                    let user = AuthUser(id: userId, email: userDict["email"] as? String)
                    let session = AuthSession(
                        accessToken: accessToken,
                        refreshToken: refreshToken,
                        expiresAt: expiresAt,
                        user: user
                    )
                    
                    print("✅ Sign in successful: User ID \(userId)")
                    return (userId, session)
                } catch {
                    print("❌ Failed to parse sign in response: \(error)")
                    throw AuthError.unknownError("Failed to parse sign in response: \(error.localizedDescription)")
                }
            } else {
                let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                let errorMessage = errorData?["message"] as? String ?? errorData?["error_description"] as? String ?? errorData?["msg"] as? String ?? "Unknown error"
                
                // Log the error for debugging
                print("❌ Supabase Sign In Error [\(httpResponse.statusCode)]: \(errorMessage)")
                if let fullError = errorData {
                    print("Full error data: \(fullError)")
                }
                
                // Check for specific error types
                if errorMessage.contains("Invalid login credentials") || 
                   errorMessage.contains("invalid password") ||
                   errorMessage.contains("Email not confirmed") ||
                   errorMessage.contains("Invalid email or password") ||
                   errorMessage.contains("Invalid credentials") {
                    // For invalid credentials, we need to determine if it's wrong password or user not found
                    // Supabase doesn't distinguish, so we'll try to check via a different method
                    // For now, assume it's invalid credentials (wrong password)
                    throw AuthError.invalidCredentials
                } else if errorMessage.contains("User not found") || 
                          errorMessage.contains("No user found") ||
                          errorMessage.contains("Email not found") {
                    throw AuthError.userNotFound
                }
                
                throw AuthError.unknownError(errorMessage)
            }
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Check if user exists in auth.users (Supabase Auth)
    func checkUserExistsInAuth(email: String) async throws -> Bool {
        // Use a database function to check auth.users
        // This function is defined in the migration and can be called via REST API
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(supabaseURL)/rest/v1/rpc/check_user_exists_in_auth?check_email=\(encodedEmail)") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        
        // RPC functions need a POST request with the parameters in the body
        let body: [String: Any] = ["check_email": email]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Function returns a boolean
                if let result = try? JSONSerialization.jsonObject(with: data) as? Bool {
                    return result
                }
                // Sometimes it returns as an array with one boolean
                if let resultArray = try? JSONSerialization.jsonObject(with: data) as? [Bool],
                   let result = resultArray.first {
                    return result
                }
            }
            
            return false
        } catch {
            // If query fails, assume we can't check (allow signup to proceed)
            // The signup endpoint will catch duplicates
            print("⚠️ Could not check auth.users: \(error)")
            return false
        }
    }
    
    // MARK: - Check if user exists in our users table
    func checkUserExistsInTable(email: String) async throws -> Bool {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(supabaseURL)/rest/v1/users?email=eq.\(encodedEmail)&select=id") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Parse response to check if any users exist
                if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    return !jsonArray.isEmpty
                }
            }
            
            return false
        } catch {
            // If query fails, assume user doesn't exist (allow signup)
            return false
        }
    }
    
    // MARK: - Save User Data to Supabase
    func saveUserData(userId: String, userData: UserData, onboardingData: OnboardingData? = nil, accessToken: String? = nil) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/users") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use session token if available, otherwise use anon key
        // Session token is needed for RLS policies to work
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // Try to get current session
            if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
                request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
            }
        }
        
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        
        var userDataDict: [String: Any] = [
            "id": userId,
            "name": userData.name,
            "email": userData.email,
            "age": userData.age,
            "gender": userData.gender,
            "height": userData.height,
            "weight": userData.weight,
            "goal": userData.goal,
            "goal_duration": userData.goalDuration,
            "food_preferences": userData.foodPreferences,
            "notifications": userData.notifications,
            "selected_character": userData.selectedCharacter.rawValue,
            "persona_id": userData.personaID,
            "recommended_calories": userData.recommendedCalories,
            "eating_pattern": userData.eatingPattern,
            "bmi": userData.BMI,
            "body_type": userData.bodyType,
            "metabolism": userData.metabolism,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        // Add macros if available
        if let macros = userData.recommendedMacros {
            userDataDict["macro_protein"] = macros.protein
            userDataDict["macro_carbs"] = macros.carbs
            userDataDict["macro_fats"] = macros.fats
            userDataDict["macro_fiber"] = macros.fiber
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userDataDict)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.networkError("Invalid response")
            }
            
            if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
                // Try to update if insert fails (user might already exist)
                // This can happen if the trigger already created the row
                try await updateUserData(userId: userId, userData: userData, onboardingData: onboardingData, accessToken: accessToken)
            }
        } catch {
            // If insert fails, try update (trigger might have created the row)
            try await updateUserData(userId: userId, userData: userData, onboardingData: onboardingData, accessToken: accessToken)
        }
    }
    
    // MARK: - Update User Data in Supabase
    func updateUserData(userId: String, userData: UserData, onboardingData: OnboardingData? = nil, accessToken: String? = nil) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/users?id=eq.\(userId)") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use session token if available, otherwise use anon key
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // Try to get current session
            if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
                request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
            }
        }
        
        var userDataDict: [String: Any] = [
            "name": userData.name,
            "email": userData.email,
            "age": userData.age,
            "gender": userData.gender,
            "height": userData.height,
            "weight": userData.weight,
            "goal": userData.goal,
            "goal_duration": userData.goalDuration,
            "food_preferences": userData.foodPreferences,
            "notifications": userData.notifications,
            "selected_character": userData.selectedCharacter.rawValue,
            "persona_id": userData.personaID,
            "recommended_calories": userData.recommendedCalories,
            "eating_pattern": userData.eatingPattern,
            "bmi": userData.BMI,
            "body_type": userData.bodyType,
            "metabolism": userData.metabolism,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        // Add macros if available
        if let macros = userData.recommendedMacros {
            userDataDict["macro_protein"] = macros.protein
            userDataDict["macro_carbs"] = macros.carbs
            userDataDict["macro_fats"] = macros.fats
            userDataDict["macro_fiber"] = macros.fiber
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userDataDict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            let errorData = try? JSONSerialization.jsonObject(with: Data(), options: []) as? [String: Any]
            let errorMessage = errorData?["message"] as? String ?? "Failed to update user data"
            throw AuthError.unknownError(errorMessage)
        }
    }
    
    // MARK: - Load User Data from Supabase
    func loadUserData(userId: String, accessToken: String? = nil) async throws -> UserData? {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/users?id=eq.\(userId)&select=*") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use session token for authentication (required for RLS policies)
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            // Try to get current session
            if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
                request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                // Fallback to anon key (might fail with RLS, but try anyway)
                request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode == 200 {
            let users = try JSONDecoder().decode([SupabaseUser].self, from: data)
            
            guard let user = users.first else {
                return nil
            }
            
            let userData = UserData()
            userData.name = user.name ?? ""
            userData.email = user.email ?? ""
            userData.age = user.age ?? ""
            userData.gender = user.gender ?? ""
            userData.height = user.height ?? ""
            userData.weight = user.weight ?? ""
            userData.goal = user.goal ?? ""
            userData.goalDuration = user.goalDuration ?? 0
            userData.foodPreferences = user.foodPreferences ?? []
            userData.notifications = user.notifications ?? false
            userData.selectedCharacter = CharacterType(rawValue: user.selectedCharacter ?? "Forki") ?? .avatar
            userData.personaID = user.personaID ?? 13
            userData.recommendedCalories = user.recommendedCalories ?? 2000
            userData.eatingPattern = user.eatingPattern ?? ""
            userData.BMI = user.bmi ?? 0
            userData.bodyType = user.bodyType ?? ""
            userData.metabolism = user.metabolism ?? ""
            
            if let protein = user.macroProtein,
               let carbs = user.macroCarbs,
               let fats = user.macroFats,
               let fiber = user.macroFiber {
                userData.recommendedMacros = Macros(protein: protein, carbs: carbs, fats: fats, fiber: fiber)
            }
            
            return userData
        }
        
        return nil
    }
    
    // MARK: - Save Session
    func saveSession(_ session: AuthSession) {
        UserDefaults.standard.set(session.accessToken, forKey: "supabase_access_token")
        UserDefaults.standard.set(session.refreshToken, forKey: "supabase_refresh_token")
        UserDefaults.standard.set(session.expiresAt, forKey: "supabase_expires_at")
        if let userId = session.user?.id {
            UserDefaults.standard.set(userId, forKey: "supabase_user_id")
        }
    }
    
    // MARK: - Get Current Session
    func getCurrentSession() -> AuthSession? {
        guard let accessToken = UserDefaults.standard.string(forKey: "supabase_access_token"),
              let refreshToken = UserDefaults.standard.string(forKey: "supabase_refresh_token"),
              let expiresAt = UserDefaults.standard.string(forKey: "supabase_expires_at"),
              let userId = UserDefaults.standard.string(forKey: "supabase_user_id") else {
            return nil
        }
        
        return AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            user: AuthUser(id: userId, email: nil)
        )
    }
    
    // MARK: - Save Meal Log
    func saveMealLog(userId: String, mealLog: MealLog, accessToken: String? = nil) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/meal_logs") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use session token for authentication
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        }
        
        let formatter = ISO8601DateFormatter()
        var mealLogDict: [String: Any] = [
            "id": mealLog.id.uuidString,
            "user_id": userId,
            "food_id": mealLog.food.id,
            "food_name": mealLog.food.name,
            "calories": mealLog.food.calories,
            "protein": mealLog.food.protein,
            "carbs": mealLog.food.carbs,
            "fats": mealLog.food.fats,
            "category": mealLog.food.category,
            "portion": mealLog.portion,
            "logged_at": formatter.string(from: mealLog.timestamp)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: mealLogDict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
            // Try update if insert fails
            try await updateMealLog(userId: userId, mealLog: mealLog, accessToken: accessToken)
        }
    }
    
    // MARK: - Update Meal Log
    func updateMealLog(userId: String, mealLog: MealLog, accessToken: String? = nil) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/meal_logs?id=eq.\(mealLog.id.uuidString)") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        }
        
        let formatter = ISO8601DateFormatter()
        var mealLogDict: [String: Any] = [
            "food_id": mealLog.food.id,
            "food_name": mealLog.food.name,
            "calories": mealLog.food.calories,
            "protein": mealLog.food.protein,
            "carbs": mealLog.food.carbs,
            "fats": mealLog.food.fats,
            "category": mealLog.food.category,
            "portion": mealLog.portion,
            "logged_at": formatter.string(from: mealLog.timestamp),
            "updated_at": formatter.string(from: Date())
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: mealLogDict)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            let errorMessage = "Failed to update meal log"
            throw AuthError.unknownError(errorMessage)
        }
    }
    
    // MARK: - Delete Meal Log
    func deleteMealLog(mealLogId: UUID, accessToken: String? = nil) async throws {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/meal_logs?id=eq.\(mealLogId.uuidString)") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            throw AuthError.unknownError("Failed to delete meal log")
        }
    }
    
    // MARK: - Load Meal Logs
    func loadMealLogs(userId: String, accessToken: String? = nil) async throws -> [MealLog] {
        guard let url = URL(string: "\(supabaseURL)/rest/v1/meal_logs?user_id=eq.\(userId)&select=*&order=logged_at.desc") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(supabaseAPIKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken, !token.isEmpty && token != "pending" {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else if let session = getCurrentSession(), !session.accessToken.isEmpty && session.accessToken != "pending" {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseAPIKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError("Invalid response")
        }
        
        if httpResponse.statusCode == 200 {
            let mealLogs = try JSONDecoder().decode([SupabaseMealLog].self, from: data)
            return mealLogs.map { $0.toMealLog() }
        }
        
        return []
    }
    
    // MARK: - Clear Session
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
        UserDefaults.standard.removeObject(forKey: "supabase_expires_at")
        UserDefaults.standard.removeObject(forKey: "supabase_user_id")
    }
}

// MARK: - Meal Log Models
struct MealLog {
    let id: UUID
    let food: FoodItem
    let portion: Double
    let timestamp: Date
    
    init(id: UUID = UUID(), food: FoodItem, portion: Double, timestamp: Date) {
        self.id = id
        self.food = food
        self.portion = portion
        self.timestamp = timestamp
    }
    
    // Convert from LoggedFood
    init(from loggedFood: LoggedFood) {
        self.id = loggedFood.id
        self.food = loggedFood.food
        self.portion = loggedFood.portion
        self.timestamp = loggedFood.timestamp
    }
    
    // Convert to LoggedFood
    func toLoggedFood() -> LoggedFood {
        return LoggedFood(id: id, food: food, portion: portion, timestamp: timestamp)
    }
}

struct SupabaseMealLog: Codable {
    let id: String
    let userId: String?
    let foodId: Int?
    let foodName: String?
    let calories: Int?
    let protein: Double?
    let carbs: Double?
    let fats: Double?
    let category: String?
    let portion: Double?
    let loggedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case foodId = "food_id"
        case foodName = "food_name"
        case calories
        case protein
        case carbs
        case fats
        case category
        case portion
        case loggedAt = "logged_at"
    }
    
    func toMealLog() -> MealLog {
        let formatter = ISO8601DateFormatter()
        let date = loggedAt.flatMap { formatter.date(from: $0) } ?? Date()
        
        return MealLog(
            id: UUID(uuidString: id) ?? UUID(),
            food: FoodItem(
                id: foodId ?? 0,
                name: foodName ?? "Unknown",
                calories: calories ?? 0,
                protein: protein ?? 0,
                carbs: carbs ?? 0,
                fats: fats ?? 0,
                category: category ?? "Unknown",
                usdaFood: nil
            ),
            portion: portion ?? 1.0,
            timestamp: date
        )
    }
}

// MARK: - Response Models
struct AuthResponse: Codable {
    let user: AuthUser?
    let session: AuthSession?
}

struct AuthUser: Codable {
    let id: String
    let email: String?
    
    // Supabase returns many fields, but we only need id and email
    // This allows decoding to work even with extra fields
    enum CodingKeys: String, CodingKey {
        case id
        case email
    }
}

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    let user: AuthUser?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case user
    }
}

struct SupabaseUser: Codable {
    let id: String?
    let name: String?
    let email: String?
    let age: String?
    let gender: String?
    let height: String?
    let weight: String?
    let goal: String?
    let goalDuration: Int?
    let foodPreferences: [String]?
    let notifications: Bool?
    let selectedCharacter: String?
    let personaID: Int?
    let recommendedCalories: Int?
    let eatingPattern: String?
    let bmi: Double?
    let bodyType: String?
    let metabolism: String?
    let macroProtein: Int?
    let macroCarbs: Int?
    let macroFats: Int?
    let macroFiber: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case age
        case gender
        case height
        case weight
        case goal
        case goalDuration = "goal_duration"
        case foodPreferences = "food_preferences"
        case notifications
        case selectedCharacter = "selected_character"
        case personaID = "persona_id"
        case recommendedCalories = "recommended_calories"
        case eatingPattern = "eating_pattern"
        case bmi
        case bodyType = "body_type"
        case metabolism
        case macroProtein = "macro_protein"
        case macroCarbs = "macro_carbs"
        case macroFats = "macro_fats"
        case macroFiber = "macro_fiber"
    }
}

