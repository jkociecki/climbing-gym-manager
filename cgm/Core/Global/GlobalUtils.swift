//
//  GlobalUtils.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 30/12/2024.
//

import Foundation


let allDifficulties = [
    "1A", "1A+", "1B", "1B+", "1C", "1C+",
    "2A", "2A+", "2B", "2B+", "2C", "2C+",
    "3A", "3A+", "3B", "3B+", "3C", "3C+",
    "4A", "4A+", "4B", "4B+", "4C", "4C+",
    "5A", "5A+", "5B", "5B+", "5C", "5C+",
    "6A", "6A+", "6B", "6B+", "6C", "6C+",
    "7A", "7A+", "7B", "7B+", "7C", "7C+",
    "8A", "8A+", "8B", "8B+", "8C", "8C+",
    "9A", "9A+", "9B", "9B+", "9C", "9C+"
];

let levels = [
    ("Beginner", 0),
    ("1A", 50), ("1A+", 75), ("1B", 100), ("1B+", 125), ("1C", 150), ("1C+", 175),
    ("2A", 200), ("2A+", 225), ("2B", 250), ("2B+", 275), ("2C", 300), ("2C+", 325),
    ("3A", 350), ("3A+", 375), ("3B", 400), ("3B+", 425), ("3C", 450), ("3C+", 475),
    ("4A", 500), ("4A+", 525), ("4B", 550), ("4B+", 575), ("4C", 600), ("4C+", 625),
    ("5A", 650), ("5A+", 675), ("5B", 700), ("5B+", 725), ("5C", 750), ("5C+", 775),
    ("6A", 800), ("6A+", 825), ("6B", 850), ("6B+", 875), ("6C", 900), ("6C+", 925),
    ("7A", 950), ("7A+", 975), ("7B", 1000), ("7B+", 1025), ("7C", 1050), ("7C+", 1075),
    ("8A", 1100), ("8A+", 1125), ("8B", 1150), ("8B+", 1175), ("8C", 1200), ("8C+", 1225),
    ("9A", 1250), ("9A+", 1275), ("9B", 1300), ("9B+", 1325), ("9C", 1350), ("9C+", 1375)
];


func calculatePointsForBoulder(difficulty: String, isFlashed: Bool) -> Int {
    let difficultyPoints = levels.first(where: { $0.0 == difficulty })?.1 ?? 0
    let flashBonus = isFlashed ? Int(Double(difficultyPoints) * 0.2) : 0
    return Int(Double(difficultyPoints + flashBonus) * 0.1)
}

func mapDifficultyToNumber(diff: String) -> Int {
    if let index = allDifficulties.firstIndex(of: diff) { return index }
    else { return -1 }
}
