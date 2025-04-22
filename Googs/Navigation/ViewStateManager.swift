//
//  ViewStateManager.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

/// Manages the top-level view state and navigation throughout the app
class ViewStateManager: ObservableObject {
    @Published private(set) var stack: [ViewType] = [.home]
    
    /// the currently visible screen is always the top of the stack
    var currentViewType: ViewType {
        stack.last ?? .home
    }
    
    
    // Menu state
    @Published var isMenuOpen = false
    @Published var showProfileMenu = false
    
    var isShowingEmailDetail: Bool {
        if case .emailDetail = currentViewType { return true }
        return false
    }
    
    /// Navigate to a main view
    func navigateTo(_ viewType: ViewType) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if viewType.isMainView {
                // atomically replace the stack
                stack = [ viewType ]
            } else {
                stack.append(viewType)
            }
            // Close both menus too
            isMenuOpen = false
            showProfileMenu = false
        }
    }
    
    func showEmailDetailView(_ viewType: ViewType){
        if viewType.isMainView {
            // atomically replace the stack
            stack = [ viewType ]
        } else {
            stack.append(viewType)
        }
        // Close both menus too
        isMenuOpen = false
        showProfileMenu = false
    }
    
    
    /// Go back to previous view in the navigation path
    func navigateBack() {
        
        if stack.count > 1 {
            stack.removeLast()
        }
        
    }
    
    /// Toggle the side menu open/closed state
    func toggleMenu() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isMenuOpen.toggle()
            
            // Close profile menu if opening side menu
            if isMenuOpen {
                showProfileMenu = false
            }
        }
    }
    
    /// Toggle the profile menu open/closed state
    func toggleProfileMenu() {
        withAnimation(.spring()) {
            showProfileMenu.toggle()
            
            // Close side menu if opening profile menu
            if showProfileMenu {
                isMenuOpen = false
            }
        }
    }
    
    /// Close both menus
    func closeMenus() {
        
        isMenuOpen = false
        showProfileMenu = false
        
    }
}
