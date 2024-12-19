import Foundation
import Supabase
import SwiftUI

class DatabaseManager {
    
    let client = AuthManager.shared.client
    
    static let shared = DatabaseManager()
    
    func createUserEntity(userData: User) async throws {
       let response = try await client.from("Users").insert(userData).execute()
       print(response.data)
    }
    
    func editUserEntity(userData: User) async throws{
        let response = try await client.from("Users").update(userData).execute()
        print(response.data)
    }
    
    func fetchUserEntityOverEmail(email: String) async throws -> User{
        let userData: User = try await client
            .from("Users")
            .select("*")
            .eq("email", value: email)
            .single()
            .execute()
            .value
        return userData
    }

    func getGyms() async throws -> [GymD]{
        let gyms: [GymD] = try await client.from("ClimbingGyms").select("*").execute().value
        return gyms
    }
    
    func getCurrentGymBoulders() async throws -> [BoulderD] {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let gymsSectors: [BoulderD] = try await client.from("Boulders").select("*").eq("gym_id", value: currentGymId).execute().value
        return gymsSectors
    }
    
    func getCurrentGymMap() async throws -> String {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let map: GymD = try await client.from("ClimbingGyms").select("*").eq("id", value: currentGymId).single().execute().value
        return map.mapSectorsSVG
    }
    
    func getCurrentGymSectors() async throws -> [Sector] {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let sectors: [Sector] = try await client.from("Sectors").select("*").eq("gymID", value: currentGymId).execute().value
        return sectors
    }
}


///STRUCTS

struct User: Encodable, Decodable{
    var email:          String
    var uid:            UUID
    var created_at:     String?
    var name:           String?
    var surname:        String?
    var gender:         Bool?
}

struct GymD: Identifiable, Decodable{
    var id:             Int
    var name:           String
    var address:        String
    var logoSVG:        String
    var mapSectorsSVG:  String
}

struct BoulderD: Identifiable, Decodable, Encodable{
    var id:             Int
    var diff:           String
    var color:          String
    var x:              Float
    var y:              Float
    var sector_id:      Int
    var gym_id:         Int
}

struct Sector: Identifiable, Decodable, Encodable{
    var id:             Int
    var sector_name:    String
    var gymID:          Int
}
