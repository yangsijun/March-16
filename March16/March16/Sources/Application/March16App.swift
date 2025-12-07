//
//  March16App.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct March16App: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isInitialized = false

    @AppStorage("lastScheduledLanguage") private var lastScheduledLanguage: String = ""

    init() {
        requestNotificationPermission()
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                rescheduleNotificationsIfLanguageChanged()
            }
        }
    }

    private func initializeApp() async {
        // Fetch storefront region info
        await RegionManager.shared.fetchStorefront()
        print("[March16] Storefront country: \(RegionManager.shared.storefrontCountryCode ?? "nil"), isUK: \(RegionManager.shared.isUK)")

        // Request KJV database if needed (non-UK region)
        if !RegionManager.shared.isUK {
            print("[March16] Requesting KJV database...")
            ODRManager.shared.requestKJVDatabase { success in
                print("[March16] KJV database request result: \(success)")
                if success {
                    DatabaseManager.shared.attachKJVDatabase()
                    print("[March16] KJV database attached: \(DatabaseManager.shared.isKJVAttached)")
                    AppState.shared.markKJVReady()
                }
                // Schedule notifications after KJV is ready
                self.scheduleNotificationsIfAuthorized()
            }
        } else {
            // UK region - schedule notifications with WEBBE
            scheduleNotificationsIfAuthorized()
        }
    }

    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization()
    }

    private func scheduleNotificationsIfAuthorized() {
        let language = currentLanguageCode
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                NotificationManager.shared.scheduleDailyNotification()
                DispatchQueue.main.async {
                    self.lastScheduledLanguage = language
                }
            }
        }
    }

    private func rescheduleNotificationsIfLanguageChanged() {
        let currentLanguage = currentLanguageCode
        guard lastScheduledLanguage != currentLanguage else { return }
        scheduleNotificationsIfAuthorized()
    }

    private var currentLanguageCode: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
}
