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
    @State private var appearanceMode: AppearanceMode
    @State private var showDiscardAlert: Bool = false

    // Initial values to detect changes
    private let initialVersion: BibleVersion
    private let initialNotificationEnabled: Bool
    private let initialNotificationTime: Date
    private let initialAppearanceMode: AppearanceMode

    private var hasChanges: Bool {
        selectedVersion != initialVersion ||
        isNotificationEnabled != initialNotificationEnabled ||
        notificationTime != initialNotificationTime ||
        appearanceMode != initialAppearanceMode
    }

    init() {
        let settings = UserSettings.shared
        let version = settings.selectedVersion ?? BibleVersion.current
        let notificationEnabled = settings.isNotificationEnabled
        let notificationTime = settings.notificationTime
        let appearance = settings.appearanceMode

        _selectedVersion = State(initialValue: version)
        _isNotificationEnabled = State(initialValue: notificationEnabled)
        _notificationTime = State(initialValue: notificationTime)
        _appearanceMode = State(initialValue: appearance)

        self.initialVersion = version
        self.initialNotificationEnabled = notificationEnabled
        self.initialNotificationTime = notificationTime
        self.initialAppearanceMode = appearance
    }

    var body: some View {
        ZStack {
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
                        .tint(AppColor.accent)
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

                Section {
                    Picker(String(localized: "Appearance"), selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.displayName)
                                .tag(mode)
                        }
                    }
                    .listRowBackground(AppColor.groupedBackground)
                } header: {
                    Text(String(localized: "Display"))
                }
            }
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 80, for: .scrollContent)

            SettingsTopBar(
                onDismiss: {
                    if hasChanges {
                        showDiscardAlert = true
                    } else {
                        dismiss()
                    }
                },
                onSave: {
                    saveSettings()
                    dismiss()
                }
            )
        }
        .background(AppColor.background)
        .interactiveDismissDisabled(hasChanges)
        .alert(String(localized: "Discard Changes?"), isPresented: $showDiscardAlert) {
            Button(String(localized: "Discard"), role: .destructive) {
                dismiss()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "Your changes will not be saved."))
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
        settings.appearanceMode = appearanceMode

        // Reschedule notifications with new settings
        if isNotificationEnabled {
            NotificationManager.shared.scheduleDailyNotification()
        } else {
            NotificationManager.shared.cancelAllNotifications()
        }
    }
}

struct SettingsTopBar: View {
    var onDismiss: () -> Void
    var onSave: () -> Void

    var body: some View {
        VStack {
            ZStack {
                Text(String(localized: "Settings"))
                    .font(.headline)
                    .foregroundStyle(AppColor.primary)

                HStack(spacing: 12) {
                    BottomBarButton {
                        onDismiss()
                    } label: {
                        Label(String(localized: "Dismiss"), systemImage: "xmark")
                    }
                    Spacer()
                    BottomBarButton {
                        onSave()
                    } label: {
                        Label(String(localized: "Done"), systemImage: "checkmark")
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColor.background)
            Spacer()
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
