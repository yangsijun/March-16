//
//  CloudKitVerseRepository.swift
//  March16
//
//  Created by 양시준 on 12/21/25.
//

import CloudKit
import Foundation

/// Repository that fetches daily verses from CloudKit with local caching
final class CloudKitVerseRepository: DailyVerseRepository {
    static let shared = CloudKitVerseRepository()

    private let cloudKit = CloudKitManager.shared
    private let cache = VerseCache.shared

    private init() {}

    // MARK: - DailyVerseRepository (Sync - uses cache)

    func fetchDailyVerse(month: Int, day: Int, versionCode: String) -> DailyVerse? {
        // Return cached version immediately (sync)
        cache.get(month: month, day: day, versionCode: versionCode)
    }

    // MARK: - Async API

    /// Fetches verse from CloudKit and updates cache
    func fetchDailyVerseAsync(month: Int, day: Int, versionCode: String) async throws -> DailyVerse? {
        // Try cache first
        if let cached = cache.get(month: month, day: day, versionCode: versionCode) {
            return cached
        }

        // Fetch from CloudKit
        guard let verse = try await cloudKit.fetchDailyVerse(
            month: month,
            day: day,
            versionCode: versionCode
        ) else {
            return nil
        }

        // Cache the result
        cache.set(verse, month: month, day: day, versionCode: versionCode)

        return verse
    }

    /// Fetches verse for a date from CloudKit and updates cache
    func fetchDailyVerseAsync(date: Date, versionCode: String) async throws -> DailyVerse? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return try await fetchDailyVerseAsync(month: month, day: day, versionCode: versionCode)
    }

    /// Pre-fetches verses for a date range (e.g., for notifications)
    func prefetchVerses(for dates: [Date], versionCode: String) async {
        await withTaskGroup(of: Void.self) { group in
            for date in dates {
                group.addTask {
                    _ = try? await self.fetchDailyVerseAsync(date: date, versionCode: versionCode)
                }
            }
        }
    }

    /// Pre-fetches all verses for a month
    func prefetchMonth(_ month: Int, versionCode: String) async {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: dateFrom(month: month, day: 1))?.count ?? 31

        await withTaskGroup(of: Void.self) { group in
            for day in 1...daysInMonth {
                group.addTask {
                    _ = try? await self.fetchDailyVerseAsync(month: month, day: day, versionCode: versionCode)
                }
            }
        }
    }

    private func dateFrom(month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date())
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Verse Cache

/// Local cache for daily verses (persisted to disk)
final class VerseCache {
    static let shared = VerseCache()

    private let fileManager = FileManager.default
    private var memoryCache: [String: DailyVerse] = [:]
    private let cacheQueue = DispatchQueue(label: "dev.sijun.March16.verseCache", attributes: .concurrent)

    private var cacheDirectory: URL {
        let appGroup = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.sijun.March16")
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return appGroup.appendingPathComponent("VerseCache", isDirectory: true)
    }

    private init() {
        createCacheDirectoryIfNeeded()
        loadCacheFromDisk()
    }

    // MARK: - Public API

    func get(month: Int, day: Int, versionCode: String) -> DailyVerse? {
        let key = cacheKey(month: month, day: day, versionCode: versionCode)
        return cacheQueue.sync { memoryCache[key] }
    }

    func set(_ verse: DailyVerse, month: Int, day: Int, versionCode: String) {
        let key = cacheKey(month: month, day: day, versionCode: versionCode)
        cacheQueue.async(flags: .barrier) {
            self.memoryCache[key] = verse
            self.saveToDisk(verse, key: key)
        }
    }

    func clear() {
        cacheQueue.async(flags: .barrier) {
            self.memoryCache.removeAll()
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            self.createCacheDirectoryIfNeeded()
        }
    }

    // MARK: - Disk Persistence

    private func cacheKey(month: Int, day: Int, versionCode: String) -> String {
        "\(month)_\(day)_\(versionCode)"
    }

    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }

    private func loadCacheFromDisk() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let verse = try? JSONDecoder().decode(DailyVerse.self, from: data) else {
                continue
            }

            let key = file.deletingPathExtension().lastPathComponent
            memoryCache[key] = verse
        }
    }

    private func saveToDisk(_ verse: DailyVerse, key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")

        guard let data = try? JSONEncoder().encode(verse) else { return }
        try? data.write(to: fileURL)
    }
}
