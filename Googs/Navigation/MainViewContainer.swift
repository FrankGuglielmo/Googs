//
//  MainViewContainer.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI
import RiveRuntime

/// Main container view that handles top-level view switching and persistent UI elements
struct MainViewContainer: View {
    // Current main view state
    @State private var currentMainView: ViewType = .home
    
    // Menu state
    @State private var isMenuOpen = false
    @State private var showProfileMenu = false
    
    // Navigation path management
    @State private var pathStore = PathStore()
    
    // Rive animation state
    var button = RiveViewModel(fileName: "menu_button", stateMachineName: "State Machine", autoPlay: false)
    
    // Auth state
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // Sign-in state
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    
    // Helper computed property
    private var isShowingEmailDetail: Bool {
        if case .emailDetail = currentMainView { return true }
        return false
    }
    
    var body: some View {
        NavigationStack(path: $pathStore.path) {
            ZStack {
                // Background
                Color._17203a.ignoresSafeArea()
                
                // Side Menu - Always present but conditionally visible
                SideMenu(
                    currentMainView: $currentMainView,
                    isMenuOpen: $isMenuOpen,
                    showProfileMenu: $showProfileMenu
                )
                .environmentObject(authViewModel)
//                .padding(.top, 50)
//                .opacity(isMenuOpen ? 1 : 0)
//                .offset(x: isMenuOpen ? 0 : -300)
//                .rotation3DEffect(.degrees(isMenuOpen ? 0 : 30), axis: (x: 0, y: 1, z: 0))
//                .ignoresSafeArea(.all, edges: .top)
                
                // Main Content Area - This will change based on currentMainView
                currentView
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 80)
                    }
                    .safeAreaInset(edge: .top) {
                        Color.clear.frame(height: 104)
                    }
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .rotation3DEffect(.degrees(isMenuOpen ? 30 : 0), axis: (x: 0, y: -1, z: 0), perspective: 1)
                    .offset(x: isMenuOpen ? 265 : 0)
                    .scaleEffect(isMenuOpen ? 0.9 : 1)
                    .scaleEffect(showProfileMenu ? 0.92 : 1)
                    .ignoresSafeArea()
                    .onChange(of: isMenuOpen) { _, newValue in
                        button.setInput("isOpen", value: !isMenuOpen)
                    }
                
                // Menu Button - Always accessible
                button.view()
                    .frame(width: 44, height: 44)
                    .mask(Circle())
                    .shadow(color: Color("Shadow").opacity(0.2), radius: 5, x: 0, y: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                    .offset(x: isMenuOpen ? 216 : 0)
                    .onTapGesture {
                        // Set animation state before toggling menu
                        toggleMenu()
                        button.setInput("isOpen", value: !isMenuOpen)
                    }
                    .opacity(isShowingEmailDetail ? 0 : 1)
                
                // Profile Button - Always accessible
                Button(action: {
                    toggleProfileMenu()
                }) {
                    Image(systemName: "person")
                        .frame(width: 36, height: 36)
                        .background(.white)
                        .mask(Circle())
                        .shadow(color: Color("Shadow").opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
                .offset(y: 4)
                .offset(x: isMenuOpen ? 100 : 0)
                
                // Profile Menu
                if showProfileMenu {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profile")
                            .font(.title.bold())
                            .padding(.bottom, 8)
                        
                        Divider()
                        
                        Button(action: {
                            // Sign out action
                            authViewModel.signOut()
                            showProfileMenu = false
                        }) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.red)
                        }
                        .padding(.vertical, 8)
                        
                        Spacer()
                    }
                    .padding(20)
                    .frame(width: 220)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                    .zIndex(1)
                }
            }
            .preferredColorScheme(isMenuOpen ? .dark : .light)
            .navigationDestination(for: ViewType.self) { viewType in
                switch viewType {
                case .emailDetail(let email):
                    EmailDetailView(
                        email: email,
                        onBack: {
                            pathStore.navigateBack()
                        }
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // This computed property returns the appropriate view based on currentMainView
    @ViewBuilder
    private var currentView: some View {
        switch currentMainView {
        case .home:
            HomeView(
                onNavigateToEmails: { switchMainView(to: .emails) },
                onNavigateToEmailDetail: { email in
                    pathStore.navigateTo(.emailDetail(email))
                }
            )
        case .emails:
            EmailListView(
                onNavigateToSearch: { switchMainView(to: .search) },
                onNavigateToEmailDetail: { email in
                    pathStore.navigateTo(.emailDetail(email))
                }
            )
        case .search:
            PlaceholderView(title: "Search")
        case .favorites:
            PlaceholderView(title: "Favorites")
        case .help:
            PlaceholderView(title: "Help")
        case .history:
            PlaceholderView(title: "History")
        case .notifications:
            PlaceholderView(title: "Notifications")
        case .settings:
            PlaceholderView(title: "Settings")
        case .emailDetail(let email):
            EmailDetailView(
                email: email,
                onBack: {
                    pathStore.navigateBack()
                }
            )
        }
    }
    
    // Switch to a different main view
    private func switchMainView(to viewType: ViewType) {
        if viewType.isMainView {
            // Set the new view immediately
            currentMainView = viewType
            
            // Close menus with animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                closeMenus()
            }
        }
    }
    
    // Toggle the side menu
    private func toggleMenu() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isMenuOpen.toggle()
            
            // Close profile menu if opening side menu
            if isMenuOpen {
                showProfileMenu = false
            }
        }
    }
    
    // Toggle the profile menu
    private func toggleProfileMenu() {
        withAnimation(.spring()) {
            showProfileMenu.toggle()
            
            // Close side menu if opening profile menu
            if showProfileMenu {
                isMenuOpen = false
            }
        }
    }
    
    // Close both menus
    private func closeMenus() {
        isMenuOpen = false
        showProfileMenu = false
    }
}

struct MainViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
