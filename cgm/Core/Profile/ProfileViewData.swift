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

import Foundation

@MainActor
class TopBouldersManager: ObservableObject {
    private let db = DatabaseManager.shared
    
    private var toppedBoulders: [ToppedBy] = []
    private var isDataLoaded = false
    var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    func loadData() async throws {
        guard !isDataLoaded else { return }
        toppedBoulders = try await db.client
            .from("ToppedBy")
            .select("*")
            .eq("user_id", value: userID)
            .execute()
            .value as [ToppedBy]
        isDataLoaded = true
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
    
    // Funkcja do pobrania statystyk użytkownika
    func getUserStats() -> (flashes: Int, tops: Int) {
        let flashes = toppedBoulders.filter { $0.is_flashed }.count
        let tops = toppedBoulders.count
        return (flashes, tops)
    }
    

    func fetchTopTenBoulders() async throws -> [TopTenBoulder] {
        if !isDataLoaded {
            try await loadData()
        }

        let boulderIDs = toppedBoulders.map { $0.boulder_id }
        guard !boulderIDs.isEmpty else { return [] }

        let boulders: [BoulderD] = try await db.client.from("Boulders").select("*")
            .or(boulderIDs.map { "id.eq.\($0)" }.joined(separator: ","))
            .execute()
            .value as [BoulderD]
        
        let dateCutoff = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        let recentBoulders = toppedBoulders.filter { topped in
            guard let createdAtString = topped.created_at,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                return false
            }
            return createdAt >= dateCutoff
        }

        var topBoulders: [TopTenBoulder] = []

        for topped in recentBoulders {
            guard let boulder = boulders.first(where: { $0.id == topped.boulder_id }) else { continue }
            let sector = (try? await db.getSectorByID(sectorID: boulder.sector_id)?.sector_name) ?? "Unknown Sector"
            let totalPoints = calculatePointsForBoulder(difficulty: boulder.diff, isFlashed: topped.is_flashed)
            let flashBonus = topped.is_flashed ? Int(Double(totalPoints) * 0.2 / 1.2) : 0
            
            let topTenBoulder = TopTenBoulder(
                color: boulder.color,
                level: boulder.diff,
                whereBouler: sector,
                fleshPoints: flashBonus,
                pointsForBoulder: totalPoints
            )
            
            topBoulders.append(topTenBoulder)
        }

        return topBoulders.sorted(by: { $0.pointsForBoulder > $1.pointsForBoulder }).prefix(10).map { $0 }
    }
}
