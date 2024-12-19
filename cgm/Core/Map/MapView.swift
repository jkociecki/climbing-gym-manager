import SwiftUI

struct InteractiveClimbingWallView: View {
    @StateObject private var mapViewModel: MapViewModel = MapViewModel()
    
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var selectedAreaIndex: Int? = nil
    @State private var targetScale: CGFloat = 1.0
    @State private var targetOffset: CGSize = .zero
    @State private var isAlternateMapStyle: Bool = false
    
    init(climbingSectorsSVG: String) {
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                
                
                // Główna mapa
                GeometryReader { geometry in
                    ZStack {
                        Color.white
                            .ignoresSafeArea()
                        
                        mapBackground
                            .scaleEffect(lastScale * currentScale)
                            .offset(x: lastOffset.width + currentOffset.width, y: lastOffset.height + currentOffset.height)
                        bouldersOverlay
                            .scaleEffect(lastScale * currentScale)
                            .offset(x: lastOffset.width + currentOffset.width, y: lastOffset.height + currentOffset.height)
                        
                        
                    }
                    .gesture(
                        SimultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    currentOffset = value.translation
                                }
                                .onEnded { _ in
                                    lastOffset.width += currentOffset.width
                                    lastOffset.height += currentOffset.height
                                    
                                    currentOffset = .zero
                                },
                            MagnificationGesture()
                                .onChanged { value in
                                    currentScale = value
                                }
                                .onEnded { _ in
                                    lastScale *= currentScale
                                    currentScale = 1.0
                                }
                        )
                    )
                }
            }
        }
    }
    
    private var mapBackground: some View {
        ZStack {
            let boundingBox = mapViewModel.svgParser.calculateBoundingBox()
            Path { path in
                path.addRect(boundingBox)
            }
            .stroke(isAlternateMapStyle ? Color.blue : Color("Czerwony"), lineWidth: 10)
            
            ForEach(0..<mapViewModel.climbingSectors.count, id: \.self) { index in
                let path = mapViewModel.climbingSectors[index]
                let boundingBox = path.path.boundingRect // Oblicz prostokąt ograniczający
                let centerX = boundingBox.midX // Środek X prostokąta
                let centerY = boundingBox.midY // Środek Y prostokąta
                
                ClimbingArea(path: path.path,
                             fill: isAlternateMapStyle ? Color.gray : Color("Czerwony"),
                             stroke: .white,
                             isSelected: selectedAreaIndex == index,
                             lineWidth: 1)
                .onTapGesture {
                    if selectedAreaIndex == index {
                        resetZoom()
                    } else {
                        zoomToArea(path: path.path, index: index)
                    }
                }
                .shadow(color: .black.opacity(0.6), radius: 8, x: 4, y: 4)
                
                // Wyświetlanie indeksu na środku obszaru
                Text(path.sector)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Circle().fill(Color.black))
                    .position(x: centerX, y: centerY) // Pozycja tekstu w środku obszaru
            }
        }
    }
    
    
    
    
    
    private var bouldersOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(mapViewModel.boulders, id: \.id) { boulder in
                    let scaleFactor = lastScale * currentScale
                    let visibleRect = calculateVisibleRect(in: geometry.size)
                    let isVisible = visibleRect.contains(CGPoint(x: boulder.x, y: boulder.y))
                    let isZoomedIn = scaleFactor > 0.5
                    
                    let centerPosition: CGPoint = {
                        if let sectorIndex = mapViewModel.climbingSectors.firstIndex(where: { $0.sector == boulder.sector }) {
                            let boundingBox = mapViewModel.climbingSectors[sectorIndex].path.boundingRect
                            return CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                        }
                        return CGPoint(x: boulder.x, y: boulder.y)
                    }()
                    
                    Text("")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                        .padding(6)
                        .scaleEffect(lastScale * currentScale)
                        .background(
                            Circle()
                                .fill(boulder.color)
                                .shadow(color: boulder.color.opacity(0.4), radius: 5, x: 0, y: 2)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .opacity(isZoomedIn && isVisible ? 1 : 0) // Pojawienie się
                        .position(isVisible ? CGPoint(x: boulder.x, y: boulder.y) : centerPosition) // Użyj centerPosition
                        .animation(.easeInOut(duration: 0.5), value: isVisible) // Animacja ruchu
                        .animation(.easeInOut(duration: 0.3), value: isZoomedIn) // Animacja pojawienia się
                }
            }
        }
    }
    
    
    
    private func resetZoom() {
        withAnimation(.spring()) {
            selectedAreaIndex = nil
            targetScale = 1.0
            targetOffset = .zero
            lastScale = 1.0
            lastOffset = .zero
        }
    }
    
    private func calculateVisibleRect(in size: CGSize) -> CGRect {
        let scaleFactor = lastScale * currentScale
        let margin: CGFloat = 0
        
        let width = size.width / scaleFactor - margin
        let height = size.height / scaleFactor - margin
        let centerX = size.width / 2 - (lastOffset.width + currentOffset.width) / scaleFactor
        let centerY = size.height / 2 - (lastOffset.height + currentOffset.height) / scaleFactor
        
        return CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: max(width, 0),
            height: max(height, 0)
        )
    }
    
    
    
    private func zoomToArea(path: Path, index: Int) {
        let boundingBox = path.boundingRect
        
        let totalBoundingBox = path.boundingRect
        
        let scaleX = totalBoundingBox.width / boundingBox.width
        let scaleY = totalBoundingBox.height / boundingBox.height
        let newScale = min(scaleX, scaleY) * 2
        
        let offsetX = -boundingBox.midX * newScale + UIScreen.main.bounds.width / 2
        let offsetY = -boundingBox.midY * newScale + UIScreen.main.bounds.height / 2
        
        withAnimation(.spring()) {
            selectedAreaIndex = index
            lastScale = newScale
            lastOffset = CGSize(width: offsetX, height: offsetY)
            currentScale = 1.0
            currentOffset = .zero
        }
    }
    
}


