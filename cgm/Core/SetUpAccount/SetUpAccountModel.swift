//
//  SetUpAccountModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation
import Supabase

class SetUpAccountModel: ObservableObject {
    @Published var userData: User? = nil
    @Published var errorMessage: String? = nil
    
    init() {
        Task {
            await fetchUserData()
        }
    }
    
    func printCurrSession() async {
        do {
            let session = try await AuthManager.shared.client.auth.session
            let user = session.user
            print("User ID: \(user.id.uuidString)")
            print("Email: \(user.email ?? "No email")")
        } catch {
            print("Error fetching session: \(error.localizedDescription)")
        }
    }
    
    func fetchUserData() async {
        do {
            let session = try await AuthManager.shared.client.auth.session
            let user = session.user
            let data = try await DatabaseManager.shared.fetchUserEntityOverEmail(email: user.email!)
            self.userData = data
        }catch{
            print("Error fetching data")
        }
    }
}
