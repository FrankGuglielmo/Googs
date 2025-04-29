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
        ZStack {
            Image("LoginPage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            if isSignUp {
                SignUpView(
                    email: $email, 
                    password: $password, 
                    isSignUp: $isSignUp, 
                    showError: $showError, 
                    errorMessage: $errorMessage, 
                    authService: authService
                )
            } else {
                SignInView(
                    email: $email, 
                    password: $password, 
                    isSignUp: $isSignUp, 
                    showError: $showError, 
                    errorMessage: $errorMessage, 
                    authService: authService
                )
            }
        }
    }
}

struct SignInView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    var authService: AuthService
    
//    @State private var showForgotPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Login header
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.top, 60)
                .padding(.bottom, 4)
            
            Text("Please sign in to continue.")
                .foregroundStyle(.black.opacity(0.7))
                .padding(.bottom, 20)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("EMAIL")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.black)
                    TextField("", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("PASSWORD")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.black)
                    SecureField("", text: $password)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Login button
            Button {
                Task {
                    await handleSignIn()
                }
            } label: {
                HStack {
                    Text("LOGIN")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color._3E54AC)
                )
            }
            .padding(.top, 10)
            
            // Divider with "Or" text
            HStack {
                VStack { Divider() }.padding(.horizontal, 8)
                Text("OR")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 8)
                VStack { Divider() }.padding(.horizontal, 8)
            }
            .padding(.vertical)
            
            // Social sign-in options
            VStack(spacing: 16) {
                Button {
                    Task {
                        await handleGoogleSignIn()
                    }
                } label: {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Continue with Google")
                            .foregroundStyle(Color._3E54AC)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.bface2, lineWidth: 1.5)
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
                .cornerRadius(25)
            }
            
            // Sign up link
            HStack {
                Text("Don't have an account?")
                    .foregroundStyle(Color.black)
                Button("Sign up") {
                    isSignUp = true
                }
                .foregroundStyle(Color.ff9e5e)
                .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
        }
        .padding(.horizontal, 30)
        .padding(.top, 60)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleSignIn() async {
        do {
            try await authService.signInWithEmail(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func handleGoogleSignIn() async {
        do {
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

struct SignUpView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isSignUp: Bool
    @Binding var showError: Bool
    @Binding var errorMessage: String
    var authService: AuthService
    
    @State private var fullName = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Create account header
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.top, 60)
                .padding(.bottom, 20)
            
            // Full name field
            VStack(alignment: .leading, spacing: 8) {
                Text("FULL NAME")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundStyle(.black)
                    TextField("", text: $fullName)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("EMAIL")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundStyle(.black)
                    TextField("", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("PASSWORD")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.black)
                    SecureField("", text: $password)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Confirm password field
            VStack(alignment: .leading, spacing: 8) {
                Text("CONFIRM PASSWORD")
                    .font(.caption)
                    .foregroundStyle(.black)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundStyle(.black)
                    SecureField("", text: $confirmPassword)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ecf2ff, lineWidth: 1)
                        .background(Color.ecf2ff.opacity(0.3))
                )
            }
            
            // Sign up button
            Button {
                Task {
                    await handleSignUp()
                }
            } label: {
                HStack {
                    Text("SIGN UP")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color._3E54AC)
                )
            }
            .padding(.top, 10)
            
            // Login link
            HStack {
                Text("Already have an account?")
                    .foregroundStyle(.black)
                Button("Sign in") {
                    isSignUp = false
                }
                .foregroundStyle(Color.ff9e5e)
                .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
        }
        .padding(.horizontal, 30)
        .padding(.top, 60)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleSignUp() async {
        // Validate inputs
        if fullName.isEmpty {
            errorMessage = "Please enter your full name"
            showError = true
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        do {
            try await authService.signUpWithEmail(email: email, password: password)
            
            // Update the user profile with the name
            if let user = Auth.auth().currentUser {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                try await changeRequest.commitChanges()
            }
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
