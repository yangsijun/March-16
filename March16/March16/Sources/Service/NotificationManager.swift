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

    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()

        // Remove all existing daily verse notifications
        center.removePendingNotificationRequests(withIdentifiers: getDailyVerseIdentifiers())

        // Schedule notifications for the next 7 days
        let calendar = Calendar.current
        let now = Date()

        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }

            // Skip if it's today and already past notification time
            if dayOffset == 0 {
                let currentHour = calendar.component(.hour, from: now)
                let currentMinute = calendar.component(.minute, from: now)
                if currentHour > notificationHour || (currentHour == notificationHour && currentMinute >= notificationMinute) {
                    continue
                }
            }

            scheduleNotification(for: targetDate)
        }
    }

    private func scheduleNotification(for date: Date) {
        guard let dailyVerse = DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: date) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Today's Verse")
        content.body = dailyVerse.content
        content.sound = .default

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let identifier = "dailyVerse_\(calendar.component(.year, from: date))_\(calendar.component(.month, from: date))_\(calendar.component(.day, from: date))"

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
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
            let identifier = "dailyVerse_\(calendar.component(.year, from: date))_\(calendar.component(.month, from: date))_\(calendar.component(.day, from: date))"
            identifiers.append(identifier)
        }

        return identifiers
    }
}
