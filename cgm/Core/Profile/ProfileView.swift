//
//  ProfileView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 25/12/2024.
//


//
//  ProfileView.swift
//  climbing-gym-manager
//
//  Created by Malwina Juchiewicz on 20/11/2024.
//

import SwiftUI
import Charts

struct ProfileView: View {
    @StateObject var chartsViewModel: ChartsViewModel
    @StateObject var topBouldersViewModel: TopBouldersManager
    @State private var topBoulders: [TopTenBoulder] = []
    @Binding var isLoading: Bool
    @Binding var show_data_all_gyms: Bool
    
    init(userID: String, isLoading: Binding<Bool>, show_data_all_gyms: Binding<Bool>) {
        _chartsViewModel = StateObject(wrappedValue: ChartsViewModel(userID: userID, show_for_all_gyms: show_data_all_gyms.wrappedValue))
        _topBouldersViewModel = StateObject(wrappedValue: TopBouldersManager(userID: userID, show_for_all_gyms: show_data_all_gyms.wrappedValue))
        _isLoading = isLoading
        _show_data_all_gyms = show_data_all_gyms
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 16) {
                    UserProfileHeader(
                        userID: chartsViewModel.userID,
                        statsDescription: show_data_all_gyms ? "stats and progress for all gyms" : "stats and progress"
                    )
                    DisplayUserStats(
                        topBouldersViewModel: topBouldersViewModel,
                        show_data_all_gyms: $show_data_all_gyms)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("User progress")
                        .font(.system(size: 17, weight: .bold))
                        .padding(.horizontal)
                    
                    SwitchableViewProfile(viewModel: chartsViewModel)
                    
                    TopTenBoulders(topBoulders: $topBoulders)

                }
            }
            .padding(.vertical, 140)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            Task {
                isLoading = true
                await loadTopBoulders()
                await chartsViewModel.generateChartData()
                isLoading = false
            }
        }
        .onChange(of: show_data_all_gyms) { newValue in
            Task {
                isLoading = true
                
                chartsViewModel.show_for_all_gyms = newValue
                topBouldersViewModel.show_for_all_gyms = newValue
                
                await chartsViewModel.generateChartData()
                
                do {
                    try await topBouldersViewModel.loadData()
                    await loadTopBoulders()
                } catch {
                    print("Failed to load data: \(error)")
                }
                
                isLoading = false
            }
        }

    }
    
    private func loadTopBoulders() async {
        do {
            topBoulders = try await topBouldersViewModel.fetchTopTenBoulders()
        } catch {
            print("Failed to load top boulders: \(error)")
        }
    }
}

struct StatBox: View
{
    let title: String
    let subtitle: String
    
    var body: some View
    {
        VStack
        {
            Text(title)
                .font(.system(size: 20, weight: .bold))
            
            Text(subtitle)
                .font(.system(size: 10, weight: .light))
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity, minHeight: 53)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        // .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct GraphView: View
{
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .padding(.vertical)
            
            Text("Graph Placeholder")
                .foregroundColor(.gray)
        }
    }
}

struct UserProfileHeader: View {
    let userID: String
    let statsDescription: String

    @State private var userName: String = "Loading..."
    @State private var profileImageData: Data?

    var body: some View {
        HStack(spacing: 0) {
            // Wyświetlanie zdjęcia profilowego
            Image(uiImage: UIImage(data: profileImageData ?? Data()) ?? UIImage(systemName: "person.crop.circle.fill")!)
                .resizable()
                .scaledToFill()
                .frame(width: 106, height: 106)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

            VStack(alignment: .trailing, spacing: 0) {
                Text(userName)
                    .font(.system(size: 24, weight: .bold))

                Divider()
                    .background(Color.gray)
                    .frame(height: 1)
                    .padding(.vertical, 6)

                Text(statsDescription)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(Color.gray)
            }
        }
        .onAppear {
            Task {
                do {
                    let user = try await DatabaseManager.shared.getUser(userID: userID)
                    userName = makeUserName(from: user)
                    
                    profileImageData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: userID)
                } catch {
                    print("Failed to load user data or profile picture: \(error)")
                    userName = "Unknown User"
                    profileImageData = nil
                }
            }
        }
    }

    private func makeUserName(from user: User?) -> String {
        guard let user = user else { return "Unknown User" }
        let firstName = user.name ?? ""
        let lastName = user.surname ?? ""
        if firstName.isEmpty && lastName.isEmpty {
            return "Unknown User" // Jeśli oba są puste
        }
        return [firstName, lastName].joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
}


