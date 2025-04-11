import SwiftUI
import RiveRuntime

struct OnboardView: View {
    @State private var pageIndex: Int = 0
    @State private var previousIndex: Int = -1
    // A flag to control if swipes should be allowed
    @State private var isAnimating: Bool = false
    
    let onboardModel = RiveViewModel(
        fileName: "onboard",
        stateMachineName: "OnboardingMachine"
    )
    
    var background: some View {
        RiveViewModel(fileName: "animatedbackground").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .background(
                Image("Spline")
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
    }
    
    var body: some View {
        ZStack {
            // Conditionally show one background or the other
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
                    // Page 0: Welcome
                    VStack(spacing: 20) {
                        Image(systemName: "hand.wave.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        Text("Welcome to Googs!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Discover adventures tailored for you.")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .tag(0)
                    
                    // Page 1: Features
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        Text("Explore Features")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Find amazing tools to enhance your experience.")
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    .tag(1)
                    
                    // Page 2: Get Started
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        Text("Get Started")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Tap below to launch the app!")
                            .foregroundColor(.white)
                            .padding(.horizontal)
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
                    // When on page 2, wrap the Rive view in a button.
                    Button(action: {
                        onboardModel.triggerInput("buttonClick")
                        print("Rive button tapped on page 2 – navigate to next screen")
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

#Preview {
    OnboardView()
}
