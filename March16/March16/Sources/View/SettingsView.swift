//
//  SettingsView.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var settings = UserSettings.shared
    var appState = AppState.shared

    @State private var selectedVersion: BibleVersion
    @State private var isNotificationEnabled: Bool
    @State private var notificationTime: Date

    init() {
        let settings = UserSettings.shared
        _selectedVersion = State(initialValue: settings.selectedVersion ?? BibleVersion.current)
        _isNotificationEnabled = State(initialValue: settings.isNotificationEnabled)
        _notificationTime = State(initialValue: settings.notificationTime)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(String(localized: "Bible Version"), selection: $selectedVersion) {
                        ForEach(availableVersions, id: \.self) { version in
                            Text(version.displayName)
                                .tag(version)
                        }
                    }
                    .listRowBackground(AppColor.groupedBackground)
                } header: {
                    Text(String(localized: "Bible"))
                }

                Section {
                    Toggle(String(localized: "Daily Notification"), isOn: $isNotificationEnabled)
                        .listRowBackground(AppColor.groupedBackground)
                    if isNotificationEnabled {
                        DatePicker(
                            String(localized: "Notification Time"),
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .listRowBackground(AppColor.groupedBackground)
                    }
                } header: {
                    Text(String(localized: "Notification"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveSettings()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }

    private var availableVersions: [BibleVersion] {
        // Show all versions, but KJV only if available
        // Access appState.isKJVReady to trigger re-render when KJV becomes available
        if appState.isKJVReady || DatabaseManager.shared.isKJVAttached {
            return [.nkrv, .kjv, .webbe]
        } else {
            return [.nkrv, .webbe]
        }
    }

    private func saveSettings() {
        settings.selectedVersion = selectedVersion
        settings.isNotificationEnabled = isNotificationEnabled
        settings.notificationTime = notificationTime

        // Reschedule notifications with new settings
        if isNotificationEnabled {
            NotificationManager.shared.scheduleDailyNotification()
        } else {
            NotificationManager.shared.cancelAllNotifications()
        }
    }
}

extension BibleVersion {
    var displayName: String {
        switch self {
        case .nkrv:
            return "개역개정 (NKRV)"
        case .kjv:
            return "King James Version (KJV)"
        case .webbe:
            return "World English Bible (WEBBE)"
        }
    }
}

#Preview {
    SettingsView()
}
