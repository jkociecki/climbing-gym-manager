//
//  ProfileViewPerformanceTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 22/01/2025.
//
import XCTest
@testable import cgm

class TopBouldersManagerPerformanceTests: XCTestCase {
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
    
    func testPerformanceFetchTopTenBouldersLargeDataset() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        
        var toppedBoulders: [ToppedByForProfile] = []
        
        for i in 0..<5000 {
            let date = Calendar.current.date(byAdding: .day, value: -(i % 60), to: currentDate)!
            toppedBoulders.append(
                ToppedByForProfile(
                    user_id: "testUserID",
                    boulder_id: i + 1,
                    is_flashed: Bool.random(),
                    created_at: dateFormatter.string(from: date),
                    color: "Color\(i % 10)",
                    difficulty: allDifficulties[i % allDifficulties.count],
                    name: "Gym \(i)"
                )
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        let expectation = XCTestExpectation(description: "Performance test for large dataset")
        try await viewModel.loadData()
        
        measure {
            Task {
                let _ = try await viewModel.fetchTopTenBoulders()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testPerformanceFetchVisitedDatesLargeDataset() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        var toppedBoulders: [ToppedByForProfile] = []
        
        for i in 0..<5000 {
            let date = Calendar.current.date(byAdding: .day, value: -(i % 365), to: currentDate)!
            toppedBoulders.append(
                ToppedByForProfile(
                    user_id: "testUserID",
                    boulder_id: i + 1,
                    is_flashed: Bool.random(),
                    created_at: dateFormatter.string(from: date),
                    color: "Color\(i % 10)",
                    difficulty: "6A",
                    name: "Gym \(i)"
                )
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        let expectation = XCTestExpectation(description: "Performance test for visited dates")
        try await viewModel.loadData()
        
        measure {
            Task {
                let _ = await viewModel.fetchVisitedDates()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 10.0)
    }
    
    func testPerformanceGetUserStatsSmallDataset() async throws {
        let dateFormatter = ISO8601DateFormatter()
        let currentDate = Date()
        
        var toppedBoulders: [ToppedByForProfile] = []
        
        for i in 0..<100 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: currentDate)!
            toppedBoulders.append(
                ToppedByForProfile(
                    user_id: "testUserID",
                    boulder_id: i + 1,
                    is_flashed: Bool.random(),
                    created_at: dateFormatter.string(from: date),
                    color: "Color\(i % 5)",
                    difficulty: "6A",
                    name: "Gym \(i)"
                )
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        let expectation = XCTestExpectation(description: "Performance test for user stats")
        try await viewModel.loadData()
        
        measure {
            Task {
                let _ = await viewModel.getUserStats()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
