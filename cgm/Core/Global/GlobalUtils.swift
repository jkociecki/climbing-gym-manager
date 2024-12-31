//
//  GlobalUtils.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 30/12/2024.
//

import Foundation


let allDifficulties = ["4A", "4A+", "4B", "4B+", "4C", "4C+", "5A", "5A+", "5B", "5B+", "5C", "5C+", "6A", "6A+","6B","6B+","6C", "6C+", "7A", "7A+", "7B", "7B+", "7C", "7C+", "8A", "8A+", "8B", "8B+", "8C", "8C+", "9A", "9A+", "9B", "9B+", "9C", "9C+"]

func mapDifficultyToNumber(diff: String) -> Int {
    if let index = allDifficulties.firstIndex(of: diff) { return index }
    else { return -1 }
}
