//
//  March16Control.swift
//  March16Widget
//
//  Created by 양시준 on 7/13/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Open App Intent

/// Launches the main app when the control is tapped.
@available(iOS 18.0, *)
struct OpenTodayVerseIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Today's Verse"
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

// MARK: - Control Widget (Control Center / Lock Screen / Action Button)

@available(iOS 18.0, *)
struct March16Control: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "dev.sijun.March16.OpenTodayVerse") {
            ControlWidgetButton(action: OpenTodayVerseIntent()) {
                Label("Today's Verse", systemImage: "book.closed")
            }
        }
        .displayName("Today's Verse")
        .description("Open March16 to today's Bible verse.")
    }
}
