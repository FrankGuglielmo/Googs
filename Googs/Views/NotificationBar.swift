//
//  NotificationBar.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/11/25.
//

import SwiftUI
import RiveRuntime
import UserNotifications

struct NotificationBar: View {
    
    // MARK: - Rive Models
    let unmutedNotificationBell = RiveViewModel(
        fileName: "notificationBell",
        stateMachineName: "State Machine 1",
        artboardName: "unmutedBell"
    )
    
    let mutedNotificationBell = RiveViewModel(
        fileName: "notificationBell",
        stateMachineName: "State Machine 1",
        artboardName: "mutedBell"
    )
    
    // MARK: - State
    @State private var isShowingNotificationPrompt = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            Text("Get Only What You Need")
                .customFont(.largeTitle, modifiers: [.disregardsLightMode])
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            VStack(spacing: 24) {
                // Generic Email App Section
                HStack(spacing: 20) {
                    Image(systemName: "envelope")
                        .resizable()
                        .frame(width: 36, height: 28)
                        .foregroundStyle(.gray)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                    
                    Text("Your Current Email App")
                        .customFont(.callout, modifiers: [.disregardsDarkMode])
                    
                    Spacer()
                    
                    Button(action: { openNotificationSettings() }) {
                        unmutedNotificationBell.view()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 36, height: 36)
                }
                .padding()
                .background(Color.f1f0f5)
                .cornerRadius(20)
                
                // Googs App Section
                HStack(spacing: 20) {
                    Image(systemName: "figure")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.black)
                    
                    Text("Googs")
                        .customFont(.callout, modifiers: [.disregardsDarkMode])
                    
                    Spacer()
                    
                    Button(action: { openNotificationSettings() }) {
                        mutedNotificationBell.view()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 36, height: 36)
                }
                .padding()
                .background(Color.f1f0f5)
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            // Description Text
            Text("Turn off your current email notifications and enable notifications with Googs!")
                .customFont(.body, modifiers: [.disregardsLightMode])
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .padding(.horizontal, 20)
            
        }
        .padding()
        .padding(.bottom, 60)
        // No background is set here so that this view layers over your custom background.
        .onAppear { triggerBellAnimations() }
        // Alert that prompts the user to enable notifications if they declined the native prompt.
        .alert("Enable Notifications", isPresented: $isShowingNotificationPrompt) {
            Button("Open Settings") { openNotificationSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To stay up to date, please enable notifications for Googs in Settings.")
        }
    }
    
    // MARK: - Bell Animation and Notification Permission Logic
    func triggerBellAnimations() {
        // Trigger the "MUTE" animation on the unmuted bell.
        unmutedNotificationBell.triggerInput("MUTE")
        
        // Use Swift concurrency for a cleaner asynchronous flow.
        Task {
            // Wait for 1 second (adjust if needed)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            // Trigger the "UNMUTE" animation on the muted bell.
            mutedNotificationBell.triggerInput("UNMUTE")
            
            // Wait for the unmute animation to finish (assume another 1 second)
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            // Request notification authorization.
            requestNotificationAuthorization()
        }
    }
    
    /// Requests notification authorization. If the user declines, display an alert.
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    // If authorization is not granted, show the alert.
                    isShowingNotificationPrompt = true
                }
            }
        }
    }
    
    /// Opens the system settings for the current app.
    func openNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

struct NotificationBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.purple
            NotificationBar()
        }
    }
}
