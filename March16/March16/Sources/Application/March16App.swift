//
//  March16App.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

import SwiftUI
import SwiftData

@main
struct March16App: App {
    @State private var isInitialized = false

    init() {
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    guard !isInitialized else { return }
                    isInitialized = true
                    await initializeApp()
                }
        }
        .modelContainer(for: Bookmark.self)
    }

    private func initializeApp() async {
        // Fetch storefront region info
        await RegionManager.shared.fetchStorefront()

        // Request KJV database if needed (non-UK region)
        if !RegionManager.shared.isUK {
            ODRManager.shared.requestKJVDatabase { success in
                if success {
                    DatabaseManager.shared.attachKJVDatabase()
                    AppState.shared.markKJVReady()
                }
            }
        }
    }

    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.scheduleDailyNotification()
            }
        }
    }
}
