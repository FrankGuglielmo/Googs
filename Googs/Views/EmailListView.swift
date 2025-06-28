//
//  EmailListView.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct EmailListView: View {
    @ObservedObject var emailViewModel: EmailViewModel
    var onNavigateToSearch: () -> Void
    var onNavigateToEmailDetail: (Email) -> Void
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            ScrollView {
                content
            }
        }
        .task {
            // Small delay to ensure view is fully initialized
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await emailViewModel.loadEmails()
        }
        .refreshable {
            await emailViewModel.loadEmails()
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section - matched to dashboard layout
            HStack {
                Text("Emails")
                    .customFont(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                
                // Debug button (temporary)
                Button(action: {
                    let token = BackendAPI.shared.getCurrentAccessToken()
                    print("Current Access Token: \(token ?? "No token")")
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(10)
                }
                
                // Search button
                Button(action: {
                    // Action for search
                    onNavigateToSearch()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .padding(20)
                }
            }
            
            // Filter tabs (future enhancement)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    FilterTab(title: "All", isActive: true)
                    FilterTab(title: "Unread", isActive: false)
                    FilterTab(title: "Starred", isActive: false)
                    FilterTab(title: "Work", isActive: false)
                    FilterTab(title: "Personal", isActive: false)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            
            // Email list
            if emailViewModel.isLoading && emailViewModel.emails.isEmpty {
                // Loading state
                VStack {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Text("Loading emails...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if let errorMessage = emailViewModel.errorMessage, !emailViewModel.isLoading, emailViewModel.emails.isEmpty {
                // Error state (only show if not loading and no emails)
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                        .padding()
                    Text("Error loading emails")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Retry") {
                        Task {
                            await emailViewModel.loadEmails()
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if emailViewModel.emails.isEmpty {
                // Empty state
                VStack {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                        .padding()
                    Text("No emails yet")
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text("Your emails will appear here once you're signed in")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else {
                // Email list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(emailViewModel.emails) { email in
                            VStack(spacing: 0) {
                                EmailListItem(email: email) {
                                    // Mark as read when tapped
                                    if let backendId = email.backendId {
                                        Task {
                                            await emailViewModel.markAsRead(emailId: backendId, isRead: true)
                                        }
                                    }
                                    // Navigate to email detail view
                                    onNavigateToEmailDetail(email)
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                        
                        // Load more button
                        if emailViewModel.hasMoreEmails {
                            Button(action: {
                                Task {
                                    await emailViewModel.loadMoreEmails()
                                }
                            }) {
                                HStack {
                                    if emailViewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.down.circle")
                                    }
                                    Text(emailViewModel.isLoading ? "Loading..." : "Load More")
                                }
                                .foregroundColor(.blue)
                                .padding()
                            }
                            .disabled(emailViewModel.isLoading)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// Filter tab component
struct FilterTab: View {
    var title: String
    var isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(isActive ? .semibold : .medium)
            .foregroundColor(isActive ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.blue : Color.secondary.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct EmailListView_Previews: PreviewProvider {
    static var previews: some View {
        EmailListView(
                      emailViewModel: EmailViewModel(),
                      onNavigateToSearch: {},
                      onNavigateToEmailDetail: { _ in }
                  )
    }
}
