//
//  GoogsApp.swift
//  Googs
//
//  Created by Frank Guglielmo on 4/10/25.
//

import SwiftUI
import SwiftData

@main
struct GoogsApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Present the RootView, which first shows the splash and then the main content.
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
