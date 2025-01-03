import SwiftUI


struct selectBoulder: View {
    @State var tappos: CGPoint = CGPoint()
    @Binding var isPresented: Bool

    
    var body: some View {
        VStack {
            Button("Back") {
                print("tapped")
                isPresented = false
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .zIndex(200)
            
            ZStack {
                MapView(
                    mapViewModel: MapViewModel(isCurrentGym: false),
                    isTapInteractive: false,
                    tapPosistion: $tappos,
                    isEdit: true
                )
                .frame(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height - 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 2) // Opcjonalna ramka wokół mapy
                )
            }
            .padding(.horizontal)
        }
        .padding(.top, 100)
        .ignoresSafeArea(edges: .bottom) // Upewnij się, że inne elementy nie przeszkadzają
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




    var body: some View {
        Group {
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
                        }
                        Button("Delete Boulder") {
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
                difficulty: $difficulty
            )
        }

    }
    
    func fetchSectors() {
        Task {
            do {
                //HERE
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




