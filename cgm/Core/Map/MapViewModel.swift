import Foundation
import SwiftUI

struct Boulder {
    var id:         UUID
    var x:          CGFloat
    var y:          CGFloat
    var difficulty: String
    var color:      Color
    var sector:     String
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
                        return Boulder(id:          UUID(),
                                       x:           CGFloat(boulder.x),
                                       y:           CGFloat(boulder.y),
                                       difficulty:  boulder.diff,
                                       color:       Color(.orange),
                                       sector:      sector.sector_name)
                    } else {
                        return Boulder(id:          UUID(),
                                       x:           CGFloat(boulder.x),
                                       y:           CGFloat(boulder.y),
                                       difficulty:  boulder.diff,
                                       color:       Color(.orange),
                                       sector:      "Unknown")
                    }
                }
                print(boulders)
            } catch {
            }
        }
    }
}

