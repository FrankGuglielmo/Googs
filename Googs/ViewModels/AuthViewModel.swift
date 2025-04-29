import Foundation
import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var currentUser: User?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        
        // Observe authentication state on the main thread
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        authService.$user
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
} 
