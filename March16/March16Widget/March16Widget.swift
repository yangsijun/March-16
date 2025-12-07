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
            March16WidgetEntryView(entry: entry)
                .containerBackground(WidgetColor.background, for: .widget)
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
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .frame(height: 14)
                Text(dayString)
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .frame(height: 48)
            }
            .foregroundStyle(WidgetColor.primary)

            Spacer()

            // Verse Reference
            Text(entry.verse.referenceString)
                .font(.system(size: 11, weight: .regular))
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
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .frame(height: 16)
                Text(dayString)
                    .font(.system(size: 56, weight: .black, design: .serif))
                    .frame(height: 56)
            }
            .foregroundStyle(WidgetColor.primary)
            .frame(width: 80)

            // Verse
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.verse.content)
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(WidgetColor.primary)

                Text(entry.verse.referenceString)
                    .font(.system(size: 11, weight: .regular))
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
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .frame(height: 24)
                Text(dayString)
                    .font(.system(size: 96, weight: .black, design: .serif))
                    .frame(height: 96)
            }
            .foregroundStyle(WidgetColor.primary)

            Spacer()
                .frame(height: 8)

            // Verse
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.verse.content)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .italic()
                    .lineSpacing(1)
                    .foregroundStyle(WidgetColor.primary)

                Text(entry.verse.referenceString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WidgetColor.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Widget Colors

enum WidgetColor {
    static let background = Color("AppBackgroundColor")
    static let primary = Color("AppPrimaryColor")
    static let tertiary = Color("AppTertiaryColor")
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
