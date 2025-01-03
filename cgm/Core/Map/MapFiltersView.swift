//
//  MapFiltersView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.
//

import SwiftUI

let colors = [
    "FFDD2D", "FF0000", "22FF00", "0090FF", "F600FF", "0400FF",
    "000000", "FFFFFF", "00D4FF", "FFAE00", "FC43BE", "9A9A9A",
    "2DFFDD", "FF1493", "FF4500", "6A0DAD"
]

let sectors = ["Połóg", "Wu", "Diament", "Kaskady", "Piony", "Beczka",
"Prawe Zacięcie", "Mały Sześciokąt", "Duży Sześciokąt", "Lewa Grota",
"Prawa Grota", "Lewa Grota", "Tył Wieży"]


struct MapFiltersView: View {
    @State private var selectedRange:       ClosedRange<Int> = 0...allDifficulties.count - 1
    @State private var selectedColors:      Set<String> = []
    @State var selectedSectors:             Set<String> = []
    @ObservedObject var mapViewModel:       MapViewModel
    
    var sectors: [String]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 8)

    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(.fioletowy)
                            .padding(.leading, 20)
                        Text("FILTERS")
                            .font(.custom("Inter18pt-Light", size: 12))
                    }
                    .padding(.vertical, 10)

                    HStack {
                        Text("GRADE")
                            .font(.custom("Inter18pt-Bold", size: 14))
                        Text(String(allDifficulties[selectedRange.first!]))
                            .font(.custom("Inter18pt-Light", size: 12))
                        Text("-")
                            .font(.custom("Inter18pt-Light", size: 12))
                        Text(String(allDifficulties[selectedRange.last!]))
                            .font(.custom("Inter18pt-Light", size: 12))
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
                
                VStack(alignment: .leading){
                    Text("COLORS")
                        .font(.custom("Inter18pt-Bold", size: 14))
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
                                        .stroke(selectedColors.contains(color) ? Color.white : Color.clear, lineWidth: 5)
                                    Circle()
                                        .stroke(selectedColors.contains(color) ? Color.gray : Color.clear, lineWidth: 2)
                                }
                            )
                            .onTapGesture {
                                toggleSelection(for: color)
                            }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color(hex: "F4F4F4")).padding(.horizontal, 5))
                
                Divider()
                    .padding(.vertical, 10)
                
                SectorsGrid(selectedSectors: $selectedSectors, sectors: sectors)  // Dodaj $ przed selectedSectors
                    .padding(.vertical, 10)

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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                
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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)


               

            }
        }
    }

    private func toggleSelection(for color: String) {
        if selectedColors.contains(color) {
            selectedColors.remove(color) // Odznacz kolor
        } else {
            selectedColors.insert(color) // Zaznacz kolor
        }
    }
}

struct SectorsGrid: View {
    @Binding var selectedSectors: Set<String>
    var sectors: [String]

    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Text("SECTOR")
                    .font(.custom("Inter18pt-Bold", size: 14))
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
                                    .background(selectedSectors.contains(sector) ? Color.purple.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedSectors.contains(sector) ? Color.purple : Color.gray, lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                                    .foregroundColor(selectedSectors.contains(sector) ? Color.purple : Color.gray)
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
                
                // Filter panel
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
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                            .padding()
                        }
                        
                        MapFiltersView(mapViewModel: mapViewModel, sectors: mapSectorNames())
                    }
                    .frame(width: min(geometry.size.width * 0.85, 380))
                    .background(.white)
                }
                .offset(x: isShowing ? 0 : geometry.size.width)
            }
        }
    }
    
    private func mapSectorNames() -> [String] {
        return mapViewModel.gymSectors.map { $0.id }
    }
}

