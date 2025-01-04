//  SideMenuView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.

import SwiftUI

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @Binding var selectedView: String
    
    @State private var user: User?
    @State private var profileImage: Data?
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        if let profileImageData = profileImage, let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit() // Również zmienione tutaj
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .background(Circle().stroke(LinearGradient(
                                    gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ), lineWidth: 4))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(user?.name ?? "") \(user?.surname ?? "")")
                                .font(.custom("Inter18pt-Bold", size: 20))
                            Text(verbatim: user?.email ?? "example@example.com")
                                .foregroundColor(.gray)
                                .font(.custom("Inter18pt-SemiBold", size: 12))
                            HStack {
                                Text("With")
                                    .font(.custom("Inter18pt-Light", size: 12))
                                    .foregroundColor(.gray)
                                Text("WALL")
                                    .font(.custom("Righteous-Regular", size: 12))
                                    .foregroundColor(.czerwony)
                                    .frame(width: 34)
                                Text("UP")
                                    .font(.custom("Righteous-Regular", size: 12))
                                    .foregroundColor(.fioletowy)
                                    .frame(width: 16)
                                Text("since \(user?.created_at != nil ? formattedDate(user!.created_at!, dateFormat: "d MMM yyyy") : "Unknown")")
                                    .font(.custom("Inter18pt-Light", size: 12))
                                    .foregroundColor(.gray)


                            }
                        }
                    }
                    .padding(.top, 50)
                }
                .padding(.horizontal)
                Divider()
                    .padding(.vertical, 10)
                    .frame(height: 2)
                    .foregroundStyle(LinearGradient(colors: [.fioletowy, .czerwony], startPoint: .trailing, endPoint: .leading))
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        MenuGroup(title: "MAIN MENU") {
                            MenuItem(icon: "person.fill", title: "Profile Settings", selectedView: $selectedView)
                            MenuItem(icon: "doc.text.fill", title: "Your Posts", selectedView: $selectedView)
                        }
                        Divider().padding(.vertical, 10)
                        MenuGroup(title: "GYM") {
                            MenuItem(icon: "info.circle.fill", title: "About Gym", selectedView: $selectedView)
                            MenuItem(icon: "map.fill", title: "Switch Gym", selectedView: $selectedView)
                        }
                        Divider().padding(.vertical, 10)
                        MenuGroup(title: "GENERAL") {
                            MenuItem(icon: "gear", title: "Settings", selectedView: $selectedView)
                            MenuItem(icon: "arrow.right.square", title: "Logout", selectedView: $selectedView)
                        }
                        if AuthManager.shared.isAdmin {
                            MenuItem(icon: "gear", title: "Gym Owner Panel", selectedView: $selectedView)
                        }
                    }
                    .padding()
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .background(Color(UIColor.systemBackground))
            .offset(x: showSideMenu ? 0 : -UIScreen.main.bounds.width)
            .animation(.easeInOut(duration: 0.3), value: showSideMenu)
            Spacer()
        }
        .background(
            Color.black.opacity(showSideMenu ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSideMenu = false
                    }
                }
        )
        .task {
            await loadUserData()
        }
    }

    func loadUserData() async {
        do {
            user = try await DatabaseManager.shared.getUser(userID: AuthManager.shared.userUID ?? "")
            profileImage = try await StorageManager.shared.fetchUserProfilePicture(user_uid: AuthManager.shared.userUID ?? "")
        } catch {
            print("Error loading user data")
        }
    }

}



struct MenuGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Inter18pt-Light", size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            content
        }
    }
}

struct MenuItem: View {
    let icon: String
    let title: String
    @Binding var selectedView: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedView = title
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.custom("Inter18pt-Medium", size: 18))
            }
            .foregroundColor(selectedView == title ? .fioletowy : .primary)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedView == title ? Color.czerwony.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
    }
}

#Preview{
    MainView()
}
