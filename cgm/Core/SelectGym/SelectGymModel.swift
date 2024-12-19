//
//  SelectGymModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 15/12/2024.
//

import Foundation


class SelectGymModel: ObservableObject{
    @Published var climbingGyms: [GymD]? = nil
    
    init() {
        Task{ await fetchClimbingGymsData() }
    }
     
    func fetchClimbingGymsData() async {
        do{
            let session = try await AuthManager.shared.client.auth.session
            let user = session.user
            let data = try await DatabaseManager.shared.getGyms()
            self.climbingGyms = data
        }catch{
            print(error)
        }
    }
    
    
    func storeSelectedGymIntoUserData(gymID: Int){
        UserDefaults.standard.set(String(gymID), forKey: "selectedGym")
    }
    
    
    
}
