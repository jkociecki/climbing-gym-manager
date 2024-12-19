import Foundation
import SwiftUI

struct Boulder {
    var id: UUID
    var x: CGFloat  // Współrzędna X na mapie
    var y: CGFloat  // Współrzędna Y na mapie
    var difficulty: String  // Trudność (np. "easy", "medium", "hard")
    var color: Color  // Kolor bouldera
    var sector: String
}

class MapViewModel: ObservableObject {
    var svgParser: SVGparser = SVGparser()

    // Make these properties @Published so views can observe them
    @Published var climbingSectors: [MyPathWrapper] = []
    @Published var boulders: [Boulder] = []
    @Published var gymSectors: [Sector] = []

    init() {
        fetchData()
    }
    
    private func fetchData() {
        Task {
            do {
                let responseBoulders: [BoulderD] = try await DatabaseManager.shared.getCurrentGymBoulders()
                let responseMap: String = try await DatabaseManager.shared.getCurrentGymMap()
                let responseSectors: [Sector] = try await DatabaseManager.shared.getCurrentGymSectors()
                                
                self.gymSectors = responseSectors
                self.climbingSectors = svgParser.parseSVGpaths(from: responseMap)
                self.boulders = responseBoulders.map { boulder in
                    if let sector = self.gymSectors.first(where: { $0.id == boulder.sector_id }) {
                        return Boulder(id: UUID(),
                                       x: CGFloat(boulder.x),
                                       y: CGFloat(boulder.y),
                                       difficulty: boulder.diff,
                                       color: Color(.orange),
                                       sector: sector.sector_name)
                    } else {
                        return Boulder(id: UUID(),
                                       x: CGFloat(boulder.x),
                                       y: CGFloat(boulder.y),
                                       difficulty: boulder.diff,
                                       color: Color(.orange),
                                       sector: "Unknown")
                    }
                }

                print(self.boulders)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }

    
    func mapBoulders(boulders: [BoulderD]) {
        
        
    }
    
    
    
    

}
