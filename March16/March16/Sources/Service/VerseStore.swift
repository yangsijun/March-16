//
//  VerseStore.swift
//  March16
//
//  Created by 양시준 on 12/21/25.
//

import Foundation

/// View-facing store that exposes *synchronous* verse access backed by the
/// CloudKit repository cache.
///
/// The repository's synchronous API only reads the local cache, so SwiftUI
/// views would show `.placeholder` for any date not yet prefetched, and would
/// never refresh once a background fetch populated the cache. `VerseStore`
/// closes both gaps:
///
/// - On a cache miss it kicks off an on-demand CloudKit fetch.
/// - When that fetch finishes it bumps an observed `revision`, so every view
///   that read `verse(for:)` re-evaluates and picks up the freshly cached data.
@Observable
final class VerseStore {
    static let shared = VerseStore()

    @ObservationIgnored private let repository = CloudKitVerseRepository.shared

    /// Incremented whenever a background load finishes so SwiftUI re-renders the
    /// views that depend on the cache.
    private var revision = 0

    /// Keys already requested this session, to coalesce duplicate fetches and to
    /// avoid a re-fetch loop when a load fails (a failed load still bumps
    /// `revision`, which would otherwise re-trigger `verse(for:)` endlessly).
    @ObservationIgnored private var requestedKeys: Set<String> = []

    private init() {}

    /// Returns the cached verse for `date`, or `.placeholder` while it loads.
    func verse(for date: Date, versionCode: String = BibleVersion.current.code) -> DailyVerse {
        cachedVerse(for: date, versionCode: versionCode) ?? .placeholder
    }

    /// Returns the cached verse if present (no placeholder fallback), still
    /// triggering an on-demand load on a miss. Use when the caller must tell
    /// "not loaded yet" apart from a real verse (e.g. bookmark lookups).
    func cachedVerse(for date: Date, versionCode: String = BibleVersion.current.code) -> DailyVerse? {
        // Establish a dependency on `revision` so observers re-run after loads.
        _ = revision

        if let cached = repository.fetchDailyVerse(date: date, versionCode: versionCode) {
            return cached
        }

        load(date: date, versionCode: versionCode)
        return nil
    }

    private func load(date: Date, versionCode: String) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let key = "\(month)_\(day)_\(versionCode)"

        guard !requestedKeys.contains(key) else { return }
        requestedKeys.insert(key)

        Task { @MainActor in
            _ = try? await repository.fetchDailyVerseAsync(month: month, day: day, versionCode: versionCode)
            // Re-read the cache on the next render; on success this yields the
            // real verse, on failure `requestedKeys` prevents a reload loop.
            revision &+= 1
        }
    }
}
