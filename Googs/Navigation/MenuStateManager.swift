//
//  MenuStateManager.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

/// Manages the state of the menu across the app
class MenuStateManager: ObservableObject {
    @Binding var isOpen: Bool
    @Binding var showProfileMenu: Bool
    
    init(isOpen: Binding<Bool>, showProfileMenu: Binding<Bool>) {
        self._isOpen = isOpen
        self._showProfileMenu = showProfileMenu
    }
    
    /// Toggle the side menu open/closed state
    func toggleMenu() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isOpen.toggle()
        }
    }
    
    /// Toggle the profile menu open/closed state
    func toggleProfileMenu() {
        withAnimation(.spring()) {
            showProfileMenu.toggle()
        }
    }
    
    /// Close both menus
    func closeMenus() {
        isOpen = false
        showProfileMenu = false
    }
}
