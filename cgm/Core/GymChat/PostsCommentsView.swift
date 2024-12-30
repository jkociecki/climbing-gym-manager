//
//  PostCommentsView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 27/12/2024.
//

import SwiftUI
struct PostCommentsView: View {
    @State var post: Post
    @State private var commentContent: String = ""
    @State private var comments: [CommentsD] = []
    @Binding var showComments: Bool
    @State private var userCache: [Int: String] = [:]
    @State private var userProfilePicturesCache: [Int: UIImage] = [:]  // Pamięć podręczna na zdjęcia

    private func loadUserNames() async {
        for comment in comments {
            if let userData = try? await DatabaseManager.shared.getUserOverID(userID: String(comment.user_id)) {
                let fullName = (userData.name ?? "Anonymous") + " " + (userData.surname ?? "")
                userCache[comment.user_id] = fullName
                
                // Sprawdzamy, czy zdjęcie profilowe jest dostępne
                Task {
                    do {
                        if let imgData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: userData.uid.uuidString) {
                            // Jeśli jest dostępne, zapisujemy w cache
                            userProfilePicturesCache[comment.user_id] = UIImage(data: imgData)
                        } else {
                            // Jeśli brak zdjęcia, przypisujemy domyślne zdjęcie
                            userProfilePicturesCache[comment.user_id] = UIImage(named: "default_avatar")
                        }
                    } catch {
                        print("Error fetching profile picture for user \(userData.uid.uuidString): \(error)")
                    }
                }
            }
        }
    }

    private func uploadComment(comment: CommentUpload) async {
        do {
            try await DatabaseManager.shared.uploadPostComment(comment: comment)
            await fetchComments()
            await loadUserNames()
        } catch {
            print("Błąd podczas insertowania komentarzy: \(error)")
        }
    }
    
    private func fetchComments() async {
        do {
            self.comments = try await DatabaseManager.shared.getPostComments(post_id: post.post_id)
        } catch {
            print("Błąd podczas ładowania komentarzy: \(error)")
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    showComments = false
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.fioletowy)
                        Text("Back")
                            .font(.custom("Inter18pt-Light", size: 15))
                            .foregroundColor(.fioletowy)
                    }
                }
                .padding(.top, 16)
                .padding(.leading, 16)

                PostView(post: post)

                Divider()

                ScrollView {
                    ForEach(comments, id: \.comment_id) { comment in
                        let profileImage = userProfilePicturesCache[comment.user_id] ?? UIImage(named: "default_avatar")!
                        CommentView(image: profileImage, nickname: userCache[comment.user_id] ?? "Anonymous", content: comment.content, timestamp: comment.created_at)
                    }
                }
                .frame(maxHeight: .infinity)

                HStack {
                    TextField("Dodaj Komentarz", text: $commentContent)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(RoundedRectangle(cornerRadius: 30)
                            .foregroundStyle(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal, 15)

                    Image(systemName: "paperplane")
                        .padding(.trailing, 20)
                        .foregroundColor(.fioletowy)
                        .onTapGesture {
                            Task {
                                do {
                                    let currentUserID = try await DatabaseManager.shared.getCurrentUserDataBaseID()
                                    await uploadComment(comment: CommentUpload(content: commentContent, user_id: currentUserID, post_id: post.post_id))
                                    commentContent = ""
                                } catch {
                                    print("Błąd:", error)
                                }
                            }
                        }
                }

            }
            .padding(5)
            .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(.white).opacity(0.2))
        }
        .task {
            await fetchComments()
            await loadUserNames()
        }
    }
}


import SwiftUI

struct CommentView: View {
    var image: UIImage
    var nickname: String
    var content: String
    var timestamp: Date // timestamp is now a Date

    var body: some View {
        HStack(alignment: .top, spacing: 1) {
            Image(uiImage: image)
                .resizable()
                .frame(width: 33, height: 33)
                .clipShape(Circle())
                .padding()

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(nickname)
                        .font(.custom("Inter18pt-Medium", size: 12))
                    Spacer()
                    // Format the Date directly in the view
                    Text(formattedDate(formatDate(timestamp), dateFormat: "d MMM yyyy,  HH:mm"))
//                    Text(timestamp.formatted())
                        .font(.custom("Inter18pt-Light", size: 10))
                        .padding(.trailing, 5)
                        .multilineTextAlignment(.trailing)
                }
                Text(content)
                    .font(.custom("Inter18pt-Regular", size: 12))
                    .padding(.trailing, 45)
                    .lineLimit(nil)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(hex: "F8F8F8"))
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            )
            .padding(.trailing, 20)
            .padding(.top, 10)
        }
    }
}
