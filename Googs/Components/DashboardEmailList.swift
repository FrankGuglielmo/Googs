//
//  DashboardEmailList.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct DashboardEmailList: View {
    @State private var importantEmails = getImportantEmails(count: 3)
    @ObservedObject var viewStateManager: ViewStateManager
    
    // Function to navigate to email list
    func navigateToEmailList() {
        viewStateManager.navigateTo(.emails)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Email list container
            VStack(spacing: 0) {
                ForEach(importantEmails) { email in
                    VStack(spacing: 0) {
                        EmailListItem(email: email) {
                            // Navigate to email detail
                            viewStateManager.showEmailDetailView(.emailDetail(email))
                        }
                        
                        if email.id != importantEmails.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .background(Color.white.opacity(0.1))
        }
    }
}

struct DashboardEmailList_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            DashboardEmailList(viewStateManager: ViewStateManager())
                .padding()
        }
    }
}
