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

    var requiresKJVDatabase: Bool {
        self == .kjv
    }

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

    private var mainDbQueue: DatabaseQueue?
    private var kjvDbQueue: DatabaseQueue?

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        // Setup main database (NKRV, WEBBE)
        if let dbPath = Bundle.main.path(forResource: "March16DB", ofType: "sqlite") {
            do {
                var config = Configuration()
                config.readonly = true
                mainDbQueue = try DatabaseQueue(path: dbPath, configuration: config)
            } catch {
                print("[Widget] Failed to open main database: \(error)")
            }
        } else {
            print("[Widget] March16DB.sqlite not found in widget bundle")
        }

        // Setup KJV database
        if let kjvPath = Bundle.main.path(forResource: "March16DB_KJV", ofType: "sqlite") {
            do {
                var config = Configuration()
                config.readonly = true
                kjvDbQueue = try DatabaseQueue(path: kjvPath, configuration: config)
            } catch {
                print("[Widget] Failed to open KJV database: \(error)")
            }
        } else {
            print("[Widget] March16DB_KJV.sqlite not found in widget bundle")
        }
    }

    func fetchDailyVerse(date: Date) -> WidgetDailyVerse? {
        guard let mainDb = mainDbQueue else {
            print("[Widget] Main database not available")
            return nil
        }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let version = WidgetBibleVersion.current

        do {
            // Step 1: Get daily verse info from main database
            let dailyVerseInfo = try mainDb.read { db -> (id: Int, chapter: Int, startVerse: Int, endVerse: Int?)? in
                let sql = """
                    SELECT id, chapter, start_verse, end_verse
                    FROM daily_verse
                    WHERE month = ? AND day = ?
                    LIMIT 1
                    """
                guard let row = try Row.fetchOne(db, sql: sql, arguments: [month, day]) else {
                    return nil
                }
                return (
                    id: row["id"],
                    chapter: row["chapter"],
                    startVerse: row["start_verse"],
                    endVerse: row["end_verse"]
                )
            }

            guard let info = dailyVerseInfo else {
                print("[Widget] No daily verse found for \(month)/\(day)")
                return nil
            }

            // Step 2: Get verse text from appropriate database
            let verseDb = version.requiresKJVDatabase ? (kjvDbQueue ?? mainDb) : mainDb

            return try verseDb.read { db in
                let sql = """
                    SELECT book_name, content
                    FROM verse_text
                    WHERE daily_id = ? AND version_code = ?
                    LIMIT 1
                    """

                guard let row = try Row.fetchOne(db, sql: sql, arguments: [info.id, version.code]) else {
                    print("[Widget] No verse text found for daily_id: \(info.id), version: \(version.code)")
                    return nil
                }

                return WidgetDailyVerse(
                    book: row["book_name"],
                    chapter: info.chapter,
                    startVerse: info.startVerse,
                    endVerse: info.endVerse,
                    content: row["content"]
                )
            }
        } catch {
            print("[Widget] Failed to fetch daily verse: \(error)")
            return nil
        }
    }
}
