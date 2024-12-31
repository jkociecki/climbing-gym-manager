//
//  SelectGymModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation

class SelectGymModel: ObservableObject {
    @Published var selectedGym: Int? = nil
    @Published var climbingGyms: [GymD] = []
    @Published var error: Error? = nil
    
    init() {
        getStoredData() // Pobranie wybranego Gym z UserDefaults
        Task { await fetchClimbingGymsData() }
    }
    
    func fetchClimbingGymsData() async {
        do {
            let session = try await AuthManager.shared.client.auth.session
            let data = try await DatabaseManager.shared.getGyms()
            self.climbingGyms = data
        } catch {
            self.error = error // Informacja o błędzie
            print("Error fetching gyms: \(error)")
        }
    }
    
    func storeSelectedGymIntoUserData(gymID: Int) {
        UserDefaults.standard.set(String(gymID), forKey: "selectedGym")
    }
    
    func getStoredData() {
        if let idString = UserDefaults.standard.string(forKey: "selectedGym"),
           let gymID = Int(idString) {
            selectedGym = gymID
        } else {
            selectedGym = nil
        }
    }
}

