import Foundation

struct RankingUser: Identifiable {
    var id = UUID()
    var name: String
    var points: Int
    var gender: String
    var level: String
    var progress: String
    var imageData: Data?
    var user_id: UUID
}

// Struktura dla danych z bazy
struct GymUserData: Decodable {
    let user_uid: String
    let user_name: String?
    let user_surname: String?
    let user_gender: Bool?
    let boulder_id: Int
    let topped_at: String
    let is_flashed: Bool
    let boulder_diff: String
}

class RankingManager {
    let db: DatabaseManager
    
    init(databaseManager: DatabaseManager = DatabaseManager.shared) {
        self.db = databaseManager
    }
    
    func generateRanking() async throws -> [RankingUser] {
        guard let idString = UserDefaults.standard.string(forKey: "selectedGym"),
              let gymID = Int(idString) else {
            throw NSError(domain: "InvalidGymID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Gym ID is not set or invalid."])
        }
        
        let gymData = try await db.fetchGymData(gymID: gymID)
        
        let userGroupedData = Dictionary(grouping: gymData) { $0.user_uid }
        
        var rankingUsers: [RankingUser] = []
        
        for (userUid, userBoulders) in userGroupedData {
            let userData = userBoulders[0]
            
            let points = calculatePoints(userBoulders: userBoulders)
            let (level, progress) = determineLevel(points: points)
            
            let rankingUser = RankingUser(
                name: (userData.user_name?.isEmpty ?? true) && (userData.user_surname?.isEmpty ?? true)
                    ? "Anonymous"
                    : "\(userData.user_name ?? "") \(userData.user_surname ?? "")",
                points: points,
                gender: userData.user_gender == nil ? "N/A" : (userData.user_gender == true ? "M" : "K"),
                level: level,
                progress: progress,
                imageData: nil,  // Początkowo bez zdjęcia
                user_id: UUID(uuidString: userUid) ?? UUID()
            )
            
            rankingUsers.append(rankingUser)
        }
        
        return rankingUsers.sorted(by: { $0.points > $1.points })
    }
    
    func fetchUserImages(for users: [RankingUser]) async -> [RankingUser] {
        var updatedUsers = users
        
        for index in users.indices {
            do {
                let imageData = try await StorageManager.shared.fetchUserProfilePicture(user_uid: users[index].user_id.uuidString)
                updatedUsers[index].imageData = imageData
            } catch {
                print("Błąd ładowania zdjęcia dla użytkownika \(users[index].name): \(error)")
            }
        }
        
        return updatedUsers
    }

    
    private func calculatePoints(userBoulders: [GymUserData]) -> Int {
        var points = 0
        
        // Sortuj bouldery po trudności (już mamy tylko z ostatnich 2 miesięcy dzięki SQL)
        let sortedBoulders = userBoulders.sorted { b1, b2 in
            let points1 = levels.first(where: { $0.0 == b1.boulder_diff })?.1 ?? 0
            let points2 = levels.first(where: { $0.0 == b2.boulder_diff })?.1 ?? 0
            return points1 > points2
        }
        
        // Weź 10 najlepszych
        for boulder in sortedBoulders.prefix(10) {
            points += calculatePointsForBoulder(difficulty: boulder.boulder_diff, isFlashed: boulder.is_flashed)
        }
        
        return points
    }
    
    func calculatePointsForBoulder(difficulty: String, isFlashed: Bool) -> Int {
        let basePoints = levels.first(where: { $0.0 == difficulty })?.1 ?? 0
        return isFlashed ? Int(Double(basePoints) * 1.2) : basePoints
    }
    
    func determineLevel(points: Int) -> (String, String) {
        var currentLevel = "Beginner"
        var nextLevelPoints: Int? = nil
        
        for (index, level) in levels.enumerated() {
            if points >= level.1 {
                currentLevel = level.0
                nextLevelPoints = index + 1 < levels.count ? levels[index + 1].1 : nil
            }
        }
        
        if let nextLevelPoints = nextLevelPoints {
            let previousLevelPoints = levels.first { $0.0 == currentLevel }!.1
            let progress = Double(points - previousLevelPoints) / Double(nextLevelPoints - previousLevelPoints)
            let progressPercentage = Int(progress * 100)
            return (currentLevel, "+\(progressPercentage)%")
        } else {
            return (currentLevel, "+0%")
        }
    }
}
