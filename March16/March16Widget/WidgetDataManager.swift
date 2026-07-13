//
//  WidgetDataManager.swift
//  March16Widget
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

// MARK: - Widget Daily Verse Model

struct WidgetDailyVerse: Codable {
    let id: Int
    let month: Int
    let day: Int
    let book: String
    let chapter: Int
    let startVerse: Int
    let endVerse: Int?
    let content: String

    var referenceString: String {
        if let end = endVerse, end > startVerse {
            return "\(book) \(chapter):\(startVerse)-\(end)"
        } else {
            return "\(book) \(chapter):\(startVerse)"
        }
    }

    static var placeholder: WidgetDailyVerse {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"
        return WidgetDailyVerse(
            id: 0,
            month: 0,
            day: 0,
            book: isKorean ? "요한복음" : "John",
            chapter: 3,
            startVerse: 16,
            endVerse: nil,
            content: isKorean
                ? "하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라"
                : "For God so loved the world, that he gave his only born Son, that whoever believes in him should not perish, but have eternal life."
        )
    }
}

// MARK: - Widget Bible Version

private enum WidgetBibleVersion: String {
    case nkrv = "NKRV"
    case webbe = "WEBBE"
    case kjv = "KJV"

    var code: String { rawValue }

    static var current: WidgetBibleVersion {
        let defaults = UserDefaults(suiteName: "group.dev.sijun.March16")
        if let code = defaults?.string(forKey: "selectedBibleVersion"),
           let version = WidgetBibleVersion(rawValue: code) {
            return version
        }

        // Default based on locale
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode == "ko" ? .nkrv : .webbe
    }
}

// MARK: - Widget Data Manager

final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let appGroupIdentifier = "group.dev.sijun.March16"
    private let fileManager = FileManager.default

    private var cacheDirectory: URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("VerseCache", isDirectory: true)
    }

    private init() {}

    // MARK: - Fetch from CloudKit Cache

    func fetchDailyVerse(date: Date) -> WidgetDailyVerse? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let version = WidgetBibleVersion.current

        return fetchFromCache(month: month, day: day, versionCode: version.code)
    }

    private func fetchFromCache(month: Int, day: Int, versionCode: String) -> WidgetDailyVerse? {
        guard let cacheDir = cacheDirectory else {
            print("[Widget] Cache directory not available")
            return nil
        }

        let key = "\(month)_\(day)_\(versionCode)"
        let fileURL = cacheDir.appendingPathComponent("\(key).json")

        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("[Widget] Cache file not found: \(key)")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            // DailyVerse from main app is compatible with WidgetDailyVerse
            let verse = try JSONDecoder().decode(WidgetDailyVerse.self, from: data)
            return verse
        } catch {
            print("[Widget] Failed to decode cached verse: \(error)")
            return nil
        }
    }
}
