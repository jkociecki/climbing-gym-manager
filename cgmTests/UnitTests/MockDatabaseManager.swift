//
//  MockDatabaseManager.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 15/01/2025.
//
import Foundation
@testable import cgm

class MockDatabaseManager: DatabaseManager {
    var mockToppedBoulders: [ToppedByForProfile] = []
    var mockGymData: [GymUserData] = []
    
    override func getCurrentGymToppedByForProfileForAllGyms(forUserID: String) async throws -> [ToppedByForProfile] {
        return mockToppedBoulders
    }
    
    override func getCurrentGymToppedByForProfile(forUserID: String) async throws -> [ToppedByForProfile] {
        return mockToppedBoulders
    }
    
    override func fetchGymData(gymID: Int) async throws -> [GymUserData] {
        return mockGymData
    }
    
    var mockPosts: [PostsD] = []
    var mockUsersData: [Int: User] = [:]
    var mockCommentsCount: [Int: Int] = [:]
    
    override func getPaginatedPosts(page: Int) async throws -> [PostsD] {
        return mockPosts
    }
    
    override func getPaginatedPostsForUser(uid: String, page: Int) async throws -> [PostsD] {
        return mockPosts
    }
    
    override func getUserOverID(userID: String) async throws -> User? {
        return mockUsersData[Int(userID) ?? 0]
    }
    
    override func getCommentsCountForPosts(postIds: [Int]) async throws -> [Int: Int] {
        return mockCommentsCount
    }
    
    override func deletePost(postId: Int) async throws {
    }
    
    var mockBoulder: BoulderD!
    var mockSector: SectorD!
    var mockToppedByData: [ToppedBy]!
    var mockVotesData: [DatabaseManager.AllGradeGroupedVotes]!
    var mockRatingsData: [StarVote]!
    
    override func getBoulderByID(boulderID: Int) async throws -> BoulderD? {
        return mockBoulder
    }
    
    override func getSectorByID(sectorID: Int) async throws -> SectorD? {
        return mockSector
    }
    
    override func getToppedBy(boulderID: Int, userID: String) async throws -> ToppedBy? {
        guard let toppedBy = mockToppedByData.first(where: { $0.user_id == userID && $0.boulder_id == boulderID }) else {
            print("No toppedBy data found for boulderID: \(boulderID) and userID: \(userID)")
            return nil
        }
        return toppedBy
    }




    
    override func fetchGroupedGradeVotes(boulderID: Int, boulderDifficulty: String) async throws -> [DatabaseManager.AllGradeGroupedVotes] {
        return mockVotesData
    }
    
    override func getBoulderStarVotes(boulderID: Int) async throws -> [StarVote] {
        return mockRatingsData
    }
}


class MockStorageManager: StorageManager {
    var mockProfilePictureData: Data?
    
    override init() {  // Add this initializer
        super.init()
    }
    
    override func fetchUserProfilePicture(user_uid: String) async throws -> Data? {
        return mockProfilePictureData
    }
}

