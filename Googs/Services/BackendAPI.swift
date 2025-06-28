import Foundation
import Combine
import Security

// MARK: - Environment Configuration
enum Environment: String, CaseIterable {
    case local = "local"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .local:
            return "Local Development"
        case .production:
            return "Production"
        }
    }
    
    var baseURL: String {
        switch self {
        case .local:
            return "http://localhost:8000"
        case .production:
            return "http://atomaiapp.com/api"  // Changed from https to http
        }
    }
    
    var isLocal: Bool {
        return self == .local
    }
}

// MARK: - Environment Manager
class EnvironmentManager: ObservableObject {
    static let shared = EnvironmentManager()
    
    @Published var currentEnvironment: Environment {
        didSet {
            UserDefaults.standard.set(currentEnvironment.rawValue, forKey: "selectedEnvironment")
            // Notify BackendAPI to update its configuration
            NotificationCenter.default.post(name: .environmentChanged, object: currentEnvironment)
        }
    }
    
    private init() {
        // Load saved environment or default to local for DEBUG builds
        let savedEnvironment = UserDefaults.standard.string(forKey: "selectedEnvironment")
        if let saved = savedEnvironment, let env = Environment(rawValue: saved) {
            self.currentEnvironment = env
        } else {
            #if DEBUG
            self.currentEnvironment = .local
            #else
            self.currentEnvironment = .production
            #endif
        }
    }
    
    func switchEnvironment(_ environment: Environment) {
        currentEnvironment = environment
    }
    
    func getCurrentBaseURL() -> String {
        return currentEnvironment.baseURL
    }
    
    func isLocalEnvironment() -> Bool {
        return currentEnvironment.isLocal
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let environmentChanged = Notification.Name("environmentChanged")
}

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

// MARK: - Email Models
struct EmailResponse: Codable {
    let id: Int
    let gmailId: String
    let subject: String?
    let sender: String?
    let recipient: String?
    let date: String?
    let snippet: String?
    let labels: [String]?
    let threadId: String?
    let isRead: Bool
    let tags: [String]?
    let hasAttachments: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, subject, sender, recipient, date, snippet, labels, tags
        case gmailId = "gmail_id"
        case threadId = "thread_id"
        case isRead = "is_read"
        case hasAttachments = "has_attachments"
    }
}

struct EmailListResponse: Codable {
    let emails: [EmailResponse]
    let pagination: [String: String]?
    let stats: [String: String]?
}

// MARK: - Backend API Service
class BackendAPI: ObservableObject {
    static let shared = BackendAPI()
    
    // Use EnvironmentManager for dynamic URL configuration
    private var baseURL: String {
        return EnvironmentManager.shared.getCurrentBaseURL()
    }
    
    @Published private(set) var isAuthenticated = false
    var currentEnvironment: Environment {
        return EnvironmentManager.shared.currentEnvironment
    }
    
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
        
