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

    var userSettings = UserSettings.shared

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(userSettings.appearanceMode.colorScheme)
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
        // Prefetch today's verse and upcoming week from CloudKit
        await prefetchVersesFromCloudKit()

        // Schedule notifications
        scheduleNotificationsIfAuthorized()
    }

    private func prefetchVersesFromCloudKit() async {
        let repository = CloudKitVerseRepository.shared
        let versionCode = BibleVersion.current.code

        // Prefetch today's verse first (highest priority)
        _ = try? await repository.fetchDailyVerseAsync(date: Date(), versionCode: versionCode)

        // Prefetch next 7 days for notifications and widget
        var dates: [Date] = []
        for i in 1...7 {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: Date()) {
                dates.append(date)
            }
        }
        await repository.prefetchVerses(for: dates, versionCode: versionCode)

        print("[March16] CloudKit prefetch completed")
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
