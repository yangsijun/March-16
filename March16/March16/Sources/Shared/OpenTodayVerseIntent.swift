//
//  OpenTodayVerseIntent.swift
//  March16
//
//  Created by 양시준 on 7/13/26.
//

import AppIntents

/// Launches the main app. Used by the Control Center / Lock Screen control.
///
/// This intent is a member of BOTH the app and the widget extension targets.
/// The app-target membership is required: `openAppWhenRun` needs the intent to
/// exist in the app's AppIntents metadata so the system knows which app to
/// foreground when the control is tapped.
@available(iOS 18.0, *)
struct OpenTodayVerseIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Today's Verse"
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
