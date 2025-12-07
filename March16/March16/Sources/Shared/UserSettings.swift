//
//  UserSettings.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

@Observable
final class UserSettings {
    static let shared = UserSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let selectedVersion = "selectedBibleVersion"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
        static let isNotificationEnabled = "isNotificationEnabled"
    }

    // Stored properties for observation
    var selectedVersion: BibleVersion? {
        didSet {
            defaults.set(selectedVersion?.rawValue, forKey: Keys.selectedVersion)
        }
    }

    var notificationHour: Int {
        didSet {
            defaults.set(notificationHour, forKey: Keys.notificationHour)
        }
    }

    var notificationMinute: Int {
        didSet {
            defaults.set(notificationMinute, forKey: Keys.notificationMinute)
        }
    }

    var isNotificationEnabled: Bool {
        didSet {
            defaults.set(isNotificationEnabled, forKey: Keys.isNotificationEnabled)
        }
    }

    var notificationTime: Date {
        get {
            var components = DateComponents()
            components.hour = notificationHour
            components.minute = notificationMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            notificationHour = components.hour ?? 9
            notificationMinute = components.minute ?? 0
        }
    }

    private init() {
        // Load from UserDefaults
        if let code = defaults.string(forKey: Keys.selectedVersion) {
            self.selectedVersion = BibleVersion(rawValue: code)
        } else {
            self.selectedVersion = nil
        }

        if defaults.object(forKey: Keys.notificationHour) != nil {
            self.notificationHour = defaults.integer(forKey: Keys.notificationHour)
        } else {
            self.notificationHour = 9
        }

        self.notificationMinute = defaults.integer(forKey: Keys.notificationMinute)

        if defaults.object(forKey: Keys.isNotificationEnabled) != nil {
            self.isNotificationEnabled = defaults.bool(forKey: Keys.isNotificationEnabled)
        } else {
            self.isNotificationEnabled = true
        }
    }
}
