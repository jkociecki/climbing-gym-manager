//
//  LogoAnimation.swift
//  cgm
//
//  Created by Jędrzej Kocięcki on 26/12/2024.
//

import SwiftUI


struct AnimatedLetter: View {
    let letter: String
    let delay: Double
    @Binding var isAnimating: Bool
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Text(letter)
            .font(.custom("Righteous-Regular", size: 60))
            .foregroundColor(color)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : size * 0.8)
            .rotation3DEffect(
                .degrees(isAnimating ? 0 : -90),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(
                .spring(
                    response: 0.7,
                    dampingFraction: 0.7,
                    blendDuration: 0.7
                )
                .delay(delay),
                value: isAnimating
            )
    }
}

struct AnimatedLoader: View {
    let size: CGFloat
    
    @State private var animateText = false
    @State private var showGrid = false
    @State private var isGridAnimating = false
    
    let gridColumns = 7
    let gridRows = 3
    let wallLetters = ["W", "A", "L", "L"]
    let upLetters = ["U", "P"]
    
    let wallColor = Color(red: 239/255, green: 83/255, blue: 80/255)
    let upColor = Color(red: 103/255, green: 58/255, blue: 183/255)
    
    private var gridSquareSize: CGFloat { size * 0.25 }
    private var gridSpacing: CGFloat { size * 0.033 }
    private var letterSpacing: CGFloat { size * 0.033 }
    
    init(size: CGFloat = 60) {
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: letterSpacing) {
            HStack(spacing: letterSpacing) {
                ForEach(Array(wallLetters.enumerated()), id: \.offset) { index, letter in
                    AnimatedLetter(
                        letter: String(letter),
                        delay: Double(index) * 0.1,
                        isAnimating: $animateText,
                        color: wallColor,
                        size: size
                    )
                }
            }
            
            VStack(spacing: gridSpacing) {
                ForEach(0..<gridRows, id: \.self) { row in
                    HStack(spacing: gridSpacing) {
                        ForEach(0..<gridColumns, id: \.self) { column in
                            Rectangle()
                                .fill(wallColor)
                                .frame(width: gridSquareSize, height: gridSquareSize)
                                .opacity(showGrid ? 1 : 0)
                                .rotationEffect(.degrees(isGridAnimating ? 360 : 0))
                                .scaleEffect(isGridAnimating ? 1 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .delay(Double(row * gridColumns + column) * 0.05)
                                    .repeatForever(autoreverses: true),
                                    value: isGridAnimating
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, gridSpacing)
            
            HStack(spacing: letterSpacing) {
                ForEach(Array(upLetters.enumerated()), id: \.offset) { index, letter in
                    AnimatedLetter(
                        letter: String(letter),
                        delay: Double(index + wallLetters.count) * 0.1 + 0.3,
                        isAnimating: $animateText,
                        color: upColor,
                        size: size
                    )
                }
            }
        }
        .onAppear {
            withAnimation {
                animateText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showGrid = true
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isGridAnimating = true
                }
            }
        }
    }
}

struct FullScreenAnimationLoader: View {
    var size: Int
    var body: some View {
        ZStack {
            Color(.systemBackground)
            AnimatedLoader(size: 60)
        }
    }
}

#Preview{
    FullScreenAnimationLoader(size: 60)
}
