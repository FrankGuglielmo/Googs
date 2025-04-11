//
//  OnboardingView.swift
//  Googs
//
//  Created by Frank Guglielmo on 3/24/25.
//

import SwiftUI
import RiveRuntime

struct OnboardingView: View {
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                
                Text("Learn Design & Code")
                    .font(.custom("Poppins Bold", size: 60, relativeTo: .largeTitle))
                    .frame(width: 260, alignment: .leading)
                
                Text("Don't skip design. Learn design and code, by building real apps with react and Swift. Complete courses about the best tools.")
                    .customFont(.body)
                
            }
                
        }
    }
    
    var background: some View {
        RiveViewModel(fileName: "animatedbackground").view()
            .ignoresSafeArea()
            .blur(radius: 30)
            .background(
                Image("Spline")
                    .blur(radius: 50)
                    .offset(x: 200, y: 100)
            )
    }
    
}

#Preview {
    OnboardingView()
}
