//
//  HomeView.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-04-13.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewStateManager: ViewStateManager
    @State private var isShowingProfieMenu = false // Add a state for any bindings that might be needed
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            ScrollView {
                content
            }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Dashboard")
                .customFont(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            
            VStack(spacing: 0) {
                Text("Chats")
                    .customFont(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(courses) { course in
                            VCard(course: course)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            
            
            HStack {
                Text("Emails")
                    .customFont(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                
                
            Button(action: {
                viewStateManager.navigateTo(.emails)
            }) {
                Text("View All")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.trailing, 20)
            }
            }
            .padding(.vertical, 10)
            
            // Explicitly provide the view state manager to prevent parameter mismatch errors
            DashboardEmailList(viewStateManager: viewStateManager)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewStateManager: ViewStateManager())
    }
}
