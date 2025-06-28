//
//  SideMenu.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-04-20.
//

import SwiftUI
import RiveRuntime

struct SideMenu: View {
    @State var isDarkMode = false
    @State var selectedMenu: SelectedMenu = .home
    @Binding var currentMainView: ViewType
    @Binding var isMenuOpen: Bool
    @Binding var showProfileMenu: Bool
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // Update selected menu when view changes from outside the menu
    private func updateSelectedMenuFromView() {
        selectedMenu = viewTypeToSelectedMenu(currentMainView)
    }
    
    // Convert ViewType to SelectedMenu
    private func viewTypeToSelectedMenu(_ viewType: ViewType) -> SelectedMenu {
        switch viewType {
        case .home:
            return .home
        case .emails:
            return .emails
        case .search:
            return .search
        case .favorites:
            return .favorites
        case .help:
            return .help
        case .history:
            return .history
        case .notifications:
            return .notifications
        case .settings:
            return .environment // Map settings to environment for menu highlighting
        case .emailDetail:
            return .emails // Map email detail to emails section for menu highlighting
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // User avatar
                if let photoURL = authViewModel.currentUser?.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                        .padding(12)
                        .background(.white.opacity(0.2))
                        .mask(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // User display name
                    if let displayName = authViewModel.currentUser?.displayName, !displayName.isEmpty {
                        Text(displayName)
                    } else if let email = authViewModel.currentUser?.email, !email.isEmpty {
                        Text(email.components(separatedBy: "@").first ?? email)
                    } else {
                        Text("User")
                    }
                    
                    // User email or role
                    if let email = authViewModel.currentUser?.email, !email.isEmpty {
                        Text(email)
                            .font(.subheadline)
                            .opacity(0.7)
                    } else {
                        Text("Guest User")
                            .font(.subheadline)
                            .opacity(0.7)
                    }
                }
                Spacer()
            }
            .padding()
            
            Text("BROWSE")
                .font(.subheadline).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .opacity(0.7)
            
            browse
            
            Text("HISTORY")
                .font(.subheadline).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .opacity(0.7)
            
            history
            
            Spacer()
            
            HStack(spacing: 14) {
                menuItems3[0].icon.view()
                    .frame(width: 32, height: 32)
                    .opacity(0.6)
                    .onChange(of: isDarkMode) { _, newValue in
                        if newValue {
                            menuItems3[0].icon.setInput("active", value: true)
                        } else {
                            menuItems3[0].icon.setInput("active", value: false)
                        }
                    }
                Text(menuItems3[0].text)
                
                Toggle("", isOn: $isDarkMode)
            }
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(8)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: 288, maxHeight: .infinity)
        .background(Color(hex: "17203A"))
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(hex: "17203A").opacity(0.3), radius: 40, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            // Set initial selected menu based on current view
            updateSelectedMenuFromView()
        }
        .onChange(of: currentMainView) { _, newView in
            // Update selected menu when view changes
            updateSelectedMenuFromView()
        }
    }
    
    var browse: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(menuItems) { item in
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.1)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 14) {
                    item.icon.view()
                        .frame(width: 32, height: 32)
                        .opacity(0.6)
                    Text(item.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(maxWidth: selectedMenu == item.menu ? .infinity : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .onTapGesture {

                    selectedMenu = item.menu
                    
            
                    handleNavigation(for: item.menu)
                    
                    
                }
                
                
                
                
                
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
    
    var history: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(menuItems2) { item in
                Rectangle()
                    .frame(height: 1)
                    .opacity(0.1)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 14) {
                    item.icon.view()
                        .frame(width: 32, height: 32)
                        .opacity(0.6)
                    Text(item.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(maxWidth: selectedMenu == item.menu ? .infinity : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .background(Color("Background 2"))
                .onTapGesture {

                        selectedMenu = item.menu
                    

                        handleNavigation(for: item.menu)
                    
                }
                
                
                
                
                
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
    }
    
    // Handle navigation based on selected menu
    private func handleNavigation(for menuItem: SelectedMenu) {
        // Navigate based on menu selection
        switch menuItem {
        case .home:
            switchMainView(to: .home)
        case .emails:
            switchMainView(to: .emails)
        case .search:
            switchMainView(to: .search)
        case .favorites:
            switchMainView(to: .favorites)
        case .help:
            switchMainView(to: .help)
        case .history:
            switchMainView(to: .history)
        case .notifications:
            switchMainView(to: .notifications)
        case .environment:
            switchMainView(to: .settings)
        case .darkmode:
            // Dark mode toggle doesn't need navigation
            break
        }
    }
    
    // Switch to a different main view
    private func switchMainView(to viewType: ViewType) {
        // Set the new view immediately
        currentMainView = viewType
        
        // Close menus with animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isMenuOpen = false
            showProfileMenu = false
        }
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(
            currentMainView: .constant(.home),
            isMenuOpen: .constant(true),
            showProfileMenu: .constant(false)
        )
    }
}

struct MenuItem: Identifiable {
    var id = UUID()
    var text: String
    var icon: RiveViewModel
    var menu: SelectedMenu
}

var menuItems = [
    MenuItem(text: "Home", icon: RiveViewModel(fileName: "icons", stateMachineName: "HOME_interactivity", artboardName: "HOME"), menu: .home),
    MenuItem(text: "Emails", icon: RiveViewModel(fileName: "icons", stateMachineName: "CHAT_Interactivity", artboardName: "CHAT"), menu: .emails),
    MenuItem(text: "Search", icon: RiveViewModel(fileName: "icons", stateMachineName: "SEARCH_Interactivity", artboardName: "SEARCH"), menu: .search),
    MenuItem(text: "Favorites", icon: RiveViewModel(fileName: "icons", stateMachineName: "STAR_Interactivity", artboardName: "LIKE/STAR"), menu: .favorites),
    MenuItem(text: "Help", icon: RiveViewModel(fileName: "icons", stateMachineName: "CHAT_Interactivity", artboardName: "CHAT"), menu: .help)
]

var menuItems2 = [
    MenuItem(text: "History", icon: RiveViewModel(fileName: "icons", stateMachineName: "TIMER_Interactivity", artboardName: "TIMER"), menu: .history),
    MenuItem(text: "Notifications", icon: RiveViewModel(fileName: "icons", stateMachineName: "BELL_Interactivity", artboardName: "BELL"), menu: .notifications),
    MenuItem(text: "Environment", icon: RiveViewModel(fileName: "icons", stateMachineName: "SETTINGS_Interactivity", artboardName: "SETTINGS"), menu: .environment)
]

var menuItems3 = [
    MenuItem(text: "Dark Mode", icon: RiveViewModel(fileName: "icons", stateMachineName: "SETTINGS_Interactivity", artboardName: "SETTINGS"), menu: .darkmode)
]

enum SelectedMenu: String {
    case home
    case search
    case favorites
    case help
    case history
    case notifications
    case darkmode
    case emails
    case environment
}
