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
    @Binding var isShowing: Bool
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mapViewModel: MapViewModel

    
    var sectors: [String]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 8)
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    contentSection
                    buttonSection
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.fioletowy)
                Text("Filters")
                    .font(.system(size: 20, weight: .semibold))
            }
            Spacer()
            Button(action: { isShowing = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var contentSection: some View {
        VStack(spacing: 32) {
            gradeSection
            colorSection
            sectorSection
        }
        .padding(.horizontal, 20)
    }
    
    private var gradeSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Grade")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(allDifficulties[selectedRange.first!]) - \(allDifficulties[selectedRange.last!])")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(UIColor.systemGray6))
                        )
                }
                
                RangedSliderView(
                    allDifficulties: allDifficulties,
                    currentRange: $selectedRange
                )
                .frame(height: 20)
            }
        }
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Colors")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(colors, id: \.self) { color in
                    ColorCircle(color: color, isSelected: selectedColors.contains(color))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                toggleSelection(for: color)
                            }
                        }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
        }
    }
    
    private var sectorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sector")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            SectorsGrid(selectedSectors: $selectedSectors, sectors: sectors)
                .frame(height: 220)
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                isShowing = true
                mapViewModel.applyFilters(difficulties: selectedRange, colors: selectedColors, sectors: selectedSectors)

            }) {
                Text("Apply")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.fioletowy)
                    )
            }
            
            Button(action: {
                mapViewModel.resetFilters()
                isShowing = false
                selectedRange = 0...allDifficulties.count - 1
                selectedColors = []
                selectedSectors = []
            }) {
                Text("Reset")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.fioletowy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.fioletowy, lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func toggleSelection(for color: String) {
        if selectedColors.contains(color) {
            selectedColors.remove(color)
        } else {
            selectedColors.insert(color)
        }
    }
}

struct ColorCircle: View {
    let color: String
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .fill(Color(hex: color))
            .frame(width: 35, height: 35)
            .scaleEffect(isSelected ? 0.7 : 1)

            .overlay(
                ZStack{
                    Circle()
                        .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 5)
                    Circle()
                        .stroke(isSelected ? Color.secondary : Color.clear, lineWidth: 2)
                }
            )
    }
}

struct SectorsGrid: View {
    @Binding var selectedSectors: Set<String>
    var sectors: [String]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(sectors, id: \.self) { sector in
                    SectorButton(
                        title: sector,
                        isSelected: selectedSectors.contains(sector),
                        action: { toggleSelection(for: sector) }
                    )
                }
            }
        }
    }
    
    private func toggleSelection(for sector: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedSectors.contains(sector) {
                selectedSectors.remove(sector)
            } else {
                selectedSectors.insert(sector)
            }
        }
    }
}

struct SectorButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .lineLimit(1)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.fioletowy.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? Color.fioletowy : Color(UIColor.separator),
                            lineWidth: 1
                        )
                )
                .cornerRadius(8)
                .foregroundColor(isSelected ? Color.fioletowy : .primary)
        }
        .buttonStyle(PlainButtonStyle())
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
                        
                        MapFiltersView(isShowing: $isShowing, mapViewModel: mapViewModel, sectors: mapSectorNames())
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
