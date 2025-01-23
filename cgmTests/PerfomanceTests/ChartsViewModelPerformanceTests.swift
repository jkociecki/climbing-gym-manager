//
//  ChartsViewModelPerformanceTests.swift
//  cgmTests
//
//  Created by Mikołaj Olesiński on 22/01/2025.
//

import XCTest
@testable import cgm

class ChartsViewModelPerformanceTests: XCTestCase {
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
    
    func testPerformanceGenerateChartDataWithLargeDataset() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let currentDate = Date()
        
        let largeDataset = (1...20_000).map { index in
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: index,
                is_flashed: Bool.random(),
                created_at: dateFormatter.string(from: currentDate),
                color: "Color \(index % 10)",
                difficulty: allDifficulties.randomElement() ?? "6A",
                name: "Boulder \(index)"
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = largeDataset
        
        let expectation = XCTestExpectation(description: "Performance test for large dataset")
        
        measure {
            Task {
                await viewModel.generateChartData()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 60.0)
    }

    func testPerformanceGenerateChartDataWithSmallDataset() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let currentDate = Date()
        
        let smallDataset = (1...100).map { index in
            ToppedByForProfile(
                user_id: "testUserID",
                boulder_id: index,
                is_flashed: Bool.random(),
                created_at: dateFormatter.string(from: currentDate),
                color: "Color \(index % 3)",
                difficulty: allDifficulties.randomElement() ?? "6A",
                name: "Boulder \(index)"
            )
        }
        
        mockDatabaseManager.mockToppedBoulders = smallDataset
        
        let expectation = XCTestExpectation(description: "Performance test for small dataset")
        
        measure {
            Task {
                await viewModel.generateChartData()
                expectation.fulfill()
            }
        }
        await fulfillment(of: [expectation], timeout: 60.0)
    }



}
