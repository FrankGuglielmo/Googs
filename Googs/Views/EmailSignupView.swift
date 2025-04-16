//
//  EmailSignupView.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/11/25.
//

import SwiftUI

struct EmailSignUpView: View {
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Sign Up for Email")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 40)
            
            Button(action: {
                // Handle the email sign-up action (for now, just print)
                print("Email submitted: \(email)")
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .navigationTitle("Email Sign Up")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EmailSignUpView()
}

