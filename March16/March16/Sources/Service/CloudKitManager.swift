//
//  CloudKitManager.swift
//  March16
//
//  Created by 양시준 on 12/21/25.
//

import CloudKit
import Foundation

// MARK: - CloudKit Record Types

enum CloudKitSchema {
    static let containerIdentifier = "iCloud.dev.sijun.March16"

    enum RecordType {
        static let dailyVerse = "DailyVerse"
        static let verseText = "VerseText"
    }

    enum DailyVerseField {
        static let month = "month"
        static let day = "day"
        static let bookKey = "bookKey"
        static let chapter = "chapter"
        static let startVerse = "startVerse"
        static let endVerse = "endVerse"
    }

    enum VerseTextField {
        static let dailyVerseRef = "dailyVerseRef"
        static let versionCode = "versionCode"
        static let bookName = "bookName"
        static let content = "content"
    }
}

// MARK: - CloudKit Manager

final class CloudKitManager {
    static let shared = CloudKitManager()

    private let container: CKContainer
    private var publicDatabase: CKDatabase { container.publicCloudDatabase }

    private init() {
        self.container = CKContainer(identifier: CloudKitSchema.containerIdentifier)
    }

    // MARK: - Fetch Daily Verse

    /// Fetches a daily verse for the given date and version
    func fetchDailyVerse(month: Int, day: Int, versionCode: String) async throws -> DailyVerse? {
        // Step 1: Fetch DailyVerse record
        let dailyVersePredicate = NSPredicate(
            format: "%K == %d AND %K == %d",
            CloudKitSchema.DailyVerseField.month, month,
            CloudKitSchema.DailyVerseField.day, day
        )

        let dailyVerseQuery = CKQuery(
            recordType: CloudKitSchema.RecordType.dailyVerse,
            predicate: dailyVersePredicate
        )

        let (dailyVerseResults, _) = try await publicDatabase.records(
            matching: dailyVerseQuery,
            resultsLimit: 1
        )

        guard let dailyVerseResult = dailyVerseResults.first,
              let dailyVerseRecord = try? dailyVerseResult.1.get() else {
            return nil
        }

        // Step 2: Fetch VerseText for the version
        let verseTextPredicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            CloudKitSchema.VerseTextField.dailyVerseRef, CKRecord.Reference(record: dailyVerseRecord, action: .none),
            CloudKitSchema.VerseTextField.versionCode, versionCode
        )

        let verseTextQuery = CKQuery(
            recordType: CloudKitSchema.RecordType.verseText,
            predicate: verseTextPredicate
        )

        let (verseTextResults, _) = try await publicDatabase.records(
            matching: verseTextQuery,
            resultsLimit: 1
        )

        guard let verseTextResult = verseTextResults.first,
              let verseTextRecord = try? verseTextResult.1.get() else {
            return nil
        }

        // Step 3: Construct DailyVerse model
        return constructDailyVerse(
            from: dailyVerseRecord,
            verseText: verseTextRecord
        )
    }

    /// Fetches a daily verse for the given date
    func fetchDailyVerse(date: Date, versionCode: String) async throws -> DailyVerse? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return try await fetchDailyVerse(month: month, day: day, versionCode: versionCode)
    }

    // MARK: - Helpers

    private func constructDailyVerse(from dailyVerseRecord: CKRecord, verseText: CKRecord) -> DailyVerse? {
        guard let month = dailyVerseRecord[CloudKitSchema.DailyVerseField.month] as? Int,
              let day = dailyVerseRecord[CloudKitSchema.DailyVerseField.day] as? Int,
              let chapter = dailyVerseRecord[CloudKitSchema.DailyVerseField.chapter] as? Int,
              let startVerse = dailyVerseRecord[CloudKitSchema.DailyVerseField.startVerse] as? Int,
              let bookName = verseText[CloudKitSchema.VerseTextField.bookName] as? String,
              let content = verseText[CloudKitSchema.VerseTextField.content] as? String else {
            return nil
        }

        let endVerse = dailyVerseRecord[CloudKitSchema.DailyVerseField.endVerse] as? Int

        // Use recordName as ID (convert to hash for Int compatibility)
        let id = dailyVerseRecord.recordID.recordName.hashValue

        return DailyVerse(
            id: id,
            month: month,
            day: day,
            book: bookName,
            chapter: chapter,
            startVerse: startVerse,
            endVerse: endVerse,
            content: content
        )
    }

    // MARK: - Data Upload (for migration)

    /// Uploads a DailyVerse record to CloudKit.
    ///
    /// Uses a deterministic record name (`daily_<month>_<day>`) with overwrite
    /// semantics, so re-running the migration updates the existing record in
    /// place instead of creating duplicates.
    func uploadDailyVerse(
        month: Int,
        day: Int,
        bookKey: String,
        chapter: Int,
        startVerse: Int,
        endVerse: Int?
    ) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: "daily_\(month)_\(day)")
        let record = CKRecord(recordType: CloudKitSchema.RecordType.dailyVerse, recordID: recordID)
        record[CloudKitSchema.DailyVerseField.month] = month
        record[CloudKitSchema.DailyVerseField.day] = day
        record[CloudKitSchema.DailyVerseField.bookKey] = bookKey
        record[CloudKitSchema.DailyVerseField.chapter] = chapter
        record[CloudKitSchema.DailyVerseField.startVerse] = startVerse
        record[CloudKitSchema.DailyVerseField.endVerse] = endVerse

        return try await upsert(record)
    }

    /// Uploads a VerseText record to CloudKit.
    ///
    /// The record name is derived from the parent daily verse and version
    /// (`verse_<dailyRecordName>_<versionCode>`) so repeated migrations overwrite
    /// rather than duplicate.
    func uploadVerseText(
        dailyVerseRecord: CKRecord,
        versionCode: String,
        bookName: String,
        content: String
    ) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: "verse_\(dailyVerseRecord.recordID.recordName)_\(versionCode)")
        let record = CKRecord(recordType: CloudKitSchema.RecordType.verseText, recordID: recordID)
        record[CloudKitSchema.VerseTextField.dailyVerseRef] = CKRecord.Reference(
            record: dailyVerseRecord,
            action: .deleteSelf
        )
        record[CloudKitSchema.VerseTextField.versionCode] = versionCode
        record[CloudKitSchema.VerseTextField.bookName] = bookName
        record[CloudKitSchema.VerseTextField.content] = content

        return try await upsert(record)
    }

    /// Saves a record with `.allKeys` overwrite policy so migrations are idempotent.
    ///
    /// Because the record carries a deterministic ID and no server change tag,
    /// `.allKeys` replaces any existing record's fields instead of failing with a
    /// conflict.
    private func upsert(_ record: CKRecord) async throws -> CKRecord {
        let result = try await publicDatabase.modifyRecords(
            saving: [record],
            deleting: [],
            savePolicy: .allKeys,
            atomically: true
        )
        guard let saveResult = result.saveResults[record.recordID] else {
            return record
        }
        return try saveResult.get()
    }

    // MARK: - Check CloudKit Availability

    func checkAccountStatus() async throws -> CKAccountStatus {
        try await container.accountStatus()
    }
}
