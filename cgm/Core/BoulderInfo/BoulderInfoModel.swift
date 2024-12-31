//
//  BoulderInfoModel.swift
//  cgm
//
//  Created by Mikołaj Olesiński on 30/12/2024.
//

import Foundation
import SwiftUI


@MainActor
class BoulderInfoModel: ObservableObject {
    @Published var difficulty: String = "Loading..."
    @Published var sector: String = "Loading..."
    @Published var routesetter: String = "Loading..."
    @Published var color: String = "#00000"
    @Published var toppedByData: [ToppedBy] = []
    @Published var usersData: [String: (String?, String?, Data?)] = [:]
    @Published var isDonePressed: Bool = false
    @Published var isFlashPressed: Bool = false
    @Published var isLoading: Bool = true
    @Published var votesData: [DatabaseManager.AllGradeGroupedVotes] = []
    @Published var ratings: [StarVote] = []
    @Published var maxVoteCount: Int = 1
    @Published var errorMessage: String?

    let boulderID: Int
    let userID: String

    init(boulderID: Int, userID: String = "08BBCE85-0A59-4500-821D-0A235C7C5AEA") {
        self.boulderID = boulderID
        self.userID = userID
        Task {
            await loadBoulderData()
            await loadInitialState()
            await loadVotes()
            await loadRatings()
        }
    }

    func loadBoulderData() async {
        do {
            if let boulder = try await DatabaseManager.shared.getBoulderByID(boulderID: boulderID) {
                difficulty = boulder.diff
                color = boulder.color
                if let sectorData = try await DatabaseManager.shared.getSectorByID(sectorID: boulder.sector_id) {
                    sector = sectorData.sector_name
                } else {
                    sector = "Unknown Sector"
                }
                routesetter = "Unknown" // Replace with actual data if available
            } else {
                setUnknownState()
            }
        } catch {
            setErrorState()
        }
    }

    func loadInitialState() async {
        do {
            if let toppedBy = try await DatabaseManager.shared.getToppedBy(boulderID: boulderID, userID: userID) {
                isDonePressed = !toppedBy.is_flashed
                isFlashPressed = toppedBy.is_flashed
            } else {
                isDonePressed = false
                isFlashPressed = false
            }
            isLoading = false
        } catch {
            print("Failed to load data: \(error)")
            isLoading = false
        }
    }

    func loadVotes() async {
        do {
            let votes = try await DatabaseManager.shared.fetchGroupedGradeVotes(boulderID: boulderID, boulderDifficulty: difficulty)
            DispatchQueue.main.async {
                self.votesData = votes
                self.maxVoteCount = votes.map { $0.votes }.max() ?? 1
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadRatings() async {
        do {
            let fetchedRatings = try await DatabaseManager.shared.getBoulderStarVotes(boulderID: boulderID)
            self.ratings = fetchedRatings
            self.isLoading = false
        } catch {
            print("Failed to fetch ratings: \(error)")
            self.isLoading = false
        }
    }

    func handleButtonStateChange() async {
        do {
            if !isDonePressed && !isFlashPressed {
                try await DatabaseManager.shared.deleteToppedBy(boulderID: boulderID, userID: userID)
            } else {
                let toppedBy = ToppedBy(
                    user_id: userID,
                    boulder_id: boulderID,
                    is_flashed: isFlashPressed,
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                try await DatabaseManager.shared.updateToppedBy(toppedBy: toppedBy)
            }
        } catch {
            print("Failed to update or delete data: \(error)")
        }
    }

    func fetchToppedByData() async {
        do {
            let fetchedData = try await DatabaseManager.shared.getBoulderToppedBy(boulderID: boulderID)
            toppedByData = fetchedData
            await fetchUsersData(for: fetchedData)
        } catch {
            print("Error fetching ToppedBy data: \(error)")
        }
    }

    private func fetchUsersData(for toppedByData: [ToppedBy]) async {
        let userIds = Set(toppedByData.map { $0.user_id })
        await withTaskGroup(of: Void.self) { group in
            for userId in userIds {
                group.addTask {
                    do {
                        if let user = try await DatabaseManager.shared.getUser(userID: userId) {
                            let profilePictureData = try? await StorageManager.shared.fetchUserProfilePicture(user_uid: user.uid.uuidString)
                            DispatchQueue.main.async {
                                self.usersData[userId] = (user.name, user.surname, profilePictureData)
                            }
                        }
                    } catch {
                        print("Error fetching user data for userId: \(userId), \(error)")
                    }
                }
            }
        }
    }


    
    private func setUnknownState() {
        difficulty = "Unknown"
        sector = "Unknown"
        routesetter = "Unknown"
    }

    private func setErrorState() {
        difficulty = "Error"
        sector = "Error"
        routesetter = "Error"
    }
}




