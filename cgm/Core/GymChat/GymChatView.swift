//
//  GymChatView.swift
//  temp
//
//  Created by Malwina Juchiewicz on 30/12/2024.
//



import SwiftUI

struct GymChatView: View {
    @StateObject private var gymChatModel: GymChatModel
    @State private var selectedPost: Post? = nil
    @State private var currentUserID: Int? = nil
    @Binding var isLoading: Bool

    init(isLoading: Binding<Bool>) {
        _isLoading = isLoading
        _gymChatModel = StateObject(wrappedValue: GymChatModel(isLoading: isLoading))
    }
    
    var body: some View {
        ScrollView {
            Spacer(minLength: 135)
            LazyVStack(spacing: 16) {
                postsView
                if gymChatModel.isLoading {
                    loadingIndicatorView
                }
                if !gymChatModel.hasMorePosts && !gymChatModel.posts.isEmpty {
                    endOfContentIndicatorView
                }
            }
            .padding()
        }
        .refreshable {
            await gymChatModel.refreshPosts()
        }
        .onAppear {
            loadInitialPostsAndUserID()
        }
        .sheet(item: $selectedPost) { selectedPost in
            PostCommentsView(post: selectedPost)
        }
    }
    
    private var postsView: some View {
        ForEach(gymChatModel.posts) { post in
            postView(post: post)
                .onAppear {
                    loadMorePostsIfNeeded(post: post)
                }
        }
    }
    
    private func postView(post: Post) -> some View {
        PostView(post: post)
            .transition(.opacity)
            .onTapGesture {
                selectedPost = post
            }
            .onLongPressGesture {
                if currentUserID == post.user_short_id {
                    showActionMenu(for: post)
                }

            }
    }
    
    private var loadingIndicatorView: some View {
        VStack {
            AnimatedLoader(size: 45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
        .padding(.top, UIScreen.main.bounds.height / 3)
    }

    private var endOfContentIndicatorView: some View {
        Text("No more posts to load")
            .foregroundColor(.secondary)
            .padding()
            .transition(.opacity)
    }

    private func loadMorePostsIfNeeded(post: Post) {
        if post.id == gymChatModel.posts.last?.id {
            Task {
                await gymChatModel.loadMorePosts()
            }
        }
    }

    private func loadInitialPostsAndUserID() {
        Task {
            await gymChatModel.loadInitialPosts()
            await loadCurrentUserID()
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

    private func loadCurrentUserID() async {
        do {
            currentUserID = try await DatabaseManager.shared.getCurrentUserDataBaseID()
        } catch {
            print("Błąd podczas ładowania user_id:", error)
        }
    }
}


import SwiftUI

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme

    let post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(uiImage: post.profilePicture ?? UIImage(named: "default_avatar")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 33, height: 33)
                    .clipShape(Circle())
                    .background(Circle().stroke(LinearGradient(
                                                    gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ), lineWidth: 4))

                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.userName)
                        .font(.custom("Inter18pt-Regular", size: 15))
                    
                    // Formatowanie daty bez mikrosekund, tylko dzień, miesiąc i rok
                    Text(formatDateString(post.date, dateFormat: "d MMM yyyy"))
                        .font(.custom("Inter18pt-Light", size: 12))
                        .foregroundColor(.gray)
                        
                }
                Spacer()
                
                Text(timeAgo(from: post.date))
                    .font(.custom("Inter18pt-Light", size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 2)

            Text(post.content)
                .font(.custom("Inter18pt-Regular", size: 14))
                .lineLimit(nil)
                .padding(.top, 4)
                .padding(.bottom, 16)
                .padding(.horizontal, 2)
                .lineSpacing(2)

        
            Divider()
                .frame(height: 0.5)
                .background(Color(.systemGray))
                    .padding(.horizontal, -15)
            
            HStack {
                Image(systemName: "bubble.left")
                    .foregroundStyle(Color.primary)

                Text("Comments")
                    .font(.custom("Inter18pt-SemiBold", size: 12))
                
                Text("\(post.commentsCount)")
                                  .font(.custom("Inter18pt-SemiBold", size: 12))
                                  .foregroundStyle(.gray)
            }
            .padding(.top, 4)
            .padding(.horizontal, 2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        GymChatView()
        MainView()
    }
}
