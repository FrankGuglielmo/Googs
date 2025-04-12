import SwiftUI
import RiveRuntime

struct OnboardView: View {
    @State private var pageIndex: Int = 0
    @State private var previousIndex: Int = -1
    // A flag to control if swipes should be allowed
    @State private var isAnimating: Bool = false
    // This flag controls navigation to the EmailSignUpView
    @State private var showSignUp = false
    
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
        NavigationStack {
            ZStack {
                // Conditionally show one background or the other.
                // This block remains unchanged from your working code.
                ZStack {
                    if pageIndex == 2 {
                        background
                            .transition(.opacity)
                    } else {
                        AnimatedGradientBackground()
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: pageIndex)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // MARK: - Page Content
                    TabView(selection: $pageIndex) {
                        
                        // Page 0: Meet Your New Smart Inbox
                        VStack(spacing: 24) {
                            Text("Meet Your New Smart Inbox")
                                .font(.custom("Poppins Bold", size: 45))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Image("onboardRobot")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 300, maxHeight: 300)
                            
                            Text("""
Say hello to your AI-powered email assistant! Connect your email account, and let our intelligent system learn what matters most to you. It’s time to keep the important conversations close and the clutter far, far away.
""")
                            .font(.custom("Poppins Regular", size: 18))
                            .foregroundStyle(.white.opacity(0.9))
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
                                .font(.custom("Poppins Bold", size: 48))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Text("""
Enable our notifications, let the AI do its magic, and you’re all set. Moving forward, you’ll only hear about the emails that truly matter. Take back your focus—no more noisy inbox, just smarter conversations.
""")
                            .customFont(.body)
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
                            print("Rive button tapped on page 2 – navigating to sign up")
                            // Delay navigation slightly to let the animation play.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                showSignUp = true
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
            // Navigation to the EmailSignUpView without showing the navigation bar.
            .navigationDestination(isPresented: $showSignUp) {
                EmailSignUpView()
            }
            .navigationBarHidden(true)
        }
    }
}


struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}
