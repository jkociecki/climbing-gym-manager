//
//  BoulderInfoModelPerformanceTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 23/01/2025.
//
 
import XCTest
@testable import cgm

class BoulderInfoModelPerformanceTests: XCTestCase {
    var viewModel: BoulderInfoModel!
    var mockDatabaseManager: MockDatabaseManager!
    var mockStorageManager: MockStorageManager!
    
    override func setUp() {
        super.setUp()
        mockDatabaseManager = MockDatabaseManager()
        mockStorageManager = MockStorageManager()

        DatabaseManager.shared = mockDatabaseManager
        StorageManager.shared = mockStorageManager
        
        viewModel = BoulderInfoModel(boulderID: 1, userID: "testUserID")
    }
    
    override func tearDown() {
        viewModel = nil
        mockDatabaseManager = nil
        mockStorageManager = nil
        super.tearDown()
    }
    
    func testPerformanceLoadBoulderData() async {
        let mockBoulder = BoulderD(
            id: 1,
            diff: "6A",
            color: "#FF5733",
            x: 10.0,
            y: 20.0,
            sector_id: 1,
            gym_id: 123,
            is_active: true
        )

        let mockSector = SectorD(id: 1, sector_name: "Sector A", gymID: 123)
        
        mockDatabaseManager.mockBoulder = mockBoulder
        mockDatabaseManager.mockSector = mockSector

        let expectation = XCTestExpectation(description: "Performance test for loading boulder data")
        
        measure {
            Task {
                await viewModel.loadBoulderData()
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 60.0)
    }
    
    func testPerformanceLoadToppedByData() async {
        let mockToppedByData = (1...100).map { index in
            ToppedBy(
                user_id: "testUserID \(index)",
                boulder_id: 1,
                is_flashed: Bool.random(),
                created_at: "2024-01-23T12:00:00Z"
            )
        }

        mockDatabaseManager.mockToppedByData = mockToppedByData

        let expectation = XCTestExpectation(description: "Performance test for loading toppedBy data with 100 records")
        
        measure {
            Task {
                await viewModel.loadInitialState()
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 60.0)
    }

    
    func testPerformanceLoadVotesDataWithLargeDataset() async {
        let largeVotesData = (1...5000).map { index in
            DatabaseManager.AllGradeGroupedVotes(
                difficulty: "6A",
                votes: Int.random(in: 1...100)
            )
        }
        
        mockDatabaseManager.mockVotesData = largeVotesData
        
        let expectation = XCTestExpectation(description: "Performance test for loading large votes data")
        
        measure {
            Task {
                await viewModel.loadVotes()
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 60.0)
    }
    
    func testPerformanceLoadRatingsWithLargeDataset() async {
        let largeRatingsData = (1...5000).map { index in
            StarVote(user_id: "testUserID", boulder_id: index, star_vote: Int.random(in: 1...5))
        }
        
        mockDatabaseManager.mockRatingsData = largeRatingsData
        
        let expectation = XCTestExpectation(description: "Performance test for loading large ratings data")
        
        measure {
            Task {
                await viewModel.loadRatings()
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 60.0)
    }

    
}
