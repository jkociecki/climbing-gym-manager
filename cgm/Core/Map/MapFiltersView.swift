import SwiftUI

let colors = [
    "FFDD2D", "FF0000", "22FF00", "0090FF", "F600FF", "0400FF",
    "000000", "FFFFFF", "00D4FF", "FFAE00", "FC43BE", "9A9A9A",
    "2DFFDD", "FF1493", "FF4500", "6A0DAD"
]

struct MapFiltersView: View {
    @State private var selectedRange: ClosedRange<Int> = 0...allDifficulties.count - 1
    @State private var selectedColors: Set<String> = []
    @State var selectedSectors: Set<String> = []
    @ObservedObject var mapViewModel: MapViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var sectors: [String]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 8)

    var body: some View {
        ZStack {
            Group {
                if colorScheme == .light {
                    Color.white
                } else {
                    Color(.systemBackground)
                }
            }
            .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(.fioletowy)
                            .padding(.leading, 20)
                        Text("FILTERS")
                            .font(.custom("Inter18pt-Light", size: 12))
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 10)

                    HStack {
                        Text("GRADE")
                            .font(.custom("Inter18pt-Bold", size: 14))
                            .foregroundColor(.primary)
                        Text(String(allDifficulties[selectedRange.first!]))
                            .font(.custom("Inter18pt-Light", size: 12))
                            .foregroundColor(.primary)
                        Text("-")
                            .font(.custom("Inter18pt-Light", size: 12))
                            .foregroundColor(.primary)
                        Text(String(allDifficulties[selectedRange.last!]))
                            .font(.custom("Inter18pt-Light", size: 12))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.vertical, 10)
                }

                RangedSliderView(
                    allDifficulties: allDifficulties,
                    currentRange: $selectedRange
                )
                .frame(width: 300, height: 15)
                .padding(.vertical, 10)

                Divider()
                    .background(Color.primary.opacity(0.2))
                
                VStack(alignment: .leading){
                    Text("COLORS")
                        .font(.custom("Inter18pt-Bold", size: 14))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.vertical, 10)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 32, height: 32)
                            .scaleEffect(selectedColors.contains(color) ? 0.7 : 1)
                            .overlay(
                                ZStack{
                                    Circle()
                                        .stroke(selectedColors.contains(color) ? Color.primary : Color.clear, lineWidth: 5)
                                    Circle()
                                        .stroke(selectedColors.contains(color) ? Color.secondary : Color.clear, lineWidth: 2)
                                }
                            )
                            .onTapGesture {
                                toggleSelection(for: color)
                            }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(Color(UIColor.systemGray6))
                        .padding(.horizontal, 5)
                )
                
                Divider()
                    .background(Color.primary.opacity(0.2))
                    .padding(.vertical, 10)
                
                SectorsGrid(selectedSectors: $selectedSectors, sectors: sectors)
                    .padding(.vertical, 10)

                VStack(spacing: 10) {
                    Button {
                        mapViewModel.applyFilters(difficulties: selectedRange, colors: selectedColors, sectors: selectedSectors)
                    } label: {
                        Text("Apply")
                            .foregroundStyle(.white)
                            .font(.custom("Inter18pt-SemiBold", size: 16))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.fioletowy)
                                    .stroke(.fioletowy, lineWidth: 2)
                            )
                    }
                    
                    Button {
                        mapViewModel.resetFilters()
                    } label: {
                        Text("Reset")
                            .foregroundStyle(.white)
                            .font(.custom("Inter18pt-SemiBold", size: 16))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.fioletowy)
                                    .stroke(.fioletowy, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func toggleSelection(for color: String) {
        if selectedColors.contains(color) {
            selectedColors.remove(color)
        } else {
            selectedColors.insert(color)
        }
    }
}

struct SectorsGrid: View {
    @Binding var selectedSectors: Set<String>
    @Environment(\.colorScheme) var colorScheme
    var sectors: [String]

    var body: some View {
        ZStack {
            Group {
                if colorScheme == .light {
                    Color.white
                } else {
                    Color(.systemBackground)
                }
            }
            .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("SECTOR")
                    .font(.custom("Inter18pt-Bold", size: 14))
                    .foregroundColor(.primary)
                    .padding(.leading, 20)
                    .padding(.bottom, 10)

                GeometryReader { geometry in
                    let columns = calculateColumns(for: geometry.size.width)
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(sectors, id: \.self) { sector in
                            Button(action: {
                                toggleSelection(for: sector)
                            }) {
                                Text(sector)
                                    .font(.custom("Inter18pt-Light", size: 12))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSectors.contains(sector) ? Color.fioletowy.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedSectors.contains(sector) ? Color.fioletowy : Color.secondary, lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                                    .foregroundColor(selectedSectors.contains(sector) ? Color.fioletowy : Color.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func calculateColumns(for width: CGFloat) -> [GridItem] {
        let itemWidth: CGFloat = 100
        let spacing: CGFloat = 10
        let numberOfColumns = max(Int((width + spacing) / (itemWidth + spacing)), 1)
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: numberOfColumns)
    }

    private func toggleSelection(for sector: String) {
        if selectedSectors.contains(sector) {
            selectedSectors.remove(sector)
        } else {
            selectedSectors.insert(sector)
        }
    }
}

struct SlidingFilterPanel: View {
    @Binding var isShowing: Bool
    @ObservedObject var mapViewModel: MapViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                if isShowing {
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowing = false
                            }
                        }
                }
                
                HStack(spacing: 0) {
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isShowing = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.title2)
                            }
                            .padding()
                        }
                        
                        MapFiltersView(mapViewModel: mapViewModel, sectors: mapSectorNames())
                    }
                    .frame(width: min(geometry.size.width * 0.85, 380))
                    .background(Color(UIColor.systemBackground))
                }
                .offset(x: isShowing ? 0 : geometry.size.width)
            }
        }
    }
    
    private func mapSectorNames() -> [String] {
        return mapViewModel.gymSectors.map { $0.id }
    }
}
