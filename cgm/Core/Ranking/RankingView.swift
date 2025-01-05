//
//  RankingView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 25/12/2024.
//


import SwiftUI

struct RankingView: View {
    @State private var rankingUsersData: [RankingUser] = []
    @State private var selectedGender = 0  // 0 = BOTH, 1 = MAN, 2 = WOMAN
    @State private var searchText = ""
    @State private var isLoading = true  // Track loading state
    
    var filteredUsers: [RankingUser] {
        let genderFilteredUsers: [RankingUser]
        
        // Filtruj użytkowników po płci
        switch selectedGender {
        case 1: // MAN
            genderFilteredUsers = rankingUsersData.filter { $0.gender == "M" }
        case 2: // WOMAN
            genderFilteredUsers = rankingUsersData.filter { $0.gender == "K" }
        default: // BOTH
            genderFilteredUsers = rankingUsersData
        }
        
        // Filtruj po tekście wyszukiwania
        if searchText.isEmpty {
            return genderFilteredUsers
        } else {
            return genderFilteredUsers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                SearchBar(text: $searchText)

                SelectGenderMikolajKradnieNazwe(selectedGender: $selectedGender)

                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)

                RankingInfo()

                // Show loading indicator while data is being fetched
                if isLoading {
                    loadingIndicator
                        .padding(.top, UIScreen.main.bounds.height / 6)
                } else {
                    RankingUsersView(users: filteredUsers, isSearchActive: !searchText.isEmpty)
                }
            }
            .padding(.vertical, 140)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            Task {
                do {
                    isLoading = true
                    
                    rankingUsersData = try await RankingManager().generateRanking()
                    
                    isLoading = false
                } catch {
                    print("Błąd ładowania rankingu: \(error)")
                    isLoading = false
                }
            }
        }
    }
    
    private var loadingIndicator: some View {
        VStack {
            AnimatedLoader(size: 45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
    }
}




struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding()
            
            TextField("Search...", text: $text)
                .font(.system(size: 16))
                .padding(.vertical, 10)
        }
        .background(Color(hex: "EEEEEF"))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
        
}

struct SelectGenderMikolajKradnieNazwe: View {
    @Binding var selectedGender: Int
    
    init(selectedGender: Binding<Int>) {
        self._selectedGender = selectedGender
        
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor(named: "Fioletowy")
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let defaultAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        
        appearance.setTitleTextAttributes(attributes, for: .selected)
        appearance.setTitleTextAttributes(defaultAttributes, for: .normal)
    }
    
    var body: some View {
        Picker("Gender", selection: $selectedGender) {
            Text("BOTH").tag(0)
            Text("MAN").tag(1)
            Text("WOMAN").tag(2)
        }
        .pickerStyle(.segmented)
        .padding(16)
        
    }
}

struct RankingInfo: View {
    var body: some View {
        (Text("User ranking is based on average score of ")
        + Text("top 10 ").bold()
        + Text("most challenging boulders from past ")
        + Text("2 months.").bold())
        .font(.system(size: 12))
        .padding(.horizontal)
        .multilineTextAlignment(.center)
        .foregroundColor(Color.gray)
    }
}

struct RankingUsersView: View {
    var users: [RankingUser] // Lista użytkowników
    var isSearchActive: Bool // Czy wyszukiwanie jest aktywne
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(users.indices, id: \.self) { index in
                    let user = users[index]
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 25, alignment: .leading)
                            .foregroundColor(.gray)
                            .lineLimit(1)

                        Image(uiImage: UIImage(data: user.imageData ?? Data()) ?? UIImage(systemName: "person.crop.circle.fill")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())

                        HStack {
                            Text(user.name)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: 200, alignment: .leading)
                            
                            // Dodanie pucharu dla Top 3, tylko jeśli wyszukiwanie jest wyłączone
                            if index < 3 && !isSearchActive {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : .brown))
                                    .font(.system(size: 16))
                            }
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(user.level)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text(user.progress)
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 5)
                    
                    if index < users.count - 1 {
                        Divider()
                            .background(Color.gray)
                            .frame(height: 1)
                    }
                }
            }
            .padding(16)
        }
    }
}


struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
//        RankingView()
        MainView()
    }
}
