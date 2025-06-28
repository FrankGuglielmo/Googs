import SwiftUI

struct EnvironmentSettingsView: View {
    @StateObject private var backendAPI = BackendAPI.shared
    @StateObject private var environmentManager = EnvironmentManager.shared
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Current Environment Section
                Section(header: Text("Current Environment")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(environmentManager.currentEnvironment.displayName)
                                .font(.headline)
                            Text(environmentManager.getCurrentBaseURL())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Environment indicator
                        Circle()
                            .fill(environmentManager.isLocalEnvironment() ? Color.green : Color.blue)
                            .frame(width: 12, height: 12)
                    }
                    .padding(.vertical, 4)
                }
                
                // Environment Selection Section
                Section(header: Text("Switch Environment")) {
                    ForEach(Environment.allCases, id: \.self) { environment in
                        Button(action: {
                            switchEnvironment(environment)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(environment.displayName)
                                        .foregroundColor(.primary)
                                    Text(environment.baseURL)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if environmentManager.currentEnvironment == environment {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Connection Test Section
                Section(header: Text("Connection Test")) {
                    Button(action: testConnection) {
                        HStack {
                            Image(systemName: "network")
                            Text("Test Connection")
                            Spacer()
                            if isTestingConnection {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isTestingConnection)
                    
                    if let result = connectionTestResult {
                        HStack {
                            Image(systemName: result.contains("✅") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(result.contains("✅") ? .green : .red)
                            Text(result)
                                .font(.caption)
                        }
                    }
                }
                
                // Environment Info Section
                Section(header: Text("Environment Information")) {
                    InfoRow(title: "Base URL", value: environmentManager.getCurrentBaseURL())
                    InfoRow(title: "Environment Type", value: environmentManager.isLocalEnvironment() ? "Local Development" : "Production")
                    InfoRow(title: "Authentication Status", value: backendAPI.isAuthenticated ? "Authenticated" : "Not Authenticated")
                }
                
                // Development Tools Section (only show in DEBUG)
                #if DEBUG
                Section(header: Text("Development Tools")) {
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .foregroundColor(.red)
                    
                    Button("Reset to Local Environment") {
                        resetToLocal()
                    }
                    .foregroundColor(.orange)
                }
                #endif
            }
            .navigationTitle("Environment Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Environment Switch", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func switchEnvironment(_ environment: Environment) {
        Task {
            await MainActor.run {
                environmentManager.switchEnvironment(environment)
                alertMessage = "Switched to \(environment.displayName). Authentication has been cleared for security."
                showingAlert = true
            }
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        connectionTestResult = nil
        
        Task {
            do {
                let isConnected = try await backendAPI.testConnection()
                await MainActor.run {
                    isTestingConnection = false
                    if isConnected {
                        connectionTestResult = "✅ Connected successfully to \(environmentManager.currentEnvironment.displayName)"
                    } else {
                        connectionTestResult = "❌ Failed to connect to \(environmentManager.currentEnvironment.displayName)"
                    }
                }
            } catch {
                await MainActor.run {
                    isTestingConnection = false
                    connectionTestResult = "❌ Connection error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func clearAllData() {
        Task {
            await backendAPI.signOut()
            UserDefaults.standard.removeObject(forKey: "selectedEnvironment")
            await MainActor.run {
                alertMessage = "All data cleared. App will restart with default settings."
                showingAlert = true
            }
        }
    }
    
    private func resetToLocal() {
        Task {
            await backendAPI.signOut()
            environmentManager.switchEnvironment(.local)
            await MainActor.run {
                alertMessage = "Reset to local environment. Authentication cleared."
                showingAlert = true
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

#Preview {
    EnvironmentSettingsView()
} 