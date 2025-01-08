import Foundation

// Model danych dla TopTenBoulder
struct TopTenBoulder: Identifiable {
    var id = UUID()
    var color: String
    var level: String
    var whereBouler: String
    var fleshPoints: Int
    var pointsForBoulder: Int
}


struct ToppedByForProfile: Codable {
    var user_id: String
    var boulder_id: Int
    var is_flashed: Bool
    var created_at: String?
    var color: String
    var difficulty: String
    var name: String?
}


import Foundation

@MainActor
class TopBouldersManager: ObservableObject {
    private let db = DatabaseManager.shared
    private var toppedBoulders: [ToppedByForProfile] = []
    private var isDataLoaded = false
    var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    func loadData() async throws {
        guard !isDataLoaded else { return }
        toppedBoulders = try await db.getCurrentGymToppedByForProfile(forUserID: userID)
        isDataLoaded = true
    }
    
    func getUserStats() -> (flashes: Int, tops: Int) {
        let flashes = toppedBoulders.filter { $0.is_flashed }.count
        let tops = toppedBoulders.count
        return (flashes, tops)
    }
    
    
    func fetchVisitedDates() -> Set<String> {
        let dates = toppedBoulders.compactMap { topped -> String? in
            guard let createdAtString = topped.created_at,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                return nil
            }
            return formattedDate(createdAt, dateFormat: "yyyy-MM-dd")
        }
        return Set(dates)
    }
    
    func fetchTopTenBoulders() async throws -> [TopTenBoulder] {
        if !isDataLoaded {
            try await loadData()
        }
        
        
        let dateCutoff = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        let recentBoulders = toppedBoulders.filter { topped in
            guard let createdAtString = topped.created_at,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                return false
            }
            return createdAt >= dateCutoff
        }
        
        let topBoulders = recentBoulders.map { topped -> TopTenBoulder in
            let totalPoints = calculatePointsForBoulder(difficulty: topped.difficulty, isFlashed: topped.is_flashed)
            let flashBonus = topped.is_flashed ? Int(Double(totalPoints) * 0.2 / 1.2) : 0
            
            return TopTenBoulder(
                color: topped.color,
                level: topped.difficulty,
                whereBouler: topped.name ?? "Unkown",
                fleshPoints: flashBonus,
                pointsForBoulder: totalPoints
            )
        }

        return topBoulders.sorted(by: { $0.pointsForBoulder > $1.pointsForBoulder }).prefix(10).map { $0 }
    }
}

