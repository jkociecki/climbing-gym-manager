import SwiftUI

struct MapView: View {
    @StateObject private var mapViewModel:  MapViewModel = MapViewModel()

    let defaultScale:                       CGFloat = 0.5
    let zoomScale:                          CGFloat = 1.2
    @State var transform:                   CGAffineTransform

    
    init() {
        _transform = State(initialValue: CGAffineTransform(scaleX: defaultScale, y: defaultScale))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray5).ignoresSafeArea()
            
            ZStack {
                ForEach(Array(mapViewModel.gymSectors.enumerated()), id: \.offset) { sectorIndex, sector in
                    SectorView(
                        sector:         sector,
                        isSelected:     mapViewModel.selectedSectorIndex == sectorIndex
                    )
                }
                .transformEffect(transform)
            }
            .overlay(
                GestureTransformView(
                    transform:  $transform,
                    paths:      $mapViewModel.gymSectors
                )
            )
            
            bouldersOverlay
                .transformEffect(transform)
            
            ForEach(Array(mapViewModel.gymSectors.enumerated()), id: \.offset) { sectorIndex, sector in
                let center = sector.paths[0].path.boundingRect

            Text(sector.id)
                .font(.custom("Righteous-Regular", size: 10))
                .foregroundStyle(.white)
                .position(x: center.midX, y: center.midY)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.white, lineWidth: 3)
                        .fill(.purple)
                        .frame(width: 73, height: 26)
                        .position(x: center.midX, y: center.midY)
                ).transformEffect(transform)
                    .onAppear{
                        print("TEkST: ", sectorIndex, center.midX, " ", center.midY)
                    }
                    }

        }
    }
    
    
    
    private var bouldersOverlay: some View {
        ZStack {
            ForEach(mapViewModel.boulders, id: \.id) { boulder in
                let centerPosition: CGPoint = {
                    if let sectorIndex = mapViewModel.gymSectors.firstIndex(where: { $0.id == boulder.sector }) {
                        let firstPath = mapViewModel.gymSectors[sectorIndex].paths[0]
                        let boundingBox = firstPath.path.boundingRect
                        return CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                    }
                    return CGPoint(x: 0, y: 0)
                }()

                let scaleFactor = transform.a
                let visibleRect = calculateVisibleRect()
                let isVisible = visibleRect.contains(CGPoint(x: boulder.x, y: boulder.y))
                let isZoomedIn = scaleFactor > 1.5

                Text(boulder.difficulty)
                    .font(.custom("Righteous-Regular", size: 5 * scaleFactor))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(
                        Circle()
                            .fill(boulder.color)
                            .shadow(color: boulder.color.opacity(0.4), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .position(isVisible ? CGPoint(x: boulder.x, y: boulder.y) : centerPosition)
                    .opacity(isZoomedIn ? (isVisible ? 1 : 0) : 0)
                    .modifier(TransitionModifier(isVisible: isVisible))
            }
        }
    }

    private func calculateVisibleRect() -> CGRect {
        let inverseTransform = transform.inverted()
        // Przy założeniu, że masz znane rozmiary ekranu.
        let screenSize = UIScreen.main.bounds.size
        let topLeft = CGPoint.zero.applying(inverseTransform)
        let topRight = CGPoint(x: screenSize.width, y: 0).applying(inverseTransform)
        let bottomLeft = CGPoint(x: 0, y: screenSize.height).applying(inverseTransform)
        let bottomRight = CGPoint(x: screenSize.width, y: screenSize.height).applying(inverseTransform)

        let minX = min(min(topLeft.x, topRight.x), min(bottomLeft.x, bottomRight.x))
        let maxX = max(max(topLeft.x, topRight.x), max(bottomLeft.x, bottomRight.x))
        let minY = min(min(topLeft.y, topRight.y), min(bottomLeft.y, bottomRight.y))
        let maxY = max(max(topLeft.y, topRight.y), max(bottomLeft.y, bottomRight.y))

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    
    struct TransitionModifier: ViewModifier {
        let isVisible: Bool
        
        func body(content: Content) -> some View {
            content
                .animation(
                    .spring(
                        response: 0.55,
                        dampingFraction: 0.8,
                        blendDuration: 0
                    ),
                    value: isVisible
                )
        }
    }
    
}

struct SectorView: View {
    let sector:     Sector
    let isSelected: Bool
    
    var body: some View {
        if sector.id != "nclick" {
            ZStack {
                PathView(
                    path: sector.paths[1].path,
                    defaultColor: Color(hex: "#CFF6FF"),
                    selectedColor: Color(hex: "#DCDCDC"),
                    isSelected: isSelected
                )
                PathView(
                    path: sector.paths[2].path,
                    defaultColor: Color("Czerwony"),
                    selectedColor: Color(hex: "#7D7D7D"),
                    isSelected: isSelected
                )
                PathView(
                    path: sector.paths[3].path,
                    defaultColor: Color("Fioletowy"),
                    selectedColor: Color(hex: "#4A4A4A"),
                    isSelected: isSelected
                )

            }
        } else {
            ZStack {
                ForEach(Array(sector.paths.enumerated()), id: \.offset) { _, pathWrapper in
                    PathView(
                        path: pathWrapper.path,
                        defaultColor: pathWrapper.color,
                        selectedColor: pathWrapper.color,
                        isSelected: isSelected
                    )
                }
            }
        }
    }
}

struct PathView: View {
    let path:           Path
    let defaultColor:   Color
    let selectedColor:  Color
    let isSelected:     Bool
    
    var body: some View {
        path
            .fill(isSelected ?
                  AnyShapeStyle(selectedColor) :
                  AnyShapeStyle(defaultColor))
            .overlay(path.stroke(Color.white, lineWidth: 1))
    }
}

#Preview{
    MapView()
}
