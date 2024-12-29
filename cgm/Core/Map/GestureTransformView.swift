//
//  GestureTransformView.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 25/12/2024.
//


import SwiftUI

struct GestureTransformView: UIViewRepresentable {
    @Binding var transform:     CGAffineTransform
    @Binding var paths:         [Sector]
    var onAreaTapped:           ((Int, String) -> Void)?
    
    @State private var viewSize: CGSize = .zero
    @State private var initialTransform: CGAffineTransform = .identity

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let tapRecognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:)))
            
        let zoomRecognizer = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.zoom(_:)))
            
        let panRecognizer = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.pan(_:)))
        
        tapRecognizer.delegate = context.coordinator
        zoomRecognizer.delegate = context.coordinator
        panRecognizer.delegate = context.coordinator
        
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(panRecognizer)

        context.coordinator.tapRecognizer = tapRecognizer
        context.coordinator.zoomRecognizer = zoomRecognizer
        context.coordinator.panRecognizer = panRecognizer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if viewSize != uiView.bounds.size {
            viewSize = uiView.bounds.size
            let newTransform = calculateInitialTransform(for: uiView)
            initialTransform = newTransform
            transform = newTransform
            context.coordinator.initialTransform = newTransform
        }
    }
    
    private func calculateInitialTransform(for view: UIView) -> CGAffineTransform {
        var mapBounds = CGRect.zero
        for sector in paths {
            for pathWrapper in sector.paths {
                mapBounds = mapBounds.union(pathWrapper.path.boundingRect)
            }
        }
        
        let xScale = view.bounds.width / mapBounds.width
        let yScale = view.bounds.height / mapBounds.height
        let scale = min(xScale, yScale)
        
        let tx = (view.bounds.width - mapBounds.width * scale) / 2 - mapBounds.minX * scale
        let ty = (view.bounds.height - mapBounds.height * scale) / 2 - mapBounds.minY * scale
        
        return CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: tx/scale, y: ty/scale)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension GestureTransformView {
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent:             GestureTransformView
        var tapRecognizer:      UITapGestureRecognizer?
        var zoomRecognizer:     UIPinchGestureRecognizer?
        var panRecognizer:      UIPanGestureRecognizer?
        var currentZoomedIndex: Int? = nil
        var initialTransform:   CGAffineTransform = .identity
        
        var startTransform:     CGAffineTransform = .identity
        var previousScale:      CGFloat = 1.0
        var initialPinchCenter: CGPoint = .zero
        
        let minScale:           CGFloat = 0.1
        let maxScale:           CGFloat = 5.0
        
        init(_ parent: GestureTransformView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let gestureView = gesture.view else { return }

            let location = gesture.location(in: gestureView)
            let inverseTransform = parent.transform.inverted()
            let transformedLocation = location.applying(inverseTransform)
            
            for (sectorIndex, sector) in parent.paths.enumerated() {
                if sector.id == "nclick" { continue }
                for pathWrapper in sector.paths {
                    
                    if pathWrapper.path.contains(transformedLocation) {
                        handleAreaTap(sectorIndex: sectorIndex,
                                    pathWrapper: pathWrapper,
                                    gestureView: gestureView)
                        return
                    }
                }
            }
        }
        
        private func handleAreaTap(sectorIndex: Int,
                                 pathWrapper: PathWrapper,
                                 gestureView: UIView) {
            if currentZoomedIndex == sectorIndex {
                animateTransform(to: initialTransform)
                currentZoomedIndex = nil
            } else {
                let bounds = pathWrapper.path.boundingRect
                let areaCenter = CGPoint(x: bounds.midX, y: bounds.midY)
                
                let targetScale: CGFloat = 2.5
                let viewCenter = CGPoint(x: gestureView.bounds.midX,
                                       y: gestureView.bounds.midY)
                
                let targetTranslationX = viewCenter.x - (areaCenter.x * targetScale)
                let targetTranslationY = viewCenter.y - (areaCenter.y * targetScale)
                
                let targetTransform = CGAffineTransform.identity
                    .translatedBy(x: targetTranslationX, y: targetTranslationY)
                    .scaledBy(x: targetScale, y: targetScale)
                
                animateTransform(to: targetTransform)
                currentZoomedIndex = sectorIndex
            }
            
            parent.onAreaTapped?(sectorIndex, pathWrapper.id)
        }
        
        @objc func zoom(_ gesture: UIPinchGestureRecognizer) {
            guard let view = gesture.view else { return }
            
            switch gesture.state {
            case .began:
                startTransform = parent.transform
                previousScale = 1.0
                initialPinchCenter = gesture.location(in: view)
                
            case .changed:
                let scale = gesture.scale
                let scaleDelta = scale / previousScale
                previousScale = scale
                
                let pinchCenter = gesture.location(in: view)
                let originalPinchCenter = pinchCenter.applying(parent.transform.inverted())
                
                let currentScale = sqrt(parent.transform.a * parent.transform.a +
                                     parent.transform.c * parent.transform.c)
                let newScale = currentScale * scaleDelta
                
                if newScale >= minScale && newScale <= maxScale {
                    var newTransform = parent.transform
                        .translatedBy(x: originalPinchCenter.x,
                                    y: originalPinchCenter.y)
                        .scaledBy(x: scaleDelta, y: scaleDelta)
                        .translatedBy(x: -originalPinchCenter.x,
                                    y: -originalPinchCenter.y)
                    
                    parent.transform = newTransform
                }
                
            case .ended, .cancelled:
                startTransform = parent.transform
                
            default:
                break
            }
        }
        
        @objc func pan(_ gesture: UIPanGestureRecognizer) {
                   switch gesture.state {
                   case .began:
                       startTransform = parent.transform
                       
                   case .changed:
                       let translation = gesture.translation(in: gesture.view)
                       
                       let currentScale = sqrt(parent.transform.a * parent.transform.a +
                                            parent.transform.c * parent.transform.c)
                       
                       let adjustedTranslationX = translation.x / currentScale
                       let adjustedTranslationY = translation.y / currentScale
                       
                       parent.transform = startTransform
                           .translatedBy(x: adjustedTranslationX, y: adjustedTranslationY)
                       
                   case .ended, .cancelled:
                       startTransform = parent.transform
                       
                   default:
                       break
                   }
               }
        
        private func animateTransform(to targetTransform: CGAffineTransform) {
            let animationDuration:      TimeInterval = 0.3
            let steps:                  Int = 60
            let interval = animationDuration / Double(steps)
            
            let initialTransform = parent.transform
            
            for step in 0...steps {
                DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                    let t = CGFloat(step) / CGFloat(steps)
                    let interpolatedTransform = self.interpolateTransform(
                        from: initialTransform,
                        to: targetTransform,
                        t: t
                    )
                    self.parent.transform = interpolatedTransform
                }
            }
        }
        
        private func interpolateTransform(
            from: CGAffineTransform,
            to: CGAffineTransform,
            t: CGFloat
        ) -> CGAffineTransform {
            let t = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
            return CGAffineTransform(
                a: from.a + (to.a - from.a) * t,
                b: from.b + (to.b - from.b) * t,
                c: from.c + (to.c - from.c) * t,
                d: from.d + (to.d - from.d) * t,
                tx: from.tx + (to.tx - from.tx) * t,
                ty: from.ty + (to.ty - from.ty) * t
            )
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
