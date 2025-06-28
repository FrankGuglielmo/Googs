import Foundation
import Combine
import Security

// MARK: - API Error Types
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Unauthorized - Please sign in again"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Data Models
struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

struct GoogleAuthRequest: Codable {
    let idToken: String
    
    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

// MARK: - Backend API Service
class BackendAPI: ObservableObject {
    static let shared = BackendAPI()
    
    // Configure these for your environment
    #if DEBUG
    private let baseURL = "http://localhost:8000"  // Local development
    #else
    private let baseURL = "https://your-vps-domain.com/api"  // Production - UPDATE THIS
    #endif
    
    @Published private(set) var isAuthenticated = false
    
    private var accessToken: String?
    private var refreshToken: String?
    private let tokenSubject = PassthroughSubject<Void, Never>()
    
    private let keychainService = "com.yourapp.googs"  // UPDATE with your bundle ID
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Load tokens from Keychain on init
        loadTokensFromKeychain()
    }
    
    // MARK: - Authentication Methods
    
    /// Exchange Google ID token for backend JWT tokens
    func exchangeGoogleToken(_ idToken: String) async throws -> AuthTokens {
        let url = URL(string: "\(baseURL)/auth/google/exchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GoogleAuthRequest(idToken: idToken)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(errorMessage)
        }
        
        do {
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            
            // Store tokens
            self.accessToken = tokens.accessToken
            self.refreshToken = tokens.refreshToken
            await MainActor.run {
                self.isAuthenticated = true
            }
            saveTokensToKeychain(tokens)
            
            return tokens
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    /// Make an authenticated request to the backend
    func authenticatedRequest<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        // Ensure we have an access token
        guard let accessToken = self.accessToken else {
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // If unauthorized, try to refresh token
            if httpResponse.statusCode == 401 {
                try await refreshAccessToken()
                // Retry the request with new token
                return try await authenticatedRequest(
                    path: path,
                    method: method,
                    body: body,
                    responseType: responseType
                )
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(errorMessage)
            }
            
            return try JSONDecoder().decode(responseType, from: data)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Refresh the access token using the refresh token
    private func refreshAccessToken() async throws {
        guard let refreshToken = self.refreshToken else {
            throw APIError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            // Refresh token is invalid, need to re-authenticate
            await signOut()
            throw APIError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(errorMessage)
        }
        
        struct RefreshResponse: Codable {
            let accessToken: String
            let tokenType: String
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
            }
        }
        
        let resp = try JSONDecoder().decode(RefreshResponse.self, from: data)
        self.accessToken = resp.accessToken
        
        // Update only access token in keychain
        updateAccessTokenInKeychain(resp.accessToken)
    }
    
    /// Sign out and clear tokens
    @MainActor
    func signOut() async {
        // Call logout endpoint if we have a token
        if accessToken != nil {
            do {
                let _: [String: String] = try await authenticatedRequest(
                    path: "/auth/logout",
                    method: "POST",
                    responseType: [String: String].self
                )
            } catch {
                // Ignore errors during logout
                print("Logout error: \(error)")
            }
        }
        
        // Clear tokens
        accessToken = nil
        refreshToken = nil
        isAuthenticated = false
        deleteTokensFromKeychain()
    }
    
    // MARK: - Keychain Management
    
    private func saveTokensToKeychain(_ tokens: AuthTokens) {
        saveToKeychain(key: accessTokenKey, value: tokens.accessToken)
        saveToKeychain(key: refreshTokenKey, value: tokens.refreshToken)
    }
    
    private func updateAccessTokenInKeychain(_ token: String) {
        saveToKeychain(key: accessTokenKey, value: token)
    }
    
    private func loadTokensFromKeychain() {
        accessToken = loadFromKeychain(key: accessTokenKey)
        refreshToken = loadFromKeychain(key: refreshTokenKey)
        isAuthenticated = accessToken != nil && refreshToken != nil
    }
    
    private func deleteTokensFromKeychain() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
    }
    
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        var newQuery = query
        newQuery[kSecValueData as String] = data
        SecItemAdd(newQuery as CFDictionary, nil)
    }
    
    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Update FCM token on backend
    func updateFCMToken(_ token: String) async throws {
        let url = URL(string: "\(baseURL)/auth/fcm-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["fcm_token": token]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(errorMessage)
        }
        
        print("FCM token updated successfully on backend")
    }
    
    /// Get FCM token (for debugging)
    func getFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: "FCMToken")
    }
    
    /// Clear FCM token (for logout)
    func clearFCMToken() {
        UserDefaults.standard.removeObject(forKey: "FCMToken")
    }
} 
