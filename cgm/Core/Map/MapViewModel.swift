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


class MapViewModel: ObservableObject{
    @Published var map:                 String = ""
    @Published var boulders:            [Boulder] = []
    @Published var gymSectors:          [Sector] = []
    @Published var selectedSectorIndex: Int?

    
    init() {
        fetchData()
    }
    
    
    func selectSector(index: Int, sector: Sector) {
        selectedSectorIndex = index
    }
    
    private func fetchData() {
        Task {
            do {
                let mapResponse:        String = try await DatabaseManager.shared.getCurrentGymMap()
                let bouldersResponse:   [BoulderD] = try await DatabaseManager.shared.getCurrentGymBoulders()
                let sectorsResponse:    [SectorD] = try await DatabaseManager.shared.getCurrentGymSectors()
                
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
                try await getToppedBoulders()
                //print(boulders)
            } catch {
            }
        }
    }
    
    private func getToppedBoulders() async throws {
        let userID = try await AuthManager.shared.client.auth.session.user.id
        let response: [ToppedBy] = try await DatabaseManager.shared.getToppedBoulders(forUserID: userID.uuidString)
        print(response)
        for toppedBoulder in response {
            if let boulderIndex = boulders.firstIndex(where: { $0.id == toppedBoulder.boulder_id }){
                print("FOUND")
                boulders[boulderIndex].isDone = toppedBoulder.is_flashed ? FlashDoneNone.Done : FlashDoneNone.Flash
            }
        }
        
    }
}

