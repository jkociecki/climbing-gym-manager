//
//  ButtonAnimation.swift
//  temp
//
//  Created by Malwina Juchiewicz on 05/01/2025.
//

import Foundation
import SwiftUI
import AVFoundation


class SoundManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    init() {
        if let soundURL = Bundle.main.url(forResource: "successSound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
    }
    
    func playSound() {
        audioPlayer?.play()
    }
}

class ParticleState: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var scale: CGFloat
    var speed: Double
    var direction: Double
    
    init(position: CGPoint) {
        self.position = position
        self.color = [.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
        self.scale = CGFloat.random(in: 0.5...1.0)
        self.speed = Double.random(in: 20...200)
        self.direction = Double.random(in: -Double.pi...Double.pi)
    }
}

struct ParticleSystem: GeometryEffect {
    var time: Double
    let speed: Double
    let direction: Double
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time - 50 * time * time
        let transform = CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(transform)
    }
}

struct ParticleView: View {
    @State private var time: Double = 0.0
    let duration: Double = 1.0
    let state: ParticleState
    
    var body: some View {
        Circle()
            .fill(state.color)
            .frame(width: 10 * state.scale, height: 10 * state.scale)
            .modifier(ParticleSystem(time: time, speed: state.speed, direction: state.direction))
            .opacity(1.0 - time)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    time = duration
                }
            }
    }
}

class ParticleManager: ObservableObject {
    @Published var particles: [ParticleState] = []
    private let particleCount = 500
    
    func createParticles() {
        particles = (0..<particleCount).map { _ in
            ParticleState(position: CGPoint(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: UIScreen.main.bounds.height * 0.6...UIScreen.main.bounds.height)
            ))
        }
    }
    
    func clearParticles() {
        particles.removeAll()
    }
}
