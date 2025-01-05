//
//  GlobalUtils.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 30/12/2024.
//

import Foundation


let allDifficulties = ["4A", "4A+", "4B", "4B+", "4C", "4C+", "5A", "5A+", "5B", "5B+", "5C", "5C+", "6A", "6A+","6B","6B+","6C", "6C+", "7A", "7A+", "7B", "7B+", "7C", "7C+", "8A", "8A+", "8B", "8B+", "8C", "8C+", "9A", "9A+", "9B", "9B+", "9C", "9C+"]

let levels = [
    ("Beginner", 0),
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

func calculatePointsForBoulder(difficulty: String, isFlashed: Bool) -> Int {
    let difficultyPoints = levels.first(where: { $0.0 == difficulty })?.1 ?? 0
    let flashBonus = isFlashed ? Int(Double(difficultyPoints) * 0.2) : 0
    return Int(Double(difficultyPoints + flashBonus) * 0.1)
}

func mapDifficultyToNumber(diff: String) -> Int {
    if let index = allDifficulties.firstIndex(of: diff) { return index }
    else { return -1 }
}
