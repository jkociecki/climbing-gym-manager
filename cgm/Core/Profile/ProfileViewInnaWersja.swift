//import SwiftUI
//import Charts
//
//
//import SwiftUI
//import Charts
//
//struct ChartData: Identifiable {
//    let id = UUID()
//    let month: String // Miesiąc, który będzie na osi X
//    let difficulty: Double // Punkty za dany miesiąc
//}
//
//struct LineChartView: View {
//    
//    let userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
//    @State private var data: [ChartData] = []
//    
//    func generateMonthlyData() async {
//        do {
//            // Pobierz dane o boulderach użytkownika
//            let toppedBoulders: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID)
//            
//            // Przygotowanie miesięcy do przetworzenia (bieżący miesiąc i 4 poprzednie)
//            let currentMonth = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
//            let months = getPreviousMonths(from: currentMonth)
//            
//            var monthlyPoints: [String: Int] = [:]
//            
//            // Przetwarzanie danych o boulderach
//            for toppedBoulder in toppedBoulders {
//                // Pobierz dane bouldera na podstawie boulder_id
//                if let boulder = try await DatabaseManager.shared.getBoulderByID(boulderID: toppedBoulder.boulder_id) {
//                    // Uzyskaj trudność bouldera
//                    let difficulty = boulder.diff
//                    
//                    // Sprawdź miesiąc z daty 'created_at'
//                    if let month = extractMonth(from: toppedBoulder.created_at), months.contains(month) {
//                        // Oblicz punkty na podstawie trudności i tego, czy boulder został zflaszowany
//                        let points = calculatePointsForBoulder(difficulty: difficulty, isFlashed: toppedBoulder.is_flashed)
//                        // Logowanie punktów dla danego miesiąca
//                        print("Month: \(month), Points for Boulder: \(points)")
//                        monthlyPoints[month, default: 0] += points
//                    }
//                }
//            }
//            
//            // Generowanie danych do wykresu
//            var chartData: [ChartData] = []
//            for month in months.reversed() { // Odwrócenie kolejności miesięcy
//                let points = monthlyPoints[month, default: 0]
//                chartData.append(ChartData(month: month, difficulty: Double(points)))
//            }
//            
//            // Logowanie wygenerowanych danych do wykresu
//            for dataItem in chartData {
//                print("ChartData - Month: \(dataItem.month), Difficulty: \(dataItem.difficulty)")
//            }
//            
//            // Przypisanie danych do wykresu
//            DispatchQueue.main.async {
//                self.data = chartData
//            }
//        } catch {
//            print("Error fetching bouldering data: \(error)")
//        }
//    }
//
//    // Funkcja, która wyciąga miesiąc z daty 'created_at'
//    func extractMonth(from createdAt: String?) -> String? {
//        guard let createdAt = createdAt else { return nil }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Formatujemy datę zgodnie z oczekiwanym formatem
//        if let date = dateFormatter.date(from: createdAt) {
//            let monthFormatter = DateFormatter()
//            monthFormatter.dateFormat = "MMM" // Skrócona nazwa miesiąca (np. Jan, Feb, itd.)
//            let month = monthFormatter.string(from: date)
//            return month
//        }
//        
//        return nil
//    }
//
//    func getPreviousMonths(from currentMonth: String) -> [String] {
//        // Ustalamy bieżący miesiąc
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM" // Skrócona nazwa miesiąca (np. Jan, Feb, itd.)
//        
//        // Pobieramy dzisiejszą datę
//        let today = Date()
//        var months: [String] = []
//        
//        // Dodajemy bieżący miesiąc
//        months.append(dateFormatter.string(from: today))
//        
//        // Obliczamy poprzednie 4 miesiące
//        for i in 1..<5 {
//            if let previousMonthDate = Calendar.current.date(byAdding: .month, value: -i, to: today) {
//                let month = dateFormatter.string(from: previousMonthDate)
//                months.append(month)
//            }
//        }
//        
//        // Zwracamy miesiące w odwrotnej kolejności, tak aby bieżący miesiąc był na pierwszym miejscu
//        return months
//    }
//
//    // Dynamiczny zakres dla osi Y
//    var minY: Double {
//        let minValue = data.map { $0.difficulty }.min() ?? 0
//        return minValue - (minValue * 0.05)
//    }
//    
//    var maxY: Double {
//        let maxValue = data.map { $0.difficulty }.max() ?? 0
//        return maxValue + (maxValue * 0.05)
//    }
//    
//    var body: some View {
//        ZStack {
//            // Tło pod wykresem
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color(.secondarySystemBackground))
//            Chart {
//                ForEach(data) { item in
//                    LineMark(
//                        x: .value("Month", item.month), // Oś X
//                        y: .value("Points", item.difficulty) // Oś Y
//                    )
//                    .interpolationMethod(.linear) // Zmiana na prostą interpolację, aby uniknąć skoków
//                    .symbol {
//                        Circle()
//                            .fill(Color("Czerwony"))
//                            .frame(width: 6, height: 6) // Zmiana rozmiaru symbolu na bardziej widoczny
//                    }
//                    // Gradient na linii
//                    .foregroundStyle(
//                        LinearGradient(
//                            gradient: Gradient(colors: [Color("Fioletowy"), Color("Czerwony")]),
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                }
//            }
//            .chartYAxis {
//                AxisMarks(values: Array(stride(from: minY, through: maxY, by: 50))) { value in
//                    AxisValueLabel {
//                        Text("\(value.as(Double.self) ?? 0, specifier: "%0.f")") // Wyświetlanie punktów
//                    }
//                }
//            }
//            .chartYScale(domain: minY...maxY)
//            .chartXAxis {
//                AxisMarks(values: .automatic)
//            }
//            .frame(height: 200)
//        }
//        .onAppear {
//            Task {
//                await generateMonthlyData() // Wczytaj dane podczas inicjalizacji widoku
//            }
//        }
//    }
//}
//
//
//
//import SwiftUI
//import Charts
//
//
//struct BarChartView: View {
//    @State private var difficultyData: [String: Int] = [:]  // Store difficulty data
//    
//    // Sample userID for the sake of the example
//    let userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA"
//    
//    var body: some View {
//        ZStack {
//            // Tło pod wykresem
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color(.secondarySystemBackground))
//            
//            VStack {
//                if difficultyData.isEmpty {
//                    // Loading state or message
//                    Text("Loading data...")
//                        .foregroundColor(.gray)
//                } else {
//                    // Chart with actual data
//                    Chart(difficultyData.keys.sorted(), id: \.self) { key in
//                        BarMark(
//                            x: .value("Grade", key),
//                            y: .value("Count", difficultyData[key] ?? 0),
//                            width: 25
//                        )
//                        .cornerRadius(15)
//                        .foregroundStyle(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color("Czerwony"), Color("Fioletowy")]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                    }
//                    .chartXAxis {
//                        AxisMarks(values: .automatic)
//                    }
//                    .chartYAxis {
//                        AxisMarks(position: .leading, values: .automatic)
//                    }
//                    .frame(height: 200)
//                    .padding(.horizontal, 16)
//                }
//            }
//        }
//        .onAppear {
//            // Fetch the difficulty data when the view appears
//            Task {
//                do {
//                    difficultyData = try await generateBoulderingDifficultyData(forUserID: userID)
//                } catch {
//                    print("Error fetching difficulty data: \(error)")
//                }
//            }
//        }
//    }
//    
//    // Function to fetch and calculate the difficulty data
//    func generateBoulderingDifficultyData(forUserID userID: String) async throws -> [String: Int] {
//        let toppedBoulders: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID)
//        
//        let allBoulders: [BoulderD] = try await DatabaseManager.shared.getCurrentGymBoulders()
//        
//        // Mapa trudności bouldera
//        var boulderDifficultyMap: [Int: String] = [:]
//        for boulder in allBoulders {
//            boulderDifficultyMap[boulder.id] = boulder.diff
//        }
//        
//        // Zliczanie ukończonych boulderów według trudności
//        var difficultyCount: [String: Int] = [:]
//        
//        // Przechodzimy przez ukończone bouldery i zliczamy wystąpienia
//        for toppedBoulder in toppedBoulders {
//            if let difficulty = boulderDifficultyMap[toppedBoulder.boulder_id] {
//                difficultyCount[difficulty, default: 0] += 1
//            }
//        }
//        
//
//        
//        // Określenie najwyższej trudności ukończonej przez użytkownika
//        let completedDifficulties = difficultyCount.keys.sorted { difficultyIndex($0) < difficultyIndex($1) }
//        let highestDifficulty = completedDifficulties.last ?? ""
//        
//        // Dodanie trudności od najwyższej w dół do 5 trudniejszych
//        var extendedDifficultyCount: [String: Int] = difficultyCount
//        
//        // Dodanie trudności w dół od najwyższej
//        var currentDifficultyIndex = difficultyIndex(highestDifficulty)
//        
//        for _ in 1...5 {
//            currentDifficultyIndex -= 1
//            if currentDifficultyIndex >= 0 {
//                let lowerDifficulty = allDifficulties[currentDifficultyIndex]
//                extendedDifficultyCount[lowerDifficulty, default: 0] = 0
//            }
//        }
//        
//        return extendedDifficultyCount
//    }
//
//    // Funkcja pomocnicza do porównywania trudności na podstawie indeksu w tablicy
//    private func difficultyIndex(_ difficulty: String) -> Int {
//        return allDifficulties.firstIndex(of: difficulty) ?? -1
//    }
//}
//
//struct BarChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChartView()
////        BarChartView()
//    }
//}
//
