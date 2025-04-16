//
//  OnboardingView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/11/25.
//

import SwiftUI
import RiveRuntime

struct OnboardingView: View {
    @State private var pageIndex: Int = 0
    @State private var previousIndex: Int = -1
    // A flag to control if swipes should be allowed
    @State private var isAnimating: Bool = false
    // Access the app storage to set onboarding completion
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    let onboardModel = RiveViewModel(
        fileName: "onboard",
        stateMachineName: "OnboardingMachine"
    )
    
    var background: some View {
        // This is your custom Rive background with the Spline image.
        RiveViewModel(fileName: "animatedbackground").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .background(
                Image("Spline")
                    .resizable() // Ensure the image is resizable
                    .scaledToFill()
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [._3E54AC, ._655DBB, .bface2],   // From your custom Color extension
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()
            background
            
            VStack {
                // MARK: - Page Content
                TabView(selection: $pageIndex) {
                    
                    // Page 0: Meet Your New Smart Inbox
                    VStack(spacing: 24) {
                        Text("Meet Your New Smart Inbox")
                            .customFont(.largeTitle, modifiers: [.disregardsLightMode])
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Image("onboardRobot")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300, maxHeight: 300)
                        
                        Text("Connect your email account and let our intelligent system learn what matters most to you.")
                            .customFont(.body, modifiers: [.disregardsLightMode])
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 350)
                            .padding(.horizontal, 20)
                    }
                    .tag(0)
                    
                    // Page 1: Customize Your Notifications
                    NotificationBar()
                        .tag(1)
                    
                    // Page 2: Get Started Effortlessly
                    VStack(spacing: 32) {
                        Text("Get Started Now!")
                            .customFont(.largeTitle, modifiers: [.disregardsLightMode])
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text("""
Enable our notifications, let the AI do its magic, and you’re all set. Moving forward, you’ll only hear about the emails that truly matter. Take back your focus—no more noisy inbox, just smarter conversations.
""")
                        .customFont(.body, modifiers: [.disregardsLightMode])
                        .frame(maxWidth: 350)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: pageIndex)
                .disabled(isAnimating)
                .onChange(of: pageIndex) { oldValue, newValue in
                    guard !isAnimating else {
                        pageIndex = oldValue
                        return
                    }
                    previousIndex = oldValue
                    
                    // Trigger Rive state machine inputs.
                    onboardModel.setInput("previousPageIndex", value: Double(previousIndex))
                    onboardModel.setInput("pageIndex", value: Double(newValue))
                    
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isAnimating = false
                    }
                }
                
                Spacer()
                
                // MARK: - Rive View at the Bottom
                if pageIndex == 2 {
                    // When on page 2, the Rive view is wrapped in a button.
                    Button(action: {
                        onboardModel.triggerInput("buttonClick")
                        print("Rive button tapped on page 2 – completing onboarding")
                        // Delay the state change slightly to let the animation play.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            // Set onboarding as completed - RootView will handle navigation to SignInView
                            hasCompletedOnboarding = true
                        }
                    }) {
                        onboardModel.view()
                            .frame(width: 375, height: 100)
                    }
                    .buttonStyle(.plain)
                } else {
                    // For pages 0 and 1, show the Rive view without tap action.
                    onboardModel.view()
                        .frame(width: 375, height: 100)
                }
            }
            .padding(.vertical)
        }
    }
}


struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
