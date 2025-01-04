import Foundation
import Supabase
import SwiftUI
import MapKit

class DatabaseManager {
    
    let client = AuthManager.shared.client
    
    static let shared = DatabaseManager()
    
    func getCurrentUserDataBaseID() async throws -> Int {
        let user_uuid = try await client.auth.session.user.id
        let user: UserID = try await client
                            .from("Users")
                            .select("*")
                            .eq("uid", value: user_uuid)
                            .single()
                            .execute()
                            .value
        return user.id
        
    }
    
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
    
    func getGymBoulders(gymID: Int) async throws -> [BoulderD] {
        let gymsSectors: [BoulderD] = try await client.from("Boulders").select("*").eq("gym_id", value: gymID).execute().value
        return gymsSectors
    }
    
    func getCurrentGymMap() async throws -> String {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let map: GymD = try await client.from("ClimbingGyms").select("*").eq("id", value: currentGymId).single().execute().value
        return map.mapSectorsSVG
    }

    func getGymMap(gymID: Int) async throws -> String {
        let map: GymD = try await client.from("ClimbingGyms").select("*").eq("id", value: gymID).single().execute().value
        return map.mapSectorsSVG
    }
    
    func getCurrentGymSectors() async throws -> [SectorD] {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let sectors: [SectorD] = try await client.from("Sectors").select("*").eq("gymID", value: currentGymId).execute().value
        return sectors
    }
    
    func getGymSectors(id: Int) async throws -> [SectorD] {
        let sectors: [SectorD] = try await client.from("Sectors").select("*").eq("gymID", value: id).execute().value
        return sectors
    }
    
    func createGradeVote(gradeVote: GradeVote) async throws {
        let response = try await client.from("GradeVotes").insert(gradeVote).execute()
        print(response.data)
    }
    
    func getGradeVote(boulderID: Int, userID: String) async throws -> GradeVote? {
        let vote: [GradeVote] = try await client
            .from("GradeVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
            .value
        return vote.first
    }
    
    
    func getPostComments(post_id: Int) async throws -> [CommentsD] {
        let comments: [CommentsD] = try await client
            .from("Comments")
            .select("*")
            .eq("post_id", value: post_id)
            .execute()
            .value
        return comments
    }
    
    struct PostCommentsCount: Decodable {
        var post_id: Int
    }

    func getCommentsCountForPosts(postIds: [Int]) async throws -> [Int: Int] {
        print("A")
        let comments: [PostCommentsCount] = try await client
            .from("Comments")
            .select("post_id")
            .in("post_id", values: postIds)
            .execute()
            .value
        
        let groupedComments = Dictionary(grouping: comments, by: { $0.post_id })
        var commentsCountDict: [Int: Int] = [:]
        for (postId, commentList) in groupedComments {
            commentsCountDict[postId] = commentList.count
        }
        
        return commentsCountDict
    }



        
    func getStarVote(boulderID: Int, userID: String) async throws -> StarVote? {
        let vote: [StarVote] = try await client
            .from("StarVotes")
            .select("*")
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .limit(1) // Pobierz maksymalnie jeden rekord
            .execute()
            .value
        return vote.first
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
    
    func uploadPostComment(comment: CommentUpload) async throws {
        try await client
            .from("Comments")
            .insert(comment)
            .execute()
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
        let data: [User] = try await client
            .from("Users")
            .select("*")
            .eq("uid", value: userID)
            .limit(1)
            .execute()
            .value
        return data.first
    }
    
    func getUserOverID(userID: String) async throws -> User? {
        let data: User? = try await client
            .from("Users")
            .select("*")
            .eq("id", value: userID)
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
    
    func deleteStarVote(boulderID: Int, userID: String) async throws {
        let response = try await client
            .from("StarVotes")
            .delete()
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .execute()
        print("Deleted response: \(response.data)")
    }
    
    func deleteGradeVote(boulderID: Int, userID: String) async throws {
        let response = try await client
            .from("GradeVotes")
            .delete()
            .eq("boulder_id", value: boulderID)
            .eq("user_id", value: userID)
            .execute()
        print("Deleted response: \(response.data)")
    }
    


    //potem to dac do innej funkcji ale narazie cos nie chce mi dzialac inaczej
    struct AllGradeGroupedVotes: Identifiable {
        let id = UUID()
        let difficulty: String
        var votes: Int
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

    func getPaginatedPosts(page: Int) async throws -> [PostsD] {
        let currentGymId = UserDefaults.standard.string(forKey: "selectedGym")
        let pageSize = 10
        let start = (page - 1) * pageSize  // Zmiana tutaj
        
        let posts: [PostsD] = try await client
            .from("Posts")
            .select("*")
            .eq("gym_id", value: currentGymId)
            .range(from: start, to: start + (pageSize - 1))  // Zmiana tutaj
            .order("post_id", ascending: false)
            .execute()
            .value
        
        return posts
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
    
    
    func getToppedBoulders(forUserID userID: String) async throws -> [ToppedBy] {
        let toppedBoulders = try await client
            .from("ToppedBy")
            .select("*")
            .eq("user_id", value: userID)
            .execute().value as [ToppedBy]
        
        return toppedBoulders
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
    
    func fetchCurrentGymAboutUs() async throws -> GymInfo {
        guard let currentGymId = UserDefaults.standard.string(forKey: "selectedGym") else {
            throw NSError(domain: "GymError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No gym selected"])
        }
        
        let response: [GymInfo] = try await client.from("AbouGym")
            .select("*")
            .eq("id", value: currentGymId)
            .execute()
            .value
        guard let gymInfo = response.first else {
            throw NSError(domain: "GymError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Gym not found"])
        }
        return gymInfo
    }
    
    func getCurrentGymBouldersGroupedBy() async throws -> [groupedBoulders] {
        guard let currentGymId = UserDefaults.standard.string(forKey: "selectedGym") else {
            throw NSError(domain: "GymError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No gym selected"])
        }

        guard let gymId = Int(currentGymId) else {
            throw NSError(domain: "GymError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid gym ID"])
        }

        let response: [groupedBoulders] = try await client
            .rpc("fetch_grouped_boulders", params: ["input_id": gymId])
            .execute()
            .value
        return response
        print("response \(response)")
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
    var adminOf:        Int?
}

struct UserID: Encodable, Decodable{
    var id:             Int
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

struct BoulderDUpload:  Decodable, Encodable{
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

struct PostsD: Encodable, Decodable {
    var post_id:   Int
    var created_at: Date
    var text:      String
    var user_id:       Int
    var gym_id:     Int
}

struct CommentsD: Encodable, Decodable {
    var comment_id:    Int
    var created_at: Date
    var content: String
    var user_id: Int
    var post_id: Int
}

struct CommentUpload: Encodable, Decodable {
    var content: String
    var user_id: Int
    var post_id: Int
}

struct Address {
    let street:         String
    let city:           String
    let postalCode:     String
    let coordinates:    CLLocationCoordinate2D
}


struct GymInfo: Codable {
    var name: String
    var description: String
    let street: String
    let city: String
    let postal_code: String
    let latitude: Float
    let longitude: Float
    let openingHours: OpeningHoursWrapper
}

struct OpeningHoursWrapper: Codable {
    let openingHours: [String: DayHours]
}

struct DayHours: Codable {
    let open: String
    let close: String
}

struct groupedBoulders: Encodable, Decodable {
    var diff: String
    var count: Int
}
