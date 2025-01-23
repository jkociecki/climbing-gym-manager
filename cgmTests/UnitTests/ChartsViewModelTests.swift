//
//  ChartsViewModelTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 15/01/2025.
//

import XCTest
@testable import cgm


class ChartsViewModelTests: XCTestCase {
    var viewModel: ChartsViewModel!
    var mockDatabaseManager: MockDatabaseManager!
    
    override func setUp() {
        super.setUp()
        mockDatabaseManager = MockDatabaseManager()
        DatabaseManager.shared = mockDatabaseManager
        viewModel = ChartsViewModel(userID: "testUserID", show_for_all_gyms: true)
    }
    
    override func tearDown() {
        viewModel = nil
        mockDatabaseManager = nil
        super.tearDown()
    }
    
    func testGenerateChartDataWithSingleBoulder() async {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let toppedBoulders = [
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 1,
                is_flashed: true,
                created_at: formattedDate,
                color: "Red",
                difficulty: "6A",
                name: "Test Boulder"
            )
        ]
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        await viewModel.generateChartData()
        await Task.sleep(500_000_000)
        
        XCTAssertFalse(viewModel.lineChartData.isEmpty, "Line chart data should not be empty")
        XCTAssertEqual(viewModel.lineChartData.count, 5, "Should have data for 5 months")
        
        if let firstMonthData = viewModel.lineChartData.last {
            XCTAssertEqual(firstMonthData.difficulty, 96.0, accuracy: 0.1)
        }
        
        
        XCTAssertFalse(viewModel.barChartData.isEmpty, "Bar chart data should not be empty")
        
        let hasDifficulty = viewModel.barChartData.contains { $0.difficulty == "6A" }
        XCTAssertTrue(hasDifficulty, "Bar chart should contain difficulty 6A")
    }
    
    func testEmptyData() async {
        mockDatabaseManager.mockToppedBoulders = []
        
        await viewModel.generateChartData()
        
        await Task.sleep(500_000_000)
        
        XCTAssertEqual(viewModel.lineChartData.count, 5, "Should have 5 months with zero values")
        XCTAssertTrue(viewModel.lineChartData.allSatisfy { $0.difficulty == 0 })
        XCTAssertTrue(viewModel.barChartData.isEmpty || viewModel.barChartData.allSatisfy { $0.done == 0 })
    }
    
    func testMultipleMonthsData() async {
        // Given
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let currentDate = Date()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: currentDate)!
        
        let toppedBoulders = [
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 1,
                is_flashed: true,
                created_at: dateFormatter.string(from: currentDate),
                color: "Red",
                difficulty: "6A",
                name: "Current Month Boulder"
            ),
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 2,
                is_flashed: false,
                created_at: dateFormatter.string(from: oneMonthAgo),
                color: "Blue",
                difficulty: "6B",
                name: "Last Month Boulder"
            ),
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: 3,
                is_flashed: true,
                created_at: dateFormatter.string(from: twoMonthsAgo),
                color: "Green",
                difficulty: "6C",
                name: "Two Months Ago Boulder"
            )
        ]
        
        mockDatabaseManager.mockToppedBoulders = toppedBoulders
        
        await viewModel.generateChartData()
        
        await Task.sleep(500_000_000)
        
        XCTAssertEqual(viewModel.lineChartData.count, 5, "Should have data for 5 months")
        XCTAssertFalse(viewModel.barChartData.isEmpty, "Bar chart should have data")
        
        let difficulties = viewModel.barChartData.map { $0.difficulty }
        XCTAssertTrue(difficulties.contains("6A"))
        XCTAssertTrue(difficulties.contains("6B"))
        XCTAssertTrue(difficulties.contains("6C"))
    }
}
