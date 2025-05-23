////
////  SignInView.swift
////  AnimatedApp
////
////  Created by Meng To on 2022-04-11.
////
//
//import SwiftUI
//import RiveRuntime
//
//struct SignInView: View {
//    @State var email = ""
//    @State var password = ""
//    @State var isLoading = false
//    @AppStorage("isSignedIn") var isSignedIn: Bool = false
//    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
//    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
//    
//    func logIn() {
//        isLoading = true
//        
//        if email != "" {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                check.triggerInput("Check")
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                confetti.triggerInput("Trigger explosion")
//                withAnimation {
//                    isLoading = false
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                withAnimation {
//                    // Set isSignedIn to true, which will trigger RootView to show ContentView
//                    isSignedIn = true
//                }
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                check.triggerInput("Error")
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                isLoading = false
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack(spacing: 24) {
//            Text("Sign in")
//                .customFont(.largeTitle)
//            Text("Access to 240+ hours of content. Learn design and code, by building real apps with React and Swift.")
//                .foregroundStyle(.secondary)
//            VStack(alignment: .leading) {
//                Text("Email")
//                    .customFont(.subheadline)
//                    .foregroundStyle(.secondary)
//                TextField("", text: $email)
//                    .customTextField(image: Image("Icon Email"))
//            }
//            VStack(alignment: .leading) {
//                Text("Password")
//                    .customFont(.subheadline)
//                    .foregroundStyle(.secondary)
//                SecureField("", text: $password)
//                    .customTextField(image: Image("Icon Lock"))
//            }
//            Button {
//                logIn()
//            } label: {
//                HStack {
//                    Image(systemName: "arrow.right")
//                    Text("Sign in")
//                        .customFont(.headline)
//                }
//                .largeButton()
//            }
//            
//            HStack {
//                Rectangle().frame(height: 1).opacity(0.1)
//                Text("OR").customFont(.subheadline2).foregroundStyle(.black.opacity(0.3))
//                Rectangle().frame(height: 1).opacity(0.1)
//            }
//            
//            Text("Sign up with Email, Apple, Google")
//                .customFont(.subheadline)
//                .foregroundStyle(.secondary)
//            
//            HStack {
//                Image("Logo Email")
//                Spacer()
//                Image("Logo Apple")
//                Spacer()
//                Image("Logo Google")
//            }
//        }
//        .padding(30)
//        .background(.regularMaterial)
//        .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
//        .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
//        .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
//        .overlay(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .stroke(.linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
//        )
//        .overlay(
//            ZStack {
//                if isLoading {
//                    check.view()
//                        .frame(width: 100, height: 100)
//                        .allowsHitTesting(false)
//                }
//                confetti.view()
//                    .scaleEffect(3)
//                    .allowsHitTesting(false)
//            }
//        )
//        .padding()
//    }
//}
//
//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
