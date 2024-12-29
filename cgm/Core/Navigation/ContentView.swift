import SwiftUI


struct MainView: View {
    @State private var selectedTab: String = "housee"
    @State private var showSideMenu: Bool = false
    @State private var selectedView: String = "Home"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Stack
            
            VStack{
                TopBar(config: getTopBarConfig())
                    .zIndex(1)
                    .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                   

                    
                TabView(selectedTab: $selectedTab, selectedView: $selectedView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            
            // Custom Tab Bar nakładający się na zawartość
            CustomTabBar(selectedTab: $selectedTab, onTabSelected: { tab in
                            // Update both selectedTab and selectedView
                            selectedTab = tab
                            selectedView = getDefaultViewForTab(tab)
                        })
                .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                .padding(.bottom, -40) // Oddalenie od dolnej krawędzi o 20 punktów
            
            // Side Menu Overlay
            if showSideMenu {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSideMenu = false
                        }
                    }
            }
            
            // Side Menu
            SideMenuView(showSideMenu: $showSideMenu, selectedView: $selectedView)
                .zIndex(1)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: showSideMenu)
    }
    
    private func getTopBarConfig() -> TopBarConfig {
        switch selectedView {
        case "Home":
            return TopBarConfig(
                title: "Home",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .notification {
                    print("Home notification tapped")
                }
            )
            
        case "Profile":
            return TopBarConfig(
                title: "Profile",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .custom(icon: "gear") {
                    print("Settings tapped")
                },
                additionalContent: AnyView(ProfileTopBarContent())
            )
            
        case "About Gym":
            return TopBarConfig(
                title: "About Gym",
                leftButton: .back {
                    selectedView = "Home"
                },
                rightButton: .custom(icon: "square.and.arrow.up") {
                    print("Share tapped")
                }
            )
            
        default:
            return TopBarConfig.defaultConfig(title: selectedView, showSideMenu: $showSideMenu)
        }
    }
    
    private func getDefaultViewForTab(_ tab: String) -> String {
        switch tab {
        case "house": return "Home"
        case "chart.bar": return "Statistics"
        case "person": return "Profile"
        case "plus": return "Add New"
        default: return "Home"
        }
    }
    
}


struct TabView: View {
    @Binding var selectedTab: String
    @Binding var selectedView: String
    
    var body: some View {
        ZStack {
            if isTabBarSelection {
                switch selectedTab {
                case "house":
                    MapView()
                case "chart.bar":
                    RankingView()
                case "person":
                    ProfileView()
                case "plus":
                    GymChatView()
                default:
                    ProfileView()
                }
            }
            else {
                switch selectedView {
                case "Home":
                    HomeView()
                        .padding(.bottom, 90)
                case "Profile":
                    SetUpAccountView()
                case "Statistics":
                    HomeView()
                        .padding(.bottom, 90)
                case "About Gym":
                    HomeView()
                        .padding(.bottom, 90)
                case "Your Posts":
                    HomeView()
                        .padding(.bottom, 90)
                case "Favourites":
                    SelectGymView()
                default:
                    HomeView()
                        .padding(.bottom, 90)
                }
            }
        }
    }
    
    // Sprawdza czy aktywna jest nawigacja z TabBara
    private var isTabBarSelection: Bool {
        !selectedTab.isEmpty && selectedView == getDefaultViewForTab(selectedTab)
    }
    
    // Mapuje tab na odpowiedni widok
    private func getDefaultViewForTab(_ tab: String) -> String {
        switch tab {
        case "house": return "Home"
        case "chart.bar": return "Statistics"
        case "person": return "Profile"
        case "plus": return "Add New"
        default: return "Home"
        }
    }
}

struct AddNewView: View {
    var body: some View {
        VStack {
            Text("Add New")
                .font(.largeTitle)
            Text("Create new content")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Example View Implementations
struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Home View")
                .font(.largeTitle)
            Text("Welcome to your climbing app!")
                .foregroundColor(.gray)
            
            // Przykładowa zawartość
            List {
                ForEach(1...15, id: \.self) { item in
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.blue)
                        Text("Route \(item)")
                        Spacer()
                        Text("6a+")
                            .foregroundColor(.gray)
                    }
                }
            }.ignoresSafeArea()
        }
    }
}

// Podobnie zaimplementuj pozostałe widoki...

// MARK: - Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
