//
//  GymChatView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 18/12/2024.
//

import SwiftUI

struct GymChatView: View {
    @StateObject private var gymChatModel = GymChatModel()
    @State private var selectedPost: Post? = nil
    @State private var showComments = false

    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(gymChatModel.posts) { post in
                        PostView(post: post)
                            .transition(.opacity)
                            .onTapGesture {
                                selectedPost = post
                                showComments = true
                            }
                            .onAppear {
                                if post.id == gymChatModel.posts.last?.id {
                                    Task {
                                        print("new posts coming")
                                        await gymChatModel.loadMorePosts()
                                    }
                                }
                            }
                        Divider()
                            .padding(.horizontal)
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
            .refreshable {
                await gymChatModel.refreshPosts()
            }
            .onAppear {
                Task {
                    await gymChatModel.loadInitialPosts()
                }
            }
            .navigationDestination(isPresented: $showComments) {
                if let post = selectedPost {
                    PostCommentsView(post: post, showComments: $showComments)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    private var loadingIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading posts...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity)
    }
    
    private var endOfContentIndicator: some View {
        Text("No more posts to load")
            .foregroundColor(.secondary)
            .padding()
            .transition(.opacity)
    }
}

import SwiftUI

struct PostView: View {
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
                
                VStack(alignment: .leading) {
                    Text(post.userName)
                        .font(.custom("Inter18pt-Regular", size: 15))
                    
                    // Formatowanie daty bez mikrosekund, tylko dzień, miesiąc i rok
                    Text(formatDate2(post.date))
                        .font(.custom("Inter18pt-Light", size: 12))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                Text(timeAgo(from: post.date))
                    .font(.custom("Inter18pt-Light", size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 2)
            
            Text(post.content)
                .font(.custom("Inter18pt-Regular", size: 14))
                .lineLimit(nil)
                .padding(.top, 4)
                .padding(.horizontal, 3)
            
            HStack {
                Image(systemName: "bubble.left")
                    .resizable()
                    .frame(width: 13, height: 13)
                Text("Comment")
                    .font(.custom("Inter18pt-SemiBold", size: 12))
                    .foregroundStyle(.black)
                
                // Wyświetlenie liczby komentarzy
                Text("\(post.commentsCount)")
                    .font(.custom("Inter18pt-SemiBold", size: 12))
                    .foregroundStyle(.gray)
            }
            .padding(.top, 4)
            .padding(.horizontal, 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GymChatView()
    }
}

