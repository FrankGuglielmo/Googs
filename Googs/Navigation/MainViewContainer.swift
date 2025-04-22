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
    @StateObject private var viewStateManager = ViewStateManager()
    var button = RiveViewModel(fileName: "menu_button", stateMachineName: "State Machine", autoPlay: false)
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    
    var body: some View {
        ZStack {
            // Background
            Color._17203a.ignoresSafeArea()
            
            // Side Menu - Always present but conditionally visible
            SideMenu(viewStateManager: viewStateManager)
                .padding(.top, 50)
                .opacity(viewStateManager.isMenuOpen ? 1 : 0)
                .offset(x: viewStateManager.isMenuOpen ? 0 : -300)
                .rotation3DEffect(.degrees(viewStateManager.isMenuOpen ? 0 : 30), axis: (x: 0, y: 1, z: 0))
                .ignoresSafeArea(.all, edges: .top)
            
            // Main Content Area - This will change based on currentViewType
            currentView
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 104)
                }
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .rotation3DEffect(.degrees(viewStateManager.isMenuOpen ? 30 : 0), axis: (x: 0, y: -1, z: 0), perspective: 1)
                .offset(x: viewStateManager.isMenuOpen ? 265 : 0)
                .scaleEffect(viewStateManager.isMenuOpen ? 0.9 : 1)
                .scaleEffect(viewStateManager.showProfileMenu ? 0.92 : 1)
                .ignoresSafeArea()
                .onChange(of: viewStateManager.isMenuOpen) { _, newValue in
                    button.setInput("isOpen", value: !viewStateManager.isMenuOpen)
                }
            
            // Tab Bar
//            TabBar()
//                .offset(y: -24)
//                .background(
//                    LinearGradient(colors: [Color("Background").opacity(0), Color("Background")],
//                                   startPoint: .top, endPoint: .bottom)
//                    .frame(height: 150)
//                    .frame(maxHeight: .infinity, alignment: .bottom)
//                    .allowsHitTesting(false)
//                )
//                .ignoresSafeArea()
//                .offset(y: viewStateManager.isMenuOpen ? 300 : 0)
//                .offset(y: viewStateManager.showProfileMenu ? 200 : 0)
            
            // Menu Button - Always accessible
            button.view()
                .frame(width: 44, height: 44)
                .mask(Circle())
                .shadow(color: Color("Shadow").opacity(0.2), radius: 5, x: 0, y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .offset(x: viewStateManager.isMenuOpen ? 216 : 0)
                .onTapGesture {
                    // Set animation state before toggling menu
                    viewStateManager.toggleMenu()
                    button.setInput("isOpen", value: !viewStateManager.isMenuOpen)
                }
              .opacity(viewStateManager.isShowingEmailDetail ? 0 : 1)
            
            // Profile Button - Always accessible
            Button(action: {
                viewStateManager.toggleProfileMenu()
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
            .offset(x: viewStateManager.isMenuOpen ? 100 : 0)
            
            // Profile Menu
            if viewStateManager.showProfileMenu {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile")
                        .font(.title.bold())
                        .padding(.bottom, 8)
                    
                    Divider()
                    
                    Button(action: {
                        // Sign out action
                        isSignedIn = false
                        viewStateManager.showProfileMenu = false
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
        .preferredColorScheme(viewStateManager.isMenuOpen ? .dark : .light)
    }
    
    // This computed property returns the appropriate view based on currentViewType
    @ViewBuilder
    private var currentView: some View {
        switch viewStateManager.currentViewType {
        case .home:
            HomeView(viewStateManager: viewStateManager)
        case .emails:
              EmailListView(viewStateManager: viewStateManager)
        case .search:
            PlaceholderView(title: "Search", viewStateManager: viewStateManager)
        case .favorites:
            PlaceholderView(title: "Favorites", viewStateManager: viewStateManager)
        case .help:
            PlaceholderView(title: "Help", viewStateManager: viewStateManager)
        case .history:
            PlaceholderView(title: "History", viewStateManager: viewStateManager)
        case .notifications:
            PlaceholderView(title: "Notifications", viewStateManager: viewStateManager)
        case .settings:
            PlaceholderView(title: "Settings", viewStateManager: viewStateManager)
        case .emailDetail(let email):
          EmailDetailView(email: email, viewStateManager: viewStateManager)
            
        }
    }
}

struct MainViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContainer()
    }
}
