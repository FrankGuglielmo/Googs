import SwiftUI
import FirebaseMessaging

struct FCMTestView: View {
    @StateObject private var fcmService = FCMService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FCM Status")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        StatusRow(title: "FCM Token", value: fcmService.fcmToken ?? "Not available")
                        StatusRow(title: "Registered", value: fcmService.isRegistered ? "Yes" : "No")
                        StatusRow(title: "Permission", value: permissionStatusText)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Actions Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Actions")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button("Request Permission") {
                            Task {
                                let granted = await fcmService.requestPermission()
                                await MainActor.run {
                                    alertMessage = granted ? "Permission granted!" : "Permission denied"
                                    showingAlert = true
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Refresh Token") {
                            fcmService.refreshToken()
                            alertMessage = "Token refresh initiated"
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Send Test Notification") {
                            fcmService.sendTestNotification()
                            alertMessage = "Test notification scheduled (5 seconds)"
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Print Status to Console") {
                            fcmService.printStatus()
                            alertMessage = "Status printed to console"
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Topics Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Topic Management")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button("Subscribe to 'googs_notifications'") {
                            fcmService.subscribe(toTopic: "googs_notifications")
                            alertMessage = "Subscribed to googs_notifications topic"
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Unsubscribe from 'googs_notifications'") {
                            fcmService.unsubscribe(fromTopic: "googs_notifications")
                            alertMessage = "Unsubscribed from googs_notifications topic"
                            showingAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Debug Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Debug Info")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let token = fcmService.fcmToken {
                            Text("Token Preview:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(token.prefix(20)) + "...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color(.systemGray5))
                                .cornerRadius(5)
                        }
                        
                        Button("Copy Token to Clipboard") {
                            if let token = fcmService.fcmToken {
                                UIPasteboard.general.string = token
                                alertMessage = "Token copied to clipboard"
                                showingAlert = true
                            } else {
                                alertMessage = "No token available"
                                showingAlert = true
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(fcmService.fcmToken == nil)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("FCM Test")
            .navigationBarTitleDisplayMode(.inline)
            .alert("FCM Test", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var permissionStatusText: String {
        switch fcmService.notificationPermissionStatus {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
}

struct StatusRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
    }
}

struct FCMTestView_Previews: PreviewProvider {
    static var previews: some View {
        FCMTestView()
    }
} 