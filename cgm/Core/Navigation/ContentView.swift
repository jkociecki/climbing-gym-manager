import SwiftUI


struct MainView: View {
    @State private var selectedTab:         String = "house"
    @State private var showSideMenu:        Bool = false
    @State private var selectedView:        String = "Home"
    @State private var showFilterPanel:     Bool = false
    @State private var showAddNewPost:      Bool = false
    @State private var show_data_all_gyms:  Bool = false
    @State private var isAuthenticated:     Bool = true
    @State private var isWhileZooming:      Bool = false
    @State private var isLoading:           Bool = false
    @State private var isAuthenhicating:    Bool = false
    @StateObject private var mapViewModel: MapViewModel = MapViewModel(isCurrentGym: false)
    @StateObject private var authManager = AuthManager.shared
    

    
    
    var body: some View {
         Group {
             if authManager.isAuthenticated {
                 ZStack {
                     TopBar(config: getTopBarConfig())
                         .zIndex(1)
                         .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                         .ignoresSafeArea()
                         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                         .padding(.top, -5)
                     
                     TabView(selectedTab: $selectedTab,
                            selectedView: $selectedView,
                             isLoading: $isLoading, mapViewModel: mapViewModel)
                         .frame(maxWidth: .infinity, maxHeight: .infinity)
                         .ignoresSafeArea()
                         .zIndex(0)
                     
                     CustomTabBar(selectedTab: $selectedTab, onTabSelected: { tab in
                         selectedTab = tab
                         selectedView = getDefaultViewForTab(tab)
                     })
                     .offset(x: showSideMenu ? UIScreen.main.bounds.width * 0.8 : 0)
                     .background(Color.black.opacity(0.8))
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
                     
                     SideMenuView(showSideMenu: $showSideMenu,
                                 selectedView: $selectedView)
                         .zIndex(1)
                     
                     SlidingFilterPanel(isShowing: $showFilterPanel,
                                      mapViewModel: mapViewModel)
                         .zIndex(2)
                     
                     SlidinNewPostView(isShowing: $showAddNewPost)
                         .zIndex(2)
                 }
                 .ignoresSafeArea(.keyboard, edges: .bottom)
                 .animation(.easeInOut(duration: 0.3), value: showSideMenu)
             } else {
                 RegisterView()
                     .navigationBarBackButtonHidden(true)
             }
         }
         .task {
             isAuthenhicating = true
             await authManager.checkAuth()
             isAuthenhicating = false
         }
//         .onTapGesture {
//             hideKeyboard()
//         }
     }
    
    private func getTopBarConfig() -> TopBarConfig {
        switch selectedView {
        case "Home":
            return TopBarConfig(
                title: UserDefaults.standard.string(forKey: "selectedGymName") ?? "Gym Name",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .custom(icon: "slider.vertical.3") { showFilterPanel.toggle() },
                isLoading: $isLoading
                
            )
            
        case "Statistics":
            return TopBarConfig(
                title: UserDefaults.standard.string(forKey: "selectedGymName").map { "\($0) Ranking" } ?? "Gym Ranking",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )

            
        case "Profile":
            return TopBarConfig(
                title: "Profile",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .custom(icon: "arrow.left.arrow.right", action: {
                    show_data_all_gyms.toggle()
                }),
                isLoading: $isLoading
            )
            
            
        case "Gym Owner Panel":
            return TopBarConfig(
                title: "Gym Administrator Panel",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
      
        case "Profile Settings":
            return TopBarConfig(
                title: "Profile Settings",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
            
        case "About Gym":
            return TopBarConfig(
                title: "About" +
                (UserDefaults.standard.string(forKey: "selectedGymName") ?? "Gym"),
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )

        case "Switch Gym":
            return TopBarConfig(
                title: "Select gym",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
            
        case "Settings":
            return TopBarConfig(
                title: "Settings",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
            
        case "Your Posts":
            return TopBarConfig(
                title: "Your posts",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
            

        case "Add New":
            return TopBarConfig(
                title: ( UserDefaults.standard.string(forKey: "selectedGymName") ?? "Gym" ) + " Chat",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                rightButton: .custom(icon: "plus.bubble", action: {
                    showAddNewPost.toggle()
                }),
                isLoading: $isLoading
            )
            
        default:
            return TopBarConfig(
                title: "",
                leftButton: .menuButton(showSideMenu: $showSideMenu),
                isLoading: $isLoading
            )
        }
    }
    
    private func getDefaultViewForTab(_ tab: String) -> String {
        switch tab {
        case "house":       return "Home"
        case "medal":       return "Statistics"
        case "person":      return "Profile"
        case "message":     return "Add New" // to jest chat xd
        default:            return "Home"
        }
    }
    
}


struct TabView: View {
    @Binding var selectedTab: String
    @Binding var selectedView: String
    @Binding var isLoading:     Bool
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var authManager = AuthManager.shared
    @State private var tapPosistion:        CGPoint = CGPoint(x: 0, y: 0)

    
    var body: some View {
        ZStack {
            if isTabBarSelection {
                switch selectedTab {
                case "house":
                    MapView(mapViewModel: mapViewModel, isTapInteractive: true, tapPosistion: $tapPosistion, isEdit: false, isLoading: $isLoading)
                        .onAppear {
                            mapViewModel.fetchData(isCurrentGym: true)
                        }
                case "medal":
                    RankingView(loading: $isLoading)
                case "person":
                    ProfileView(userID: AuthManager.shared.userUID ?? "", isLoading: $isLoading)
                case "message":
                    GymChatView(isLoading: $isLoading)
                default:
                    //GymChatView()
                    MapView(mapViewModel: mapViewModel, isTapInteractive: true, tapPosistion: $tapPosistion, isEdit: false, isLoading: $isLoading)
                }
            }
            else {
                switch selectedView {
                case "Profile Settings":
                    SetUpAccountView(isLoading: $isLoading)
                case "Your Posts":
                    YourPostsView()
                case "About Gym":
                    GymInfoView(isLoading: $isLoading)
                case "Switch Gym":
                    SelectGymView(isLoading: $isLoading)
                 case "Settings":
                    SettingsView()
                case "Logout":
                    LogoutHandlerView()
                case "Gym Owner Panel":
                    GymOwnerView(isLoading: $isLoading)
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
        case "house":       return "Home"
        case "medal":       return "Statistics"
        case "person":      return "Profile"
        case "message":     return "Add New" // to jest chat xd
        default:            return "Home"
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

struct LogoutHandlerView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoggingOut = false
    
    var body: some View {
        VStack {
            if isLoggingOut {
                ProgressView("Logging out...")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await handleLogout()
        }
    }
    
    private func handleLogout() async {
        isLoggingOut = true
        do {
            try await authManager.logOut()
            await authManager.checkAuth()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoggingOut = false
    }
}
