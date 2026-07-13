//
//  March16Control.swift
//  March16Widget
//
//  Created by 양시준 on 7/13/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Control Widget (Control Center / Lock Screen / Action Button)
//
// Note: `OpenTodayVerseIntent` is defined in the shared file
// Sources/Shared/OpenTodayVerseIntent.swift, which is a member of both the app
// and this widget extension target so the control can launch the app.

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
