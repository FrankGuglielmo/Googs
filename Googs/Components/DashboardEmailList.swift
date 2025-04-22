//
//  DashboardEmailList.swift
//  Googs
//
//  Created on 2025-04-18.
//

import SwiftUI

struct DashboardEmailList: View {
    @State private var importantEmails = getImportantEmails(count: 3)
    var onNavigateToEmailDetail: (Email) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Email list container
            VStack(spacing: 0) {
                ForEach(importantEmails) { email in
                    VStack(spacing: 0) {
                        EmailListItem(email: email) {
                            // Navigate to email detail using callback
                            onNavigateToEmailDetail(email)
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
            
            DashboardEmailList(onNavigateToEmailDetail: { _ in })
                .padding()
        }
    }
}
