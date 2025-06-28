//
//  MockEmails.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

// Mock email data for testing and development
let mockEmails = [
    Email(
        backendId: 1,
        sender: "Jane Smith",
        subject: "Project Proposal",
        preview: "Hello,",
        content: "Hello,\n\nI've attached the project proposal for your review. Please let me know if you have any questions or need any clarification.\n\nBest regards,\nJane",
        timestamp: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
        isStarred: true,
        priority: .high,
        category: .work,
        hasAttachments: true,
        attachmentCount: 1,
        isRead: false
    ),
    Email(
        backendId: 2,
        sender: "Mike Johnson",
        subject: "Lunch next week?",
        preview: "Hey,",
        content: "Hey,\n\nWould you be available for lunch next week? I was thinking Tuesday or Wednesday around noon. Let me know what works for you!\n\nCheers,\nMike",
        timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
        isStarred: false,
        priority: .low,
        category: .personal,
        hasAttachments: false,
        attachmentCount: 0,
        isRead: true
    ),
    Email(
        backendId: 3,
        sender: "Sarah Williams",
        subject: "Quarterly Report",
        preview: "Hi,",
        content: "Hi,\n\nAttached is the quarterly report for Q1. Please review it before our meeting on Friday.\n\nRegards,\nSarah",
        timestamp: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
        isStarred: false,
        priority: .high,
        category: .work,
        hasAttachments: true,
        attachmentCount: 1,
        isRead: true
    ),
    Email(
        backendId: 4,
        sender: "Alex Brown",
        subject: "New Product Launch",
        preview: "Team,",
        content: "Team,\n\nI'm excited to announce that we're launching our new product next month. There will be a planning meeting on Monday to discuss the marketing strategy.\n\nLet me know if you have any ideas or suggestions.\n\nBest,\nAlex",
        timestamp: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
        isStarred: true,
        priority: .promotional,
        category: .work,
        hasAttachments: false,
        attachmentCount: 0,
        isRead: true
    ),
    Email(
        backendId: 5,
        sender: "Lisa Chen",
        subject: "Weekend Getaway Plans",
        preview: "Hi there,",
        content: "Hi there,\n\nI'm planning a weekend getaway to the mountains next month. Would you be interested in joining? It would be a great opportunity to relax and recharge.\n\nLet me know your thoughts!\n\nLisa",
        timestamp: Calendar.current.date(byAdding: .day, value: -9, to: Date()) ?? Date(),
        isStarred: false,
        priority: .normal,
        category: .personal,
        hasAttachments: false,
        attachmentCount: 0,
        isRead: true
    ),
    Email(
        backendId: 6,
        sender: "David Wilson",
        subject: "Budget Approval Request",
        preview: "Hello Team,",
        content: "Hello Team,\n\nI need approval for the marketing budget for next quarter. I've attached the breakdown of expenses and projected ROI.\n\nPlease review and get back to me by the end of the week.\n\nRegards,\nDavid",
        timestamp: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
        isStarred: false,
        priority: .high,
        category: .work,
        hasAttachments: true,
        attachmentCount: 2,
        isRead: true
    )
]

// Convenience function to get the most important emails
func getImportantEmails(count: Int = 3) -> [Email] {
    // Sort by priority (high first) and then by timestamp (recent first)
    let sorted = mockEmails.sorted { 
        if $0.priority == .high && $1.priority != .high {
            return true
        } else if $0.priority != .high && $1.priority == .high {
            return false
        } else {
            return $0.timestamp > $1.timestamp
        }
    }
    
    // Return the specified number of emails
    return Array(sorted.prefix(count))
}
