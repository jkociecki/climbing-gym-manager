import SwiftUI


struct MapView: View {
    @ObservedObject private var mapViewModel: MapViewModel
    @State private var selectedBoulder: Int? = nil
    var isTapInteractive: Bool
    var isEdit: Bool
    let defaultScale: CGFloat = 0.5
    let zoomScale: CGFloat = 1.2
    @State var transform: CGAffineTransform
    @Binding var tapPosition: CGPoint
    @State private var isWhileZooming:      Bool = false

    init(mapViewModel: MapViewModel, isTapInteractive: Bool, tapPosistion: Binding<CGPoint>, isEdit: Bool) {
        _transform = State(initialValue: CGAffineTransform(scaleX: defaultScale, y: defaultScale))
        self.mapViewModel = mapViewModel
        self.isTapInteractive = isTapInteractive
        self._tapPosition = tapPosistion
        self.isEdit = isEdit
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray5)
                .ignoresSafeArea()
            
            ZStack {
                ForEach(Array(mapViewModel.gymSectors.enumerated()), id: \.offset) { sectorIndex, sector in
                    SectorView(
                        sector: sector,
                        isSelected: mapViewModel.selectedSectorIndex == sectorIndex
                    )
                }
                .transformEffect(transform)
                .ignoresSafeArea()
            }
            .overlay(
                GestureTransformView(
                    transform: $transform,
                    paths: $mapViewModel.gymSectors,
                    prevTapPos: $tapPosition,
                    isWhileZooming: $isWhileZooming,
                    isTapInteractive: isTapInteractive
                )
                .ignoresSafeArea()
            )
            
            bouldersOverlay
                .transformEffect(transform)
                .ignoresSafeArea()
                .drawingGroup()
            
            
            ForEach(Array(mapViewModel.gymSectors.enumerated()), id: \.offset) { sectorIndex, sector in
                let center = sector.paths[0].path.boundingRect
                
                Text(sector.id)
                    .font(.custom("Righteous-Regular", size: 8))
                    .foregroundStyle(.white)
                    .position(x: center.midX, y: center.midY)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(.white, lineWidth: 3)
                            .fill(.purple)
                            .frame(width: 73, height: 26)
                            .position(x: center.midX, y: center.midY)
                    )
                    .transformEffect(transform)
                    .ignoresSafeArea()
                    .drawingGroup()
                
                
            }
        }
        .sheet(item: $selectedBoulder) { boulderId in
            if isEdit{
                EditDeleteBoulder(boulderID: boulderId)
            }else{
                BoulderInfoView(viewModel: BoulderInfoModel(boulderID: boulderId, userID: AuthManager.shared.userUID ?? ""), boulders: $mapViewModel.boulders)
            }
            
        }
    }
    
    private var bouldersOverlay: some View {
        ZStack {
            let visibleRect: CGRect = {
                if isWhileZooming {
                    return CGRect()
                } else {
                    return calculateVisibleRect()
                }
            }()
            
            let scaleFactor = transform.a

            ForEach(mapViewModel.boulders, id: \.id) { boulder in
                let centerPosition: CGPoint = {
                    if let sectorIndex = mapViewModel.gymSectors.firstIndex(where: { $0.id == boulder.sector }) {
                        let firstPath = mapViewModel.gymSectors[sectorIndex].paths[0]
                        let boundingBox = firstPath.path.boundingRect
                        return CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                    }
                    return CGPoint(x: 0, y: 0)
                }()
                
                let isVisible = visibleRect.contains(CGPoint(x: boulder.x, y: boulder.y))
                let isZoomedIn = scaleFactor > 1.5
                
                let targetPosition = CGPoint(x: boulder.x, y: boulder.y)
                let offsetX = isVisible && isZoomedIn ? 0 : (centerPosition.x - targetPosition.x)
                let offsetY = isVisible && isZoomedIn ? 0 : (centerPosition.y - targetPosition.y)
                
                ZStack {
                    Text(boulder.difficulty)
                        .font(.custom("Righteous-Regular", size: 5))
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
                        .overlay(getBoulderIcon(isFlased: boulder.isDone))
                        .position(targetPosition)
                        .offset(x: offsetX, y: offsetY)
                        .animation(.easeOut(duration: 0.2), value: offsetX)
                        .animation(.easeOut(duration: 0.2), value: offsetY)
                        .opacity(isZoomedIn ? (isVisible ? 1 : 0) : 0)
                        .onTapGesture {
                            if isVisible && isZoomedIn {
                                selectedBoulder = boulder.id
                            }
                        }
                }
            }
        }
    }

    struct BoulderView: View {
        let boulder: Boulder // załóżmy że to jest twój model boulderu
        let isVisible: Bool
        let isZoomedIn: Bool
        let centerPosition: CGPoint
        let onTap: () -> Void
        
        var body: some View {
            Text(boulder.difficulty)
                .font(.custom("Righteous-Regular", size: 5))
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
                //.overlay(getBoulderIcon(isFlased: boulder.isDone))
                .position(
                    isVisible && isZoomedIn ?
                        CGPoint(x: boulder.x, y: boulder.y) :
                        centerPosition
                )
                .opacity(isZoomedIn ? (isVisible ? 1 : 0) : 0)
//                .animation(
//                    isVisible ? .easeOut(duration: 0.15) : nil,
//                    value: isVisible && isZoomedIn
//                )
                .onTapGesture(perform: onTap)
        }
    }
    
    @ViewBuilder
    func getBoulderIcon(isFlased: FlashDoneNone) -> some View {
        switch isFlased {
        case .Flash:
            ZStack{
                Circle()
                    .stroke(.yellow, lineWidth: 2)
                    .opacity(0.9)
                    .frame(width: 24, height: 24)
            }
        case .Done:
            ZStack{
                Circle()
                    .stroke(.yellow, lineWidth: 2)
                    .opacity(0.9)
                    .frame(width: 24, height: 24)
                Circle()
                    .stroke(.yellow, lineWidth: 1.5)
                    .opacity(0.5)
                    .scaleEffect(1.2)
                    .frame(width: 24, height: 24)
            }
        default:
            EmptyView()
        }
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
    
    private func calculateVisibleRect() -> CGRect {
        print("sadsada")
        let inverseTransform = transform.inverted()
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
    
    
    
    
    
    
}

extension Int: Identifiable {
    public var id: Int { self }
}
struct SectorView: View {
    let sector:     Sector
    let isSelected: Bool
    
    var body: some View {
        if sector.id != "nclick" {
            ZStack {
                ForEach(Array(sector.paths.enumerated()), id: \.offset) { _, pathWrapper in
                    PathView(path: pathWrapper.path,
                             defaultColor: pathWrapper.color,
                             selectedColor: pathWrapper.color,
                             isSelected: isSelected)
                }

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


struct HighQualityText: UIViewRepresentable {
    let text: String
    let font: UIFont
    let transform: CGAffineTransform
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.alignmentMode = .center
        view.layer.addSublayer(textLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let textLayer = uiView.layer.sublayers?.first as? CATextLayer {
            textLayer.transform = CATransform3DMakeAffineTransform(transform)
            textLayer.setAffineTransform(transform)
        }
    }
}
