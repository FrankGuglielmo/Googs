import SwiftUI
import FirebaseMessaging

struct FCMTestView: View {
    @StateObject private var fcmService = FCMService.shared
    @StateObject private var backendAPI = BackendAPI.shared
    @State private var fcmToken: String = ""
    @State private var isRegistered = false
    @State private var debugOutput: String = ""
    @State private var isTestingConnection = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                mainContent
            }
            .navigationTitle("FCM & Backend Test")
            .navigationBarTitleDisplayMode(.inline)
            .alert("FCM Test", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            fcmSection
            backendDebugSection
            environmentSection
            statusSection
            actionsSection
            topicsSection
            debugSection
        }
        .padding()
    }
    
    private var fcmSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FCM Token")
                .font(.headline)
            
            TextField("FCM Token", text: $fcmToken)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button("Get Token") {
                    fcmToken = fcmService.getCurrentToken() ?? "No token available"
                }
                .buttonStyle(.bordered)
                
                Button("Register") {
                    Task {
                        await registerFCMToken()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(fcmToken.isEmpty)
            }
            
            if isRegistered {
                Text("✅ FCM Token registered successfully!")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var backendDebugSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Backend Connection Debug")
                .font(.headline)
            
            HStack {
                Text("Environment:")
                Spacer()
                Text(backendAPI.getCurrentEnvironmentName())
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Base URL:")
                Spacer()
                Text(backendAPI.isLocalEnvironment() ? "http://localhost:8000" : "http://atomaiapp.com/api")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Button("Test Connection") {
                Task {
                    await testBackendConnection()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isTestingConnection)
            
            if isTestingConnection {
                ProgressView("Testing...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if !debugOutput.isEmpty {
                Text("Debug Output:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ScrollView {
                    Text(debugOutput)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Environment Settings")
                .font(.headline)
            
            EnvironmentPickerView(backendAPI: backendAPI)
            
            Text("Switch environments to test different configurations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var statusSection: some View {
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
    }
    
    private var actionsSection: some View {
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
    }
    
    private var topicsSection: some View {
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
    }
    
    private var debugSection: some View {
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
    
    private func registerFCMToken() async {
        guard !fcmToken.isEmpty else { return }
        
        do {
            try await backendAPI.updateFCMToken(fcmToken)
            await MainActor.run {
                isRegistered = true
            }
        } catch {
            print("Failed to register FCM token: \(error)")
        }
    }
    
    private func testBackendConnection() async {
        await MainActor.run {
            isTestingConnection = true
            debugOutput = ""
        }
        
        // Capture debug output
        let originalPrint = print
        var capturedOutput: [String] = []
        
        // Override print to capture output
        func capturePrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
            let output = items.map { "\($0)" }.joined(separator: separator) + terminator
            capturedOutput.append(output)
            print(output, separator: "", terminator: "")
        }
        
        // Temporarily replace print function
        // Note: This is a simplified approach - in a real app you might want to use a proper logging system
        
        await backendAPI.debugConnection()
        
        await MainActor.run {
            debugOutput = capturedOutput.joined()
            isTestingConnection = false
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

struct EnvironmentPickerView: View {
    @ObservedObject var backendAPI: BackendAPI
    
    var body: some View {
        Picker("Environment", selection: Binding(
            get: { backendAPI.currentEnvironment },
            set: { backendAPI.switchEnvironment($0) }
        )) {
            ForEach(Environment.allCases, id: \.self) { environment in
                Text(environment.displayName).tag(environment)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
} 