struct ClimbingArea: View {
    let path: Path
    let fill: Color
    let stroke: Color
    let isSelected: Bool
    let lineWidth: CGFloat
    
    var body: some View {
        path
            .fill(isSelected ? AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(fill))
            .overlay(path.stroke(stroke, lineWidth: lineWidth))
            .shadow(color: isSelected ? .orange : .clear, radius: isSelected ? 10 : 0)
    }
}



struct MockDataBoulders {
    static func generateBoulders() -> [Boulder] {
       return [
            Boulder(id: UUID(), x: 15, y: 320, difficulty: "1", color: .green, sector: "Połóg"),
            Boulder(id: UUID(), x: 8, y: 200, difficulty: "2", color: .red,sector: "Wu"),   // Obszar #2
            Boulder(id: UUID(), x: 20, y: 150, difficulty: "3", color: .blue,sector: "Diament"), // Obszar #3
            Boulder(id: UUID(), x: 50, y: 50, difficulty: "4", color: .orange,sector: "Wu"), // Obszar #4
            Boulder(id: UUID(), x: 170, y: 160, difficulty: "5", color: .purple,sector: "Wu"), // Obszar #5
            Boulder(id: UUID(), x: 200, y: 180, difficulty: "6", color: .yellow,sector: "Wu"), // Obszar #6
            Boulder(id: UUID(), x: 210, y: 140, difficulty: "7", color: .red,sector: "Wu"), // Obszar #7
            Boulder(id: UUID(), x: 280, y: 120, difficulty: "8", color: .pink,sector: "Wu"), // Obszar #8
            Boulder(id: UUID(), x: 370, y: 90, difficulty: "9", color: .brown,sector: "Wu"), // Obszar #9
            Boulder(id: UUID(), x: 250, y: 15, difficulty: "10+", color: .blue,sector: "Wu"), // Obszar #10
            Boulder(id: UUID(), x: 380, y: 200, difficulty: "11", color: .orange,sector: "Wu"), // Obszar #11
            Boulder(id: UUID(), x: 140, y: 130, difficulty: "12", color: .cyan,sector: "Wu"), // Obszar #12
            Boulder(id: UUID(), x: 300, y: 20, difficulty: "13+", color: .purple,sector: "Wu"), // Obszar #13
            Boulder(id: UUID(), x: 45, y: 310, difficulty: "14", color: .blue,sector: "Wu"),   // Obszar #14
            Boulder(id: UUID(), x: 60, y: 250, difficulty: "15", color: .green,sector: "Wu"),  // Obszar #15
            Boulder(id: UUID(), x: 100, y: 180, difficulty: "16", color: .yellow,sector: "Wu"), // Obszar #16
            Boulder(id: UUID(), x: 120, y: 320, difficulty: "17+", color: .orange,sector: "Wu"), // Obszar #17
            Boulder(id: UUID(), x: 400, y: 220, difficulty: "18", color: .red,sector: "Wu"),   // Obszar #18
            Boulder(id: UUID(), x: 340, y: 110, difficulty: "19", color: .purple,sector: "Wu"), // Obszar #19
            Boulder(id: UUID(), x: 410, y: 70, difficulty: "20", color: .pink,sector: "Wu"),   // Obszar #20
            Boulder(id: UUID(), x: 90, y: 90, difficulty: "21", color: .cyan,sector: "Wu"),     // Obszar #21
            Boulder(id: UUID(), x: 50, y: 60, difficulty: "22", color: .brown,sector: "Wu"),    // Obszar #22
            Boulder(id: UUID(), x: 360, y: 300, difficulty: "23", color: .blue,sector: "Wu"),   // Obszar #23
            Boulder(id: UUID(), x: 300, y: 250, difficulty: "24", color: .red,sector: "Wu"),   // Obszar #24
            Boulder(id: UUID(), x: 240, y: 50, difficulty: "25", color: .yellow,sector: "Wu"), // Obszar #25
            Boulder(id: UUID(), x: 20, y: 180, difficulty: "26", color: .orange,sector: "Wu"), // Obszar #26
            Boulder(id: UUID(), x: 80, y: 400, difficulty: "27", color: .green,sector: "Wu"),   // Obszar #27
            Boulder(id: UUID(), x: 200, y: 400, difficulty: "28", color: .pink,sector: "Wu"),   // Obszar #28
            Boulder(id: UUID(), x: 300, y: 350, difficulty: "29", color: .purple,sector: "Wu"), // Obszar #29
            Boulder(id: UUID(), x: 420, y: 50, difficulty: "30", color: .blue,sector: "Wu"),    // Obszar #30
            Boulder(id: UUID(), x: 30, y: 240, difficulty: "31", color: .red,sector: "Wu"),     // Obszar #31
            Boulder(id: UUID(), x: 370, y: 330, difficulty: "32", color: .cyan,sector: "Wu"),   // Obszar #32
            Boulder(id: UUID(), x: 180, y: 70, difficulty: "33", color: .orange,sector: "Wu"), // Obszar #33
            Boulder(id: UUID(), x: 50, y: 200, difficulty: "34", color: .yellow,sector: "Wu"),  // Obszar #34
            Boulder(id: UUID(), x: 10, y: 280, difficulty: "35", color: .green,sector: "Wu"),  // Obszar #35
            Boulder(id: UUID(), x: 390, y: 130, difficulty: "36", color: .purple,sector: "Wu"), // Obszar #36
            Boulder(id: UUID(), x: 250, y: 70, difficulty: "37", color: .red,sector: "Wu"),     // Obszar #37
            Boulder(id: UUID(), x: 100, y: 270, difficulty: "38", color: .brown,sector: "Wu"),  // Obszar #38
            Boulder(id: UUID(), x: 300, y: 200, difficulty: "39", color: .cyan,sector: "Wu"),  // Obszar #39
            Boulder(id: UUID(), x: 70, y: 320, difficulty: "40", color: .pink,sector: "Wu"),    // Obszar #40
            Boulder(id: UUID(), x: 420, y: 360, difficulty: "41", color: .blue,sector: "Wu"),  // Obszar #41
            Boulder(id: UUID(), x: 220, y: 140, difficulty: "42", color: .orange,sector: "Wu"),// Obszar #42
            Boulder(id: UUID(), x: 350, y: 60, difficulty: "43", color: .yellow,sector: "Wu"),  // Obszar #43
            Boulder(id: UUID(), x: 160, y: 200, difficulty: "44", color: .red,sector: "Wu"),
            Boulder(id: UUID(), x: 260, y: 340, difficulty: "45", color: .purple,sector: "Wu")  // Obszar #45
        ]

    }
}


