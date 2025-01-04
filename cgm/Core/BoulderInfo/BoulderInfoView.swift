//
//  BoulderInfoView.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 20/12/2024.
//


//TODO

    //czciionke dodac
    //zrobic zeby gradient byl spokny dla ikonki i tekstu w buttonach

import SwiftUI

struct BoulderInfoView: View {
    @StateObject var viewModel: BoulderInfoModel
    @Binding var boulders: [Boulder]

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                AnimatedLoader(size: 60) 
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    VStack {
                        Spacer()
                        BoulderTopBar(
                            difficulty: viewModel.difficulty,
                            sector: viewModel.sector,
                            routesetter: viewModel.routesetter,
                            color: viewModel.color
                        )
                        Buttons_FL_Done(viewModel: viewModel, boulders: $boulders)

                        Divider()
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                        
                        SwitchableView(boulderInfoModel: viewModel)
                        
                        ToppedByTable(viewModel: viewModel)

                        Spacer()
                    }
                }
            }
        }
    }
}


struct Buttons_FL_Done: View {
    @ObservedObject var viewModel: BoulderInfoModel
    @Binding var boulders: [Boulder]
    func handleButtonStateChange() {
        if let boulder = boulders.firstIndex(where: { $0.id == viewModel.boulderID }) {
            if !viewModel.isDonePressed && !viewModel.isFlashPressed {
                boulders[boulder].isDone = FlashDoneNone.NotDone
            } else {
                boulders[boulder].isDone = viewModel.isFlashPressed ? FlashDoneNone.Done : FlashDoneNone.Flash
            }
        }
    }

    var body: some View {
        VStack {
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
                            handleButtonStateChange()
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
                            handleButtonStateChange()
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
                .background(isSelected ? Color("Fioletowy") :  Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(15)
        }
        .zIndex(isSelected ? 1 : 0)
    }
}

struct SwitchableView: View {

    @State private var selectedTab: Tab = .gradeRating
    @ObservedObject var boulderInfoModel: BoulderInfoModel

    enum Tab {
        case gradeRating
        case starRating
    }

    init(boulderInfoModel: BoulderInfoModel) {
        self.boulderInfoModel = boulderInfoModel
    }

