//
//  SelectGymModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation
import SwiftUICore

class SelectGymModel: ObservableObject {
    @Published var selectedGym: Int? = nil
    @Published var climbingGyms: [GymD] = []
    @Published var error: Error? = nil
    @Binding var isLoading: Bool
    
    init(isLoading: Binding<Bool>) {
        _isLoading = isLoading
        getStoredData() // Pobranie wybranego Gym z UserDefaults
        Task { await fetchClimbingGymsData() }
    }
    
    func fetchClimbingGymsData() async {
        do {
            isLoading = true
            let data = try await DatabaseManager.shared.getGyms()
            self.climbingGyms = data
            isLoading = false
        } catch {
            isLoading = false
            self.error = error
            print("Error fetching gyms: \(error)")
        }
    }
    
    func storeSelectedGymIntoUserData(gymID: Int) {
        UserDefaults.standard.set(String(gymID), forKey: "selectedGym")
        let selectedgymname = climbingGyms.first(where: { $0.id == selectedGym })?.name
        UserDefaults.standard.set(selectedgymname, forKey: "selectedGymName")
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

