import SwiftUI


struct selectBoulder: View {
    @State var tappos: CGPoint = CGPoint()
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool
    @State var mapViewModel: MapViewModel = MapViewModel(isCurrentGym: false)
    
    
    var body: some View {
        ZStack {
            MapView(
                mapViewModel: mapViewModel,
                isTapInteractive: false,
                tapPosistion: $tappos,
                isEdit: true,
                isLoading: $isLoading
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        print("tapped")
                        isPresented = false
                    }) {
                        HStack {
                            Text("Back")
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct EditDeleteBoulder: View {
    var boulderID: Int
    @State private var boulder: BoulderD?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedColor: String? = nil
    @State private var difficulty: String = ""
    @State private var sectors: [SectorD] = []
    @State private var selectedSectorID: Int? = nil
    @State private var sector: String = ""
    @State private var isShowingMap = false
    @State private var tapPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Binding var boulders: [Boulder]
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .zIndex(10)
            }
            else if let boulder = boulder {
                ScrollView{
                    VStack(spacing: 24) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(hex: boulder.color))
                                .frame(width: 40, height: 40)
                                .shadow(radius: 2)

                            VStack(alignment: .leading) {
                                Text("Difficulty")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(boulder.diff)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 5)
                        )

                        DifficultySelectionView(difficulty: $difficulty)
                        ColorSelectionView(selectedColor: $selectedColor)
                        SectorSelectionView(sector: $sector, selectedSectorID: $selectedSectorID, sectors: sectors)
                        LocationSelectionView(isShowingMap: $isShowingMap, tapPosition: $tapPosition)

                        Button("Edit Boulder") {
                            Task {
                                do {
                                    var updatedBoulder = boulder
                                    let boulderIndex = boulders.firstIndex(where: { $0.id == boulder.id })
                                    
                                    if let newColor = selectedColor, !newColor.isEmpty, newColor != boulder.color {
                                        updatedBoulder.color = newColor
                                        if let boulderIndex = boulderIndex {
                                            boulders[boulderIndex].color = Color(hex: newColor)
                                        }                                   }
                                    if !difficulty.isEmpty, difficulty != boulder.diff {
                                        updatedBoulder.diff = difficulty
                                        if let boulderIndex = boulderIndex {
                                            boulders[boulderIndex].difficulty = difficulty
                                        }
                                    }
                                    if let newSectorID = selectedSectorID, newSectorID != boulder.sector_id {
                                        updatedBoulder.sector_id = newSectorID
                                        if let sector = sectors.first(where: { $0.id == selectedSectorID } )
                                        {
                                            if let boulderIndex = boulderIndex {
                                                boulders[boulderIndex].sector = sector.sector_name
                                            }
                                        }

                                    }
                                    if tapPosition != CGPoint(x: 0, y: 0) {
                                        updatedBoulder.x = Float(tapPosition.x)
                                        updatedBoulder.y = Float(tapPosition.y)
                                        if let boulderIndex = boulderIndex {
                                            boulders[boulderIndex].x = CGFloat(tapPosition.x)
                                            boulders[boulderIndex].y = CGFloat(tapPosition.y)
                                        }
                                    }
                                    
                                    try await DatabaseManager.shared.updateBoulder(boulder: updatedBoulder)
                                    DispatchQueue.main.async {
                                        alertMessage = "Boulder successfully updated."
                                        showAlert = true
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        alertMessage = "Error updating boulder: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                }
                            }
                        }

                        Button("Delete Boulder") {
                            Task {
                                do {
                                    try await DatabaseManager.shared.deleteBoulderWithIsActive(boulderID: boulderID)
                                    DispatchQueue.main.async {
                                        alertMessage = "Boulder successfully deleted."
                                        showAlert = true
                                    }
                                    boulders.removeAll(where: { $0.id == boulderID })
                                } catch {
                                    DispatchQueue.main.async {
                                        alertMessage = "Error deleting boulder: \(error.localizedDescription)"
                                        showAlert = true
                                    }
                                }
                            }
                        }
                    }
                }
                .zIndex(10)
                .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .onAppear{ fetchSectors() }
        .task {
            await loadBoulderData()
        }
        .fullScreenCover(isPresented: $isShowingMap) {
            FullScreenMapView(
                isPresented: $isShowingMap,
                tapPosistion: $tapPosition,
                selectedColor: $selectedColor,
                sector: $sector,
                difficulty: $difficulty,
                isloading: $isLoading
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Add Boulder"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func fetchSectors() {
        Task {
            do {
                let res = try await DatabaseManager.shared.getGymSectors(id: AuthManager.shared.adminOf)
                DispatchQueue.main.async {
                    self.sectors = res
                }
            } catch {
                print("Error fetching sectors: \(error)")
            }
        }
    }

    private func loadBoulderData() async {
        do {
            if let fetchedBoulder = try await DatabaseManager.shared.getBoulderByID(boulderID: boulderID) {
                boulder = fetchedBoulder
            } else {
                errorMessage = "Boulder not found"
            }
        } catch {
            errorMessage = "Error loading boulder: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview{
    MainView()
}
