import SwiftUI

struct MapView: View {
    @State private var selectedSectorIndex: Int? = nil
    var sectors: [Sector]
    var svgParser: SVGParser
    let defaultScale: CGFloat = 0.5
    let zoomScale: CGFloat = 1.2
    @State var transform: CGAffineTransform

    
    init() {
        self.svgParser = SVGParser()
        self.sectors = svgParser.parseSVG(from: svg)
        _transform = State(initialValue: CGAffineTransform(scaleX: defaultScale, y: defaultScale))
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray5).ignoresSafeArea()
            
            ZStack {
                ForEach(Array(sectors.enumerated()), id: \.offset) { sectorIndex, sector in
                    SectorView(
                        sector: sector,
                        isSelected: selectedSectorIndex == sectorIndex
                    )
                }
                .transformEffect(transform)
            }
            .overlay(
                GestureTransformView(
                    transform: $transform,
                    paths: sectors,
                    onAreaTapped: { index, sector in
                        print(sector)
                    }
                )
            )
            
            bouldersOverlay
                .transformEffect(transform)
            
            ForEach(Array(sectors.enumerated()), id: \.offset) { sectorIndex, sector in
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
                    }

        }
    }
    
    private var bouldersOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(boulders, id: \.id) { boulder in
                    let centerPosition: CGPoint = {
                        if let sectorIndex = sectors.firstIndex(where: { $0.id == boulder.sector }) {
                            if let firstPath = sectors[sectorIndex].paths.first {
                                let boundingBox = firstPath.path.boundingRect
                                return CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                            }
                        }
                        return CGPoint(x: boulder.x, y: boulder.y)
                    }()
                    
                    let scaleFactor = transform.a
                    let visibleRect = calculateVisibleRect(in: geometry.size)
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
                        // Animacja przezroczystości
                        .opacity(isZoomedIn ? (isVisible ? 1 : 0) : 0)
                        // Animacja pozycji
                        .position(isVisible ? CGPoint(x: boulder.x, y: boulder.y) : centerPosition)
                        // Animacja skali
                        .scaleEffect(isVisible ? 1 : 0.5)
                        // Połączone animacje
                        .modifier(TransitionModifier(isVisible: isVisible))
                }
            }
        }
    }

    // Własny modifier do animacji
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
    
    private func calculateVisibleRect(in size: CGSize) -> CGRect {
        let inverseTransform = transform.inverted()
        let topLeft = CGPoint.zero.applying(inverseTransform)
        let topRight = CGPoint(x: size.width, y: 0).applying(inverseTransform)
        let bottomLeft = CGPoint(x: 0, y: size.height).applying(inverseTransform)
        let bottomRight = CGPoint(x: size.width, y: size.height).applying(inverseTransform)
        
        let minX = min(min(topLeft.x, topRight.x), min(bottomLeft.x, bottomRight.x))
        let maxX = max(max(topLeft.x, topRight.x), max(bottomLeft.x, bottomRight.x))
        let minY = min(min(topLeft.y, topRight.y), min(bottomLeft.y, bottomRight.y))
        let maxY = max(max(topLeft.y, topRight.y), max(bottomLeft.y, bottomRight.y))
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
}

