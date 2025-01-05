//
//  YourPostsView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 05/01/2025.
//

import SwiftUI

struct YourPostsView: View {
    let userID: String // UserID z sesji
    @StateObject private var gymChatModel = GymChatModel()
    @State private var selectedPost: Post? = nil // Przechowuje wybrany post
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Wyświetlanie postów
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

                    // Wskaźnik ładowania
                    if gymChatModel.isLoading {
                        loadingIndicator
                    }

                    // Informacja o końcu postów
                    if !gymChatModel.hasMorePosts && !gymChatModel.posts.isEmpty {
                        endOfContentIndicator
                    }
                }
                .padding()
            }
            .navigationTitle("Your Posts")
            .sheet(item: $selectedPost) { selectedPost in
                PostCommentsView(post: selectedPost) // Wyświetlanie widoku komentarzy
            }
        }
        .onAppear {
            // Ładowanie postów, tylko raz przy pojawieniu się widoku
            if gymChatModel.posts.isEmpty {
                Task {
                    await gymChatModel.loadPostsForUser(userID: userID)
                }
            }
        }
    }
    
    // Funkcja wyświetlająca menu akcji dla posta
    private func showActionMenu(for post: Post) {
        let actionSheet = UIAlertController(title: "Manage Post", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            print("Edit post tapped", post.post_id)
        }))
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

#Preview {
    YourPostsView(userID: "3")
}
