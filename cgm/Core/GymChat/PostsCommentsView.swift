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
    @State private var userCache: [Int: String] = [:]
    @State private var userProfilePicturesCache: [Int: UIImage] = [:]
    
    @State private var showActionSheet: Bool = false
    @State private var selectedComment: CommentsD? = nil
    
    // Zmienna przechowująca aktualne user_id
    @State private var currentUserID: Int? = nil

    private func loadUserNames() async {
        for comment in comments {
            if let userData = try? await DatabaseManager.shared.getUserOverID(userID: String(comment.user_id)) {
                let fullName = (userData.name ?? "Anonymous") + " " + (userData.surname ?? "")
                userCache[comment.user_id] = fullName

                Task {
                    do {
                        if let imgData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: userData.uid.uuidString) {
                            userProfilePicturesCache[comment.user_id] = UIImage(data: imgData)
                        } else {
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
    
    private func loadCurrentUserID() async {
        do {
            currentUserID = try await DatabaseManager.shared.getCurrentUserDataBaseID()
        } catch {
            print("Błąd podczas ładowania user_id:", error)
        }
    }

    // Funkcja usuwająca komentarz z bazy danych i lokalnej listy
    private func deleteComment(commentId: Int) async {
        do {
            // Usunięcie komentarza z bazy danych
            try await DatabaseManager.shared.deleteComment(commentId: commentId)
            
            // Usunięcie komentarza z lokalnej listy
            if let index = comments.firstIndex(where: { $0.comment_id == commentId }) {
                comments.remove(at: index)
            }
            
            print("Comment with ID \(commentId) has been deleted.")
        } catch {
            print("Failed to delete comment with ID \(commentId): \(error)")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
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
                        
                        Text((formatDateString(post.date, dateFormat: "dd/MM/yyyy, HH:mm")))
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
                    .padding(.horizontal, 2)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 16)
            
            Divider()
                .background(Color(.systemGray2))
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                ForEach(comments, id: \.comment_id) { comment in
                    let profileImage = userProfilePicturesCache[comment.user_id] ?? UIImage(named: "default_avatar")!
                    CommentView(image: profileImage, nickname: userCache[comment.user_id] ?? "Anonymous", content: comment.content, timestamp: comment.created_at)
                        .onLongPressGesture {
                            if comment.user_id == currentUserID {
                                selectedComment = comment
                                showActionSheet = true // Pokaż action sheet, tylko jeśli user_id jest taki sam jak aktualny user
                            }
                        }
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
                    .foregroundColor(Color.czerwony)
                    .onTapGesture {
                        Task {
                            let currentUserID = try await DatabaseManager.shared.getCurrentUserDataBaseID()
                            await uploadComment(comment: CommentUpload(content: commentContent, user_id: currentUserID, post_id: post.post_id))
                            commentContent = ""
                        }
                    }
            }
        }
        .padding(5)
        .task {
            await fetchComments()
            await loadUserNames()
            await loadCurrentUserID()
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Manage Comment"),
                message: nil,
                buttons: [
                    .destructive(Text("Delete")) {
                        if let comment = selectedComment {
                            print("Delete clicked for comment with ID: \(comment.comment_id)")
                            if let commentId = selectedComment?.comment_id {
                                Task {
                                    await deleteComment(commentId: commentId)
                                }
                            }
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
}

struct CommentView: View {
    var image: UIImage
    var nickname: String
    var content: String
    var timestamp: Date

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
                    Text(timestamp.formatted())
                        .font(.custom("Inter18pt-Light", size: 10))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(Color(.systemGray))
                }
                .padding(.bottom, 2)
                Text(content)
                    .font(.custom("Inter18pt-Regular", size: 12))
                    .lineLimit(nil)
                    .lineSpacing(2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(.systemGray5))
            )
            .padding(.trailing, 20)
            .padding(.top, 10)
        }
    }
}

#Preview {
    MainView()
}
