//
//  DailyVerseRepository.swift
//  March16
//
//  Created by 양시준 on 12/6/25.
//

import Foundation
import GRDB

// MARK: - Protocol

protocol DailyVerseRepository {
    func fetchDailyVerse(month: Int, day: Int, versionCode: String) -> DailyVerse?
    func fetchDailyVerse(date: Date, versionCode: String) -> DailyVerse?
}

extension DailyVerseRepository {
    func fetchDailyVerse(date: Date, versionCode: String = BibleVersion.current.code) -> DailyVerse? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return fetchDailyVerse(month: month, day: day, versionCode: versionCode)
    }
}

// MARK: - DB Records

struct DailyVerseRecord: Codable, FetchableRecord {
    let id: Int
    let month: Int
    let day: Int
    let bookKey: String
    let chapter: Int
    let startVerse: Int
    let endVerse: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case month
        case day
        case bookKey = "book_key"
        case chapter
        case startVerse = "start_verse"
        case endVerse = "end_verse"
    }
}

struct VerseTextRecord: Codable, FetchableRecord {
    let id: Int
    let dailyId: Int
    let versionCode: String
    let bookName: String
    let content: String

    enum CodingKeys: String, CodingKey {
        case id
        case dailyId = "daily_id"
        case versionCode = "version_code"
        case bookName = "book_name"
        case content
    }
}

// MARK: - Implementation

final class DailyVerseRepositoryImpl: DailyVerseRepository {
    static let shared = DailyVerseRepositoryImpl()

    private let database: DatabaseManager

    init(database: DatabaseManager = .shared) {
        self.database = database
    }

    func fetchDailyVerse(month: Int, day: Int, versionCode: String = BibleVersion.current.code) -> DailyVerse? {
        do {
            return try database.read { db in
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

                return DailyVerse(
                    id: row["id"],
                    month: row["month"],
                    day: row["day"],
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
