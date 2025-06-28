import Foundation
import CryptoKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Combine
import AuthenticationServices

class AuthService: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    private let backendAPI = BackendAPI.shared
    
    init() {
        // Listen for auth state changes on the main thread
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
        
        // Also observe backend authentication state
        backendAPI.$isAuthenticated
            .sink { [weak self] isBackendAuthenticated in
                // If backend is not authenticated but Firebase is, we might need to re-exchange tokens
                if !isBackendAuthenticated && self?.user != nil {
                    print("Backend authentication lost while Firebase user exists")
                }
            }
            .store(in: &cancellables)
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Get ID token and exchange with backend
            let idToken = try await result.user.getIDToken()
            _ = try await backendAPI.exchangeGoogleToken(idToken)
            
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
            }
        } catch {
            throw error
        }
    }
    
    func signUpWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Get ID token and exchange with backend
            let idToken = try await result.user.getIDToken()
            _ = try await backendAPI.exchangeGoogleToken(idToken)
            
            await MainActor.run {
                self.user = result.user
                self.isAuthenticated = true
            }
        } catch {
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            
            // Also sign out from backend
            Task {
                await backendAPI.signOut()
            }
            
            DispatchQueue.main.async {
                self.user = nil
                self.isAuthenticated = false
            }
        } catch {
            throw error
        }
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No client ID found"])
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No ID token found"])
            }
            
            // First authenticate with Firebase
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: result.user.accessToken.tokenString)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Then exchange the Google ID token with our backend
            _ = try await backendAPI.exchangeGoogleToken(idToken)
            
            await MainActor.run {
                self.user = authResult.user
                self.isAuthenticated = true
            }
        } catch {
            throw error
        }
    }
    
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = SignInWithAppleDelegate(nonce: nonce) { result in
                continuation.resume(with: result)
            }
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            // Keep the delegate alive until the request completes
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: result.idToken,
            rawNonce: result.nonce
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // Get Firebase ID token and exchange with backend
        let idToken = try await authResult.user.getIDToken()
        _ = try await backendAPI.exchangeGoogleToken(idToken)
        
        await MainActor.run {
            self.user = authResult.user
            self.isAuthenticated = true
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check and refresh backend authentication if needed
    func ensureBackendAuthentication() async throws {
        // If we have a Firebase user but backend is not authenticated
        if let user = self.user, !backendAPI.isAuthenticated {
            // Get fresh ID token from Firebase
            let idToken = try await user.getIDToken()
            _ = try await backendAPI.exchangeGoogleToken(idToken)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - Sign in with Apple Delegate

private class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let nonce: String
    private let completion: (Result<(idToken: String, nonce: String), Error>) -> Void
    
    init(nonce: String, completion: @escaping (Result<(idToken: String, nonce: String), Error>) -> Void) {
        self.nonce = nonce
        self.completion = completion
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])))
            return
        }
        
        completion(.success((idToken: idTokenString, nonce: nonce)))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
} 
