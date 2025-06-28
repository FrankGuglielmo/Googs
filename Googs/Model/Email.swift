//
//  Email.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct Email: Identifiable {
    var id = UUID()
    var backendId: Int? // Backend email ID for API calls
    var sender: String
    var subject: String
    var preview: String
    var content: String
    var timestamp: Date
    var isStarred: Bool
    var priority: Priority
    var category: Category
    var hasAttachments: Bool
    var attachmentCount: Int
    var isRead: Bool
    
    enum Priority: String, CaseIterable {
        case high = "High Priority"
        case low = "Low Priority"
        case normal = "Normal"
        case promotional = "Promotional"
        
        var color: Color {
            switch self {
            case .high:
                return Color(hex: "E25A5A") // Red color for high priority
            case .low:
                return Color(hex: "5C92FF") // Blue color for low priority
            case .normal:
                return Color(hex: "8E8E93") // Gray for normal
            case .promotional:
                return Color(hex: "E6B93F") // Yellow/gold for promotional
            }
        }
    }
    
    enum Category: String, CaseIterable {
        case work = "Work"
        case personal = "Personal"
        
        var color: Color {
            switch self {
            case .work:
                return Color(hex: "9F6FFF") // Purple for work
            case .personal:
                return Color(hex: "4CD964") // Green for personal
            }
        }
    }
    
    // Returns a formatted string representing the time since the email was received
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Simplified time ago for list views (e.g., "6 days ago")
    var shortTimeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: timestamp, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}