        // Listen for environment changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(environmentChanged),
            name: .environmentChanged,
            object: nil
        )
    }
    
    @objc private func environmentChanged() {
        // Clear authentication when switching environments
        // This ensures we don't use tokens from one environment in another
        Task { @MainActor in
            await signOut()
        }
    }
    
    // MARK: - Environment Management
    
    /// Switch to a different environment
    func switchEnvironment(_ environment: Environment) {
        EnvironmentManager.shared.switchEnvironment(environment)
    }
    
    /// Get current environment display name
    func getCurrentEnvironmentName() -> String {
        return currentEnvironment.displayName
    }
    
    /// Check if currently in local environment
    func isLocalEnvironment() -> Bool {
        return EnvironmentManager.shared.isLocalEnvironment()
    }
    
    /// Test connection to current environment
    func testConnection() async throws -> Bool {
        let url = URL(string: "\(baseURL)/health")!
        let request = URLRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            // Print debug info
            print("BackendAPI: Health check status: \(httpResponse.statusCode)")
            if let responseData = String(data: data, encoding: .utf8) {
                print("BackendAPI: Health check response: \(responseData)")
            }
            
            return httpResponse.statusCode == 200
        } catch {
            print("BackendAPI: Health check failed: \(error)")
            return false
        }
    }
    
    /// Test auth endpoint specifically
    func testAuthEndpoint() async throws -> Bool {
        let url = URL(string: "\(baseURL)/auth/google/exchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send a minimal request to test if endpoint exists
        let testBody = ["id_token": "test"]
        request.httpBody = try JSONSerialization.data(withJSONObject: testBody)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            print("BackendAPI: Auth endpoint test status: \(httpResponse.statusCode)")
            if let responseData = String(data: data, encoding: .utf8) {
                print("BackendAPI: Auth endpoint response: \(responseData)")
            }
            
            // Even if we get 401 (unauthorized), the endpoint exists
            return httpResponse.statusCode != 404
        } catch {
            print("BackendAPI: Auth endpoint test failed: \(error)")
            return false
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Exchange Google ID token for backend JWT tokens
    func exchangeGoogleToken(_ idToken: String) async throws -> AuthTokens {
        print("BackendAPI: Starting token exchange...")
        let url = URL(string: "\(baseURL)/auth/google/exchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = GoogleAuthRequest(idToken: idToken)
        request.httpBody = try JSONEncoder().encode(body)
        
        print("BackendAPI: Making request to \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("BackendAPI: Invalid response type")
            throw APIError.invalidResponse
        }
        
        print("BackendAPI: Response status code: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 401 {
            print("BackendAPI: Unauthorized response")
            throw APIError.unauthorized
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("BackendAPI: Server error: \(errorMessage)")
            throw APIError.serverError(errorMessage)
        }
        
        do {
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            print("BackendAPI: Successfully decoded tokens")
            
            // Store tokens
            self.accessToken = tokens.accessToken
            self.refreshToken = tokens.refreshToken
            await MainActor.run {
                self.isAuthenticated = true
            }
            saveTokensToKeychain(tokens)
            
            return tokens
        } catch {
            print("BackendAPI: Decoding error: \(error)")
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
    
    /// Get current access token (for debugging)
    func getCurrentAccessToken() -> String? {
        return accessToken
    }
    
    /// Clear FCM token (for logout)
    func clearFCMToken() {
        UserDefaults.standard.removeObject(forKey: "FCMToken")
    }
    
    // MARK: - Email API Methods
    
    /// Fetch emails from the backend
    func fetchEmails(limit: Int = 50, offset: Int = 0) async throws -> [EmailResponse] {
        guard let accessToken = accessToken else {
            throw APIError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/emails?limit=\(limit)&offset=\(offset)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let emails = try JSONDecoder().decode([EmailResponse].self, from: data)
                return emails
            case 401:
                throw APIError.unauthorized
            case 500:
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                throw APIError.serverError(errorResponse?["detail"] ?? "Server error")
            default:
                throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Fetch emails with cursor-based pagination (more efficient for iOS)
    func fetchEmailsWithCursor(cursor: Int? = nil, limit: Int = 20) async throws -> (emails: [EmailResponse], nextCursor: Int?) {
        guard let accessToken = accessToken else {
            throw APIError.unauthorized
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)/emails/cursor")!
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: "\(cursor)"))
        }
        
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let emails = try JSONDecoder().decode([EmailResponse].self, from: data)
                let nextCursor = httpResponse.value(forHTTPHeaderField: "X-Next-Cursor").flatMap { Int($0) }
                return (emails, nextCursor)
            case 401:
                throw APIError.unauthorized
            case 500:
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                throw APIError.serverError(errorResponse?["detail"] ?? "Server error")
            default:
                throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Mark email as read/unread
    func markEmailAsRead(emailId: Int, isRead: Bool) async throws -> EmailResponse {
        guard let accessToken = accessToken else {
            throw APIError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/emails/\(emailId)/read")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["is_read": isRead]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let email = try JSONDecoder().decode(EmailResponse.self, from: data)
                return email
            case 401:
                throw APIError.unauthorized
            case 500:
                let errorResponse = try? JSONDecoder().decode([String: String].self, from: data)
                throw APIError.serverError(errorResponse?["detail"] ?? "Server error")
            default:
                throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Debug Methods
    
    /// Comprehensive debug method to test all connection aspects
    func debugConnection() async {
        print("🔍 BackendAPI: Starting connection debug...")
        print("🔍 BackendAPI: Current environment: \(currentEnvironment.displayName)")
        print("🔍 BackendAPI: Base URL: \(baseURL)")
        
        // Test health endpoint
        print("🔍 BackendAPI: Testing health endpoint...")
        do {
            let healthOk = try await testConnection()
            print("🔍 BackendAPI: Health check result: \(healthOk ? "✅ SUCCESS" : "❌ FAILED")")
        } catch {
            print("🔍 BackendAPI: Health check error: \(error)")
        }
        
        // Test auth endpoint
        print("🔍 BackendAPI: Testing auth endpoint...")
        do {
            let authOk = try await testAuthEndpoint()
            print("🔍 BackendAPI: Auth endpoint result: \(authOk ? "✅ EXISTS" : "❌ NOT FOUND")")
        } catch {
            print("🔍 BackendAPI: Auth endpoint error: \(error)")
        }
        
        // Test direct URL access
        print("🔍 BackendAPI: Testing direct URL access...")
        let testURL = URL(string: "\(baseURL)/auth/google/exchange")!
        print("🔍 BackendAPI: Full URL: \(testURL)")
        
        var request = URLRequest(url: testURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["id_token": "test"])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 BackendAPI: Direct test status: \(httpResponse.statusCode)")
                if let responseText = String(data: data, encoding: .utf8) {
                    print("🔍 BackendAPI: Direct test response: \(responseText)")
                }
            }
        } catch {
            print("🔍 BackendAPI: Direct test error: \(error)")
        }
        
        print("🔍 BackendAPI: Debug complete!")
    }
} 
