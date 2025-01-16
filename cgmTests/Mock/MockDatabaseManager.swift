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

