//
//  GymChatView.swift
//  temp
//
//  Created by Malwina Juchiewicz on 30/12/2024.
//



import SwiftUI

struct GymChatView: View {
    @StateObject private var gymChatModel =     GymChatModel()
    @State private var selectedPost: Post? =    nil
//    @State private var showComments =           false

    
    var body: some View {
//        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(gymChatModel.posts) { post in
                        PostView(post: post)
                            .transition(.opacity)
                            .onTapGesture {
                                selectedPost = post
                                //showComments = true
                            }
                            .onAppear {
                                if post.id == gymChatModel.posts.last?.id {
                                    Task {
                                        await gymChatModel.loadMorePosts()
                                    }
                                }
                            }
                    }
                    
                    if gymChatModel.isLoading {
                        if gymChatModel.posts.isEmpty {  // pokazuj loader tylko gdy nie ma jeszcze postów
                            loadingIndicator
                                .padding(.top, UIScreen.main.bounds.height / 3)
                        }
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
            .sheet(item: $selectedPost){ selectedPost in
                PostCommentsView(post: selectedPost)
            }
//            .navigationDestination(isPresented: $showComments) {
//                if let post = selectedPost {
//                    PostCommentsView(post: post, showComments: $showComments)
//                        .navigationBarBackButtonHidden(true)
//                }
//            }
//        }
    }
    
    private var loadingIndicator: some View {
        VStack {
            AnimatedLoader(size: 45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    Text(formatDate2(post.date))
                        .font(.custom("Inter18pt-Light", size: 12))
                        .foregroundColor(.gray)
                        
                }
                Spacer()
                
                Text("5 min ago")
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
        GymChatView()
    }
}
