//
//  ContentView.swift
//  AnimatedApp
//
//  Created by Meng To on 2022-03-29.
//

import SwiftUI

/// A simple wrapper for MainViewContainer to maintain backward compatibility
struct ContentView: View {
    var body: some View {
        MainViewContainer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
