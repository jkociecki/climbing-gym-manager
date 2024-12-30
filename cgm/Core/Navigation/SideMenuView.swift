//
//  SideMenuView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @Binding var selectedView: String
    
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                            .background(Circle().stroke(LinearGradient(
                                gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ), lineWidth: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.custom("Inter18pt-Bold", size: 20))
                            
                            Text(verbatim: "jedrzej.kociecki@wp.pl")
                                .foregroundColor(.gray)
                                .font(.custom("Inter18pt-SemiBold", size: 12))


                            HStack{
                                Text("With")
                                    .font(.custom("Inter18pt-Light", size: 12))
                                    .foregroundColor(.gray)
                                Text("WALL")
                                    .font(.custom("Righteous-Regular", size: 12))
                                    .foregroundColor(.czerwony)
                                    .frame(width: 32)
                                Text("UP")
                                    .font(.custom("Righteous-Regular", size: 12))
                                    .foregroundColor(.fioletowy)
                                    .frame(width: 16)
                                Text("since 12 Jan 2024")
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
                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.fioletowy, .czerwony]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        MenuGroup(title: "MAIN MENU")
                            {
                            MenuItem(icon: "house.fill", title: "Home", selectedView: $selectedView)
                            MenuItem(icon: "person.fill", title: "Profile", selectedView: $selectedView)
                            MenuItem(icon: "doc.text.fill", title: "Your Posts", selectedView: $selectedView)
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        MenuGroup(title: "GYM") {
                            MenuItem(icon: "info.circle.fill", title: "About Gym", selectedView: $selectedView)
                            MenuItem(icon: "map.fill", title: "Groto", selectedView: $selectedView)
                            MenuItem(icon: "heart.fill", title: "Favourites", selectedView: $selectedView)
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        MenuGroup(title: "GENERAL") {
                            MenuItem(icon: "gear", title: "Settings", selectedView: $selectedView)
                            MenuItem(icon: "arrow.right.square", title: "Logout", selectedView: $selectedView)
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
