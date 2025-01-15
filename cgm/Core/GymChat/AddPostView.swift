//
//  AddPostView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 05/01/2025.
//

import SwiftUI

struct SlidinNewPostView: View {
    @Binding var isShowing: Bool
    @StateObject private var postViewModel = PostViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                if isShowing {
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowing = false
                            }
                        }
                        .transition(.opacity)
                }
                
                HStack(spacing: 0) {
                    NewPostView(isShowing: $isShowing, viewModel: postViewModel)
                }
                .frame(width: geometry.size.width)
                .background(.white)
                .offset(x: isShowing ? 0 : geometry.size.width + 100)
                .animation(.easeInOut(duration: 0.3), value: isShowing)
            }
            .onChange(of: isShowing) { newValue in
                if newValue {
                    Task {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        await postViewModel.loadUserData()
                    }
                }
            }
        }
    }
}

class PostViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var profilePic: Data = Data()
    @Published var gymName: String = ""
    
    @MainActor
    func loadUserData() async {
        do {
            if let uid =  AuthManager.shared.userUID {
                let user = try await DatabaseManager.shared.getUser(userID: uid)
                
                DispatchQueue.main.async {
                    self.username = (user?.name ?? "") + (user?.surname ?? "")
                }
                
                if let profData = try await StorageManager.shared.fetchUserProfilePicture(user_uid: uid) {
                    DispatchQueue.main.async {
                        self.profilePic = profData
                    }
                }
                
                if let idString = UserDefaults.standard.string(forKey: "selectedGymName") {
                    DispatchQueue.main.async {
                        self.gymName = idString
                    }
                }
            }
        } catch {
            print("Error loading user data: \(error)")
        }
    }
}


struct NewPostView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isShowing: Bool
    @ObservedObject var viewModel: PostViewModel
    
    @State private var postContent: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12)
            {
                HStack(spacing: 12)
                {
                    
                    if let uiImage = UIImage(data: viewModel.profilePic) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .background(Circle().stroke(LinearGradient(
                                                            gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ), lineWidth: 5))
                    } else {
                        Image("default_avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .background(Circle().stroke(LinearGradient(
                                                            gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ), lineWidth: 5))                    }

                    
                    VStack(alignment: .leading, spacing: 4)
                    {
                        Text(viewModel.username)
                            .font(.system(size: 20, weight: .bold, design: .default))
                        
                        Divider()
                            .frame(height: 0.5)
                            .background(Color(.systemGray))
                            .padding(.horizontal, -14)
                            .padding(4)
                        
                        Text(viewModel.gymName)
                            .font(.system(size: 14, weight: .light, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task{
                            try await publishPost()
                            isShowing = false
                        }
                    })
                        {
                        VStack(spacing: 5) {
                            Image(systemName:"plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.primary)
                            
                            Text("Publish")
                                .font(.caption)
                                .foregroundColor(Color(.systemGray))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    }
                }
                .padding(.horizontal)
                
                
                TextField("Add description...", text: $postContent, axis: .vertical)
                    .padding()
                    .textFieldStyle(.plain)
                    .lineLimit(5...100)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .focused($isTextFieldFocused)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = false
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New post")
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isShowing.toggle()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                        Text(formattedDate())
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                
            }
            .onAppear {
                isTextFieldFocused = false
            }
        }.onAppear {
            isTextFieldFocused = false
            Task {
                await viewModel.loadUserData()
            }
        }
        
        
    }
    
    
    struct postUpload: Encodable {
        var created_at : Date
        var text    : String
        var user_id: Int
        var gym_id: Int
    }
    
    func publishPost() async throws {
        do{
            print("1")
            let id = try await DatabaseManager.shared.getCurrentUserDataBaseID()
            
            if let gym_id = UserDefaults.standard.string(forKey: "selectedGym") {
                print("2")
                if let i_gym_id = Int(gym_id)
                {
                    print("3")

                    let post = postUpload(created_at: Date(), text: postContent, user_id: id, gym_id: i_gym_id)
                    try await DatabaseManager.shared.client.from("Posts")
                        .insert(post)
                        .execute()
                }
            }
        
        }catch{
            print("error \(error)")
        }
    }
}


private func formattedDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yy"
    return dateFormatter.string(from: Date())
}


