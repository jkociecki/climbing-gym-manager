//
//  RankingPerformanceTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 22/01/2025.
//
import XCTest
@testable import cgm

class RankingManagerPerformanceTests: XCTestCase {
    var sut: RankingManager!
    var mockDB: MockDatabaseManager!
    
    override func setUp() {
        super.setUp()
        mockDB = MockDatabaseManager()
        sut = RankingManager(databaseManager: mockDB)
        UserDefaults.standard.set("1", forKey: "selectedGym")
    }
    
    override func tearDown() {
        sut = nil
        mockDB = nil
        UserDefaults.standard.removeObject(forKey: "selectedGym")
        super.tearDown()
    }
    
    func testPerformanceGenerateRankingLargeDataset() async throws {
        let mockData = (1...5000).map { i in
            GymUserData(
                user_uid: String(i % 100), // 100 unique users
                user_name: "User",
                user_surname: "Number \(i % 100)",
                user_gender: i % 2 == 0,
                boulder_id: i,
                topped_at: "2024-01-15",
                is_flashed: Bool.random(),
                boulder_diff: ["6A", "6B", "6C", "7A", "7B", "7C"].randomElement()!
            )
        }
        
        mockDB.mockGymData = mockData
        
        let expectation = XCTestExpectation(description: "Generate ranking for large dataset")
        
        measure {
            Task {
                _ = try await sut.generateRanking()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testPerformanceDetermineLevelMultipleCalls() {
        let testPoints = Array(stride(from: 0, through: 2000, by: 5))
        
        measure {
            for points in testPoints {
                _ = sut.determineLevel(points: points)
            }
        }
    }
    
    func testPerformanceCalculatePointsBulk() {
        let difficulties = ["1A", "2A", "3A", "4A", "5A", "6A", "6B", "6C", "7A", "7B", "7C", "8A", "8B", "8C", "9A"]
        let testCases = difficulties.flatMap { difficulty in
            [
                (difficulty, true),
                (difficulty, false)
            ]
        }
        
        measure {
            for _ in 0..<1000 {
                for (difficulty, isFlashed) in testCases {
                    _ = sut.calculatePointsForBoulder(difficulty: difficulty, isFlashed: isFlashed)
                }
            }
        }
    }
    
    func testPerformanceGenerateRankingWithManyUsers() async throws {
        // Generowanie danych dla 100 użytkowników, każdy z 50 boulderami
        var mockData: [GymUserData] = []
        
        for userID in 1...100 {
            for boulderID in 1...50 {
                mockData.append(
                    GymUserData(
                        user_uid: String(userID),
                        user_name: "User",
                        user_surname: "Number \(userID)",
                        user_gender: userID % 2 == 0,
                        boulder_id: boulderID,
                        topped_at: "2024-01-15",
                        is_flashed: Bool.random(),
                        boulder_diff: ["6A", "6B", "6C", "7A", "7B", "7C"].randomElement()!
                    )
                )
            }
        }
        
        mockDB.mockGymData = mockData
        
        let expectation = XCTestExpectation(description: "Generate ranking for many users")
        
        measure {
            Task {
                _ = try await sut.generateRanking()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
}
