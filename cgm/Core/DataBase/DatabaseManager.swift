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
    
    func getCurrentGymSectors() async throws -> [SectorD] {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let sectors: [SectorD] = try await client.from("Sectors").select("*").eq("gymID", value: currentGymId).execute().value
        return sectors
    }
    
    func createGradeVote(gradeVote: GradeVote) async throws {
        let response = try await client.from("GradeVotes").insert(gradeVote).execute()
        print(response.data)
    }
    
    func getGradeVote(boulderID: Int, userID: String) async throws -> GradeVote? {
        let vote: GradeVote? = try await client
            .from("GradeVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .single()
            .execute()
            .value
        return vote
    }
        
    func getStarVote(boulderID: Int, userID: String) async throws -> StarVote? {
        let vote: StarVote? = try await client
            .from("StarVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .single()
            .execute()
            .value
        return vote
    }

    
    func getBoulderStarVotes(boulderID: Int) async throws -> [StarVote] {

        let votes: [StarVote] = try await client
            .from("StarVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .execute()
            .value
        
        return votes
    }
    
    func getBoulderToppedBy(boulderID: Int) async throws -> [ToppedBy] {
        let data: [ToppedBy] = try await client
            .from("ToppedBy")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .execute()
            .value
        return data
    }
    
    
    func updateStarVote(starVote: StarVote) async throws {
        let response = try await client
            .from("StarVotes")
            .upsert(starVote)
            .execute()
        print("Updated response: \(response.data)")
    }
    
    func updateGradeVote(gradeVote: GradeVote) async throws {
        let response = try await client
            .from("GradeVotes")
            .upsert(gradeVote)
            .execute()
        print("Updated response: \(response.data)")
    }
    
    
    func updateToppedBy(toppedBy: ToppedBy) async throws {
        let response = try await client
            .from("ToppedBy")
            .upsert(toppedBy)
            .execute()
        print("Updated response: \(response.data)")
    }
    
    func getToppedBy(boulderID: Int, userID: String) async throws -> ToppedBy? {
        let data: [ToppedBy] = try await client
            .from("ToppedBy")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
            .value
        return data.first
    }
    
    func getUser(userID: String) async throws -> User? {
        let data: User? = try await client
            .from("Users")
            .select("*")
            .eq("uid", value: userID)
            .single()
            .execute()
            .value
        return data
    }
    
    func deleteToppedBy(boulderID: Int, userID: String) async throws {
        let response = try await client
            .from("ToppedBy")
            .delete()
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .execute()
        print("Deleted response: \(response.data)")
    }
    
    func getUserDetails(userID: String) async throws -> User? {
        let data: [User] = try await client
            .from("Users")
            .select("*")
            .eq("uid", value: userID)
            .limit(1)
            .execute()
            .value
        return data.first
    }

    


    //potem to dac do innej funkcji ale narazie cos nie chce mi dzialac inaczej
    struct AllGradeGroupedVotes: Identifiable {
        let id = UUID()
        let difficulty: String
        let votes: Int
    }
    func fetchGroupedGradeVotes(boulderID: Int, boulderDifficulty: String) async throws -> [AllGradeGroupedVotes] {
        // Fetch the votes from the database
        let votes: [GradeVote] = try await client
            .from("GradeVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .execute()
            .value ?? []

        let groupedVotes = Dictionary(grouping: votes, by: { $0.grade_vote })
        let allGroupedVotes: [AllGradeGroupedVotes] = groupedVotes.map { difficulty, voteList in
            AllGradeGroupedVotes(difficulty: difficulty, votes: voteList.count)
        }
        
        let currentIndex = allDifficulties.firstIndex(of: boulderDifficulty) ?? 0
        
        let lowerBound = max(0, currentIndex - 4)
        let upperBound = min(allDifficulties.count - 1, currentIndex + 4)
        let relevantDifficulties = Array(allDifficulties[lowerBound...upperBound])
        
        var difficultyVotes: [String: Int] = [:]
        
        for vote in allGroupedVotes {
            difficultyVotes[vote.difficulty] = vote.votes
        }
        
        var result: [AllGradeGroupedVotes] = []
        
        for difficulty in relevantDifficulties {
            let voteCount = difficultyVotes[difficulty] ?? 0
            result.append(AllGradeGroupedVotes(difficulty: difficulty, votes: voteCount))
        }
        
        return result
    }
    
    func getToppedBoulders(forUserID userID: String) async throws -> [ToppedBy] {
        let toppedBoulders = try await client
            .from("ToppedBy")
            .select("*")
            .eq("user_id", value: userID)
            .execute().value as [ToppedBy]
        
        return toppedBoulders
    }

        
    func fetchStarVotesForBoulder(boulderID: Int) async throws -> [StarVote] {
            let votes: [StarVote] = try await client
                .from("StarVotes")
                .select("*")
                .eq("boulder_id", value: boulderID)
                .execute()
                .value
            return votes
        }
    
    func getBoulderByID(boulderID: Int) async throws -> BoulderD? {
        let boulder: BoulderD? = try await client
            .from("Boulders")
            .select("*")
            .eq("id", value: boulderID)
            .single()
            .execute()
            .value
        return boulder
    }
    
    func getSectorByID(sectorID: Int) async throws -> SectorD? {
        let sector: SectorD? = try await client
            .from("Sectors")
            .select("*")
            .eq("id", value: sectorID)
            .single()
            .execute()
            .value
        
        return sector
    }
    
    func getUserStats(userID: String) async throws -> (flashes: Int, tops: Int) {
        let data: [ToppedBy] = try await client
            .from("ToppedBy")
            .select("*")
            .eq("user_id", value: userID)
            .execute()
            .value
        
        let flashes = data.filter { $0.is_flashed }.count
        let tops = data.count
        
        return (flashes, tops)
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

struct SectorD: Identifiable, Decodable, Encodable{
    var id:             Int
    var sector_name:    String
    var gymID:          Int
}


struct GradeVote: Encodable, Decodable {
    var user_id: String
    var boulder_id: Int
    var created_at: String?
    var grade_vote: String
}


struct StarVote: Encodable, Decodable {
    var user_id: String
    var boulder_id: Int
    var created_at: String?
    var star_vote: Int
}

struct ToppedBy: Encodable, Decodable {
    var user_id: String
    var boulder_id: Int
    var is_flashed: Bool
    var created_at: String?
}
