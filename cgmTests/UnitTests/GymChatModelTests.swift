//
//  GymChatModelTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 16/01/2025.
//

import XCTest
@testable import cgm
import SwiftUICore

class GymChatModelTests: XCTestCase {
    var viewModel: GymChatModel!
    var mockDatabaseManager: MockDatabaseManager!
    var mockStorageManager: MockStorageManager!
    
    override func setUp() {
        super.setUp()
        
        mockDatabaseManager = MockDatabaseManager()
        mockStorageManager = MockStorageManager()
        DatabaseManager.shared = mockDatabaseManager
        StorageManager.shared = mockStorageManager
        
        viewModel = GymChatModel(isLoading: .constant(false))
        viewModel.isTesting = true
 
    }
    
    override func tearDown() {
        viewModel = nil
        mockDatabaseManager = nil
        mockStorageManager = nil
        
        super.tearDown()
    }

    
    func testLoadInitialPosts() async throws {
        let mockPosts = [
            PostsD(post_id: 1, created_at: Date(), text: "Post 1", user_id: 1, gym_id: 1),
            PostsD(post_id: 2, created_at: Date(), text: "Post 2", user_id: 2, gym_id: 1)
        ]
        
        let mockUserData = [
            1: User(email: "john@example.com", uid: UUID(), name: "John", surname: "Doe"),
            2: User(email: "jane@example.com", uid: UUID(), name: "Jane", surname: "Smith")
        ]
        
        let mockCommentsCounts = [1: 5, 2: 3]
        
        mockDatabaseManager.mockPosts = mockPosts
        mockDatabaseManager.mockUsersData = mockUserData
        mockDatabaseManager.mockCommentsCount = mockCommentsCounts

        await viewModel.loadInitialPosts()
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sekundy
        
        // Sprawdzenie wyników
        XCTAssertFalse(viewModel.posts.isEmpty, "Posts array should not be empty")
        XCTAssertEqual(viewModel.posts.count, 2, "Should load 2 posts")
        XCTAssertEqual(viewModel.posts[0].content, "Post 1", "Pierwszy post powinien mieć treść 'Post 1'")
        XCTAssertEqual(viewModel.posts[1].commentsCount, 3, "Drugi post powinien mieć 3 komentarze")
    }


    func testLoadMorePosts() async throws {
        let firstPagePosts = [
            PostsD(post_id: 1, created_at: Date(), text: "Post 1", user_id: 1, gym_id: 1),
            PostsD(post_id: 2, created_at: Date(), text: "Post 2", user_id: 2, gym_id: 1)
        ]
        
        let secondPagePosts = [
            PostsD(post_id: 3, created_at: Date(), text: "Post 3", user_id: 1, gym_id: 1),
            PostsD(post_id: 4, created_at: Date(), text: "Post 4", user_id: 2, gym_id: 1)
        ]
        
        let mockUserData = [
            1: User(email: "john@example.com", uid: UUID(), name: "John", surname: "Doe"),
            2: User(email: "jane@example.com", uid: UUID(), name: "Jane", surname: "Smith")
        ]
        
        mockDatabaseManager.mockPosts = firstPagePosts
        mockDatabaseManager.mockUsersData = mockUserData
        
        await viewModel.loadInitialPosts()
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sekundy
        
        XCTAssertEqual(viewModel.posts.count, 2, "Should load 2 initial posts")
        
        mockDatabaseManager.mockPosts = secondPagePosts
        
        await viewModel.loadMorePosts()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sekundy
        
        XCTAssertEqual(viewModel.posts.count, 4, "Should load 4 posts total")
    }
    
    func testEmptyPageStopsLoading() async throws {
        mockDatabaseManager.mockPosts = []
        
        await viewModel.loadInitialPosts()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sekundy
        
        XCTAssertFalse(viewModel.hasMorePosts, "hasMorePosts should be false when receiving empty page")
        XCTAssertEqual(viewModel.posts.count, 0, "Should have no posts")
    }
    
    func testLoadPostsForUser() async throws {
        let userID = UUID().uuidString
        let mockUserPosts = [
            PostsD(post_id: 1, created_at: Date(), text: "Post 1", user_id: 1, gym_id: 1),
            PostsD(post_id: 2, created_at: Date(), text: "Post 2", user_id: 1, gym_id: 1),
        ]
        
        let mockUserData = [
            1: User(email: "john@example.com", uid: UUID(), name: "John", surname: "Doe"),
        ]
        
        mockDatabaseManager.mockPosts = mockUserPosts
        mockDatabaseManager.mockUsersData = mockUserData
        
        await viewModel.loadPostsForUser(userID: userID)
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertEqual(viewModel.posts.count, 2, "Should load 2 posts for user")
        XCTAssertTrue(viewModel.posts.allSatisfy { $0.userName == "John Doe" })
    }
    
    func testDeletePost() async throws {
        let mockPosts = [
            PostsD(post_id: 1, created_at: Date(), text: "Post 1", user_id: 1, gym_id: 1),
            PostsD(post_id: 2, created_at: Date(), text: "Post 2", user_id: 2, gym_id: 1)
        ]
        
        let mockUserData = [
            1: User(email: "john@example.com", uid: UUID(), name: "John", surname: "Doe"),
            2: User(email: "jane@example.com", uid: UUID(), name: "Jane", surname: "Smith")
        ]
        
        mockDatabaseManager.mockPosts = mockPosts
        mockDatabaseManager.mockUsersData = mockUserData
        
        await viewModel.loadInitialPosts()
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertEqual(viewModel.posts.count, 2, "Should start with 2 posts")

        await viewModel.deletePost(postId: 1)
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        XCTAssertEqual(viewModel.posts.count, 1, "Should have 1 post after deletion")
        XCTAssertFalse(viewModel.posts.contains { $0.post_id == 1 }, "Deleted post should not exist")
    }
    
    func testLoadUserProfilePicture() async throws {
        let userID = UUID().uuidString
        let mockImageData = Data("test image data".utf8)
        mockStorageManager.mockProfilePictureData = mockImageData
        
        let resultData = try await viewModel.loadUserProfilePictureOverUID(uid: userID)
        
        XCTAssertNotNil(resultData, "Should return profile picture data")
        XCTAssertEqual(resultData, mockImageData, "Should return correct image data")
    }
    
    
}
