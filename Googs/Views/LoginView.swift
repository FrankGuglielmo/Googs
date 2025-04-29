//
//  LoginView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/28/25.
//

import GoogleSignIn
import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isSignUp ? "Create Account" : "Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(isSignUp ? .newPassword : .password)
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        await handleEmailAuth()
                    }
                } label: {
                    Text(isSignUp ? "Sign Up" : "Sign In")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button {
                    isSignUp.toggle()
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
                Divider()
                    .padding(.vertical)
                
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await handleGoogleSignIn()
                        }
                    } label: {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                await handleAppleSignIn(result: result)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func handleEmailAuth() async {
        do {
            if isSignUp {
                try await authService.signUpWithEmail(email: email, password: password)
            } else {
                try await authService.signInWithEmail(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleGoogleSignIn() async {
        do {
            // Get the root view controller on the main thread
            let rootViewController = await MainActor.run {
                getRootViewController()
            }
            
            if let rootViewController = rootViewController {
                try await authService.signInWithGoogle(presenting: rootViewController)
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        do {
            try await authService.signInWithApple()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    LoginView()
}

@MainActor
func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = scene.windows.first?.rootViewController
    else { return nil }
    return getVisibleViewController(from: rootViewController)
}

@MainActor
private func getVisibleViewController(from viewController: UIViewController) -> UIViewController? {
    if let navigationController = viewController as? UINavigationController {
        return getVisibleViewController(from: navigationController.visibleViewController!)
    }
    if let tabBarController = viewController as? UITabBarController {
        return getVisibleViewController(from: tabBarController.selectedViewController!)
    }
    if let presentedViewController = viewController.presentedViewController {
        return getVisibleViewController(from: presentedViewController)
    }
    return viewController
}
