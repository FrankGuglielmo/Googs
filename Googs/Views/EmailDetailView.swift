//
//  EmailDetailView.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct EmailDetailView: View {
    var email: Email
    var onBack: () -> Void
    
    init(email: Email, onBack: @escaping () -> Void) {
        self.email = email
        self.onBack = onBack
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        // Back button - positioned away from the universal menu button
                        Button(action: {
                            // Go back to previous view
                            onBack()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Actions
                        HStack(spacing: 24) {
                            Button(action: {}) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 18))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: email.isStarred ? "star.fill" : "star")
                                    .font(.system(size: 18))
                                    .foregroundColor(email.isStarred ? .yellow : .primary)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Subject
                    HStack {
                        Text(email.subject)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Metadata row
                        HStack(spacing: 8) {
                            // Priority badge
                            PriorityBadge(priority: email.priority)
                            
                            // Category badge
                            CategoryBadge(category: email.category)
                            
                            
                        }
                    }
                    
                    
                    
                    // Sender info
                    HStack(spacing: 12) {
                        // Sender avatar
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(email.sender.prefix(1)))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                            )
                        
                        // Sender details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(email.sender)
                                .font(.headline)
                            
                            Text("To: me")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Timestamp
                        Text(email.timeAgo)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    
                }
                    
        
                
                Divider()
                    
                
                // Email content
                VStack(alignment: .leading, spacing: 16) {
                    // Email body
                    Text(email.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Attachments section (if any)
                    if email.hasAttachments {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Attachments")
                                .font(.headline)
                            
                            ForEach(0..<email.attachmentCount, id: \.self) { index in
                                HStack {
                                    Image(systemName: "doc.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Attachment \(index + 1).pdf")
                                            .font(.subheadline)
                                        
                                        Text("125 KB")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "arrow.down.circle")
                                            .font(.system(size: 22))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(10)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
        .background(Color("Background").ignoresSafeArea())
    }
}

struct EmailDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EmailDetailView(
            email: mockEmails[0],
            onBack: {}
        )
    }
}
