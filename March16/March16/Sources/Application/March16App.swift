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
    init() {
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Bookmark.self)
    }

    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.scheduleDailyNotification()
            }
        }
    }
}