struct SectorView: View {
    let sector: Sector
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
    let path: Path
    let defaultColor: Color
    let selectedColor: Color
    let isSelected: Bool
    
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



///TODO
///po kliknieciu nie dziala kolor
///nwm animacja jakos
///ramka
///gowno
///
///
///
///

let svg = """
<svg width="950" height="820" viewBox="0 0 950 820" fill="none" xmlns="http://www.w3.org/2000/svg">
<g id="Połóg">
<path id="Po&#197;&#130;&#195;&#179;g" d="M182.244 794.529L180.021 798.974H184.466L182.244 794.529Z" fill="black"/>
<path id="Vector" d="M27.1651 684.184L37.2678 679.694H188.135L196.849 684.184V716.425H242.568L281.303 750.08V818.887H259.528L15.7153 797.783L27.1651 684.184Z" fill="#DCDCDC"/>
<path id="Vector_2" d="M15.7154 684.184C19.0845 682.915 22.086 680.602 27.1651 684.184L33.788 734.922L35.3596 797.783L113.347 806.912L135.254 784.369L202.952 778.925L107.706 814.565H7.30249V698.328L15.7154 684.184Z" fill="#9F9F9F"/>
<path id="Vector_3" d="M0 684.184C3.3934 682.224 7.58286 681.109 15.7153 684.184V797.783H134.254L145.03 785.66L202.952 778.925H241.567L259.528 802.273V818.887H0L0 684.184Z" fill="#7D7D7D"/>
</g>
<g id="Wu">
<path id="Wu" d="M38.0998 551.961L33.6548 556.406H42.5447L38.0998 551.961Z" fill="black"/>
<path id="Vector_4" d="M126.176 416.707C140.184 426.258 151.941 439.987 154.203 471.352C174.836 488.948 191.685 512.511 196.849 554.501V684.184H27.1651L37.1556 400.971C70.7935 386.395 126.176 416.707 126.176 416.707Z" fill="#DCDCDC"/>
<path id="Vector_5" d="M15.7153 409.443C17.38 401.708 31.6116 397.125 37.1555 400.971L54.6669 422.075L70.8312 457.546V530.061L89.9141 613.465L27.165 684.184H15.7153L6.73511 674.53L15.7153 409.443Z" fill="#9F9F9F"/>
<path id="Vector_6" d="M0 684.184H15.7153V409.443C10.1631 405.365 4.95382 405.743 0 409.443V684.184Z" fill="#7D7D7D"/>
</g>
<g id="Diament">
<path id="Diament" d="M26.6698 283.358L22.2249 287.803H31.1148L26.6698 283.358Z" fill="black"/>
<path id="Vector_7" d="M37.1555 400.971L126.176 416.707C144.476 387.434 140.269 333.148 132.526 298.763C142.826 281.171 160.404 251.145 147.579 218.254C142.994 186.042 102.91 159.955 80.3269 163.026L15.7153 280.775L37.1555 400.971Z" fill="#DCDCDC"/>
<path id="Vector_8" d="M15.7153 152.107C40.2186 147.442 61.8102 150.929 80.3269 163.026L73.9743 224.061L67.4637 253.696L37.1555 291.637V400.971L15.7153 409.443L6.73511 399.063V163.782L15.7153 152.107Z" fill="#9F9F9F"/>
<path id="Vector_9" d="M0 409.443H15.7153V152.107C6.92991 145.828 3.9456 149.819 0 152.107V409.443Z" fill="#7D7D7D"/>
</g>
<g id="Kaskady">
<path id="Kaskady" d="M53.3396 43.3297L48.8947 47.7747H57.7846L53.3396 43.3297Z" fill="black"/>
<path id="Vector_10" d="M202.246 41.4247C226.655 65.2651 247.463 147.671 241.546 174.881C199.077 215.48 217.14 206.439 147.579 218.254L80.3269 163.026L45.0847 45.2346L120.181 17.9298L202.246 41.4247Z" fill="#DCDCDC"/>
<path id="Vector_11" d="M192.152 18.8255C198.424 19.331 205.316 33.7914 202.246 41.4247L80.327 163.026L15.7154 152.107L7.30249 138.319V10.6274H167.956L192.152 18.8255Z" fill="#9F9F9F"/>
<path id="Vector_12" d="M0 152.107H15.7153V17.9298H188.594C193.609 14.2793 194.921 8.91165 188.594 0H0V152.107Z" fill="#7D7D7D"/>
</g>
<g id="Piony">
<path id="Piony" d="M328.928 29.9949L320.038 38.8848H337.818L328.928 29.9949Z" fill="black"/>
<path id="Vector_13" d="M525.776 32.5348C538.468 48.8524 545.109 116.3 510.973 131.004C448.66 158.131 383.71 160.653 316.317 140.369C295.35 164.086 269.363 172.308 241.546 174.881L202.246 41.4248L363.217 5.07129H485.188L525.776 32.5348Z" fill="#DCDCDC"/>
<path id="Vector_14" d="M525.141 16.6599C530.772 24.3602 530.921 29.624 525.776 32.5348L441.957 45.8697L365.757 33.1699L295.59 63.0146L202.246 41.4248L188.88 17.7168L315.752 5.07129H508.331L525.141 16.6599Z" fill="#9F9F9F"/>
<path id="Vector_15" d="M188.594 0L188.88 17.7167L281.938 41.4247L351.787 17.9298L459.102 34.4398L525.141 16.6599C528.929 11.3294 528.986 5.77945 525.141 0H188.594Z" fill="#7D7D7D"/>
</g>
<g id="Beczka">
<path id="Beczka" d="M635.63 34.4397L631.185 38.8847H640.075L635.63 34.4397Z" fill="black"/>
<path id="Vector_16" d="M723.26 203.666H681.668C606.376 205.885 547.961 183.845 510.973 131.004L525.776 32.5348L723.26 17.1361C739.583 96.4953 739.108 158.172 723.26 203.666Z" fill="#DCDCDC"/>
<path id="Vector_17" d="M525.776 32.5348L668.65 97.3043L686.43 82.6994L723.26 17.1361L708.02 6.5H562.288L525.141 16.6599L525.776 32.5348Z" fill="#9F9F9F"/>
<path id="Vector_18" d="M525.141 0V16.6599H658.49L682.62 31.2647L691.669 17.1361H723.26C728.405 9.04949 729.112 3.0111 723.26 0H525.141Z" fill="#7D7D7D"/>
</g>
<g id="Prawe Zacięcie">
<path id="Prawe Zaci&#196;&#153;cie" d="M920.108 18.8823L917.886 23.3273H922.331L920.108 18.8823Z" fill="black"/>
<path id="Vector_19" d="M900.81 124.089C888.568 140.447 749.511 217.852 735.325 203.666H723.26V17.1361L742.627 6.5H939.476V99.2093L900.81 124.089Z" fill="#DCDCDC"/>
<path id="Vector_20" d="M816.058 6.5L795.945 17.4215L823.272 55.0771L910.583 91.2718L900.81 124.089C910.364 129.134 920.51 130.825 931.856 125.72L939.476 96.1931V6.5H816.058Z" fill="#9F9F9F"/>
<path id="Vector_21" d="M723.26 0V17.1361L844.544 17.6123L931.856 72.222V125.72C937.324 129.926 942.792 129.117 948.26 125.72V0H723.26Z" fill="#7D7D7D"/>
</g>
<g id="Mały Sześciokąt">
<path id="Ma&#197;&#130;y Sze&#197;&#155;ciok&#196;&#133;t" d="M903.065 224.602L898.62 229.047H907.51L903.065 224.602Z" fill="black"/>
<path id="Vector_22" d="M840.416 337.967C804.195 351.661 769.151 351.813 735.325 337.967V203.666L900.81 124.089L893.439 289.708L840.416 337.967Z" fill="#DCDCDC"/>
<path id="Vector_23" d="M840.416 337.967V312.25L856.609 252.878L872.484 218.906L900.81 124.089L931.856 125.72L940.111 137.785V313.838L913.708 337.967C888.557 348.779 864.382 344.937 840.416 337.967Z" fill="#9F9F9F"/>
<path id="Vector_24" d="M931.856 125.72H948.26V337.967C936.743 351.558 925.225 345.101 913.708 337.967L910.583 324.95L931.856 281.453V125.72Z" fill="#7D7D7D"/>
</g>
<g id="Duży Sześciokąt">
<path id="Du&#197;&#188;y Sze&#197;&#155;ciok&#196;&#133;t" d="M913.441 427.819L911.218 432.264H917.886L913.441 427.819Z" fill="black"/>
<path id="Vector_25" d="M888.676 571.011H781.997V501.161L735.325 419.855V337.968H840.416L940.111 388.053V538.626L888.676 571.011Z" fill="#DCDCDC"/>
<path id="Vector_26" d="M913.708 337.968H840.416L860.101 420.517L870.896 435.122L904.868 465.602L888.676 571.011H932.491L940.111 558.946V356.391L913.708 337.968Z" fill="#9F9F9F"/>
<path id="Vector_27" d="M948.26 337.968H913.708L932.491 405.595V571.011H948.26V337.968Z" fill="#7D7D7D"/>
</g>
<g id="Lewa Grota">
<path id="Lewa Grota" d="M284.478 381.147L280.033 385.592H288.923L284.478 381.147Z" fill="black"/>
<path id="Vector_28" d="M217.548 405.441C192.179 419.302 157.659 430.387 154.203 471.352L196.849 554.501H407.667C410.967 505.195 402.473 464.466 368.637 442.168L217.548 405.441Z" fill="#DCDCDC"/>
<path id="Vector_29" d="M258.901 311.567C265.244 295.146 272.038 278.951 311.148 278.913C354.338 330.328 363.138 386.041 368.637 442.168L226.75 434.984L217.548 405.441L253.363 363.367L258.901 311.567Z" fill="#9F9F9F"/>
<path id="Vector_30" d="M217.548 405.441L298.191 402.42L258.901 311.567C250.175 311.618 243.965 315.679 240.028 323.363C225.311 336.83 216.716 362.07 217.548 405.441Z" fill="#7D7D7D"/>
</g>
<g id="Prawa Grota">
<path id="Prawa Grota" d="M395.602 358.922L391.157 363.367H400.047L395.602 358.922Z" fill="black"/>
<path id="Click" d="M368.637 442.168L407.667 554.501L512.696 490.766C503.696 447.782 482.945 416.037 446.419 399.382L395.577 395.246L368.637 442.168Z" fill="#DCDCDC"/>
<path id="Vector_31" d="M311.148 278.913L368.637 442.168L385.25 436.331L446.419 399.382C448.138 377.747 441.013 365.842 430.825 357.305L410.373 289.78L367.295 274.421C344.12 265.97 326.579 270.088 311.148 278.913Z" fill="#9F9F9F"/>
<path id="Vector_32" d="M367.295 274.421C382.082 262.612 399.715 259.121 422.272 270.023C439.791 300.204 435.69 328.783 430.825 357.305L367.295 274.421Z" fill="#7D7D7D"/>
</g>
<g id="Groto">
<path id="Groto" d="M506.726 292.248L502.281 296.693H511.171L506.726 292.248Z" fill="black"/>
<path id="Click Groto" d="M446.419 399.382L512.696 490.765L630.55 419.247L681.668 341.778V203.666L510.973 131.004C478.374 148.026 471.773 173.714 482.236 205.091L523.545 298.485L446.419 399.382Z" fill="#DCDCDC"/>
<path id="Vector_33" d="M430.825 357.305L446.419 399.382L540.608 342.488L573.385 277.381L482.236 205.091C452.611 216.159 434.426 236.194 426.951 264.624L469.889 315.996L430.825 357.305Z" fill="#9F9F9F"/>
<path id="Vector_34" d="M430.825 357.305L496.38 319.364L426.951 264.624C423.281 264.773 421.501 267.734 422.272 270.023L430.825 357.305Z" fill="#7D7D7D"/>
</g>
<g id="Tył Wieży">
<path id="Ty&#197;&#130; Wie&#197;&#188;y" d="M297.813 234.463L293.368 238.908H302.258L297.813 234.463Z" fill="black"/>
<path id="Click Ty&#197;&#130; Wie&#197;&#188;y" d="M482.236 205.091L510.973 131.004L316.317 140.369L241.546 174.881L147.579 218.254L132.526 298.763L126.176 416.707L154.203 471.352L217.548 405.441L223.836 298.915L482.236 205.091Z" fill="#DCDCDC"/>
<path id="Vector_35" d="M258.901 311.567L311.148 278.913L367.295 274.421L380.536 257.176L426.951 264.624L482.236 205.091L401.415 216.989L319.403 223.033L260.983 237.638L219.341 283.106L210.024 288.494L223.836 298.915L258.901 311.567Z" fill="#9F9F9F"/>
<path id="Vector_36" d="M217.548 405.441L240.028 323.363L258.901 311.567L241.474 271.268L210.024 288.494L217.548 405.441Z" fill="#7D7D7D"/>
<path id="Vector_37" d="M334.288 231.358L372.229 221.479L426.951 264.624L422.272 270.023L367.295 274.421L334.288 231.358Z" fill="#7D7D7D"/>
</g>
<g id="nclick">
<path id="dressingrooms" d="M696.863 818.887V571.482H546.894V519.397H760.622V571.011H948.26V818.887H696.863Z" fill="#9D9D9D" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_38" d="M696.863 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_39" d="M688.531 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_40" d="M680.2 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_41" d="M671.868 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_42" d="M663.536 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_43" d="M655.205 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_44" d="M646.873 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_45" d="M605.215 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_46" d="M596.883 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_47" d="M588.552 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_48" d="M580.22 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_49" d="M555.225 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_50" d="M563.557 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_51" d="M571.888 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_52" d="M546.894 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_53" d="M613.547 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_54" d="M621.878 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_55" d="M630.21 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
<path id="Vector_56" d="M638.542 571.482V519.397" stroke="#4A4A4A" stroke-width="1.77799"/>
</g>
<g id="nclick">
<path id="nclick" d="M461.642 818.887L489.582 736.745H568.956L591.816 780.559H565.146L556.256 761.51H509.266L496.567 800.244H599.436L610.231 818.887H461.642Z" fill="#4A4A4A"/>
</g>
</svg>
"""
