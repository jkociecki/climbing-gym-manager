//  YourPostsView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 05/01/2025.
//
import SwiftUI


struct YourPostsView: View {
    @State private var selectedPost: Post? = nil
    @State private var isLoading: Bool = false
    @StateObject private var gymChatModel: GymChatModel
    @State private var posts: [Post] = []
    @State private var userID: Int? = nil

    init() {
        _gymChatModel = StateObject(wrappedValue: GymChatModel(isLoading: .constant(false)))
    }

    var body: some View {
        VStack {
            Spacer(minLength: 135)

            if isLoading {
                loadingIndicator
            } else {
                if gymChatModel.posts.isEmpty {
                    noPostsIndicator
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(gymChatModel.posts) { post in
                                PostView(post: post)
                                    .onAppear {
                                        loadMorePostsIfNeeded(post: post)
                                    }
                                    .onLongPressGesture {
                                        showActionMenu(for: post)
                                    }
                                    .onTapGesture {
                                        selectedPost = post
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
                }
            }
        }
        .sheet(item: $selectedPost) { selectedPost in
            PostCommentsView(post: selectedPost)
        }
        .onAppear {
            Task {
                await loadUserData()
            }
        }
        .onDisappear {
            hideKeyboard()
        }
    }

    private func loadUserData() async {
        isLoading = true
        do {
            userID = try await DatabaseManager.shared.getCurrentUserDataBaseID()
            if let userID = userID {
                await loadPosts(userID: userID)
            }
        } catch {
            print("Error loading user ID: \(error)")
        }
    }

    private func loadPosts(userID: Int) async {
        do {
            await gymChatModel.loadPostsForUser(userID: String(userID))
        } catch {
            print("Error loading posts: \(error)")
        }
        isLoading = false
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

    private func loadMorePostsIfNeeded(post: Post) {
        if post.id == gymChatModel.posts.last?.id {
            Task {
                await gymChatModel.loadMorePosts()
            }
        }
    }

    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
    }

    private var noPostsIndicator: some View {
        Text("No posts available")
            .foregroundColor(.secondary)
            .padding()
            .transition(.opacity)
    }

    private var endOfContentIndicator: some View {
        Text("No more posts to load")
            .foregroundColor(.secondary)
            .padding()
            .transition(.opacity)
    }
}

#Preview {
    MainView()
}
