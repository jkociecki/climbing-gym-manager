//
//  BoulderInfoView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 20/12/2024.
//


//TODO
    //mozna cofac glosy
    //aktualizuje sie wykres przy klikiecy change czy save

    //czciionke dodac
    //zrobic zeby gradient byl spokny dla ikonki i tekstu w buttonach

import SwiftUI
import UIKit

struct BoulderInfo: View {
    var boulderID: Int
    var userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
    
    @State private var difficulty: String = "Loading..."
    @State private var sector: String = "Loading..."
    @State private var routesetter: String = "Loading..."
    @State private var color: String = "#00000"
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Spacer()
                    BoulderTopBar(difficulty: difficulty, sector: sector, routesetter: routesetter, color: color)
                    Buttons_FL_Done(userID: userID, boulderID: boulderID)
                    
                    Divider()
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                    
                    SwitchableView(userID: userID, boulderID: boulderID, initialDifficulty: difficulty)
                    
                    ToppedByTable(boulderID: boulderID)
                    
                    Spacer()
                }
            }
            .onAppear {
                Task {
                    await loadBoulderData()
                }
            }
        }
    }
    
    private func loadBoulderData() async {
        do {
            if let boulder = try await DatabaseManager.shared.getBoulderByID(boulderID: boulderID) {
                difficulty = boulder.diff
                color = boulder.color
                
                // Pobierz nazwę sektora
                if let sectorData = try await DatabaseManager.shared.getSectorByID(sectorID: boulder.sector_id) {
                    sector = sectorData.sector_name
                } else {
                    sector = "Unknown Sector"
                }
                
                // Dla prostoty routesetter ustawiony jako "Unknown" (można rozszerzyć logikę)
                routesetter = "Unknown"
            } else {
                difficulty = "Unknown"
                sector = "Unknown"
                routesetter = "Unknown"
            }
        } catch {
            difficulty = "Error"
            sector = "Error"
            routesetter = "Error"
        }
    }
}


struct BoulderTopBar: View {
    var difficulty: String
    var sector: String
    var routesetter: String? // Może być nil
    var color: String

    var body: some View {
        HStack {
            Text("\(difficulty) ")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [Color("Czerwony"), Color("Fioletowy")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text("\(difficulty)")
                            .font(.system(size: 60, weight: .bold))
                    )
                )

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(UIColor(hex: color) ?? .yellow)) // Bezpośrednie użycie koloru
                        .frame(width: 25, height: 25)
                    Text("\(sector)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.black)
                }

                Divider()
                    .padding(.vertical, 4)

                if let routesetter = routesetter, !routesetter.isEmpty {
                    Text(routesetter)
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(Color.gray)
                } else {
                    Text("") // Puste pole w przypadku nil lub pustego tekstu
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}


// Rozszerzenie UIColor dla obsługi Hex
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: CGFloat
        switch hexSanitized.count {
        case 6: // RGB (bez alfa)
            r = CGFloat((rgb >> 16) & 0xFF) / 255.0
            g = CGFloat((rgb >> 8) & 0xFF) / 255.0
            b = CGFloat(rgb & 0xFF) / 255.0
            a = 1.0
        case 8: // RGBA
            r = CGFloat((rgb >> 24) & 0xFF) / 255.0
            g = CGFloat((rgb >> 16) & 0xFF) / 255.0
            b = CGFloat((rgb >> 8) & 0xFF) / 255.0
            a = CGFloat(rgb & 0xFF) / 255.0
        default:
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}


struct GradientButton: View {
    var iconName: String
    var buttonText: String
    var gradientStartColor: Color
    var gradientEndColor: Color
    var isPressed: Bool
    var onTap: () -> Void

    @State private var isAnimating = false

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 25))
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isPressed ? [gradientStartColor, gradientEndColor] : [Color.gray, Color.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Image(systemName: iconName)
                            .font(.system(size: 25))
                    )
                )
            
            Text(buttonText)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.clear)
                .padding(.leading, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isPressed ? [gradientStartColor, gradientEndColor] : [Color.gray, Color.gray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text(buttonText)
                            .font(.system(size: 25, weight: .bold))
                    )
                )
        }
        .frame(maxWidth: .infinity, minHeight: 65)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .scaleEffect(isAnimating ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isAnimating.toggle()
            }
            onTap()
        }
        .animation(.easeInOut(duration: 0.2), value: isAnimating)
    }
}