struct DisplayUserStats: View {
    @ObservedObject var topBouldersViewModel: TopBouldersManager
    @Binding var show_data_all_gyms: Bool  // Nowy Binding

    @State private var flashes: Int = 0
    @State private var tops: Int = 0
    @State private var visits: Int = 0  // Track visits
    @State private var accountCreationDate: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            StatBox(title: "\(tops) Tops", subtitle: sinceText)
            StatBox(title: "\(flashes) Flashes", subtitle: sinceText)
            StatBox(title: "\(visits) Visits", subtitle: sinceText)
        }
        .onAppear {
            Task {
                await loadUserStats()
            }
        }
        .onChange(of: show_data_all_gyms) { newValue in
            Task {

                await loadUserStats()
            }
        }
    }

    private func loadUserStats() async {
        do {
            try await topBouldersViewModel.loadData()
            
            let stats = topBouldersViewModel.getUserStats()
            flashes = stats.flashes
            tops = stats.tops

            let visitedDates = topBouldersViewModel.fetchVisitedDates()
            visits = visitedDates.count

            let user = try await DatabaseManager.shared.getUserDetails(userID: topBouldersViewModel.userID)
            accountCreationDate = user?.created_at

        } catch {
            print("Error loading user stats: \(error)")
        }
    }
    
    private var sinceText: String {
        if let date = accountCreationDate {
            return "since \(formattedDate(date, dateFormat: "MMM yyyy"))"
        } else {
            return ""
        }
    }
}


struct SwitchableButtonProfile: View
{
    var buttonText: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            Text(buttonText)
                .font(.system(size: 15, weight: .semibold))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 42)
                .background(isSelected ? Color("Fioletowy") : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(15)
        }
        .zIndex(isSelected ? 1 : 0)
    }
}


struct SwitchableViewProfile: View {
    var viewModel: ChartsViewModel
    @State private var selectedTab = 0
    
    
    var body: some View {
        VStack {
            CustomSegmentedControl(selectedIndex: $selectedTab, titles: ["PROGRESS", "COMBINED"])
                .padding(.horizontal)
            if selectedTab == 0 {
                LineChartView(viewModel: viewModel)
                    .frame(height: 250)
                    .padding()
                    .cornerRadius(15)
            } else {
                BarChartView(viewModel: viewModel)
                    .frame(height: 250)
                    .padding()
                    .cornerRadius(15)
            }
        }
    }
}


struct TopTenBoulders: View {
    @Binding var topBoulders: [TopTenBoulder]
    @State private var isLoading = true
    @State private var avgPoints: Int = 0 // Store the average points here

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView("Loading...")
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your top 10 roads")
                            .font(.system(size: 17, weight: .bold))
                        
                        Text("From past two months")
                            .font(.system(size: 10, weight: .light))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    AvgPointsBox(title: "\(avgPoints)", subtitle: "points in average")
                }
                
                ForEach(topBoulders.indices, id: \.self) { index in
                    let boulder = topBoulders[index]
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 25, alignment: .leading)
                        Circle()
                            .fill(Color(hex: boulder.color))
                            .frame(width: 25, height: 25)
                        
                        Text(boulder.level)
                            .font(.system(size: 16))
                            .frame(maxWidth: 40, alignment: .leading)
                        
                        Text(boulder.whereBouler)
                            .font(.system(size: 16))
                            .frame(maxWidth: 300, alignment: .leading)
                        
                        Spacer()
                        
                        Text(boulder.fleshPoints > 0 ? "+\(boulder.fleshPoints)" : "")
                            .font(.system(size: 16, weight: .ultraLight))
                            .frame(maxWidth: 50, alignment: .leading)
                        
                        Text("\(boulder.pointsForBoulder)")
                            .font(.system(size: 16))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear {
            isLoading = false
            calculateAvgPoints()
        }
        .onChange(of: topBoulders) { _ in
            calculateAvgPoints()
        }
        .padding(.horizontal, 16)
    }

    private func calculateAvgPoints() {
        guard !topBoulders.isEmpty else {
            avgPoints = 0
            return
        }
        let totalPoints = topBoulders.reduce(0) { $0 + $1.pointsForBoulder }
        avgPoints = totalPoints / topBoulders.count
    }
}


struct AvgPointsBox: View
{
    let title: String
    let subtitle: String
    
    var body: some View
    {
        VStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primary)

            Text(subtitle)
                .font(.system(size: 10, weight: .light))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: 115, minHeight: 53)
        .background(Color(.systemGray6))
        .cornerRadius(15)

    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(userID: "A42FC0DC-FF3A-40B7-99E0-66DA9AC67220")
//    }
//}

#Preview {
    MainView()
}
