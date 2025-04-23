//
//  SplashView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/12/25.
//


import SwiftUI
import RiveRuntime

struct SplashView: View {
    // Your Rive model for the animated splash screen.
    let splashModel = RiveViewModel(fileName: "googslaunchscreen", stateMachineName: "State Machine 1", artboardName: "Atom")
    
    // Binding that allows this view to notify the parent when to transition.
    @Binding var showMainContent: Bool
    
    var body: some View {
        ZStack {
            // The Rive animation, which will cover the whole screen.
            splashModel.view()
                .ignoresSafeArea()
        }
        .onAppear {
            // Trigger the Rive animation if needed.
            splashModel.triggerInput("start")
            
            // After the animation completes (e.g. after 1.5 seconds), set the flag to show main content.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.51) {
                withAnimation {
                    showMainContent = true
                }
            }
        }
    }
}