struct Buttons_FL_Done: View {
    @State private var isDonePressed = false
    @State private var isFlashPressed = false
    @State private var isLoading = true
    
    
    var userID: String
    var boulderID: Int

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: 16) {
                    GradientButton(
                        iconName: "hand.thumbsup.fill",
                        buttonText: "DONE",
                        gradientStartColor: Color("Czerwony"),
                        gradientEndColor: Color("Fioletowy"),
                        isPressed: isDonePressed,
                        onTap: {
                            isDonePressed.toggle()
                            isFlashPressed = false
                            Task {
                                await handleButtonStateChange()
                            }
                        }
                    )

                    GradientButton(
                        iconName: "hands.clap.fill",
                        buttonText: "FLASH",
                        gradientStartColor: Color("Fioletowy"),
                        gradientEndColor: Color("Czerwony"),
                        isPressed: isFlashPressed,
                        onTap: {
                            isFlashPressed.toggle()
                            isDonePressed = false
                            Task {
                                await handleButtonStateChange()
                            }
                        }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .onAppear {
            Task {
                await loadInitialState()
            }
        }
    }

    private func loadInitialState() async {
        do {
            if let toppedBy = try await DatabaseManager.shared.getToppedBy(boulderID: boulderID, userID: userID) {
                isDonePressed = !toppedBy.is_flashed
                isFlashPressed = toppedBy.is_flashed
            } else {
                isDonePressed = false
                isFlashPressed = false
            }
            isLoading = false
        } catch {
            print("Failed to load data: \(error)")
            isLoading = false
        }
    }

    private func handleButtonStateChange() async {
        do {
            if !isDonePressed && !isFlashPressed {
                try await DatabaseManager.shared.deleteToppedBy(boulderID: boulderID, userID: userID)
            } else {
                let toppedBy = ToppedBy(
                    user_id: userID,
                    boulder_id: boulderID,
                    is_flashed: isFlashPressed,
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                try await DatabaseManager.shared.updateToppedBy(toppedBy: toppedBy)
            }
        } catch {
            print("Failed to update or delete data: \(error)")
        }
    }

}


struct SwitchableButton: View
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
                .background(isSelected ? Color("Fioletowy") : Color("SzaryTlo"))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(15)
        }
        .zIndex(isSelected ? 1 : 0)
    }
}

struct SwitchableView: View
{
    var userID: String
    var boulderID: Int
    var initialDifficulty: String
    
    @State private var selectedTab: Tab = .gradeRating
    
    enum Tab
    {
        case gradeRating
        case starRating
    }
    
    var body: some View
    {
        VStack
        {
            HStack(spacing: -20)
            {
                SwitchableButton(
                    buttonText: "GRADE RATING",
                    isSelected: selectedTab == .gradeRating,
                    action: {
                        selectedTab = .gradeRating
                    }
                )
                
                SwitchableButton(
                    buttonText: "STAR RATING",
                    isSelected: selectedTab == .starRating,
                    action: {
                        selectedTab = .starRating
                    }
                )
            }
            .padding(.horizontal)
            
            if selectedTab == .gradeRating
            {
                VotesAndSliderView(userId: userID, boulderId: boulderID, initialDifficulty: initialDifficulty)
                
            } else if selectedTab == .starRating
            {
                RatingSummaryAndRatingView(userId: userID, boulderId: boulderID)
            }
        }
    }
}

struct VotesAndSliderView: View {
    var userId: String
    var boulderId: Int
    var initialDifficulty: String
    
    @State private var sliderValue: Double = 0
    @State private var isChanged: Bool = false

