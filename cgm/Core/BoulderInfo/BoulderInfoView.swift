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

struct BoulderInfoView: View {
    @StateObject var viewModel: BoulderInfoModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Spacer()
                    BoulderTopBar(
                        difficulty: viewModel.difficulty,
                        sector: viewModel.sector,
                        routesetter: viewModel.routesetter,
                        color: viewModel.color
                    )
                    Buttons_FL_Done(viewModel: viewModel)

                    Divider()
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                    
                    SwitchableView(
                        userID: viewModel.userID,
                        boulderID: viewModel.boulderID,
                        initialDifficulty: viewModel.difficulty)


                    ToppedByTable(viewModel: viewModel)

                    Spacer()
                }
            }
        }
    }
}

struct Buttons_FL_Done: View {
    @ObservedObject var viewModel: BoulderInfoModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                HStack(spacing: 16) {
                    GradientButton(
                        iconName: "hand.thumbsup.fill",
                        buttonText: "DONE",
                        gradientStartColor: Color("Czerwony"),
                        gradientEndColor: Color("Fioletowy"),
                        isPressed: viewModel.isDonePressed,
                        onTap: {
                            viewModel.isDonePressed.toggle()
                            viewModel.isFlashPressed = false
                            Task {
                                await viewModel.handleButtonStateChange()
                            }
                        }
                    )

                    GradientButton(
                        iconName: "hands.clap.fill",
                        buttonText: "FLASH",
                        gradientStartColor: Color("Fioletowy"),
                        gradientEndColor: Color("Czerwony"),
                        isPressed: viewModel.isFlashPressed,
                        onTap: {
                            viewModel.isFlashPressed.toggle()
                            viewModel.isDonePressed = false
                            Task {
                                await viewModel.handleButtonStateChange()
                            }
                        }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
    }
}

struct ToppedByTable: View {
    @ObservedObject var viewModel: BoulderInfoModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Topped by")
                .font(.system(size: 20, weight: .semibold))
                .padding(.bottom, 8)

            ForEach(viewModel.toppedByData, id: \.user_id) { toppedBy in
                HStack {
                    // Profile Image and Name
                    HStack {
                        Image(uiImage: viewModel.usersData[toppedBy.user_id]?.2
                                .flatMap { UIImage(data: $0) }
                                ?? UIImage(systemName: "person.crop.circle.fill")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())

                        if let user = viewModel.usersData[toppedBy.user_id] {
                            Text("\(user.0 ?? "") \(user.1 ?? "")")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Spacer()

                    // Flash and Date Information
                    VStack(alignment: .trailing) {
                        Text(toppedBy.is_flashed ? "FL" : "RP")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if let createdAt = toppedBy.created_at {
                            Text("\(timeAgo(from: createdAt))")
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
                await viewModel.fetchToppedByData()
            }
        }
    }
}

struct BoulderTopBar: View {
    var difficulty: String
    var sector: String
    var routesetter: String?
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
                        .fill(Color(hex: color))
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
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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

struct SwitchableView: View {
    var userID: String
    var boulderID: Int
    var initialDifficulty: String
    
    @State private var selectedTab: Tab = .gradeRating
    @StateObject private var boulderInfoModel: BoulderInfoModel
    
    enum Tab {
        case gradeRating
        case starRating
    }
    
    init(userID: String, boulderID: Int, initialDifficulty: String) {
        self.userID = userID
        self.boulderID = boulderID
        self.initialDifficulty = initialDifficulty
        _boulderInfoModel = StateObject(wrappedValue: BoulderInfoModel(boulderID: boulderID, userID: userID))
    }

    var body: some View {
        VStack {
            HStack(spacing: -20) {
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
            
            if selectedTab == .gradeRating {
                VotesAndSliderView(
                    userId: userID,
                    boulderId: boulderID,
                    initialDifficulty: boulderInfoModel.difficulty,
                    votesData: boulderInfoModel.votesData
                )
            } else if selectedTab == .starRating {
                RatingSummaryAndRatingView(userId: userID, boulderId: boulderID)
            }
        }
        .onAppear {
            Task {
                await boulderInfoModel.loadBoulderData()
            }
        }
    }
}

struct VotesAndSliderView: View {
    var userId: String
    var boulderId: Int
    var initialDifficulty: String
    var votesData: [DatabaseManager.AllGradeGroupedVotes]
    
    @State private var sliderValue: Double = 0
    @State private var isChanged: Bool = false
    @State private var isInitialDifficultyLoaded: Bool = false  // Track if initial difficulty is loaded
    
    var body: some View {
        VStack(spacing: 0) {
            // Vote Chart, you can change this based on how you want to display votes
            VotesBarChart(votesData: votesData)
            
            Divider()
                .padding(.vertical, 20)

            if isInitialDifficultyLoaded {
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
            } else {
                Text("Loading difficulty...")
                    .font(.system(size: 17, weight: .semibold))
                    .padding()
            }
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding([.leading, .top, .trailing], 16)
        .padding(.bottom, 20)
        .onAppear {
            Task {
                await fetchUserVote()
            }
        }
    }
    
    func fetchUserVote() async {
        do {
            let difficulties = getDifficultiesSubset()

            if let fetchedVote = try await DatabaseManager.shared.getGradeVote(boulderID: boulderId, userID: userId) {
                if let index = difficulties.firstIndex(of: fetchedVote.grade_vote) {
                    sliderValue = Double(index)
                } else {
                    //print("fetched vote is not in the difficulties")
                }
                isChanged = true
            } else {
                if let index = difficulties.firstIndex(of: initialDifficulty) {
                    sliderValue = Double(index)
                } else {
                    //print("initialDifficulty is not found in the difficulties list")
                }

                isChanged = false
            }
            
            isInitialDifficultyLoaded = true
        } catch {
            print("Error fetching vote")
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
    let votesData: [DatabaseManager.AllGradeGroupedVotes]

    private var maxVoteCount: Int {
        votesData.map { $0.votes }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Community grade votes")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 30)
                .padding(.leading, 12)

            Text("\(totalVotes) votes in total")
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.gray)
                .padding(.leading, 12)

            HStack(alignment: .bottom, spacing: 15) {
                ForEach(votesData) { vote in
                    VStack {
                        ZStack(alignment: .bottom) {
                            // Background bar (gray)
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 12, height: 110)

                            // Gradient filled bar based on the number of votes
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color("Czerwony"), Color("Fioletowy")]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(
                                    width: 12,
                                    height: CGFloat(vote.votes) / CGFloat(maxVoteCount) * 110
                                )
                                .shadow(radius: 2)
                        }

                        // Difficulty label with vote count at the top
                        VStack {
                            Text(vote.difficulty)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var totalVotes: Int {
        votesData.reduce(0) { $0 + $1.votes }
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
    @StateObject private var boulderInfoModel: BoulderInfoModel
    
    init(userId: String, boulderId: Int) {
        self.userId = userId
        self.boulderId = boulderId
        _boulderInfoModel = StateObject(wrappedValue: BoulderInfoModel(boulderID: boulderId, userID: userId))
    }
    
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

struct BoulderInfo_Previews: PreviewProvider {
    static var previews: some View {
        BoulderInfoView(viewModel: BoulderInfoModel(boulderID: 6))
    }
}

