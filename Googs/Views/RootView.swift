//
//  RootView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/12/25.
//


import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var showMainContent = false
    
    var body: some View {
        Group {
            if showMainContent {
                // Once the splash has finished, show the appropriate content.
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardView()
                }
            } else {
                // Show the splash screen.
                SplashView(showMainContent: $showMainContent)
            }
        }
        .animation(.easeInOut, value: showMainContent)
    }
}
