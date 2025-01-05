import Foundation

struct RankingUser: Identifiable {
    var id = UUID()
    var name: String
    var points: Int
    var gender: String
    var level: String
    var progress: String
    var imageData: Data?
}


class RankingManager {
    let db = DatabaseManager.shared
    
    func calculatePoints(toppedBoulders: [ToppedBy], boulders: [BoulderD]) -> Int {
        var points = 0
        
        let calendar = Calendar.current
        let dateCutoff = calendar.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        
        let recentToppedBoulders = toppedBoulders.filter { topped in
            guard let createdAtString = topped.created_at,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                return false
            }
            return createdAt >= dateCutoff
        }

        let sortedBoulders = recentToppedBoulders.compactMap { topped -> (ToppedBy, BoulderD)? in
            if let boulder = boulders.first(where: { $0.id == topped.boulder_id }) {
                return (topped, boulder)
            }
            return nil
        }
        .sorted { b1, b2 in
            let points1 = levels.first(where: { $0.0 == b1.1.diff })?.1 ?? 0
            let points2 = levels.first(where: { $0.0 == b2.1.diff })?.1 ?? 0
            return points1 > points2
        }

        // Calculate total points
        for (topped, boulder) in sortedBoulders.prefix(10) {
            let pointsToAdd = calculatePointsForBoulder(difficulty: boulder.diff, isFlashed: topped.is_flashed)
            points += pointsToAdd
        }
        
        return points
    }

    
    // Funkcja do określania poziomu na podstawie zdobytych punktów
    func determineLevel(points: Int) -> (String, String) {
        var currentLevel = "Beginner"
        var nextLevelPoints: Int? = nil
        
        for (index, level) in levels.enumerated() {
            if points >= level.1 {
                currentLevel = level.0
                nextLevelPoints = index + 1 < levels.count ? levels[index + 1].1 : nil
            }
        }
        
        // Jeśli istnieje następny poziom, obliczamy postęp
        if let nextLevelPoints = nextLevelPoints {
            let previousLevelPoints = levels.first { $0.0 == currentLevel }!.1
            let progress = Double(points - previousLevelPoints) / Double(nextLevelPoints - previousLevelPoints)
            let progressPercentage = Int(progress * 100)
            return (currentLevel, "+\(progressPercentage)%")
        } else {
            return (currentLevel, "+0%")
        }
    }


    func generateRanking() async throws -> [RankingUser] {
        guard let idString = UserDefaults.standard.string(forKey: "selectedGym"),
              let gymID = Int(idString) else {
            throw NSError(domain: "InvalidGymID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Gym ID is not set or invalid."])
        }
        
        print("1")
        let users = try await db.client.from("Users").select("*").execute().value as [User]
        let toppedBoulders = try await db.client.from("ToppedBy").select("*").execute().value as [ToppedBy]
        let boulders = try await db.client.from("Boulders").select("*").execute().value as [BoulderD]



        let gymBoulders = boulders.filter { $0.gym_id == gymID }

        let gymToppedBoulders = toppedBoulders.filter { toppedBoulder in
            return gymBoulders.contains { $0.id == toppedBoulder.boulder_id }
        }

        let gymUsers = users.filter { user in
            return gymToppedBoulders.contains { $0.user_id == user.uid.uuidString }
        }

        var rankingUsers: [RankingUser] = []

        for user in gymUsers {
            let userBoulders = gymToppedBoulders.filter { $0.user_id == user.uid.uuidString }
            
            let points = calculatePoints(toppedBoulders: userBoulders, boulders: gymBoulders)
            
            let (level, progress) = determineLevel(points: points)

            let imageData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: user.uid.uuidString)
            let rankingUser = RankingUser(
                name: "\(user.name ?? "") \(user.surname ?? "")",
                points: points,
                gender: user.gender == nil ? "N/A" : (user.gender == true ? "M" : "K"),
                level: level,
                progress: progress,
                imageData: imageData
            )
            
            rankingUsers.append(rankingUser)
        }

        // Sort the ranking users by points in descending order
        return rankingUsers.sorted(by: { $0.points > $1.points })
    }


}
