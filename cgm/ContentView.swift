import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "house"
    @State private var selectedGym: String? = UserDefaults.standard.string(forKey: "selectedGym")
    @State private var showSideMenu: Bool = false // Stan bocznego menu
    @State private var selectedView: String = "home" // Stan wybranego widoku
    
    var body: some View {
        ZStack {
            if selectedGym == nil {
                VStack {
                    SelectGymView()
                    
                    Button("Save") {
                        let gymName = "Example Gym"
                        UserDefaults.standard.set(gymName, forKey: "selectedGym")
                        selectedGym = gymName
                    }
                }
            } else {
                
                VStack {
                    TopBar(selectedTab: $selectedTab, showSideMenu: $showSideMenu) // Przekazanie stanu menu
                    TabView(selectedTab: $selectedTab, selectedView: $selectedView)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            
            // Boczne menu
            SideMenuView(showSideMenu: $showSideMenu, selectedView: $selectedView)
        }
    }
}

struct TopBar: View {
    @Binding var selectedTab: String
    @Binding var showSideMenu: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    showSideMenu.toggle() // Pokazanie/ukrycie menu
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            Text(tabTitle(for: selectedTab))
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    private func tabTitle(for tab: String) -> String {
        switch tab {
        case "house": return "Ekran Główny"
        case "chart.bar": return "Statystyki"
        case "person": return "Profil"
        case "plus": return "Dodaj"
        default: return "Nieznana Zakładka"
        }
    }
}

struct SideMenuView: View {
    @Binding var showSideMenu: Bool
    @Binding var selectedView: String // Przekazanie stanu wybranego widoku
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading) {
                    // Profile info
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                            Text("With WALL UP since 12 Jan 2024")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 40)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Menu Items
                    MenuItem(title: "Home", icon: "house", selectedView: $selectedView)
                    MenuItem(title: "Profile", icon: "person", selectedView: $selectedView)
                    MenuItem(title: "Your Posts", icon: "square.and.pencil", selectedView: $selectedView)
                    MenuItem(title: "Logout", icon: "arrow.backward", selectedView: $selectedView)
                    
                    Divider()
                    
                    Text("YOUR GYM")
                        .font(.headline)
                        .padding(.vertical, 10)
                    
                    MenuItem(title: "About Gym", icon: "info.circle", selectedView: $selectedView)
                    MenuItem(title: "Groto", icon: "house", selectedView: $selectedView)
                    MenuItem(title: "Favourites", icon: "heart", selectedView: $selectedView)
                    
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width * 0.7)
                .background(Color.white)
                .offset(x: showSideMenu ? 0 : -geometry.size.width * 0.7)
                .animation(.easeInOut, value: showSideMenu)
                
                Spacer()
            }
            .background(Color.black.opacity(showSideMenu ? 0.5 : 0))
            .onTapGesture {
                withAnimation {
                    showSideMenu = false
                }
            }
        }
    }
}

struct MenuItem: View {
    var title: String
    var icon: String
    @Binding var selectedView: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedView = title.lowercased() // Ustawienie wybranego widoku
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                Text(title)
                    .foregroundColor(.black)
                    .font(.headline)
            }
            .padding(.vertical, 8)
        }
    }
}

struct TabView: View {
    @Binding var selectedTab: String
    @Binding var selectedView: String // Przekazanie stanu wybranego widoku
    
    var body: some View {
        ZStack {
            switch selectedView {
            case "home":
                HomeView()
            case "profile":
                ProfileView()
            case "your posts":
                PostsView()
            default:
                Text("Nieznana zakładka")
            }
        }
        .animation(.easeInOut, value: selectedView)
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home")
            .font(.largeTitle)
            .foregroundColor(.green)
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
}

struct PostsView: View {
    var body: some View {
        Text("Your Posts")
            .font(.largeTitle)
            .foregroundColor(.orange)
    }
}


struct CustomTabBar: View {
    @Binding var selectedTab: String
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(image: "house", selectedTab: $selectedTab, isSelectedColor: Color("Czerwony"))
            TabBarButton(image: "chart.bar", selectedTab: $selectedTab, isSelectedColor: Color("Czerwony"))
            TabBarButton(image: "person", selectedTab: $selectedTab, isSelectedColor: Color("Czerwony"))
            TabBarButton(image: "plus", selectedTab: $selectedTab, isSelectedColor: Color("Czerwony"))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 30)
        .background(Color.black.opacity(0.8))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct TabBarButton: View {
    var image: String
    @Binding var selectedTab: String
    var isSelectedColor: Color
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = image
            }
        }) {
            Image(systemName: image)
                .font(.system(size: 30, weight: .regular))
                .foregroundColor(selectedTab == image ? isSelectedColor : Color.white)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainView()
}
