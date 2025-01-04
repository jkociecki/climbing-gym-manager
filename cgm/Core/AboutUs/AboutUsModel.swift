//
//  AboutUsModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 04/01/2025.
//

import Foundation
import MapKit

class GymInfoModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var address: Address = Address(street: "", city: "", postalCode: "", coordinates: CLLocationCoordinate2D())
    @Published var avatarImageName: String = ""
    @Published var backgroundImageName: String = ""
    @Published var rating: Double = 0.0
    @Published var openingHours: [String: (start: String, end: String)] = [:]
    @Published var isLoading = true
    @Published var boulderData: [(grade: String, count: Int)] = []
    @Published var background: Data = Data()
    @Published var logo: Data = Data()
    @Published var totalBoulders: Int = 0
    
    @MainActor
    func loadData() async {
        do {
            let gymInfo = try await DatabaseManager.shared.fetchCurrentGymAboutUs()
            
            self.name = gymInfo.name
            self.description = gymInfo.description
            
            self.address = Address(
                street: gymInfo.street,
                city: gymInfo.city,
                postalCode: gymInfo.postal_code,
                coordinates: CLLocationCoordinate2D(
                    latitude: Double(gymInfo.latitude),
                    longitude: Double(gymInfo.longitude)
                )
            )
          self.openingHours = Dictionary(uniqueKeysWithValues: gymInfo.openingHours.openingHours.map { day, hours in
                (day, (start: hours.open, end: hours.close))
            })
            print("address \(address)")
//            print(name)
//            print(description)
            isLoading = false
            
        } catch {
            print("Error loading gym info: \(error)")
        }
    }
    
    func loadBoulders() async {
        do {
            let response: [groupedBoulders] = try await DatabaseManager.shared.getCurrentGymBouldersGroupedBy()
            let mapped: [(grade: String, count: Int)] = response.map { boulder in
                (grade: boulder.diff, count: boulder.count)
            }
            self.boulderData = mapped
            print("Mapped boulders: \(mapped)")
            self.totalBoulders = boulderData.map { $0.count }.reduce(0, +)
            print(totalBoulders)

        } catch {
            print("Error loading gym info: \(error)")
        }
    }
    
    func loadImagaes() async {
        do {
            if let background = try await StorageManager.shared.currentGymBackGround() {
                self.background = background
            }
            if let logo = try await StorageManager.shared.currentGymLog() {
                self.logo = logo
            }
        }catch{
            print("Error loading gym images: \(error)")

        }
    }
    


}
