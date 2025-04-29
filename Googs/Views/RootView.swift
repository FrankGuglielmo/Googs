//
//  RootView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/12/25.
//

import GoogleSignIn
import SwiftUI
import FirebaseAnalytics

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State private var showMainContent = false
    
    var body: some View {
        Group {
            if showMainContent {
                // Once the splash has finished, show the appropriate content based on user state.
                if !hasCompletedOnboarding {
                    // User hasn't completed onboarding
                    OnboardingView()
                        .analyticsScreen(name: "Onboarding")
                } else if !isSignedIn {
                    // User has completed onboarding but isn't signed in
                    LoginView()
                        .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                            
                        }
                        .analyticsScreen(name: "Login")
                } else {
                    // User is onboarded and signed in
                    MainViewContainer()
                }
            } else {
                // Show the splash screen.
                SplashView(showMainContent: $showMainContent)
            }
        }
        .animation(.easeInOut, value: showMainContent)
    }
}
