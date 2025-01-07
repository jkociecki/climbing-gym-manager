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
    @Binding var isLoading: Bool
    
    static func defaultConfig(title: String, showSideMenu: Binding<Bool>, isLoading: Binding<Bool>) -> TopBarConfig {
        return TopBarConfig(
            title: title,
            leftButton: .menuButton(showSideMenu: showSideMenu),
            rightButton: .notificationButton {}, isLoading: isLoading
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
    @State private var gradientColors = [Color.red, Color.purple, Color.red] // Początkowe kolory gradientu

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
                        .padding(.bottom, bot)
                } else {
                    Color.clear
                        .frame(width: 44, height: 44)
                        .padding(.trailing)
                        .padding(.top, top)
                        .padding(.bottom, bot)
                }
            }

            if config.isLoading {
                loadingBar
            }

            if let additionalContent = config.additionalContent {
                additionalContent
            }
        }
        .background(Color.black.opacity(0.8))
        .shadow(radius: 5)
    }

    private var loadingBar: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width, height: 6) // Gradient na pełną szerokość
            .onAppear {
                animateGradientColors()
            }
        }
        .frame(height: 6)
    }

    private func animateGradientColors() {
        let color1 = Color.red
        let color2 = Color.purple
        let color3 = Color.blue
        
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            gradientColors = [color2, color3, color2]
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                gradientColors = [color3, color1, color3]
            }
        }
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
