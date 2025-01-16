//
//  ProfileViewTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 15/01/2025.
//
import XCTest
@testable import cgm

class TopBouldersManagerTests: XCTestCase {
    var viewModel: TopBouldersManager!
    var mockDatabaseManager: MockDatabaseManager!
    
    override func setUpWithError() throws {
        super.setUp()
        
        mockDatabaseManager = MockDatabaseManager()
        DatabaseManager.shared = mockDatabaseManager
        
        let testExpectation = expectation(description: "Setup")
        Task { @MainActor in
            viewModel = TopBouldersManager(userID: "testUserID", show_for_all_gyms: false)
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1.0)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockDatabaseManager = nil
        super.tearDown()
    }
    
    func testLoadData() async throws {
        let toppedBoulders: [ToppedByForProfile] = [
            ToppedByForProfile(user_id: "testUserID", boulder_id: 1, is_flashed: true, created_at: "2024-01-01T12:00:00Z", color: "Red", difficulty: "6A", name: "Gym A"),
            ToppedByForProfile(user_id: "testUserID", boulder_id: 2, is_flashed: false, created_at: "2024-01-05T12:00:00Z", color: "Blue", difficulty: "6B", name: "Gym B")
        ]
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        XCTAssertNotNil(viewModel, "viewModel should not be nil")
        
        try await viewModel.loadData()
        
        let stats = await viewModel.getUserStats()
        XCTAssertEqual(stats.tops, 2, "Should have 2 tops")
        XCTAssertEqual(stats.flashes, 1, "Should have 1 flash")
    }

    func testFetchVisitedDates() async throws {
        let toppedBoulders: [ToppedByForProfile] = [
            ToppedByForProfile(user_id: "testUserID", boulder_id: 1, is_flashed: true, created_at: "2024-01-01T12:00:00Z", color: "Red", difficulty: "6A", name: "Gym A"),
            ToppedByForProfile(user_id: "testUserID", boulder_id: 2, is_flashed: false, created_at: "2024-01-05T12:00:00Z", color: "Blue", difficulty: "6B", name: "Gym B")
        ]
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        try await viewModel.loadData()
        
        let visitedDates = await viewModel.fetchVisitedDates()
        XCTAssertTrue(visitedDates.contains("2024-01-01"), "Should contain '2024-01-01'")
        XCTAssertTrue(visitedDates.contains("2024-01-05"), "Should contain '2024-01-05'")
    }
    
    func testFetchTopTenBoulders() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: currentDate)!
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: currentDate)!
        
        let toppedBoulders: [ToppedByForProfile] = [
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 1,
                is_flashed: true,
                created_at: dateFormatter.string(from: twoWeeksAgo),
                color: "Red",
                difficulty: "6A",
                name: "Gym A"
            ),
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 2,
                is_flashed: false,
                created_at: dateFormatter.string(from: oneWeekAgo),
                color: "Blue",
                difficulty: "6B",
                name: "Gym B"
            ),
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 3,
                is_flashed: true,
                created_at: dateFormatter.string(from: currentDate),
                color: "Green",
                difficulty: "7A",
                name: "Gym C"
            ),
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 4,
                is_flashed: true,
                created_at: dateFormatter.string(from: threeMonthsAgo),
                color: "Yellow",
                difficulty: "8A",
                name: "Gym D"
            )
        ]
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        try await viewModel.loadData()
        
        let topBoulders = try await viewModel.fetchTopTenBoulders()
        XCTAssertEqual(topBoulders.count, 3, "Powinny być tylko 3 bouldery z ostatnich 2 miesięcy")
        
        XCTAssertFalse(topBoulders.contains { $0.level == "8A" }, "Boulder sprzed 3 miesięcy nie powinien być uwzględniony")
        XCTAssertTrue(topBoulders.contains { $0.level == "6A" })
        XCTAssertTrue(topBoulders.contains { $0.level == "6B" })
        XCTAssertTrue(topBoulders.contains { $0.level == "7A" })
    }
    
    func testFetchTopTenBouldersWithMoreThanTenBoulders() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        

        var toppedBoulders: [ToppedByForProfile] = []
        let difficulties = ["3A", "4A", "4C", "5A", "5C", "6A", "6B", "6C", "7A", "7B", "7C", "8A", "8B", "8C", "9A"]
        
        for (index, difficulty) in difficulties.enumerated() {
            let date = Calendar.current.date(byAdding: .day, value: -index, to: currentDate)!
            toppedBoulders.append(
                ToppedByForProfile(
                    user_id: "testUserID",
                    boulder_id: index + 1,
                    is_flashed: false,
                    created_at: dateFormatter.string(from: date),
                    color: "Color\(index)",
                    difficulty: difficulty,
                    name: "Gym \(index)"
                )
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        try await viewModel.loadData()
        
        let topBoulders = try await viewModel.fetchTopTenBoulders()
        
        XCTAssertEqual(topBoulders.count, 10, "Powinno być zwrócone dokładnie 10 boulderów")
        
        let expectedDifficulties = ["9A", "8C", "8B", "8A", "7C", "7B", "7A", "6C", "6B", "6A"]
        for (index, difficulty) in expectedDifficulties.enumerated() {
            XCTAssertEqual(topBoulders[index].level, difficulty, "Boulder na pozycji \(index) powinien mieć trudność \(difficulty)")
        }
        
        let excludedDifficulties = ["5C", "5A", "4C", "4A", "3A"]
        for difficulty in excludedDifficulties {
            XCTAssertFalse(topBoulders.contains { $0.level == difficulty }, "Boulder o trudności \(difficulty) nie powinien być w top 10")
        }
    }
}
