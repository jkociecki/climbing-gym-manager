//
//  ProfileViewData.swift
//  climbing-gym-manager
//
//  Created by Malwina Juchiewicz on 20/11/2024.
//

import Foundation

struct TopTenBoulder: Identifiable
{
    var id = UUID()
    var color: String
    var level: String
    var whereBouler: String
    var fleshPoints: Int
    var pointsForBoulder: Int
}

class TopBouldersManager {
    let db = DatabaseManager.shared

    func fetchTopTenBoulders(for userID: String) async throws -> [TopTenBoulder] {
        let toppedBoulders = try await db.client.from("ToppedBy").select("*")
            .eq("user_id", value: userID)
            .execute().value as [ToppedBy]

        let boulderIDs = toppedBoulders.map { $0.boulder_id }
        guard !boulderIDs.isEmpty else { return [] }
        
        let boulders = try await db.client.from("Boulders").select("*")
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

            var sector = "Unknown Sector"
            let sectorID = boulder.sector_id
            do {
                if let sectorData = try await DatabaseManager.shared.getSectorByID(sectorID: sectorID) {
                    sector = sectorData.sector_name
                } else {
                    sector = "Unknown Sector"
                }
            } catch {
                sector = "Unknown Sector"
            }


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
