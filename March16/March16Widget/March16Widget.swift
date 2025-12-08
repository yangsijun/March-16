//
//  March16Widget.swift
//  March16Widget
//
//  Created by 양시준 on 12/7/25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct DailyVerseEntry: TimelineEntry {
    let date: Date
    let verse: WidgetDailyVerse
}

// MARK: - Timeline Provider

struct DailyVerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseEntry {
        DailyVerseEntry(date: Date(), verse: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseEntry) -> Void) {
        let entry = DailyVerseEntry(date: Date(), verse: fetchTodayVerse())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseEntry>) -> Void) {
        let currentDate = Date()
        let verse = fetchTodayVerse()
        let entry = DailyVerseEntry(date: currentDate, verse: verse)

        // Update at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)

        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    private func fetchTodayVerse() -> WidgetDailyVerse {
        WidgetDataManager.shared.fetchDailyVerse(date: Date()) ?? .placeholder
    }
}

// MARK: - Widget Configuration

struct March16Widget: Widget {
    let kind: String = "March16Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseProvider()) { entry in
            let appearanceMode = WidgetAppearanceMode.current
            if appearanceMode.isSystemMode {
                March16WidgetEntryView(entry: entry)
                    .containerBackground(WidgetColor.background, for: .widget)
            } else {
                March16WidgetEntryView(entry: entry)
                    .environment(\.colorScheme, appearanceMode.resolvedColorScheme)
                    .containerBackground(for: .widget) {
                        Color("AppBackgroundColor")
                            .environment(\.colorScheme, appearanceMode.resolvedColorScheme)
                    }
            }
        }
        .configurationDisplayName("Today's Verse")
        .description("Daily Bible verse for spiritual reflection.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Entry View

struct March16WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: DailyVerseEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (2x2)

struct SmallWidgetView: View {
    var entry: DailyVerseEntry

    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: entry.date).uppercased()
    }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Spacer()

            // Date
            VStack(spacing: 0) {
                Text(monthString)
                    .widgetFont(.smallDateMonth)
                    .frame(height: 14)
                Text(dayString)
                    .widgetFont(.smallDateDay)
                    .frame(height: 48)
            }
            .foregroundStyle(WidgetColor.primary)

            Spacer()

            // Verse Reference
            Text(entry.verse.referenceString)
                .widgetFont(.smallVerseReference)
                .foregroundStyle(WidgetColor.tertiary)

            Spacer()
                .frame(height: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget (4x2)

struct MediumWidgetView: View {
    var entry: DailyVerseEntry

    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: entry.date).uppercased()
    }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(spacing: 0) {
                Text(monthString)
                    .widgetFont(.mediumDateMonth)
                    .frame(height: 16)
                Text(dayString)
                    .widgetFont(.mediumDateDay)
                    .frame(height: 56)
            }
            .foregroundStyle(WidgetColor.primary)
            .frame(width: 80)

            // Verse
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.verse.content)
                    .widgetFont(.mediumVerseContent)
                    .foregroundStyle(WidgetColor.primary)

                Text(entry.verse.referenceString)
                    .widgetFont(.mediumVerseReference)
                    .foregroundStyle(WidgetColor.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Large Widget (4x4)

struct LargeWidgetView: View {
    var entry: DailyVerseEntry

    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: entry.date).uppercased()
    }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d"
        return formatter.string(from: entry.date)
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Date
            VStack(spacing: 0) {
                Text(monthString)
                    .widgetFont(.largeDateMonth)
                    .frame(height: 24)
                Text(dayString)
                    .widgetFont(.largeDateDay)
                    .frame(height: 96)
            }
            .foregroundStyle(WidgetColor.primary)

            Spacer()
                .frame(height: 8)

            // Verse
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.verse.content)
                    .widgetFont(.largeVerseContent)
                    .lineSpacing(1)
                    .foregroundStyle(WidgetColor.primary)

                Text(entry.verse.referenceString)
                    .widgetFont(.largeVerseReference)
                    .foregroundStyle(WidgetColor.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Appearance Mode

private enum WidgetAppearanceMode: String {
    case system
    case light
    case dark

    var resolvedColorScheme: ColorScheme {
        switch self {
        case .system:
            // Default to light for system (widget will follow system automatically for .system)
            return .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var isSystemMode: Bool {
        self == .system
    }

    static var current: WidgetAppearanceMode {
        let defaults = UserDefaults(suiteName: "group.dev.sijun.March16")
        if let modeString = defaults?.string(forKey: "appearanceMode"),
           let mode = WidgetAppearanceMode(rawValue: modeString) {
            return mode
        }
        return .system
    }
}

// MARK: - Widget Colors

enum WidgetColor {
    static let background = Color("AppBackgroundColor")
    static let primary = Color("AppPrimaryColor")
    static let tertiary = Color("AppTertiaryColor")
}

// MARK: - Widget Fonts

enum WidgetFont {
    // Small Widget
    case smallDateMonth
    case smallDateDay
    case smallVerseReference

    // Medium Widget
    case mediumDateMonth
    case mediumDateDay
    case mediumVerseContent
    case mediumVerseReference

    // Large Widget
    case largeDateMonth
    case largeDateDay
    case largeVerseContent
    case largeVerseReference

    private static var isKorean: Bool {
        let defaults = UserDefaults(suiteName: "group.dev.sijun.March16")
        let code = defaults?.string(forKey: "selectedBibleVersion")
        if let code = code {
            return code == "NKRV"
        }
        // Default based on locale
        return Locale.current.language.languageCode?.identifier == "ko"
    }

    var font: Font {
        let isKorean = Self.isKorean

        switch self {
        // Small Widget
        case .smallDateMonth:
            return .system(size: 14, weight: .bold, design: .serif)
        case .smallDateDay:
            return .system(size: 48, weight: .black, design: .serif)
        case .smallVerseReference:
            return .system(size: 11, weight: .regular)

        // Medium Widget
        case .mediumDateMonth:
            return .system(size: 16, weight: .bold, design: .serif)
        case .mediumDateDay:
            return .system(size: 56, weight: .black, design: .serif)
        case .mediumVerseContent:
            return isKorean
                ? .custom("KoPubBatangPM", size: 13)
                : .system(size: 14, weight: .regular, design: .serif)
        case .mediumVerseReference:
            return .system(size: 11, weight: .regular)

        // Large Widget
        case .largeDateMonth:
            return .system(size: 24, weight: .bold, design: .serif)
        case .largeDateDay:
            return .system(size: 96, weight: .black, design: .serif)
        case .largeVerseContent:
            return isKorean
                ? .custom("KoPubBatangPM", size: 16)
                : .system(size: 17, weight: .regular, design: .serif)
        case .largeVerseReference:
            return .system(size: 13, weight: .regular)
        }
    }
}

extension View {
    func widgetFont(_ font: WidgetFont) -> some View {
        self.font(font.font)
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    March16Widget()
} timeline: {
    DailyVerseEntry(date: Date(), verse: .placeholder)
}

#Preview(as: .systemMedium) {
    March16Widget()
} timeline: {
    DailyVerseEntry(date: Date(), verse: .placeholder)
}

#Preview(as: .systemLarge) {
    March16Widget()
} timeline: {
    DailyVerseEntry(date: Date(), verse: .placeholder)
}
