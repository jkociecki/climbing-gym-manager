//
//  YourPostsView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 05/01/2025.
//

import SwiftUI

struct YourPostsView: View {
    let userID: String
    @State private var selectedPost: Post? = nil
    @State private var isLoading: Bool = false
    @StateObject private var gymChatModel: GymChatModel

    init(userID: String) {
        self.userID = userID
        _gymChatModel = StateObject(wrappedValue: GymChatModel(isLoading: .constant(false)))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {

                    ForEach(gymChatModel.posts) { post in
                        PostView(post: post)
                            .onLongPressGesture {
                                showActionMenu(for: post)
                            }
                            .onTapGesture {
                                selectedPost = post
                            }
                            .onAppear {
                                if gymChatModel.posts.isEmpty {
                                    Task {
                                        await gymChatModel.loadPostsForUser(userID: userID)
                                    }
                                }
                            }
                    }

                    if gymChatModel.isLoading {
                        loadingIndicator
                    }

                    if !gymChatModel.hasMorePosts && !gymChatModel.posts.isEmpty {
                        endOfContentIndicator
                    }
                }
                .padding()
            }
            .navigationTitle("Your Posts")
            .sheet(item: $selectedPost) { selectedPost in
                PostCommentsView(post: selectedPost)
            }
        }
        .onAppear {
            if gymChatModel.posts.isEmpty {
                Task {
                    await gymChatModel.loadPostsForUser(userID: userID)
                }
            }
        }
    }
    

    private func showActionMenu(for post: Post) {
        let actionSheet = UIAlertController(title: "Manage Post", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            Task {
                await gymChatModel.deletePost(postId: post.post_id)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(actionSheet, animated: true)
        }
    }

    // Wskaźnik ładowania
    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
    }

    // Komunikat o końcu dostępnych postów
    private var endOfContentIndicator: some View {
        Text("No more posts to load")
            .foregroundColor(.secondary)
            .padding()
            .transition(.opacity)
    }
}


