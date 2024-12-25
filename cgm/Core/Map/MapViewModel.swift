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

let boulders = [
    Boulder(id: UUID(), x: 245.5, y: 45.5, difficulty: "70", color: Color(hex: "#F9F9F9"), sector: "Kaskady"),
    Boulder(id: UUID(), x: 334.5, y: 12.5, difficulty: "71", color: Color(hex: "#FAFAFA") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 18, y: 59, difficulty: "5A", color: Color(hex: "#fce050") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 45, y: 47, difficulty: "7A", color: Color(hex: "#7cfc50") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 25, y: 24, difficulty: "5B", color: Color(hex: "#50e7fc") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 71, y: 19, difficulty: "4B+", color: Color(hex: "#9c50fc"), sector: "Kaskady"),
    Boulder(id: UUID(), x: 105, y: 18, difficulty: "6B", color: Color(hex: "#50fc96"), sector: "Piony"),
    Boulder(id: UUID(), x: 130, y: 19, difficulty: "8A", color: Color(hex: "#df50fc") , sector: "Piony"),
    Boulder(id: UUID(), x: 155, y: 15, difficulty: "4C", color: Color(hex: "#fcf250") , sector: "Piony"),
    Boulder(id: UUID(), x: 184, y: 13, difficulty: "7C", color: Color(hex: "#fc5050") , sector: "Piony"),
    Boulder(id: UUID(), x: 215, y: 12, difficulty: "6A", color: Color(hex: "#b3fc50") , sector: "Piony"),
    Boulder(id: UUID(), x: 236, y: 11, difficulty: "6C+", color: Color(hex: "#50fcef") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 256, y: 21, difficulty: "7A+", color: Color(hex: "#effc50") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 263, y: 12, difficulty: "4C+", color: Color(hex: "#fc50f4") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 278, y: 23, difficulty: "5B+", color: Color(hex: "#5062fc") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 294, y: 11, difficulty: "6B", color: Color(hex: "#50fc5a") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 315, y: 11, difficulty: "5A", color: Color(hex: "#50fce2") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 341, y: 13, difficulty: "6B+", color: Color(hex: "#ab50fc"), sector: "Kaskady"),
    Boulder(id: UUID(), x: 361, y: 12, difficulty: "5C+", color: Color(hex: "#effc50") , sector: "Kaskady"),
    Boulder(id: UUID(), x: 388, y: 14, difficulty: "4C", color: Color(hex: "#f950fc") , sector: "Kaskady"),
    // Dodaj kolejne obiekty w podobny sposób
]
