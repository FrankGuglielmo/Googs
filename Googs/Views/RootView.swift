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
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showMainContent = false
    
    var body: some View {
        Group {
            if showMainContent {
                // Once the splash has finished, show the appropriate content based on user state.
                if !hasCompletedOnboarding {
                    // User hasn't completed onboarding
                    OnboardingView()
                        .analyticsScreen(name: "Onboarding")
                } else if !authViewModel.isAuthenticated {
                    // User has completed onboarding but isn't signed in
                    LoginView()
                        .onOpenURL { url in
                            GIDSignIn.sharedInstance.handle(url)
                        }
                        .analyticsScreen(name: "Login")
                } else {
                    // User is onboarded and signed in
                    MainViewContainer()
                        .environmentObject(authViewModel)
                }
            } else {
                // Show the splash screen.
                SplashView(showMainContent: $showMainContent)
            }
        }
        .animation(.easeInOut, value: showMainContent)
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .animation(.easeInOut, value: hasCompletedOnboarding)
    }
}
