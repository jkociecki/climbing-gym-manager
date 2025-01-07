import SwiftUI

struct AddBouldersView: View {
    @State private var difficulty: String = ""
    @State private var selectedColor: String? = nil
    @State private var sector: String = ""
    @State private var selectedSectorID: Int? = nil
    @State private var isShowingMap = false
    @State private var tapPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var sectors: [SectorD] = []
    
    @Binding var isPresented: Bool


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
    
    func addBoulder() {
        Task {
            do {
                let res = try await DatabaseManager.shared.client.from("Boulders").insert(
                    BoulderDUpload(
                        diff: difficulty,
                        color: "#" + (selectedColor ?? "000000"),
                        x: Float(tapPosition.x),
                        y: Float(tapPosition.y),
                        sector_id: selectedSectorID ?? 1,
                        gym_id: AuthManager.shared.adminOf
                    )
                ).execute()
                print(res)
                print("Boulder added successfully.")
            } catch {
                print("Error adding boulder: \(error)")
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Button("Back") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                HeaderView()
                DifficultySelectionView(difficulty: $difficulty)
                ColorSelectionView(selectedColor: $selectedColor)
                SectorSelectionView(sector: $sector, selectedSectorID: $selectedSectorID, sectors: sectors)
                LocationSelectionView(isShowingMap: $isShowingMap, tapPosition: $tapPosition)
                Button("Add Boulder") {
                    addBoulder()
                }
            }
        }
        .onAppear {
            fetchSectors()
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
}

struct HeaderView: View {
    var body: some View {
        Text("Add New Boulder")
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

struct DifficultySelectionView: View {
    @Binding var difficulty: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty Level")
                .font(.headline)
            Menu {
                ForEach(allDifficulties, id: \ .self) { diff in
                    Button(action: { difficulty = diff }) {
                        HStack {
                            Text(diff)
                            if difficulty == diff {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                SelectionButton(label: difficulty.isEmpty ? "Select difficulty" : difficulty)
            }
        }
        .padding(.horizontal)
    }
}

struct ColorSelectionView: View {
    @Binding var selectedColor: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(colors, id: \ .self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .opacity(selectedColor == color ? 1 : 0)
                        )
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        .scaleEffect(selectedColor == color ? 0.92 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedColor)
                        .onTapGesture {
                            withAnimation {
                                selectedColor = selectedColor == color ? nil : color
                            }
                        }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.horizontal)
    }
}

struct SectorSelectionView: View {
    @Binding var sector: String
    @Binding var selectedSectorID: Int?
    var sectors: [SectorD]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sector")
                .font(.headline)
            Menu {
                ForEach(sectors, id: \.id) { sectorOption in
                    Button(action: {
                        sector = sectorOption.sector_name
                        selectedSectorID = sectorOption.id
                    }) {
                        HStack {
                            Text(sectorOption.sector_name)
                            if sector == sectorOption.sector_name {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                SelectionButton(label: sector.isEmpty ? "Select sector" : sector)
            }
        }
        .padding(.horizontal)
    }
}

struct LocationSelectionView: View {
    @Binding var isShowingMap: Bool
    @Binding var tapPosition: CGPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
            VStack(spacing: 12) {
                if tapPosition != CGPoint(x: 0, y: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Selected coordinates:")
                                .foregroundColor(.gray)
                            Text(String(format: "X: %.2f, Y: %.2f", tapPosition.x, tapPosition.y))
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                Button(action: { isShowingMap = true }) {
                    HStack {
                        Image(systemName: "map")
                        Text(tapPosition == CGPoint(x: 0, y: 0) ? "Select Location" : "Change Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SelectionButton: View {
    let label: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(label == "Select difficulty" || label == "Select sector" ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}


struct FullScreenMapView: View {
    @Binding var isPresented: Bool
    @State var mapViewModel: MapViewModel = MapViewModel(isCurrentGym: false)
    @Binding var tapPosistion: CGPoint
    @Binding var selectedColor: String?
    @Binding var sector: String
    @Binding var difficulty: String
    @State private var isloading: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Text("Confirm")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .zIndex(2)
                
                MapView(mapViewModel: mapViewModel, isTapInteractive: false, tapPosistion: $tapPosistion, isEdit: false, isLoading: $isloading)
            }
            .onChange(of: tapPosistion) { _, newValue in
                if let index = mapViewModel.boulders.firstIndex(where: { $0.id == -1 }) {
                    mapViewModel.boulders.remove(at: index)
                }
                mapViewModel.boulders.append(
                    Boulder(
                        id: -1,
                        x: newValue.x,
                        y: newValue.y,
                        difficulty: difficulty,
                        color: Color(hex: selectedColor ?? "#000000"),
                        sector: sector,
                        isDone: .NotDone
                    )
                )
            }
        }
    }
}

