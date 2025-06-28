import Foundation
import FirebaseMessaging
import UserNotifications
import Combine

class FCMService: ObservableObject {
    static let shared = FCMService()
    
    @Published var fcmToken: String?
    @Published var isRegistered = false
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
        checkNotificationPermission()
        loadStoredToken()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Listen for FCM token updates
        NotificationCenter.default.publisher(for: .fcmTokenRefresh)
            .sink { [weak self] _ in
                self?.refreshToken()
            }
            .store(in: &cancellables)
    }
    
    private func loadStoredToken() {
        fcmToken = UserDefaults.standard.string(forKey: "FCMToken")
        isRegistered = fcmToken != nil
    }
    
    // MARK: - Public Methods
    
    /// Request notification permission and register for FCM
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.notificationPermissionStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Register for remote notifications
    func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /// Refresh FCM token
    func refreshToken() {
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                return
            }
            
            guard let token = token else {
                print("FCM token is nil")
                return
            }
            
            DispatchQueue.main.async {
                self?.fcmToken = token
                self?.isRegistered = true
                UserDefaults.standard.set(token, forKey: "FCMToken")
                
                // Send token to backend
                Task {
                    await self?.sendTokenToBackend(token)
                }
            }
        }
    }
    
    /// Subscribe to a topic
    func subscribe(toTopic topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("Error subscribing to topic \(topic): \(error)")
            } else {
                print("Successfully subscribed to topic: \(topic)")
            }
        }
    }
    
    /// Unsubscribe from a topic
    func unsubscribe(fromTopic topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("Error unsubscribing from topic \(topic): \(error)")
            } else {
                print("Successfully unsubscribed from topic: \(topic)")
            }
        }
    }
    
    /// Check current notification permission status
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Send FCM token to backend
    func sendTokenToBackend(_ token: String) async {
        // This will be implemented when you have the backend endpoint ready
        print("Sending FCM token to backend: \(token)")
        
        // Example implementation:
        // let backendAPI = BackendAPI.shared
        // try? await backendAPI.updateFCMToken(token)
    }
    
    /// Get current FCM token
    func getCurrentToken() -> String? {
        return fcmToken
    }
    
    /// Clear stored token (useful for logout)
    func clearToken() {
        fcmToken = nil
        isRegistered = false
        UserDefaults.standard.removeObject(forKey: "FCMToken")
    }
    
    // MARK: - Testing Methods
    
    /// Send a test local notification
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from Googs!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
    
    /// Print current FCM status for debugging
    func printStatus() {
        print("=== FCM Status ===")
        print("Token: \(fcmToken ?? "nil")")
        print("Registered: \(isRegistered)")
        print("Permission Status: \(notificationPermissionStatus.rawValue)")
        print("==================")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let fcmTokenRefresh = Notification.Name("fcmTokenRefresh")
} 