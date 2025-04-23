//
//  EmailListView.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct EmailListView: View {
    @State private var emails = mockEmails
    var onNavigateToSearch: () -> Void
    var onNavigateToEmailDetail: (Email) -> Void
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            ScrollView {
                content
            }
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(emails) { email in
                        VStack(spacing: 0) {
                            EmailListItem(email: email) {
                                // Navigate to email detail view
                                onNavigateToEmailDetail(email)
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
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
            onNavigateToSearch: {},
            onNavigateToEmailDetail: { _ in }
        )
    }
}
