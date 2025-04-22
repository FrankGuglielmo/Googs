//
//  ViewType.swift
//  Googs
//
//  Created on 2025-04-18.
//

import Foundation

/// Navigation destination types for the app
enum ViewType: Hashable {
    // Main views (top level)
    case home
    case emails
    case search
    case favorites
    case help
    case history
    case notifications
    case settings
    
    // Detail views (second level)
    case emailDetail(Email)
    
    /// Helper property to determine if this is a main view
    var isMainView: Bool {
        switch self {
        case .home, .emails, .search, .favorites, .help, .history, .notifications, .settings:
            return true
        case .emailDetail:
            return false
        }
    }
    
    // Implement Hashable manually for the case with associated value
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(0)
        case .emails:
            hasher.combine(1)
        case .emailDetail(let email):
            hasher.combine(2)
            hasher.combine(email.id)
        case .search:
            hasher.combine(3)
        case .favorites:
            hasher.combine(4)
        case .help:
            hasher.combine(5)
        case .history:
            hasher.combine(6)
        case .notifications:
            hasher.combine(7)
        case .settings:
            hasher.combine(8)
        }
    }
    
    static func == (lhs: ViewType, rhs: ViewType) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.emails, .emails):
            return true
        case (.emailDetail(let email1), .emailDetail(let email2)):
            return email1.id == email2.id
        case (.search, .search):
            return true
        case (.favorites, .favorites):
            return true
        case (.help, .help):
            return true
        case (.history, .history):
            return true
        case (.notifications, .notifications):
            return true
        case (.settings, .settings):
            return true
        default:
            return false
        }
    }
}
