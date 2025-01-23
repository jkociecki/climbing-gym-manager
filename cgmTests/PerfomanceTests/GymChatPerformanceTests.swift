//
//  GymChatPerformanceTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 22/01/2025.
//
import XCTest
@testable import cgm

class GymChatModelPerformanceTests: XCTestCase {
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
    
    func testPerformanceLoadInitialPostsWithLargeDataSet() async throws {
        let userCount = 50
        let postCount = 200

        var mockPosts: [PostsD] = []
        var mockUserData: [Int: User] = [:]
        var mockCommentsCounts: [Int: Int] = [:]

        let baseDate = Date()


        for userID in 1...userCount {
            mockUserData[userID] = User(
                email: "user\(userID)@example.com",
                uid: UUID(),
                name: "User \(userID)",
                surname: "Test"
            )
        }

        for postID in 1...postCount {
            let userID = (postID % userCount) + 1
            mockPosts.append(
                PostsD(
                    post_id: postID,
                    created_at: baseDate.addingTimeInterval(-Double(postID * 3600)), 
                    text: "Post \(postID)",
                    user_id: userID,
                    gym_id: 1
                )
            )
            mockCommentsCounts[postID] = Int.random(in: 0...10)
        }


        mockDatabaseManager.mockPosts = mockPosts
        mockDatabaseManager.mockUsersData = mockUserData
        mockDatabaseManager.mockCommentsCount = mockCommentsCounts

        measure {
            let expectation = XCTestExpectation(description: "Load initial posts for 50 users and 200 posts")

            Task {
                await viewModel.loadInitialPosts()
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }

        XCTAssertFalse(viewModel.posts.isEmpty, "Posts array should not be empty after loading")
        XCTAssertEqual(viewModel.posts.count, 200, "Should load 200 posts")
    }

    
    func testPerformanceLoadMorePostsWithExistingData() async throws {
        let initialPosts = (1...1000).map { i in
            PostsD(
                post_id: i,
                created_at: Date(),
                text: "Initial Post \(i)",
                user_id: i % 50,
                gym_id: 1
            )
        }
        
        mockDatabaseManager.mockPosts = initialPosts
        await viewModel.loadInitialPosts()
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let morePosts = (1001...2000).map { i in
            PostsD(
                post_id: i,
                created_at: Date(),
                text: "More Post \(i)",
                user_id: i % 50,
                gym_id: 1
            )
        }
        
        mockDatabaseManager.mockPosts = morePosts
        
        let expectation = XCTestExpectation(description: "Load more posts")
        
        measure {
            Task {
                await viewModel.loadMorePosts()
                try await Task.sleep(nanoseconds: 500_000_000)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testPerformanceLoadUserProfilePictures() async throws {
        let userIDs = (1...100).map { _ in UUID().uuidString }
        let mockImageData = Data("test image data".utf8)
        mockStorageManager.mockProfilePictureData = mockImageData
        
        let expectation = XCTestExpectation(description: "Load profile pictures")
        
        measure {
            Task {
                for userID in userIDs {
                    _ = try await viewModel.loadUserProfilePictureOverUID(uid: userID)
                }
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testPerformanceLoadPostsForUser() async throws {
        let userID = UUID().uuidString
        
        let userCount = 5
        let postCount = 200

        var mockUserData: [Int: User] = [:]
        for userID in 1...userCount {
            mockUserData[userID] = User(
                email: "user\(userID)@example.com",
                uid: UUID(),
                name: "User \(userID)",
                surname: "Test"
            )
        }

        var mockPosts: [PostsD] = []
        for postID in 1...postCount {
            let postUserID = postID <= 50 ? 1 : (postID % userCount) + 1
            print(postUserID)
            mockPosts.append(
                PostsD(
                    post_id: postID,
                    created_at: Date(),
                    text: "Post \(postID)",
                    user_id: postUserID,
                    gym_id: 1
                )
            )
        }

        mockDatabaseManager.mockPosts = mockPosts
        mockDatabaseManager.mockUsersData = mockUserData

        measure {
            let expectation = XCTestExpectation(description: "Load posts for user with 200 posts, 50 for the given user")

            Task {
                await viewModel.loadPostsForUser(userID: userID)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }

}
