//
//  PlaceholderView.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

/// A placeholder view for screens that haven't been implemented yet
struct PlaceholderView: View {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header section - matched to dashboard layout
                Text(title)
                    .customFont(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                Spacer()
                
                // Special case for notifications - show FCM test
                if title.lowercased() == "notifications" {
                    VStack(spacing: 24) {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 72))
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("FCM Test Available")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Test your Firebase Cloud Messaging setup")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                        
                        NavigationLink(destination: FCMTestView()) {
                            Text("Open FCM Test")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Default placeholder content
                    VStack(spacing: 24) {
                        Image(systemName: "hammer.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("\(title) View")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("This feature is coming soon!")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView(title: "Example")
    }
}
