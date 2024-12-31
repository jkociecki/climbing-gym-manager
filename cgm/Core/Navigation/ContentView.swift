import SwiftUI


struct MainView: View {
    @State private var selectedTab:         String = "housee"
    @State private var showSideMenu:        Bool = false
    @State private var selectedView:        String = "Home"
    @State private var showFilterPanel:     Bool = false
    
    @StateObject private var mapViewModel: MapViewModel = MapViewModel()
    
    
    var body: some View {
            ZStack{

                TopBar(config: getTopBarConfig())
                        .zIndex(1)
                        .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, -5)
                        
                                        
                TabView(selectedTab: $selectedTab, selectedView: $selectedView, mapViewModel: mapViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(0)

                    
                CustomTabBar(selectedTab: $selectedTab, onTabSelected: { tab in
                    selectedTab = tab
                    selectedView = getDefaultViewForTab(tab)
                })
                .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                .background(Color.black.opacity(0.8)) // Tło dla TabBar
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, -40)
                
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
                
                SideMenuView(showSideMenu: $showSideMenu, selectedView: $selectedView)
                    .zIndex(1)
                
                SlidingFilterPanel(isShowing: $showFilterPanel, mapViewModel: mapViewModel)
                    .zIndex(2)
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
                    withAnimation(.easeInOut(duration: 0.3)) {
                                            showFilterPanel.toggle()
                                        }
                }
            )
            
        case "Profile":
            return TopBarConfig(
                title: "Profile",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .custom(icon: "gear") {
                    print("Settings tapped")
                }
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
        case "house":       return "Home"
        case "chart.bar":   return "Statistics"
        case "person":      return "Profile"
        case "plus":        return "Add New"
        default:            return "Home"
        }
    }
    
}


struct TabView: View {
    @Binding var selectedTab: String
    @Binding var selectedView: String
    @ObservedObject var mapViewModel: MapViewModel
    
    var body: some View {
        ZStack {
            if isTabBarSelection {
                switch selectedTab {
                case "house":
                    MapView(mapViewModel: mapViewModel)
                        .onAppear {
                            mapViewModel.fetchData()
                        }
                case "chart.bar":
                    RankingView()
                        .padding(.top, 100)
                case "person":
                    ProfileView()
                case "plus":
                    GymChatView()
                        .padding(.top, 100)
                default:
                    MapView(mapViewModel: mapViewModel)
                }
            }
            else {
                switch selectedView {
                case "Profile Settings":
                    SetUpAccountView()
                case "Your Posts":
                    AddNewView()
                case "About Gym":
                    HomeView()
                case "Switch Gym":
                    SelectGymView()
                 case "Settings":
                    AddNewView()
                case "Logout":
                    AddNewView()
                default:
                    HomeView()
                }
            }
        }
    }
    
    private var isTabBarSelection: Bool {
        !selectedTab.isEmpty && selectedView == getDefaultViewForTab(selectedTab)
    }
    
    private func getDefaultViewForTab(_ tab: String) -> String {
        switch tab {
        case "house":           return "Home"
        case "chart.bar":       return "Statistics"
        case "person":          return "Profile"
        case "plus":            return "Add New"
        default:                return "Home"
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

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Home View")
                .font(.largeTitle)
            Text("Welcome to your climbing app!")
                .foregroundColor(.gray)
            
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


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
