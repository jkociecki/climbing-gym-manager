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

struct ProfileView: View
{
    var userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
    var body: some View
    {
        ScrollView {
            VStack(spacing: 16)
            {
                VStack(spacing: 16)
                {
                    UserProfileHeader(
                                    userID: userID,
                                    statsDescription: "stats and progress"
                                )
                    DisplayUserStats(userId: userID)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16)
                {
                    Text("User progress")
                        .font(.system(size: 17, weight: .bold))
                        .padding(.horizontal)
                    
                    SwitchableViewProfile()
                    
                    TopTenBoulders(userID: userID)

                }

            }
            .padding(.vertical)
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
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 53)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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
                    // Pobieranie danych użytkownika
                    let user = try await DatabaseManager.shared.getUser(userID: userID)
                    userName = makeUserName(from: user)
                    
                    // Pobieranie zdjęcia profilowego
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
    var userId: String
    @State private var flashes: Int = 0
    @State private var tops: Int = 0
    @State private var accountCreationDate: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            StatBox(title: "\(tops) Tops", subtitle: sinceText)
            StatBox(title: "\(flashes) Flashes", subtitle: sinceText)
            StatBox(title: "81 Visits", subtitle: sinceText)
        }
        .onAppear {
            Task {
                do {
                    let user = try await DatabaseManager.shared.getUserDetails(userID: userId)
                    accountCreationDate = user?.created_at
                    let stats = try await DatabaseManager.shared.getUserStats(userID: userId)
                    flashes = stats.flashes
                    tops = stats.tops
                } catch {
                    print("Error fetching data: \(error)")
                }
            }
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

struct SwitchableViewProfile: View
{
    @State private var selectedTab: Tab = .progress
    enum Tab
    {
        case progress
        case combined
    }
    
    
    var body: some View
    {
        VStack
        {
            HStack(spacing: -20)
            {
                SwitchableButtonProfile(
                    buttonText: "PROGRESS",
                    isSelected: selectedTab == .progress,
                    action: {
                        selectedTab = .progress
                    }
                )
                
                SwitchableButtonProfile(
                    buttonText: "COMBINED",
                    isSelected: selectedTab == .combined,
                    action: {
                        selectedTab = .combined
                    }
                )
            }
            .padding(.horizontal)
            
            if selectedTab == .progress
            {
                LineChartView() // <-- Zmieniamy GraphView na LineChartView
                        .frame(height: 250) // Dostosowanie wysokości wykresu
                        .padding()
                        .cornerRadius(15)

            } else if selectedTab == .combined
            {
                BarChartView() // <-- Zmieniamy GraphView na LineChartView
                        .frame(height: 250) // Dostosowanie wysokości wykresu
                        .padding()
                        .cornerRadius(15)
            }
        }
    }
}

//struct ProgressSummaryView: View
//{
//    var body: some View
//    {}
//}


struct TopTenBoulders: View {
    var userID: String
    @State private var boulders: [TopTenBoulder] = []
    @State private var isLoading = true

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
                    
                    AvgPointsBox(title: "\(calculateAvgPoints())", subtitle: "points in average")
                }
                
                ForEach(boulders.indices, id: \.self) { index in
                    let boulder = boulders[index]
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(width: 18, alignment: .leading)
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
            Task {
                do {
                    let manager = TopBouldersManager()
                    boulders = try await manager.fetchTopTenBoulders(for: userID)
                } catch {
                    print("Failed to load boulders: \(error)")
                }
                isLoading = false
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func calculateAvgPoints() -> Int {
        guard !boulders.isEmpty else { return 0 }
        let totalPoints = boulders.reduce(0) { $0 + $1.pointsForBoulder }
        return totalPoints / boulders.count
    }
}


struct AvgPointsBox: View
{
    let title: String
    let subtitle: String
    
    var body: some View
    {
        
//        VStack {
//            Text(title)
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(Color.white)
//
//            Text(subtitle)
//                .font(.system(size: 10, weight: .light))
//                .foregroundColor(Color.white)
//        }
//        .frame(maxWidth: 115, minHeight: 53)
//        .background(Color(hex: "FE4851"))
//        .cornerRadius(15)
//        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
//
//    }
        VStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.black)

            Text(subtitle)
                .font(.system(size: 10, weight: .light))
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: 115, minHeight: 53)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

    }
}

// Podgląd w trybie projektowania
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

