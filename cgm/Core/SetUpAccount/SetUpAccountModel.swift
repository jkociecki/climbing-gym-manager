//
//  SetUpAccountModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation
import Supabase


@MainActor
class SetUpAccountModel: ObservableObject {
    @Published var userData: User? = nil
    @Published var errorMessage: String? = nil
    @Published var showImagePicker = false
    @Published var imageData: Data?
    @Published var userUploas: userUpload = userUpload()
    
    
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
    
    struct userUpload: Encodable {
        var name:   String?
        var surname: String?
        var gender: Bool?
    }
    
    func saveUserData(name: String, surname: String, gender: Gender?) async throws {
        guard let userData = userData else {
            throw NSError(domain: "UserDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User data is missing."])
        }

        print(userData.name)
        print(userData.surname)
        print(userData.gender)

        // Konwersja Gender? na Bool?
        let genderBool: Bool? = {
            switch gender {
            case .female: return true
            case .male: return false
            case nil: return nil
            }
        }()

        // Przygotowanie danych do aktualizacji
        var updateData = userUpload(name: name, surname: surname, gender: genderBool)

        print(userData.uid)

        // Wykonanie zapytania
        try await DatabaseManager.shared.client
            .from("Users")
            .update(updateData)
            .eq("uid", value: userData.uid)
            .execute()
    }



    
    func fetchProfilePicture() async throws {
        guard let userData = userData else {
            throw NSError(domain: "UserDataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User data is missing."])
        }

        do {
            // Asynchroniczne pobranie zdjęcia
            if let data = try await StorageManager.shared.fetchUserProfilePicture(user_uid: userData.uid.uuidString) {
                    self.imageData = data
            } else {
                    self.errorMessage = "Profile picture not found."
            }
        } catch {
                self.errorMessage = "Error fetching profile picture: \(error.localizedDescription)"
        }
    }


    
    func fetchUserData() async {
        do {
            let session = try await AuthManager.shared.client.auth.session
            let user = session.user
            let data = try await DatabaseManager.shared.fetchUserEntityOverEmail(email: user.email!)
            self.userData = data
            try await fetchProfilePicture()
        }catch{
            print("Error fetching data")
        }
    }
    
    
}
