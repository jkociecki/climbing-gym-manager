//
//  AuthManager.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation
import Supabase


struct AppUser{
    let uid: String
    let email: String?
}



class AuthManager{
    static let shared = AuthManager()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://hawfslcnxjerfllpbriq.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhd2ZzbGNueGplcmZsbHBicmlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQyMTAzNjcsImV4cCI6MjA0OTc4NjM2N30.hAAMQQ9YeNCwopa3UzUCaJ8NlHrxNfS2zJTnrljIp3k")
    
    func getCurrentSession() async throws{
        let session = try await client.auth.session
        print(session)
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser{
        let session = try await client.auth.signIn(email: email, password: password)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func registerWithEmail(email: String, password: String) async throws -> AppUser{
        let registerResponse = try await client.auth.signUp(email: email, password: password)
        guard let session = registerResponse.session else { throw NSError() }
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func storeUser(){
        
    }
    
}