    let allDifficulties = ["4A", "4A+", "4B", "4B+", "4C", "4C+", "5A", "5A+", "5B", "5B+", "5C", "5C+", "6A", "6A+", "7A", "7A+", "7B", "7B+", "7C", "7C+", "8A", "8A+", "8B", "8B+", "8C", "8C+", "9A", "9A+", "9B", "9B+", "9C", "9C+"]
    
    var body: some View {
        VStack(spacing: 0) {
            VotesBarChart(boulderID: 6, BoulderGrade: "5B")

            Divider()
                .padding(.vertical, 20)

            // Slider for difficulty
            BoulderDifficultySlider(
                initialDifficulty: initialDifficulty,
                sliderValue: $sliderValue,
                difficulties: getDifficultiesSubset()
            )
            .onAppear {
                Task {
                    await fetchUserVote()
                }
            }

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await saveOrUpdateVote()
                    }
                }) {
                    Text(isChanged ? "CHANGE" : "SAVE")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("Fioletowy"))
                }
                .padding(.trailing, 30)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding([.leading, .top, .trailing], 16)
        .padding(.bottom, 20)
    }
    
    func fetchUserVote() async {
        do {
            if let fetchedVote = try await DatabaseManager.shared.getGradeVote(boulderID: boulderId, userID: userId) {
                if let index = allDifficulties.firstIndex(of: fetchedVote.grade_vote) {
                    sliderValue = Double(index)
                }
                isChanged = true

            } else {
                if let index = allDifficulties.firstIndex(of: initialDifficulty) {
                    sliderValue = Double(index)
                }
                isChanged = false
            }
        } catch {
            print("Error fetching vote: \(error)")
        }
    }

    
    func saveOrUpdateVote() async {
        let selectedDifficulty = getCurrentDifficulty()
        let newGradeVote = GradeVote(
            user_id: userId,
            boulder_id: boulderId,
            created_at: ISO8601DateFormatter().string(from: Date()),
            grade_vote: selectedDifficulty
        )

        do {
            try await DatabaseManager.shared.updateGradeVote(gradeVote: newGradeVote)
            if isChanged {
                print("Updated grade vote")
            } else {
                print("Created new grade vote")
            }
            isChanged = true
        } catch {
            print("Error saving or updating star vote: \(error)")
        }
    }


    private func getCurrentDifficulty() -> String {
        let currentIndex = Int(sliderValue)
        let difficultiesSubset = getDifficultiesSubset()
        return difficultiesSubset[currentIndex]
    }

    private func getDifficultiesSubset() -> [String] {
        let currentIndex = allDifficulties.firstIndex(of: initialDifficulty) ?? 0
        let lowerBound = max(0, currentIndex - 4)
        let upperBound = min(allDifficulties.count - 1, currentIndex + 4)
        
        return Array(allDifficulties[lowerBound...upperBound])
    }
}



struct BoulderDifficultySlider: View {
    var initialDifficulty: String
    @Binding var sliderValue: Double

    var difficulties: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Your grade vote")
                .font(.headline)
                .padding(.leading, 25)
                .padding(.bottom, 45)

            ZStack {
                Slider(
                    value: $sliderValue,
                    in: 0...Double(difficulties.count - 1),
                    step: 1
                )
                .accentColor(Color("Fioletowy"))
                .padding(.horizontal, 40)
                .cornerRadius(10)

                Circle()
                    .fill(LinearGradient(
                        colors: [Color("Czerwony")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(difficulties[safeIndex(for: sliderValue)])
                            .font(.headline)
                            .foregroundColor(.white)
                    )

                    .offset(x: calculateOffsetX(), y: -40)
            }
            .padding(.bottom, 20)
        }
    }

    
    //bez tego wychodzi poza index i wywala previdew
    private func safeIndex(for value: Double) -> Int {
        let index = Int(value)
        return min(max(index, 0), difficulties.count - 1)
    }
    
    private func calculateOffsetX() -> CGFloat {
        let sliderWidth = UIScreen.main.bounds.width - 140
        let circleWidth: CGFloat = 40
        let maxSliderValue = CGFloat(difficulties.count - 1)

        let offsetX = CGFloat(sliderValue) * (sliderWidth / maxSliderValue)

        return offsetX - (sliderWidth / 2) + (circleWidth / 2) - 20
    }
}



