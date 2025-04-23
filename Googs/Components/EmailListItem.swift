//
//  EmailListItem.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct EmailListItem: View {
    var email: Email
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Star icon
                Image(systemName: email.isStarred ? "star.fill" : "star")
                    .foregroundColor(email.isStarred ? .yellow : .gray)
                    .font(.system(size: 20))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        // Sender name
                        Text(email.sender)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        PriorityBadge(priority: email.priority)
                        
                        // Category badge
                        CategoryBadge(category: email.category)
                        
                    }
                    
                    // Subject
                    HStack {
                        Text(email.subject)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                        
                        // Timestamp
                        Text(email.shortTimeAgo)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Preview
                    Text(email.preview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
//                    HStack(spacing: 8) {
//                        // Priority badge
//                        
//                        
//                        Spacer()
//                        
//                        // Attachment indicator
//                        if email.hasAttachments {
//                            HStack(spacing: 4) {
//                                Image(systemName: "paperclip")
//                                    .font(.system(size: 12))
//                                    .foregroundStyle(.red)
//                                
//                                Text("\(email.attachmentCount) attachment\(email.attachmentCount > 1 ? "s" : "")")
//                                    .font(.system(size: 12))
//                                    .foregroundStyle(.red)
//                            }
//                            .foregroundColor(.secondary)
//                        }
//                    }
                }
            }
            .padding(12)
            .contentShape(Rectangle())
            .background(email.isRead ? Color.clear : Color.blue.opacity(0.1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Badge for priority level
struct PriorityBadge: View {
    var priority: Email.Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(priority.color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

// Badge for category
struct CategoryBadge: View {
    var category: Email.Category
    
    var body: some View {
        Text(category.rawValue)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(category.color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct EmailListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmailListItem(email: mockEmails[0], onTap: {})
            EmailListItem(email: mockEmails[1], onTap: {})
            EmailListItem(email: mockEmails[2], onTap: {})
        }
        .previewLayout(.sizeThatFits)
    }
}
