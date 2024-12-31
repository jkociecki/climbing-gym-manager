//
//  GymChatModel.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 26/12/2024.
//


import Foundation
import SwiftUI

struct Post: Identifiable, Equatable {
    let id =            UUID()
    let post_id:        Int
    let userName:       String
    let userImage:      String
    let date:           String
    let content:        String
    let uid:            String
    let profilePicture: UIImage?
    let commentsCount:  Int
}


class GymChatModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasMorePosts: Bool = true
    
    private var loadingTask: Task<Void, Never>?
    
    private var currentPage:                Int = 0
    private var userCache:                  [Int: String] = [:]
    private var userCacheUID:               [Int: String] = [:]
    private var userProfilePictureCache:    [Int: Data] = [:]
    private var wasLoaded:                  Bool    = false
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    @MainActor
    private func setLoading(_ loading: Bool) async {
        if loading {
            isLoading = true
            if !wasLoaded && posts.isEmpty {  // dodatkowe sprawdzenie posts.isEmpty
                try? await Task.sleep(nanoseconds: 1000_000_000)
            }
        } else {
            isLoading = false
        }
        wasLoaded = true
    }
    
    @MainActor
    func loadInitialPosts() async {
        currentPage = 1
        posts = []
        hasMorePosts = true
        await loadMorePosts()
    }
    
    @MainActor
    func refreshPosts() async {
        await loadInitialPosts()
    }
    
    @MainActor
    func loadMorePosts() async {
        guard !isLoading && hasMorePosts else { return }
        
        loadingTask?.cancel()
        loadingTask = Task {
            await setLoading(true)
            
            do {
                let newPosts = try await DatabaseManager.shared.getPaginatedPosts(page: currentPage)
                
                if newPosts.isEmpty {
                    hasMorePosts = false
                } else {
                    let postIds = newPosts.map { $0.post_id }
                    let commentsCountDict = try await DatabaseManager.shared.getCommentsCountForPosts(postIds: postIds)
                    
                    if !Task.isCancelled {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            posts.append(contentsOf: newPosts.map { post in
                                let userImage = userProfilePictureCache[post.user_id] != nil ? "profile_picture_\(post.user_id)" : "default_avatar"
                                let profilePicture = userProfilePictureCache[post.user_id].flatMap { UIImage(data: $0) }
                                
                                let commentsCount = commentsCountDict[post.post_id] ?? 0
                                
                                return Post(
                                    post_id: post.post_id,
                                    userName: userCache[post.user_id] ?? "Anonymous",
                                    userImage: userImage,
                                    date: formatter.string(from: post.created_at),
                                    content: post.text,
                                    uid: userCache[post.user_id] ?? "",
                                    profilePicture: profilePicture,
                                    commentsCount: commentsCount
                                )
                            })
                        }
                        currentPage += 1
                    }
                }
            } catch {
                print("Error loading posts: \(error)")
                hasMorePosts = false
            }
            
            if !Task.isCancelled {
                await setLoading(false)
            }
        }
    }


    private func loadUserNames(for posts: [PostsD]) async {
        for post in posts where userCache[post.user_id] == nil {
            if let userData = try? await DatabaseManager.shared.getUserOverID(userID: String(post.user_id)) {
                let fullName = (userData.name ?? "Anonymous") + " " + (userData.surname ?? "")
                userCache[post.user_id] = fullName
                userCacheUID[post.user_id] = userData.uid.uuidString
                
                Task {
                    do {
                        if let imgData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: userData.uid.uuidString) {
                            userProfilePictureCache[post.user_id] = imgData
                        } else {
                            userProfilePictureCache[post.user_id] = nil
                        }
                    } catch {
                        print("Error fetching user profile picture: \(error)")
                    }
                }
            }
        }
    }

    func loadUserProfilePictureOverUID(uid: String) async throws -> Data? {
        let img = try await StorageManager.shared.fetchUserProfilePicture(user_uid: uid)
        return img
    }
}
