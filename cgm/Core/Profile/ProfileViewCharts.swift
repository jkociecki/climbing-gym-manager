import SwiftUI
import Charts


struct ChartData: Identifiable {
    let id = UUID()
    let month: String // Miesiąc, który będzie na osi X
    let difficulty: Double // Punkty za dany miesiąc
}

struct LineChartView: View {
    
    let userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
    @State private var data: [ChartData] = []
    
    func generateMonthlyData() async {
        do {
            let toppedBoulders: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID)
            
            let currentMonth = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            let months = getPreviousMonths(from: currentMonth)
            
            var monthlyPoints: [String: Int] = [:]
            
            for toppedBoulder in toppedBoulders {
                if let boulder = try await DatabaseManager.shared.getBoulderByID(boulderID: toppedBoulder.boulder_id) {
                    let difficulty = boulder.diff
                    
                    if let month = extractMonth(from: toppedBoulder.created_at), months.contains(month) {
                        let points = calculatePointsForBoulder(difficulty: difficulty, isFlashed: toppedBoulder.is_flashed)
                        monthlyPoints[month, default: 0] += points
                    }
                }
            }
            
            var chartData: [ChartData] = []
            for month in months.reversed() {
                let points = monthlyPoints[month, default: 0]
                chartData.append(ChartData(month: month, difficulty: Double(points)))
            }
            
            DispatchQueue.main.async {
                self.data = chartData
            }
        } catch {
            print("Error fetching bouldering data: \(error)")
        }
    }

    func extractMonth(from createdAt: String?) -> String? {
        guard let createdAt = createdAt else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = dateFormatter.date(from: createdAt) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            let month = monthFormatter.string(from: date)
            return month
        }
        
        return nil
    }

    func getPreviousMonths(from currentMonth: String) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        let today = Date()
        var months: [String] = []

        months.append(dateFormatter.string(from: today))
        
        for i in 1..<5 {
            if let previousMonthDate = Calendar.current.date(byAdding: .month, value: -i, to: today) {
                let month = dateFormatter.string(from: previousMonthDate)
                months.append(month)
            }
        }
        
        return months
    }

    var minY: Double {
        return 0 // Ustalamy 0 jako minimalną wartość na osi Y
    }
    
    var maxY: Double {
        return (data.map { $0.difficulty }.max() ?? 0) * 1.05 // Najwyższa wartość powiększona o 5% dla lepszego widoku
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Points", item.difficulty)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Circle()
                            .fill(Color("Czerwony"))
                            .frame(width: 0.1, height: 8)
                    }
                    // Gradient na linii
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("Fioletowy"), Color("Czerwony")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
            }
            .chartYAxis {
                AxisMarks(values: [minY, maxY]) { value in
                    AxisValueLabel {
                        Text("\(value.as(Double.self) ?? 0, specifier: "%0.f")") // Wyświetlanie punktów
                    }
                }
            }
            .chartYScale(domain: minY...maxY)
            .chartXAxis {
                AxisMarks(values: .automatic)
            }
            .frame(height: 200)
        }
        .onAppear {
            Task {
                await generateMonthlyData() // Wczytaj dane podczas inicjalizacji widoku
            }
        }
    }
}



// Preview
//struct LineChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChartView()
//    }
//}


import SwiftUI
import Charts


struct DifficultyData {
    var difficulty: String
    var done: Int
}

struct BarChartView: View {
    @State private var difficultyData: [DifficultyData] = []  // Store difficulty data
    
    // Sample userID for the sake of the example
    let userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
    
    var body: some View {
        ZStack {
            // Tło pod wykresem
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
            
            VStack {
                if difficultyData.isEmpty {
                    // Loading state or message
                    Text("Loading data...")
                        .foregroundColor(.gray)
                } else {
                    // Chart with actual data
                    Chart(difficultyData.map { $0.difficulty }, id: \.self) { key in
                        BarMark(
                            x: .value("Grade", key),
                            y: .value("Count", difficultyData.first { $0.difficulty == key }?.done ?? 0),
                            width: 25
                        )
                        .cornerRadius(15)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Czerwony"), Color("Fioletowy")]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic)
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            Task {
                do {
                    difficultyData = try await generateBoulderingDifficultyData(forUserID: userID)
                } catch {
                    print("Error fetching difficulty data: \(error)")
                }
            }
        }
    }
    
    func generateBoulderingDifficultyData(forUserID userID: String) async throws -> [DifficultyData] {
        let toppedBoulders: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID)
        
        let allBoulders: [BoulderD] = try await DatabaseManager.shared.getCurrentGymBoulders()
        
        var boulderDifficultyMap: [Int: String] = [:]
        for boulder in allBoulders {
            boulderDifficultyMap[boulder.id] = boulder.diff
        }
        
        var difficultyCount: [String: Int] = [:]
        
        // Liczymy wystąpienia trudności
        for toppedBoulder in toppedBoulders {
            if let difficulty = boulderDifficultyMap[toppedBoulder.boulder_id] {
                difficultyCount[difficulty, default: 0] += 1
            }
        }
        
        let completedDifficulties = difficultyCount.keys.sorted { difficultyIndex($0) < difficultyIndex($1) }
        let highestDifficulty = completedDifficulties.last ?? ""
        
        var difficultyData: [DifficultyData] = []

        var currentDifficultyIndex = difficultyIndex(highestDifficulty)
        
        for _ in 0..<6 {
            if currentDifficultyIndex >= 0 {
                let lowerDifficulty = allDifficulties[currentDifficultyIndex]
                difficultyData.append(DifficultyData(difficulty: lowerDifficulty, done: difficultyCount[lowerDifficulty, default: 0]))
                currentDifficultyIndex -= 1
            }
        }
        
        return difficultyData.reversed()
    }

    private func difficultyIndex(_ difficulty: String) -> Int {
        return allDifficulties.firstIndex(of: difficulty) ?? -1
    }
}


struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView()
//        BarChartView()
    }
}

