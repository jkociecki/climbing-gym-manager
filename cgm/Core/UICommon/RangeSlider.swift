import SwiftUI

struct RangedSliderView: View {
    let allDifficulties: [String]
    @Binding var currentRange: ClosedRange<Int>
    
    public init(allDifficulties: [String], currentRange: Binding<ClosedRange<Int>>) {
        self.allDifficulties = allDifficulties
        self._currentRange = currentRange
    }
    
    var body: some View {
        GeometryReader { geometry in
            sliderView(sliderSize: geometry.size)
        }
    }
    
    @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
        let sliderViewYCenter = sliderSize.height / 2
        let stepWidthInPixel = sliderSize.width / CGFloat(allDifficulties.count - 1)
        
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.fioletowy.opacity(0.5))
                .frame(height: 4)
            
            let leftThumbLocation = CGFloat(currentRange.lowerBound) * stepWidthInPixel
            let rightThumbLocation = CGFloat(currentRange.upperBound) * stepWidthInPixel
            
            lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
            
            thumbView(position: CGPoint(x: leftThumbLocation, y: sliderViewYCenter), value: allDifficulties[currentRange.lowerBound])
                .highPriorityGesture(DragGesture().onChanged { dragValue in
                    let newIndex = calculateIndex(from: dragValue.location.x, stepWidth: stepWidthInPixel, totalSteps: allDifficulties.count)
                    if newIndex < currentRange.upperBound {
                        currentRange = newIndex...currentRange.upperBound
                    }
                })
            
            thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: allDifficulties[currentRange.upperBound])
                .highPriorityGesture(DragGesture().onChanged { dragValue in
                    let newIndex = calculateIndex(from: dragValue.location.x, stepWidth: stepWidthInPixel, totalSteps: allDifficulties.count)
                    if newIndex > currentRange.lowerBound {
                        currentRange = currentRange.lowerBound...newIndex
                    }
                })
        }
    }
    
    @ViewBuilder func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(Color.fioletowy, lineWidth: 4)
    }
    
    @ViewBuilder func thumbView(position: CGPoint, value: String) -> some View {
        ZStack {
//            Text(value)
//                .font(.caption)
//                .offset(y: -20)
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(.fioletowy)
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                .contentShape(Rectangle())
        }
        .position(x: position.x, y: position.y)
    }
    
    private func calculateIndex(from locationX: CGFloat, stepWidth: CGFloat, totalSteps: Int) -> Int {
        let index = Int(round(locationX / stepWidth))
        return min(max(index, 0), totalSteps - 1)
    }
}
