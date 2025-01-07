import SwiftUI
import Charts

// MARK: - Models

struct ChartData: Identifiable {
    let id = UUID()
    let month: String
    let difficulty: Double
}

struct DifficultyData {
    var difficulty: String
    var done: Int
}

// MARK: - ViewModel for Both Charts

class ChartsViewModel: ObservableObject {
    @Published var lineChartData: [ChartData] = []
    @Published var barChartData: [DifficultyData] = []
    
    let userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    // Generate data for both charts
    func generateChartData() async {
        do {
            // For LineChart data
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
            
            var lineChartData: [ChartData] = []
            for month in months.reversed() {
                let points = monthlyPoints[month, default: 0]
                lineChartData.append(ChartData(month: month, difficulty: Double(points)))
            }
            
            // For BarChart data
            let allBoulders: [BoulderD] = try await DatabaseManager.shared.getCurrentGymBoulders()
            var boulderDifficultyMap: [Int: String] = [:]
            for boulder in allBoulders {
                boulderDifficultyMap[boulder.id] = boulder.diff
            }
            
            var difficultyCount: [String: Int] = [:]
            for toppedBoulder in toppedBoulders {
                if let difficulty = boulderDifficultyMap[toppedBoulder.boulder_id] {
                    difficultyCount[difficulty, default: 0] += 1
                }
            }
            
            let completedDifficulties = difficultyCount.keys.sorted { difficultyIndex($0) < difficultyIndex($1) }
            let highestDifficulty = completedDifficulties.last ?? ""
            
            var barChartData: [DifficultyData] = []
            var currentDifficultyIndex = difficultyIndex(highestDifficulty)
            
            for _ in 0..<6 {
                if currentDifficultyIndex >= 0 {
                    let lowerDifficulty = allDifficulties[currentDifficultyIndex]
                    barChartData.append(DifficultyData(difficulty: lowerDifficulty, done: difficultyCount[lowerDifficulty, default: 0]))
                    currentDifficultyIndex -= 1
                }
            }
            
            DispatchQueue.main.async {
                self.lineChartData = lineChartData
                self.barChartData = barChartData.reversed()
            }
        } catch {
            print("Error fetching data for charts: \(error)")
        }
    }
    
    private func extractMonth(from createdAt: String?) -> String? {
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

    private func getPreviousMonths(from currentMonth: String) -> [String] {
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
    
    private func difficultyIndex(_ difficulty: String) -> Int {
        return allDifficulties.firstIndex(of: difficulty) ?? -1
    }
    
    var minY: Double {
        return 0
    }
    
    var maxY: Double {
        return (lineChartData.map { $0.difficulty }.max() ?? 0) * 1.05
    }
}


struct LineChartView: View {
    @StateObject var viewModel: ChartsViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
                .padding(.horizontal, 0)
            
            if viewModel.lineChartData.isEmpty {
                // Show "No Data Available" when there's no data
                Text("No Data Available")
                    .foregroundColor(.gray)
                    .font(.title3)
                    .bold()
                    .opacity(0.6)
                    .padding()
            } else {
                // Chart with data
                Chart {
                    ForEach(viewModel.lineChartData) { item in
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
                    AxisMarks(values: [viewModel.minY, viewModel.maxY]) { value in
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%0.f")")
                        }
                    }
                }
                .chartYScale(domain: viewModel.minY...viewModel.maxY)
                .chartXAxis {
                    AxisMarks(values: .automatic)
                }
                .frame(height: 200)
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            Task {
                await viewModel.generateChartData()
            }
        }
    }
}


// MARK: - BarChartView

struct BarChartView: View {
    @StateObject var viewModel: ChartsViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.secondarySystemBackground))
                .padding(.horizontal, 0)
            
            VStack {
                if viewModel.barChartData.isEmpty {
                    // Show "No Data Available" message when no bar data
                    Text("No Data Available")
                        .foregroundColor(.gray)
                        .font(.title3)
                        .bold()
                        .opacity(0.6)
                        .padding()
                } else {
                    // Chart with data
                    Chart(viewModel.barChartData.map { $0.difficulty }, id: \.self) { key in
                        BarMark(
                            x: .value("Grade", key),
                            y: .value("Count", viewModel.barChartData.first { $0.difficulty == key }?.done ?? 0),
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
                await viewModel.generateChartData()
            }
        }
    }
}
