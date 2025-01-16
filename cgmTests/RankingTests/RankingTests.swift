//  RankingTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 15/01/2025.
//

import XCTest
@testable import cgm

class RankingTests: XCTestCase {
    var sut: RankingManager!
    var mockDB: MockDatabaseManager!
    
    override func setUp() {
        super.setUp()
        mockDB = MockDatabaseManager()
        sut = RankingManager(databaseManager: mockDB)
    }
    
    
    override func tearDown() {
        sut = nil
        mockDB = nil
        super.tearDown()
    }
    
    
    func testCalculatePointsForBoulder() {
        let testCases = [
            ("1A", false, 50),
            ("1A", true, 60),
            ("6C", false, 900),
            ("6C", true, 1080),
            ("9C+", false, 1375),
            ("9C+", true, 1650),
            ("Invalid", false, 0)
        ]
        
        for (difficulty, isFlashed, expectedPoints) in testCases {
            let points = sut.calculatePointsForBoulder(difficulty: difficulty, isFlashed: isFlashed)
            XCTAssertEqual(points, expectedPoints, "Błąd dla trudności \(difficulty) (flash: \(isFlashed))")
        }
    }
    
    
    func testDetermineLevel() {
        let testCases = [
            (0, "Beginner", "+0%"),
            (25, "Beginner", "+50%"),
            (50, "1A", "+0%"),
            (62, "1A", "+48%"),
            (75, "1A+", "+0%"),
            (850, "6B", "+0%"),
            (862, "6B", "+48%"),
            (1375, "9C+", "+0%")
        ]
        
        for (points, expectedLevel, expectedProgress) in testCases {
            let (level, progress) = sut.determineLevel(points: points)
            XCTAssertEqual(level, expectedLevel)
            XCTAssertEqual(progress, expectedProgress)
        }
    }
    
    
    func testDetermineLevelForLargePoints() {
        let points = 10000
        let (level, progress) = sut.determineLevel(points: points)
        
        XCTAssertEqual(level, "9C+")
        XCTAssertEqual(progress, "+0%")
    }
    
    
    func testGenerateRanking() async throws {
        let mockData: [GymUserData] = [
            GymUserData(user_uid: "1", user_name: "Jan", user_surname: "Kowalski",
                       user_gender: true, boulder_id: 1, topped_at: "2024-01-15",
                       is_flashed: true, boulder_diff: "6A"),
            GymUserData(user_uid: "1", user_name: "Jan", user_surname: "Kowalski",
                       user_gender: true, boulder_id: 2, topped_at: "2024-01-15",
                       is_flashed: false, boulder_diff: "6B"),
            GymUserData(user_uid: "2", user_name: "Anna", user_surname: "Nowak",
                       user_gender: false, boulder_id: 3, topped_at: "2024-01-15",
                       is_flashed: true, boulder_diff: "7A")
        ]
        
        let mockDB = MockDatabaseManager()
        mockDB.mockGymData = mockData
        
        let sut = RankingManager(databaseManager: mockDB)
        UserDefaults.standard.set("1", forKey: "selectedGym")
        
        let ranking = try await sut.generateRanking()
        
        XCTAssertEqual(ranking.count, 2)
        XCTAssertTrue(ranking[0].points > ranking[1].points)
        
        let firstUser = ranking[0]
        XCTAssertTrue(firstUser.name.contains("Jan") || firstUser.name.contains("Anna"))
        XCTAssertTrue(firstUser.gender == "M" || firstUser.gender == "K")
    }
    
    
    func testGenerateRankingSorting() async throws {
        let mockData: [GymUserData] = [
            GymUserData(user_uid: "1", user_name: "Jan", user_surname: "Kowalski", user_gender: true, boulder_id: 1, topped_at: "2024-01-15", is_flashed: true, boulder_diff: "6A"),
            GymUserData(user_uid: "2", user_name: "Anna", user_surname: "Nowak", user_gender: false, boulder_id: 3, topped_at: "2024-01-15", is_flashed: true, boulder_diff: "7A"),
            GymUserData(user_uid: "3", user_name: "Marek", user_surname: "Nowak", user_gender: true, boulder_id: 2, topped_at: "2024-01-15", is_flashed: true, boulder_diff: "6B")
        ]
        
        mockDB.mockGymData = mockData
        UserDefaults.standard.set("1", forKey: "selectedGym")
        
        let ranking = try await sut.generateRanking()
        
        XCTAssertTrue(ranking[0].points >= ranking[1].points)
        XCTAssertTrue(ranking[1].points >= ranking[2].points)
    }

    
    
    func testGenerateRankingWithNoData() async throws {
        mockDB.mockGymData = []
        UserDefaults.standard.set("1", forKey: "selectedGym")
        
        let ranking = try await sut.generateRanking()
        

        XCTAssertEqual(ranking.count, 0)
    }
    
    
    func testInvalidGymID() async {
        UserDefaults.standard.removeObject(forKey: "selectedGym")
        
        do {
            _ = try await sut.generateRanking()
            XCTFail("Powinien być rzucony błąd dla nieprawidłowego gym ID")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("Gym ID"))
        }
    }
    
}

