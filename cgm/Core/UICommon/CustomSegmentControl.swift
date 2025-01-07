//
//  CustomSegmentControl.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 06/01/2025.
//

import Foundation
import SwiftUI

struct CustomSegmentedControl: UIViewRepresentable {
    @Binding var selectedIndex: Int
    let titles: [String]

    func makeUIView(context: Context) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: titles)
        segmentedControl.selectedSegmentIndex = selectedIndex
        segmentedControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.segmentChanged(_:)),
            for: .valueChanged
        )
        
        // Stylizacja
        segmentedControl.selectedSegmentTintColor = UIColor(named: "Fioletowy")
        segmentedControl.backgroundColor = UIColor.systemGray6
        segmentedControl.layer.cornerRadius = 30 
        segmentedControl.clipsToBounds = true
        
        


        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]
        segmentedControl.setTitleTextAttributes(defaultAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        return segmentedControl
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selectedIndex
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CustomSegmentedControl

        init(_ parent: CustomSegmentedControl) {
            self.parent = parent
        }

        @objc func segmentChanged(_ sender: UISegmentedControl) {
            parent.selectedIndex = sender.selectedSegmentIndex
        }
    }
}