struct VotesBarChart: View {
    @State private var votesData: [DatabaseManager.AllGradeGroupedVotes] = []
    @State private var maxVoteCount: Int = 1
    @State private var isLoading = true
    @State private var errorMessage: String?

    let boulderID: Int
    let BoulderGrade: String

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading votes...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                VStack(alignment: .leading) {
                    Text("Community grade votes")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.top, 30)
                        .padding(.leading, 12)
                    
                    Text("\(totalVotes) votes in total")
                        .font(.system(size: 13, weight: .light))
                        .foregroundColor(.gray)
                        .padding(.leading, 12)
                }

                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(votesData) { vote in
                        VStack {
                            ZStack(alignment: .bottom) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 10, height: 110)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color("Czerwony"), Color("Fioletowy")]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .frame(
                                        width: 10,
                                        height: CGFloat(vote.votes) / CGFloat(maxVoteCount) * 110
                                    )
                            }
                            Text(vote.difficulty)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .onAppear {
            Task {
                await loadVotes()
            }
        }
    }
    
    private var totalVotes: Int {
        votesData.reduce(0) { $0 + $1.votes }
    }

    private func loadVotes() async {
        do {
            let votes = try await DatabaseManager.shared.fetchGroupedGradeVotes(boulderID: boulderID, boulderDifficulty: BoulderGrade)
            DispatchQueue.main.async {
                self.votesData = votes
                self.maxVoteCount = votes.map { $0.votes }.max() ?? 1
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}



struct RatingSummaryView: View {
    @State private var ratings: [StarVote] = []
    @State private var isLoading = true
    
    let boulderID: Int
    
    var averageRating: Double {
        let totalRating = ratings.reduce(0) { $0 + Double($1.star_vote) }
        return ratings.isEmpty ? 0.0 : totalRating / Double(ratings.count)
    }
    
    var totalVotes: Int {
        ratings.count
    }
    
    var ratingDistribution: [Int] {
        (1...5).map { rating in
            ratings.filter { $0.star_vote == rating }.count
        }
    }
    
    func loadRatings() async {
        do {
            let fetchedRatings = try await DatabaseManager.shared.getBoulderStarVotes(boulderID: boulderID)
            self.ratings = fetchedRatings
            self.isLoading = false
        } catch {
            print("Failed to fetch ratings: \(error)")
            self.isLoading = false
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Rating overview")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("\(totalVotes) votes in total")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Text(String(format: "%.1f", averageRating))
                                .font(.system(size: 20, weight: .bold))
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("Czerwony"))
                        }
                        
                        Text("in average")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 20)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(1...5, id: \.self) { rating in
                        HStack {
                            Text("\(rating)")
                                .frame(width: 20, alignment: .trailing)
                                .padding(.trailing, 4)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(Color("Czerwony"))
                            
                            GeometryReader { geometry in
                                let maxVotes = ratingDistribution.max() ?? 1
                                let width = CGFloat(ratingDistribution[rating - 1]) / CGFloat(maxVotes) * geometry.size.width
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: geometry.size.width, height: 15)
                                        .cornerRadius(10)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color("Fioletowy"), Color("Czerwony")]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: width, height: 15)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(height: 15)
                            
                            Text("\(ratingDistribution[rating - 1])")
                                .font(.subheadline)
                                .frame(width: 40, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .onAppear {
            Task {
                await loadRatings()
            }
        }
    }
}

struct RatingView: View {
    @Binding var selectedRating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= selectedRating ? "star.fill" : "star")
                    .font(.system(size: 30))
                    .foregroundColor(index <= selectedRating ? Color("Czerwony") : .gray)
                    .onTapGesture {
                        selectedRating = index
                    }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 30)
    }
}




struct RatingSummaryAndRatingView: View {
    var userId: String
    var boulderId: Int
    
    @State private var selectedRating: Int = 5
    @State private var isChanged: Bool = false
    @State private var starVote: StarVote? = nil

