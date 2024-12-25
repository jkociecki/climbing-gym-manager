import Foundation

// Struktura poziomów trudności i punktów
let levels = [
    ("Beginner", 0), // Początkowy poziom
    ("4A", 100),
    ("4B", 150),
    ("4C", 200),
    ("5A", 250),
    ("5A+", 300),
    ("5B", 350),
    ("5C", 400),
    ("6A", 450),
    ("6A+", 500),
    ("6B", 550),
    ("6B+", 600),
    ("6C", 650),
    ("6C+", 700),
    ("7A", 750),
    ("7A+", 800),
    ("7B", 850),
    ("7B+", 900),
    ("7C", 950),
    ("7C+", 1000),
    ("8A", 1100),
    ("8A+", 1200),
    ("8B", 1300),
    ("8B+", 1400),
    ("8C", 1500),
    ("8C+", 1600),
    ("9A", 1700),
    ("9A+", 1800),
    ("9B", 1900),
    ("9B+", 2000),
    ("9C", 2100),
    ("9C+", 2200)
]

struct RankingUser: Identifiable {
    var id = UUID()
    var name: String
    var points: Int
    var gender: String
    var level: String
    var progress: String
}

import Foundation

class RankingManager {
    let db = DatabaseManager.shared
    
    func calculatePoints(toppedBoulders: [ToppedBy], boulders: [BoulderD]) -> Int {
        var points = 0
        
        // Obliczanie daty sprzed 2 miesięcy
        let calendar = Calendar.current
        let dateCutoff = calendar.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        
        // Filtrowanie ukończonych boulderów, które są z ostatnich 2 miesięcy
        let recentToppedBoulders = toppedBoulders.filter { topped in
            guard let createdAtString = topped.created_at,
                  let createdAt = ISO8601DateFormatter().date(from: createdAtString) else {
                return false
            }

            return createdAt >= dateCutoff
        }

        // Sortowanie boulderów według trudności (od najwyższego do najniższego)
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

        for (topped, boulder) in sortedBoulders.prefix(10) {
            let difficultyPoints = levels.first(where: { $0.0 == boulder.diff })?.1 ?? 0
            let pointsToAdd = Int(Double(difficultyPoints) * 0.1) // 90% wartości punktów za trudność
            points += pointsToAdd
            
            if topped.is_flashed {
                let flashBonus = Int(Double(pointsToAdd) * 0.2) // +20% bonus za flash na zaktualizowanych punktach
                points += flashBonus
            }
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

    // Funkcja generująca ranking
    func generateRanking() async throws -> [RankingUser] {
        let users = try await db.client.from("Users").select("*").execute().value as [User]
        let toppedBoulders = try await db.client.from("ToppedBy").select("*").execute().value as [ToppedBy]
        let boulders = try await db.client.from("Boulders").select("*").execute().value as [BoulderD]
        
        var rankingUsers: [RankingUser] = []
        
        for user in users {
            let userBoulders = toppedBoulders.filter { $0.user_id == user.uid.uuidString }
            let points = calculatePoints(toppedBoulders: userBoulders, boulders: boulders)
            let (level, progress) = determineLevel(points: points)
            
            let rankingUser = RankingUser(
                name: "\(user.name ?? "") \(user.surname ?? "")", // Jeśli name lub surname są nil, będą puste
                points: points,
                gender: user.gender == nil ? "N/A" : (user.gender == true ? "M" : "K"), // Jeśli gender jest nil, używamy "N/A"
                level: level,
                progress: progress
            )
            rankingUsers.append(rankingUser)
        }
        
        return rankingUsers.sorted(by: { $0.points > $1.points })
    }
}
