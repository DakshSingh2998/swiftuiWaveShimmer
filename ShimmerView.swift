//
//  ShimmerView.swift
//  TV
//
//  Created by Daksh_Singh on 20/07/24.
//

import SwiftUI

//struct WavePhysics: Hashable {
//    static func == (lhs: WavePhysics, rhs: WavePhysics) -> Bool {
//        return lhs.phase == rhs.phase && lhs.x == rhs.x
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(phase)
//        hasher.combine(x)
//    }
//    let phase: Double
//    let x: Double
//    init(phase: Double, x: Double) {
//        self.phase = phase
//        self.x = x
//    }
//}

class WaveMemoization {
    static let shared = WaveMemoization()
    var memoizedX: [Double: Double] = [:]
}

struct Wave: Shape {
    // how high our waves should be
    let strength: Double
    
    // how frequent our waves should be
    let frequency: Double
    
    var phase: Double
    
    let maxYOffset: Double
    
    var animatableData: Double {
        get { phase }
        set { self.phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        
        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height) - (maxYOffset * 2)
        let midWidth = width / 2
        let midHeight = height / 2
        
        // split our total width up based on the frequency
        let wavelength = width / frequency
        let oneOverMidWidth = 1 / midWidth
        
        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // now count across individual horizontal points one by one
        for x in stride(from: 0, through: width, by: 2) {
            // find our current position relative to the wavelength
            let relativeX = x / wavelength
            // find how far we are from the horizontal center
            let distanceFromMidWidth = x - midWidth
            
            // bring that into the range of -1 to 1
            let normalDistance = oneOverMidWidth * distanceFromMidWidth
            let parabola = -(normalDistance * normalDistance) + 1
            
            // calculate the sine of that position
            var sine = 0.0
            if let memoizedSine = WaveMemoization.shared.memoizedX[relativeX + phase] {
                sine = memoizedSine
            } else {
                sine = sin(relativeX + phase)
            }
            
            // multiply that sine by our strength to determine final offset, then move it down to the middle of our view
            let y = parabola * strength * sine + midHeight
            //                WaveMemoization.shared.memoizedX[wavePhysics] = y
            // add a line to here
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        
        
        
        return Path(path.cgPath)
    }
}


struct ShimmerView: View {
    @State private var phase = 0.0
    var body: some View {
        ZStack {
            ForEach(-5..<5) { i in
                Wave(strength: 50, frequency: 30, phase: self.phase, maxYOffset: 50)
                    .stroke(Color.red.opacity(Double(i) / 10), lineWidth: 5)
                    .offset(y: CGFloat(i) * 10)
                
            }
            .mask(
                LinearGradient(gradient: Gradient(colors: [.clear, .white, .clear]), startPoint: .leading, endPoint: .trailing)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation(.linear.repeatForever(autoreverses: false), {
                    self.phase = .pi * 2
                })
            })
            
        }
        
    }
}

#Preview {
    ShimmerView()
}
