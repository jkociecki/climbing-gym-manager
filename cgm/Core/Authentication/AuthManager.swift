//
//  AuthManager.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//
import Foundation
import Supabase

struct AppUser {
    let uid: String
    let email: String?
}

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var isAuthenticated = false
    @Published var userUID: String? {
        didSet {
            if let uid = userUID {
                UserDefaults.standard.set(uid, forKey: "userUID")
            } else {
                UserDefaults.standard.removeObject(forKey: "userUID")
            }
        }
    }
    @Published var isAdmin: Bool = false {
        didSet {
            UserDefaults.standard.set(isAdmin, forKey: "isAdmin")
        }
    }
    @Published var adminOf: Int = -1 {
        didSet {
            UserDefaults.standard.set(adminOf, forKey: "adminOf")
        }
    }
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://hawfslcnxjerfllpbriq.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhd2ZzbGNueGplcmZsbHBicmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQyMTAzNjcsImV4cCI6MjA0OTc4NjM2N30.hAAMQQ9YeNCwopa3UzUCaJ8NlHrxNfS2zJTnrljIp3k")
    
    private init() {
        loadStoredUserData()
    }
    
    private func loadStoredUserData() {
        if let storedUID = UserDefaults.standard.string(forKey: "userUID") {
            self.userUID = storedUID
            self.isAdmin = UserDefaults.standard.bool(forKey: "isAdmin")
            self.adminOf = UserDefaults.standard.integer(forKey: "adminOf")
            
            Task {
                await refreshUserData()
            }
        }
    }
    
    func refreshUserData() async {
        guard let uid = userUID else { return }
        
        do {
            if let response = try await DatabaseManager.shared.getUser(userID: uid) {
                await MainActor.run {
                    self.isAdmin = response.adminOf == nil ? false : true
                    self.adminOf = response.adminOf ?? -1
                }
            }
        } catch {
            print("Error refreshing user data: \(error)")
        }
    }
    
    func checkSession() async throws {
       let session = try await client.auth.session
        await MainActor.run {
            self.userUID = session.user.id.uuidString
            self.isAuthenticated = true
        }
        await refreshUserData()
        
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        let session = try await client.auth.signIn(email: email, password: password)
        await MainActor.run {
            self.userUID = session.user.id.uuidString
            self.isAuthenticated = true
        }
        
        if let response = try await DatabaseManager.shared.getUser(userID: userUID ?? "") {
            await MainActor.run {
                self.isAdmin = response.adminOf == nil ? false : true
                self.adminOf = response.adminOf ?? -1
            }
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func registerWithEmail(email: String, password: String) async throws -> AppUser {
        let registerResponse = try await client.auth.signUp(email: email, password: password)
        guard let session = registerResponse.session else { throw NSError() }
        await MainActor.run {
            self.userUID = session.user.id.uuidString
            self.isAuthenticated = true
        }
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func logOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.userUID = nil
            self.isAdmin = false
            self.adminOf = -1
            self.isAuthenticated = false
        }
    }
    
    @MainActor
    func checkAuth() async {
        do {
            if try await client.auth.session.isExpired == false {
                isAuthenticated = true
                await refreshUserData()
            } else {
                isAuthenticated = false
                userUID = nil
                isAdmin = false
                adminOf = -1
            }
        } catch {
            isAuthenticated = false
        }
    }
}
