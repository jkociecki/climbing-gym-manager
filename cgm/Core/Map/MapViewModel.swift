import Foundation
import SwiftUI

struct Boulder {
    var id:         Int
    var x:          CGFloat
    var y:          CGFloat
    var difficulty: String
    var color:      Color
    var sector:     String
    var isDone:       FlashDoneNone
}

enum FlashDoneNone{
    case Flash, Done, NotDone
}

@MainActor
class MapViewModel: ObservableObject{
    @Published var map:                 String = ""
    @Published var selectedSectorIndex: Int?
    @Published var boulders:            [Boulder] = []
    @Published var gymSectors:          [Sector] = []
    @Published var originalBoulders:    [Boulder] = []


    
    init(isCurrentGym: Bool) {
        fetchData(isCurrentGym: isCurrentGym)
    }
    
    
    func selectSector(index: Int, sector: Sector) {
        selectedSectorIndex = index
    }
    
    func fetchData(isCurrentGym: Bool) {
        Task {
            do {
        
              let mapResponse: String
              let bouldersResponse: [BoulderD]
              let sectorsResponse: [SectorD]
              
              if isCurrentGym {
                  mapResponse = try await DatabaseManager.shared.getCurrentGymMap()
                  bouldersResponse = try await DatabaseManager.shared.getCurrentGymBoulders()
                  sectorsResponse = try await DatabaseManager.shared.getCurrentGymSectors()
              } else {
                  mapResponse = try await DatabaseManager.shared.getGymMap(gymID: AuthManager.shared.adminOf)
                  bouldersResponse = try await DatabaseManager.shared.getGymBoulders(gymID: AuthManager.shared.adminOf)
                  sectorsResponse = try await DatabaseManager.shared.getGymSectors(id: AuthManager.shared.adminOf)
              }
                
                let parser:             SVGConverter = SVGConverter()
                
                self.gymSectors = parser.parseSVG(from: mapResponse)
                self.boulders = bouldersResponse.map{ boulder in
                    if let sector = sectorsResponse.first(where: { $0.id == boulder.sector_id }){
                        return Boulder(id:          boulder.id,
                                       x:           CGFloat(boulder.x),
                                       y:           CGFloat(boulder.y),
                                       difficulty:  boulder.diff,
                                       color:       Color(hex: boulder.color),
                                       sector:      sector.sector_name,
                                       isDone:      FlashDoneNone.NotDone)
                    } else {
                        return Boulder(id:          boulder.id,
                                       x:           CGFloat(boulder.x),
                                       y:           CGFloat(boulder.y),
                                       difficulty:  boulder.diff,
                                       color:       Color(.orange),
                                       sector:      "Unknown",
                                       isDone:      FlashDoneNone.NotDone)
                    }
                }
                self.originalBoulders = self.boulders
                try await getToppedBoulders()
            } catch {
            }
        }
    }
    
    private func getToppedBoulders() async throws {
        let userID = try await AuthManager.shared.client.auth.session.user.id
        let response: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID.uuidString)
        for toppedBoulder in response {
            if let boulderIndex = boulders.firstIndex(where: { $0.id == toppedBoulder.boulder_id }){
                boulders[boulderIndex].isDone = toppedBoulder.is_flashed ? FlashDoneNone.Done : FlashDoneNone.Flash
            }
        }
        
    }
    
    func applyFilters(difficulties: ClosedRange<Int>, colors: Set<String>, sectors: Set<String>) {
        boulders = originalBoulders.filter { boulder in
            let mappedDifficulty = mapDifficultyToNumber(diff: boulder.difficulty)
            print("Mapped Diff: \(mappedDifficulty) diff \(boulder.difficulty)")
            print("Sector: \(boulder.sector) diff \(sectors.first)")
            print("Color: \(boulder.color.toHex()) diff \(boulder.difficulty)")
            print(colors)
            print(sectors)
            
            let difficultyMatch: Bool = difficulties.contains(mappedDifficulty)
            let colorMatch: Bool = colors.isEmpty ? true : colors.contains(boulder.color.toHex())
            let sectorMatch: Bool = sectors.isEmpty ? true : sectors.contains(boulder.sector)
            return difficultyMatch  && sectorMatch && colorMatch
        }
    }
    
    func resetFilters() {
        boulders = originalBoulders
    }
}

