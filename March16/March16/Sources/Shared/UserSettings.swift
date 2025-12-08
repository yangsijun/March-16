//
//  UserSettings.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - User Settings

@Observable
final class UserSettings {
    static let shared = UserSettings()

    private let defaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.dev.sijun.March16")

    private enum Keys {
        static let selectedVersion = "selectedBibleVersion"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
        static let isNotificationEnabled = "isNotificationEnabled"
        static let appearanceMode = "appearanceMode"
    }

    // Stored properties for observation
    var selectedVersion: BibleVersion? {
        didSet {
            defaults.set(selectedVersion?.rawValue, forKey: Keys.selectedVersion)
            // Sync to shared UserDefaults for widget
            sharedDefaults?.set(selectedVersion?.rawValue, forKey: Keys.selectedVersion)
            WidgetCenter.shared.reloadTimelines(ofKind: "March16Widget")
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

    var appearanceMode: AppearanceMode {
        didSet {
            defaults.set(appearanceMode.rawValue, forKey: Keys.appearanceMode)
            // Sync to shared UserDefaults for widget
            sharedDefaults?.set(appearanceMode.rawValue, forKey: Keys.appearanceMode)
            WidgetCenter.shared.reloadTimelines(ofKind: "March16Widget")
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

        if let modeString = defaults.string(forKey: Keys.appearanceMode),
           let mode = AppearanceMode(rawValue: modeString) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .system
        }

        // Sync to shared UserDefaults for widget on init
        syncToWidget()
    }

    func syncToWidget() {
        sharedDefaults?.set(selectedVersion?.rawValue, forKey: Keys.selectedVersion)
        sharedDefaults?.set(appearanceMode.rawValue, forKey: Keys.appearanceMode)
        WidgetCenter.shared.reloadTimelines(ofKind: "March16Widget")
    }
}
