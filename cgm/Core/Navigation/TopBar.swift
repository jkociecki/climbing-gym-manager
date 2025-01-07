//
//  TopBar.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.
//

import SwiftUI

struct TopBarConfig {
    var title: String
    var leftButton: TopBarButton
    var rightButton: TopBarButton?
    var additionalContent: AnyView?
    
    static func defaultConfig(title: String, showSideMenu: Binding<Bool>) -> TopBarConfig {
        return TopBarConfig(
            title: title,
            leftButton: .menuButton(showSideMenu: showSideMenu),
            rightButton: .notificationButton {}
        )
    }
}

enum TopBarButton {
    case menu(action: () -> Void)
    case back(action: () -> Void)
    case close(action: () -> Void)
    case notification(action: () -> Void)
    case custom(icon: String, action: () -> Void)
    case customRotated(icon: String, action: () -> Void)
    
    static func menuButton(showSideMenu: Binding<Bool>) -> TopBarButton {
        .menu {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSideMenu.wrappedValue.toggle()
            }
        }
    }
    
    static func notificationButton(action: @escaping () -> Void) -> TopBarButton {
        .notification(action: action)
    }
    
    @ViewBuilder
    func buttonView() -> some View {
        switch self {
        case .menu(let action):
            Button(action: action) {
                Image(systemName: "line.horizontal.3")
                    .topBarIcon()
            }
            
        case .back(let action):
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .topBarIcon()
            }
            
        case .close(let action):
            Button(action: action) {
                Image(systemName: "xmark")
                    .topBarIcon()
            }
            
        case .notification(let action):
            Button(action: action) {
                Image(systemName: "bell")
                    .topBarIcon()
            }
            
        case .custom(let icon, let action):
            Button(action: action) {
                Image(systemName: icon)
                    .topBarIcon()
            }
            
        case .customRotated(let icon, let action):
            Button(action: action) {
                Image(systemName: icon)
                    .topBarIcon()
            }.rotationEffect(Angle(degrees: 90.0))

        }
    }
}

struct TopBar: View {
    var config: TopBarConfig
    
    var body: some View {
        let top = CGFloat(50)
        let bot = CGFloat(10)
        VStack(spacing: 0) {
            HStack {
                config.leftButton.buttonView()
                    .padding(.leading)
                    .padding(.top, top)
                    .padding(.bottom, bot)
                Spacer()
                

                Text(config.title)
                    .font(.headline)
                    .padding(.top, top)
                    .padding(.bottom, bot)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let rightButton = config.rightButton {
                    rightButton.buttonView()
                        .padding(.trailing)
                        .padding(.top, top)
                        .padding(.bottom, bot)                } else {
                            Color.clear
                                .frame(width: 44, height: 44)
                                .padding(.trailing)
                                .padding(.top, top)
                                .padding(.bottom, bot)
                }
            }
            //.padding(.top, 40)
            

            if let additionalContent = config.additionalContent {
                additionalContent
            }
        }
        .background(Color.black.opacity(0.8))
        .shadow(radius: 5)
    }
}

extension Image {
    func topBarIcon() -> some View {
        self
            .font(.system(size: 24))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
    }
}

struct HomeTopBarContent: View {
    var body: some View {
        HStack {
            Text("Additional Home Content")
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

struct ProfileTopBarContent: View {
    var body: some View {
        // Przykładowa dodatkowa zawartość dla Profile
        HStack {
            Text("Profile Settings")
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

#Preview{
    MainView()
}
