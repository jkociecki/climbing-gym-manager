//
//  SignInViewModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation


class EmailAuthModel: ObservableObject{
    
    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser{
        return try await AuthManager.shared.registerWithEmail(email: email, password: password)
    }
    
    func storeUser() async throws{
        let session = try await AuthManager.shared.client.auth.session
        let userData = User(email: session.user.email!, uid: session.user.id)
        try await DatabaseManager.shared.createUserEntity(userData: userData)
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser{
        return try await AuthManager.shared.signInWithEmail(email: email, password: password)

    }
    
}

