//
//  ContentView.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-03-29.
//

import SwiftUI
import RiveRuntime

struct ContentView: View {
    @State var showProfileMenu = false
    @State var isOpen = false
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    var button = RiveViewModel(fileName: "menu_button", stateMachineName: "State Machine", autoPlay: false)
    
    var body: some View {
        ZStack {
            Color._17203a.ignoresSafeArea()
            
            SideMenu()
                .padding(.top, 50)
                .opacity(isOpen ? 1 : 0)
                .offset(x: isOpen ? 0 : -300)
                .rotation3DEffect(.degrees(isOpen ? 0 : 30), axis: (x: 0, y: 1, z: 0))
                .ignoresSafeArea(.all, edges: .top)
            
            HomeView()
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 104)
                }
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .rotation3DEffect(.degrees(isOpen ? 30 : 0), axis: (x: 0, y: -1, z: 0), perspective: 1)
                .offset(x: isOpen ? 265 : 0)
                .scaleEffect(isOpen ? 0.9 : 1)
                .scaleEffect(showProfileMenu ? 0.92 : 1)
                .ignoresSafeArea()
            
            TabBar()
                .offset(y: -24)
                .background(
                    LinearGradient(colors: [Color("Background").opacity(0), Color("Background")],
                                   startPoint: .top, endPoint: .bottom)
                        .frame(height: 150)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .allowsHitTesting(false)
                )
                .ignoresSafeArea()
                .offset(y: isOpen ? 300 : 0)
                .offset(y: showProfileMenu ? 200 : 0)
            
            button.view()
                .frame(width: 44, height: 44)
                .mask(Circle())
                .shadow(color: Color("Shadow").opacity(0.2), radius: 5, x: 0, y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .offset(x: isOpen ? 216 : 0)
                .onTapGesture {
                    button.setInput("isOpen", value: isOpen)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isOpen.toggle()
                    }
                }
                // Removed onChange block that used the deprecated API
            
            // Profile Button
            Button(action: {
                withAnimation(.spring()) {
                    showProfileMenu.toggle()
                }
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
            .offset(x: isOpen ? 100 : 0)
            
            // Profile Menu
            if showProfileMenu {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile")
                        .font(.title.bold())
                        .padding(.bottom, 8)
                    
                    Divider()
                    
                    Button(action: {
                        // Sign out action
                        isSignedIn = false
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
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        // Use SwiftUI's preferredColorScheme modifier to set the status bar style automatically.
        .preferredColorScheme(isOpen ? .dark : .light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