struct InteractiveClimbingWallView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveClimbingWallView(climbingSectorsSVG: svg)
    }
}


let svg =
"""
<svg width="402" height="346" viewBox="0 0 402 346" fill="none" xmlns="http://www.w3.org/2000/svg">
<path id="Polog" d="M110.116 338.578V344.997H1.80231V289.035H12.4331L15.4418 336.974L57.9651 336.372L61.7761 331.759L85.8459 329.151H102.895L110.116 338.578Z" fill="url(#paint0_linear_464_39)"/>
<path id="Wu" d="M12.2325 289.035H1.80231L2.00289 169.288H16.4447L23.6657 178.113L30.4854 192.756V223.645L38.7093 259.148L12.2325 289.035Z" fill="url(#paint1_linear_464_39)"/>
<path id="Diament" d="M16.4447 169.288H2.00289L1.20056 68.3954H34.4971L31.8895 94.4709L28.8808 106.907L16.4447 123.154V169.288Z" fill="url(#paint2_linear_464_39)"/>
<path id="Kaskady" d="M34.4971 68.3954H0.999985L1.80231 1.40117H85.8459L86.0465 17.0465L34.4971 68.3954Z" fill="url(#paint3_linear_464_39)"/>
<path id="Lewa Grtoa" d="M122.953 194.762L118.942 183.328L128.169 150.233L159.66 126.965L182.125 197.169L122.953 194.762Z" fill="url(#paint4_linear_464_39)"/>
<path id="Prawa Grota" d="M182.326 197.369L159.66 127.166L201.581 123.355L209.003 162.468L222.241 175.706L189.346 195.363L182.326 197.369Z" fill="url(#paint5_linear_464_39)"/>
<path id="Pion" d="M86.2471 17.0465V1L223.044 1.20058V13.6366L186.538 18.6512L154.445 13.6366L124.959 25.8721L86.2471 17.0465Z" fill="url(#paint6_linear_464_39)"/>
<path id="Groto" d="M209.003 162.669L201.581 123.555L231.067 98.282L268.977 128.57L254.936 156.049L222.642 175.706L209.003 162.669Z" fill="url(#paint7_linear_464_39)"/>
<path id="MalySzesciokat" d="M384.913 38.1075H400.759L400.558 131.378H356.029L362.849 106.706L369.067 93.468L384.913 38.1075Z" fill="url(#paint8_linear_464_39)"/>
<path id="Beczka" d="M223.044 13.8372L223.244 1.20059H301.07V10.4273L288.834 23.2645L273.791 30.0843L223.044 13.8372Z" fill="url(#paint9_linear_464_39)"/>
<path id="Duzy Szesciokat" d="M356.23 131.177H400.759V240.294H376.307L382.868 196.285L364.579 178.2L356.23 142.029V131.177Z" fill="url(#paint11_linear_464_39)"/>
<path id="Tyl Wiezy" d="M127.968 150.433L118.942 183.328L115.532 133.183L119.142 131.378L137.195 111.922L162.669 105.302L196.968 103.297L229.863 98.4826L201.581 123.355L159.66 127.166L127.968 150.433Z" fill="url(#paint12_linear_464_39)" fill-opacity="0.929412"/>
<path id="Prawe Zaciecie" d="M301.07 10.4273V1.20059H400.759V38.1076H384.913L356.831 18.8517L345.599 10.4273H335.369H301.07Z" fill="url(#paint13_linear_464_39)"/>
<rect x="3.5" y="2.5" width="396" height="341" fill="#D9D9D9" fill-opacity="0.01" stroke="white" stroke-width="5"/>
</svg>
"""