    var body: some View {
        VStack {
            // Górny przełącznik zakładek
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

            // Widok zależny od wybranej zakładki
            if selectedTab == .gradeRating {
                VotesAndSliderView(
                    boulderInfoModel: boulderInfoModel
                )
            } else if selectedTab == .starRating {
                RatingSummaryAndRatingView(boulderInfoModel: boulderInfoModel)
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
    @ObservedObject var boulderInfoModel: BoulderInfoModel

    @State private var sliderValue: Double = 0
    @State private var isChanged: Bool = false
    @State private var isInitialDifficultyLoaded: Bool = false
    @State private var isSliderChanged: Bool = false
    @State private var gradeVote: GradeVote? = nil

    var body: some View {
        VStack(spacing: 0) {
            VotesBarChart(votesData: boulderInfoModel.votesData)
            
            Divider()
                .padding(.vertical, 20)

            if isInitialDifficultyLoaded {
                BoulderDifficultySlider(
                    initialDifficulty: boulderInfoModel.difficulty,
                    sliderValue: $sliderValue,
                    difficulties: getDifficultiesSubset()
                )
                .onAppear {
                    Task {
                        await fetchUserVote()
                    }
                }
                .onChange(of: sliderValue) { newValue in
                    isSliderChanged = newValue != Double(getDifficultiesSubset().firstIndex(of: gradeVote?.grade_vote ?? boulderInfoModel.difficulty) ?? 0)
                    isChanged = isSliderChanged
                }

                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await saveOrUpdateVote()
                        }
                    }) {
                        Text(getButtonText())
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(getButtonTextColor())
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

            if let fetchedVote = try await DatabaseManager.shared.getGradeVote(boulderID: boulderInfoModel.boulderID, userID: boulderInfoModel.userID) {
                gradeVote = fetchedVote
                if let index = difficulties.firstIndex(of: fetchedVote.grade_vote) {
                    sliderValue = Double(index)
                }
                isChanged = true
            } else {
                if let index = difficulties.firstIndex(of: boulderInfoModel.difficulty) {
                    sliderValue = Double(index)
                }
                gradeVote = nil
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
            user_id: boulderInfoModel.userID,
            boulder_id: boulderInfoModel.boulderID,
            created_at: ISO8601DateFormatter().string(from: Date()),
            grade_vote: selectedDifficulty
        )

        do {
            if let existingVote = gradeVote {
                if existingVote.grade_vote == selectedDifficulty {
                    try await DatabaseManager.shared.deleteGradeVote(boulderID: existingVote.boulder_id, userID: existingVote.user_id)
                    print("Deleted grade vote")
                    updateVotesDataForDelete(gradeVote: existingVote)
                    gradeVote = nil
                    isChanged = false
                } else {
                    try await DatabaseManager.shared.updateGradeVote(gradeVote: newGradeVote)
                    print("Updated grade vote")
                    updateVotesDataForUpdate(oldVote: existingVote, newVote: newGradeVote)
                    gradeVote = newGradeVote
                }
            } else {
                try await DatabaseManager.shared.updateGradeVote(gradeVote: newGradeVote)
                print("Created new grade vote")
                updateVotesDataForUpdate(oldVote: nil, newVote: newGradeVote)
                gradeVote = newGradeVote
                isChanged = true
            }
        } catch {
            print("Error saving or updating grade vote: \(error)")
        }
    }

    private func getCurrentDifficulty() -> String {
        let currentIndex = Int(sliderValue)
        let difficultiesSubset = getDifficultiesSubset()
        return difficultiesSubset[currentIndex]
    }

    private func getDifficultiesSubset() -> [String] {
        let currentIndex = allDifficulties.firstIndex(of: boulderInfoModel.difficulty) ?? 0
        let lowerBound = max(0, currentIndex - 4)
        let upperBound = min(allDifficulties.count - 1, currentIndex + 4)
        
        return Array(allDifficulties[lowerBound...upperBound])
    }
    
    private func getButtonText() -> String {
        if let existingVote = gradeVote {
            if existingVote.grade_vote == getCurrentDifficulty() {
                return "DELETE"
            } else {
                return "UPDATE"
            }
        } else {
            return "SAVE"
        }
    }

    private func getButtonTextColor() -> Color {
        if let existingVote = gradeVote, existingVote.grade_vote == getCurrentDifficulty() {
            return Color.gray
        } else {
            return Color("Fioletowy")
        }
    }

    private func updateVotesDataForUpdate(oldVote: GradeVote?, newVote: GradeVote) {
        var updatedVotesData = boulderInfoModel.votesData
        
        if let oldVote = oldVote {
            if let oldIndex = updatedVotesData.firstIndex(where: { $0.difficulty == oldVote.grade_vote }) {
                updatedVotesData[oldIndex].votes -= 1
            }
        }
        
        if let newIndex = updatedVotesData.firstIndex(where: { $0.difficulty == newVote.grade_vote }) {
            updatedVotesData[newIndex].votes += 1
        } else {
            updatedVotesData.append(DatabaseManager.AllGradeGroupedVotes(difficulty: newVote.grade_vote, votes: 1))
        }
        
        boulderInfoModel.votesData = updatedVotesData
    }

    private func updateVotesDataForDelete(gradeVote: GradeVote) {
        var updatedVotesData = boulderInfoModel.votesData
        
        if let oldIndex = updatedVotesData.firstIndex(where: { $0.difficulty == gradeVote.grade_vote }) {
            updatedVotesData[oldIndex].votes -= 1
        }
        boulderInfoModel.votesData = updatedVotesData
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

    // Maksymalna liczba głosów, ustawiona na 1, jeśli brak głosów, by uniknąć dzielenia przez 0
    private var maxVoteCount: Int {
        let maxVotes = votesData.map { $0.votes }.max() ?? 1
        return maxVotes == 0 ? 1 : maxVotes // Zapewnia, że nie będzie dzielenia przez 0
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
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 12, height: 110)

                            // Wysokość słupka zależna od liczby głosów, ale minimalna wysokość to 0
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
    let ratings: [StarVote]
    
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
    
    // Maksymalna liczba głosów, ustawiona na 1, gdy brak głosów, aby uniknąć dzielenia przez 0
    private var maxVoteCount: Int {
        let maxVotes = ratingDistribution.max() ?? 0
        return maxVotes == 0 ? 1 : maxVotes // Zapewnia, że nie będzie dzielenia przez 0
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
                            let width = CGFloat(ratingDistribution[rating - 1]) / CGFloat(maxVoteCount) * geometry.size.width
                            
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
        .padding(.horizontal, 20)
        .padding(.top, 30)
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
        .padding(.bottom, 20)
    }
}

struct RatingSummaryAndRatingView: View {
    @ObservedObject var boulderInfoModel: BoulderInfoModel
    
    @State private var selectedRating: Int = 5
    @State private var isChanged: Bool = false
    @State private var starVote: StarVote? = nil

    var body: some View {
        VStack(spacing: 0) {
            RatingSummaryView(ratings: boulderInfoModel.ratings)
            
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
                    Text(getButtonText())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(getButtonTextColor())
                        .padding()
                        .cornerRadius(8)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    func fetchStarVote() async {
        do {
            if let fetchedVote = try await DatabaseManager.shared.getStarVote(boulderID: boulderInfoModel.boulderID, userID: boulderInfoModel.userID) {
                starVote = fetchedVote
                selectedRating = fetchedVote.star_vote
                isChanged = false
            } else {
                starVote = nil
                isChanged = false
                selectedRating = 5
            }
        } catch {
            print("Error fetching star vote: \(error)")
        }
    }
    
    func saveOrUpdateVote() async {
        let newStarVote = StarVote(
            user_id: boulderInfoModel.userID,
            boulder_id: boulderInfoModel.boulderID,
            created_at: ISO8601DateFormatter().string(from: Date()),
            star_vote: selectedRating
        )
        
        do {
            if let existingVote = starVote {
                if existingVote.star_vote == selectedRating {
                    try await DatabaseManager.shared.deleteStarVote(boulderID: existingVote.boulder_id, userID: existingVote.user_id)
                    print("Deleted star vote")
                    updateVotesDataForDelete(starVote: existingVote)
                    starVote = nil
                    isChanged = false
                } else {
                    try await DatabaseManager.shared.updateStarVote(starVote: newStarVote)
                    print("Updated star vote")
                    updateVotesDataForUpdate(oldVote: existingVote, newVote: newStarVote)
                    starVote = newStarVote
                    isChanged = true
                }
            } else {
                try await DatabaseManager.shared.updateStarVote(starVote: newStarVote)
                print("Created new star vote")
                updateVotesDataForUpdate(oldVote: nil, newVote: newStarVote)
                starVote = newStarVote
                isChanged = true
            }
        } catch {
            print("Error saving or updating star vote: \(error)")
        }
    }
    
    private func updateVotesDataForDelete(starVote: StarVote) {
        if let index = boulderInfoModel.ratings.firstIndex(where: { $0.user_id == starVote.user_id }) {
            boulderInfoModel.ratings.remove(at: index)
        }
    }
    
    private func updateVotesDataForUpdate(oldVote: StarVote?, newVote: StarVote) {
        if let oldVote = oldVote, let index = boulderInfoModel.ratings.firstIndex(where: { $0.user_id == oldVote.user_id }) {
            boulderInfoModel.ratings[index] = newVote
        } else {
            boulderInfoModel.ratings.append(newVote)
        }
    }
    
    private func getButtonText() -> String {
        if let existingVote = starVote {
            if existingVote.star_vote == selectedRating {
                return "DELETE"
            } else {
                return "UPDATE"
            }
        } else {
            return "SAVE"
        }
    }
    
    private func getButtonTextColor() -> Color {
        if let existingVote = starVote {
            if existingVote.star_vote == selectedRating {
                return Color.gray
            } else {
                return Color("Fioletowy")
            }
        } else {
            return Color("Fioletowy")
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


