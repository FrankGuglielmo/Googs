//
//  AnimatedGradientBackground.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/10/25.
//


import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [._3E54AC, ._655DBB, .bface2],   // From your custom Color extension
            startPoint: animateGradient ? .topLeading : .topTrailing,
            endPoint: animateGradient ? .bottomTrailing : .bottomLeading
        )
        .ignoresSafeArea()
        // Animate the gradient shift over 5 seconds, repeating forever
        .animation(
            .linear(duration: 3)
             .repeatForever(autoreverses: true),
            value: animateGradient
        )
        .onAppear {
            // Kick off the animation when this View appears
            animateGradient = true
        }
    }
}

struct AnimatedGradientBackground_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedGradientBackground()
    }
}
