//
//  BoulderInfoModelTests.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 23/01/2025.
//


import XCTest
@testable import cgm
import SwiftUICore

class BoulderInfoModelTests: XCTestCase {
    var viewmodel: BoulderInfoModel!
    var mockDatabaseManager: MockDatabaseManager!
    var mockStorageManager: MockStorageManager!

    override func setUp() {
        super.setUp()
        mockDatabaseManager = MockDatabaseManager()
        mockStorageManager = MockStorageManager()

        DatabaseManager.shared = mockDatabaseManager
        StorageManager.shared = mockStorageManager
        

        viewmodel = BoulderInfoModel(boulderID: 1, userID: "testUserID")
    }

    override func tearDown() {
        viewmodel = nil
        mockDatabaseManager = nil
        mockStorageManager = nil
        super.tearDown()
    }
    
    func testLoadBoulderData() async {
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
        
        let mockToppedBy = ToppedBy(user_id: "testUserID", boulder_id: 1, is_flashed: true, created_at: "2025-01-23T00:00:00Z")
        mockDatabaseManager.mockToppedByData = [mockToppedBy]
        
        mockDatabaseManager.mockBoulder = mockBoulder
        mockDatabaseManager.mockSector = mockSector

        await viewmodel.loadBoulderData()


        
        XCTAssertEqual(viewmodel.difficulty, "6A")
        XCTAssertEqual(viewmodel.color, "#FF5733")

    }


    func testLoadToppedByData() async {
        let mockToppedBy = ToppedBy(
            user_id: "testUserID",
            boulder_id: 1,
            is_flashed: true,
            created_at: "2024-01-23T12:00:00Z"
        )

        mockDatabaseManager.mockToppedByData = [mockToppedBy]

        await viewmodel.loadInitialState()

        XCTAssertTrue(viewmodel.isFlashPressed)
        XCTAssertFalse(viewmodel.isDonePressed)
    }

    func testLoadVotesData() async {
        let mockVotes = [DatabaseManager.AllGradeGroupedVotes(difficulty: "6A", votes: 10)]
        mockDatabaseManager.mockVotesData = mockVotes

        await viewmodel.loadVotes()
        await Task.sleep(500_000_000)

        XCTAssertEqual(viewmodel.votesData.count, 1)
        XCTAssertEqual(viewmodel.votesData.first?.votes, 10)
    }

    func testLoadRatings() async {
        let mockRatings = [StarVote(user_id: "test", boulder_id: 1, star_vote: 4)]
        mockDatabaseManager.mockRatingsData = mockRatings

        await viewmodel.loadRatings()

        XCTAssertEqual(viewmodel.ratings.count, 1)
        XCTAssertEqual(viewmodel.ratings.first?.star_vote, 4)
    }

    func testHandleButtonStateChangeWhenNotPressed() async {
        viewmodel.isFlashPressed = false
        viewmodel.isDonePressed = false
        
        await viewmodel.handleButtonStateChange()

        XCTAssertFalse(viewmodel.isFlashPressed)
        XCTAssertFalse(viewmodel.isDonePressed)
    }

    func testHandleButtonStateChangeWhenFlashPressed() async {
        viewmodel.isFlashPressed = true
        viewmodel.isDonePressed = false


        await viewmodel.handleButtonStateChange()

        XCTAssertTrue(viewmodel.isFlashPressed)
        XCTAssertFalse(viewmodel.isDonePressed)
    }
    
    func testSetErrorState() {
        viewmodel.setErrorState()
        
        XCTAssertEqual(viewmodel.difficulty, "Error")
        XCTAssertEqual(viewmodel.sector, "Error")
        XCTAssertEqual(viewmodel.routesetter, "Error")
    }
}
