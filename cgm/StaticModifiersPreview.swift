//
//  StaticModifiersPreview.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 29/12/2024.
//

import SwiftUI

struct StaticModifiersPreview: View {
    var body: some View {
        Text("7a")
            .font(.custom("Righteous-Regular", size: 30))
            .foregroundColor(.white)
            .padding(5)
            .background(
                Circle()
                    .fill(.cyan)
                    .shadow(color: .cyan.opacity(0.4), radius: 5, x: 0, y: 2)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1)
            )
            .overlay(
                Image(systemName: "hand.thumbsup.fill")
                    .foregroundStyle(.white)
                    .scaleEffect(0.6)
                    .opacity(0.6)
                    .offset(x: -20, y: -20)
                    .background(Circle()
                        .offset(x: -20, y: -20)
                        .foregroundStyle(.black.opacity(0.6))
                        )
            )
    }
    //iconName: "hands.clap.fill",
    //iconName: "hand.thumbsup.fill",


}



#Preview {
    StaticModifiersPreview()
}
