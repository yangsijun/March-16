//
//  CloudKitMigration.swift
//  March16
//
//  Created by 양시준 on 12/21/25.
//

import CloudKit
import Foundation
import GRDB

/// Migrates data from SQLite to CloudKit
/// Run this once to populate the CloudKit database
final class CloudKitMigration {
    static let shared = CloudKitMigration()

    private let cloudKit = CloudKitManager.shared
    private let database = DatabaseManager.shared

    private init() {}

    // MARK: - Migration

    /// Migrates all data from SQLite to CloudKit
    /// - Parameter includeKJV: Whether to include KJV version (requires ODR download)
    func migrateAllData(includeKJV: Bool = false) async throws -> MigrationResult {
        var result = MigrationResult()

        // Step 1: Fetch all daily verses from SQLite
        let dailyVerses = try fetchAllDailyVersesFromSQLite()
        result.totalDailyVerses = dailyVerses.count

        // Step 2: Upload each daily verse and its texts
        for dailyVerse in dailyVerses {
            do {
                // Upload DailyVerse record
                let dailyVerseRecord = try await cloudKit.uploadDailyVerse(
                    month: dailyVerse.month,
                    day: dailyVerse.day,
                    bookKey: dailyVerse.bookKey,
                    chapter: dailyVerse.chapter,
                    startVerse: dailyVerse.startVerse,
                    endVerse: dailyVerse.endVerse
                )
                result.uploadedDailyVerses += 1

                // Fetch and upload verse texts for each version
                let versions = includeKJV
                    ? [BibleVersion.nkrv, .webbe, .kjv]
                    : [BibleVersion.nkrv, .webbe]

                for version in versions {
                    if let verseText = try fetchVerseTextFromSQLite(
                        dailyId: dailyVerse.id,
                        versionCode: version.code
                    ) {
                        _ = try await cloudKit.uploadVerseText(
                            dailyVerseRecord: dailyVerseRecord,
                            versionCode: version.code,
                            bookName: verseText.bookName,
                            content: verseText.content
                        )
                        result.uploadedVerseTexts += 1
                    }
                }

                print("Uploaded: \(dailyVerse.month)/\(dailyVerse.day)")
            } catch {
                print("Failed: \(dailyVerse.month)/\(dailyVerse.day) - \(error)")
                result.errors.append("[\(dailyVerse.month)/\(dailyVerse.day)] \(error.localizedDescription)")
            }
        }

        return result
    }

    // MARK: - SQLite Fetch

    private struct SQLiteDailyVerse {
        let id: Int
        let month: Int
        let day: Int
        let bookKey: String
        let chapter: Int
        let startVerse: Int
        let endVerse: Int?
    }

    private struct SQLiteVerseText {
        let bookName: String
        let content: String
    }

    private func fetchAllDailyVersesFromSQLite() throws -> [SQLiteDailyVerse] {
        try database.read { db in
            let sql = """
                SELECT id, month, day, book_key, chapter, start_verse, end_verse
                FROM daily_verse
                ORDER BY month, day
                """

            return try Row.fetchAll(db, sql: sql).map { row in
                SQLiteDailyVerse(
                    id: row["id"],
                    month: row["month"],
                    day: row["day"],
                    bookKey: row["book_key"],
                    chapter: row["chapter"],
                    startVerse: row["start_verse"],
                    endVerse: row["end_verse"]
                )
            }
        }
    }

    private func fetchVerseTextFromSQLite(dailyId: Int, versionCode: String) throws -> SQLiteVerseText? {
        try database.read { db in
            // Handle KJV from attached database
            let tableName = versionCode == BibleVersion.kjv.code && DatabaseManager.shared.isKJVAttached
                ? "kjv.verse_text"
                : "verse_text"

            let sql = """
                SELECT book_name, content
                FROM \(tableName)
                WHERE daily_id = ? AND version_code = ?
                LIMIT 1
                """

            guard let row = try Row.fetchOne(db, sql: sql, arguments: [dailyId, versionCode]) else {
                return nil
            }

            return SQLiteVerseText(
                bookName: row["book_name"],
                content: row["content"]
            )
        }
    }

    // MARK: - Result

    struct MigrationResult {
        var totalDailyVerses = 0
        var uploadedDailyVerses = 0
        var uploadedVerseTexts = 0
        var errors: [String] = []

        var summary: String {
            """
            Migration Complete
            ─────────────────
            Daily Verses: \(uploadedDailyVerses)/\(totalDailyVerses)
            Verse Texts: \(uploadedVerseTexts)
            Errors: \(errors.count)
            """
        }
    }
}

// MARK: - Migration View (for running migration from UI)

#if DEBUG
import SwiftUI

struct CloudKitMigrationView: View {
    @State private var isRunning = false
    @State private var result: CloudKitMigration.MigrationResult?
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 20) {
            Text("CloudKit Migration")
                .font(.title)

            if isRunning {
                ProgressView("Migrating...")
            } else if let result = result {
                Text(result.summary)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)

                if !result.errors.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(result.errors, id: \.self) { error in
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }

            Button("Start Migration") {
                runMigration()
            }
            .disabled(isRunning)
        }
        .padding()
    }

    private func runMigration() {
        isRunning = true
        error = nil
        result = nil

        Task {
            do {
                let migrationResult = try await CloudKitMigration.shared.migrateAllData()
                await MainActor.run {
                    self.result = migrationResult
                    self.isRunning = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isRunning = false
                }
            }
        }
    }
}

#Preview {
    CloudKitMigrationView()
}
#endif
