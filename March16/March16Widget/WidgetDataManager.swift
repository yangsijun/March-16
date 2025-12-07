//
//  WidgetDataManager.swift
//  March16Widget
//
//  Created by 양시준 on 12/7/25.
//

import Foundation
import GRDB

// MARK: - Widget Daily Verse Model

struct WidgetDailyVerse: Codable {
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

    private var dbQueue: DatabaseQueue?

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        guard let dbPath = Bundle.main.path(forResource: "March16DB", ofType: "sqlite") else {
            print("March16DB.sqlite not found in widget bundle")
            return
        }

        do {
            var config = Configuration()
            config.readonly = true
            dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
        } catch {
            print("Failed to open database: \(error)")
        }
    }

    func fetchDailyVerse(date: Date) -> WidgetDailyVerse? {
        guard let db = dbQueue else { return nil }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let versionCode = WidgetBibleVersion.current.code

        do {
            return try db.read { db in
                let sql = """
                    SELECT dv.id, dv.month, dv.day, dv.book_key, dv.chapter, dv.start_verse, dv.end_verse,
                           vt.book_name, vt.content
                    FROM daily_verse dv
                    JOIN verse_text vt ON dv.id = vt.daily_id
                    WHERE dv.month = ? AND dv.day = ? AND vt.version_code = ?
                    LIMIT 1
                    """

                let row = try Row.fetchOne(db, sql: sql, arguments: [month, day, versionCode])

                guard let row = row else { return nil }

                let endVerse: Int? = row["end_verse"]

                return WidgetDailyVerse(
                    book: row["book_name"],
                    chapter: row["chapter"],
                    startVerse: row["start_verse"],
                    endVerse: endVerse,
                    content: row["content"]
                )
            }
        } catch {
            print("Failed to fetch daily verse: \(error)")
            return nil
        }
    }
}