    func fetchStarVote() async {
        do {
            if let fetchedVote = try await DatabaseManager.shared.getStarVote(boulderID: boulderId, userID: userId) {
                starVote = fetchedVote
                selectedRating = fetchedVote.star_vote
                isChanged = true
            } else {
                isChanged = false
                selectedRating = 5
            }
        } catch {
            print("Error fetching star vote: \(error)")
        }
    }



    func saveOrUpdateVote() async {
        let newStarVote = StarVote(
            user_id: userId,
            boulder_id: boulderId,
            created_at: ISO8601DateFormatter().string(from: Date()),
            star_vote: selectedRating
        )

        do {
            try await DatabaseManager.shared.updateStarVote(starVote: newStarVote)
            if isChanged {
                print("Updated star vote")
            } else {
                print("Created new star vote")
            }

            isChanged = true
        } catch {
            print("Error saving or updating star vote: \(error)")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            RatingSummaryView(boulderID: boulderId)

            RatingView(selectedRating: $selectedRating)
                .onAppear {
                    Task {
                        await fetchStarVote()
                    }
                }

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await saveOrUpdateVote()
                    }
                }) {
                    Text(isChanged ? "CHANGE" : "SAVE")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("Fioletowy"))
                }
                .padding(.trailing, 30)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding(16)
    }
}



struct ToppedByTable: View {
    var boulderID: Int
    
    @State private var toppedByData: [ToppedBy] = []
    @State private var usersData: [String: (String?, String?)] = [:]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Topped by")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 8)
            
            ForEach(toppedByData, id: \.user_id) { toppedBy in
                HStack {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                        
                        if let user = usersData[toppedBy.user_id] {
                            Text("\(user.0 ?? "") \(user.1 ?? "")")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(toppedBy.is_flashed ? "FL" : "RP")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        if let createdAt = toppedBy.created_at {
                            Text("\(timeAgo(from: createdAt))") // Używamy nowej funkcji
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color.gray)
                    .frame(height: 1)
            }
        }
        .padding(.horizontal, 20)
        .cornerRadius(8)
        .onAppear {
            Task {
                await fetchToppedByData()
            }
        }
    }

    private func timeAgo(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        
        // Spróbuj sparsować datę
        if let createdDate = formatter.date(from: dateString) {
            let calendar = Calendar.current
            let now = Date()

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: createdDate, to: now)

            switch (components.year, components.month, components.day, components.hour, components.minute, components.second) {
            case let (years?, _, _, _, _, _) where years > 0:
                return "\(years) years ago"
            case let (_, months?, _, _, _, _) where months > 0:
                return "\(months) months ago"
            case let (_, _, days?, _, _, _) where days > 0:
                return "\(days) days ago"
            case let (_, _, _, hours?, _, _) where hours > 0:
                return "\(hours) hours ago"
            case let (_, _, _, _, minutes?, _) where minutes > 0:
                return "\(minutes) minutes ago"
            case let (_, _, _, _, _, seconds?) where seconds > 0:
                return "\(seconds) seconds ago"
            default:
                return "Just now"
            }
        }
        return "Unknown"
    }



    private func fetchToppedByData() async {
        do {
            let fetchedData = try await DatabaseManager.shared.getBoulderToppedBy(boulderID: boulderID)
            toppedByData = fetchedData
            
            await fetchUsersData(for: fetchedData)
        } catch {
            print("Error fetching ToppedBy data: \(error)")
        }
    }

    private func fetchUsersData(for toppedByData: [ToppedBy]) async {
        let userIds = Set(toppedByData.map { $0.user_id })
        
        for userId in userIds {
            do {
                if let user = try await DatabaseManager.shared.getUser(userID: userId) {
                    usersData[userId] = (user.name, user.surname)
                }
            } catch {
                print("Error fetching user data for userId: \(userId), \(error)")
            }
        }
    }
}


struct BoulderInfo_Previews: PreviewProvider
{
    static var previews: some View
    {
        BoulderInfo(boulderID: 6)
    }
}
