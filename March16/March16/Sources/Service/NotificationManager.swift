//
//  NotificationManager.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private var notificationHour: Int {
        UserSettings.shared.notificationHour
    }

    private var notificationMinute: Int {
        UserSettings.shared.notificationMinute
    }

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }

    /// Schedules daily verse notifications for the next 7 days.
    ///
    /// Verse text now comes from CloudKit via a local cache, so before building
    /// notification content this first prefetches any missing verses. If a verse
    /// still can't be resolved (offline + cold cache), a generic fallback body is
    /// used instead of silently skipping that day. Existing notifications are only
    /// removed once the replacement requests are ready, so a fetch failure can
    /// never leave the user with zero scheduled notifications.
    func scheduleDailyNotification() async {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let now = Date()

        // Collect target dates for the next 7 days (skip today if already past time).
        var targetDates: [Date] = []
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }

            if dayOffset == 0 {
                let currentHour = calendar.component(.hour, from: now)
                let currentMinute = calendar.component(.minute, from: now)
                if currentHour > notificationHour || (currentHour == notificationHour && currentMinute >= notificationMinute) {
                    continue
                }
            }

            targetDates.append(targetDate)
        }

        // Ensure verse text is available in the cache before building content.
        let versionCode = BibleVersion.current.code
        await CloudKitVerseRepository.shared.prefetchVerses(for: targetDates, versionCode: versionCode)

        // Build all replacement requests first, then swap them in atomically.
        let requests = targetDates.map { buildRequest(for: $0, versionCode: versionCode) }

        center.removePendingNotificationRequests(withIdentifiers: getDailyVerseIdentifiers())
        for request in requests {
            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    private func buildRequest(for date: Date, versionCode: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "\(String(localized: "Today's Verse")) - \(date.formatted(Date.FormatStyle().month().day()))"

        if let dailyVerse = CloudKitVerseRepository.shared.fetchDailyVerse(date: date, versionCode: versionCode) {
            content.body = "[\(dailyVerse.referenceString)] \(dailyVerse.content)"
        } else {
            // Fallback when the verse could not be fetched (e.g. offline, cold cache).
            content.body = String(localized: "Open the app to see today's verse.")
        }
        content.sound = .default

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(
            identifier: dailyIdentifier(for: date),
            content: content,
            trigger: trigger
        )
    }

    private func dailyIdentifier(for date: Date) -> String {
        let calendar = Calendar.current
        return "dailyVerse_\(calendar.component(.year, from: date))_\(calendar.component(.month, from: date))_\(calendar.component(.day, from: date))"
    }

    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: getDailyVerseIdentifiers())
    }

    private func getDailyVerseIdentifiers() -> [String] {
        let calendar = Calendar.current
        let now = Date()
        var identifiers: [String] = []

        for dayOffset in -1..<14 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            identifiers.append(dailyIdentifier(for: date))
        }

        return identifiers
    }
}
