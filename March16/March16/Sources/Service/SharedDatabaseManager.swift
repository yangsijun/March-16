//
//  SharedDatabaseManager.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

final class SharedDatabaseManager {
    static let shared = SharedDatabaseManager()

    private let appGroupIdentifier = "group.dev.sijun.March16"
    private let mainDbName = "March16DB.sqlite"
    private let kjvDbName = "March16DB_KJV.sqlite"
    private let dbVersionKey = "sharedDbVersion"

    private var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Public Methods

    /// Copy main database to shared container if needed
    func setupSharedDatabase() {
        copyMainDatabaseIfNeeded()
    }

    /// Copy KJV database to shared container (call after ODR download)
    func copyKJVDatabaseToSharedContainer() {
        guard let bundlePath = Bundle.main.path(forResource: "March16DB_KJV", ofType: "sqlite"),
              let containerURL = sharedContainerURL else {
            print("[SharedDB] KJV database not found in bundle or container unavailable")
            return
        }

        let destinationURL = containerURL.appendingPathComponent(kjvDbName)
        copyFileIfNeeded(from: bundlePath, to: destinationURL)
    }

    /// Get path to main database in shared container
    func getSharedMainDatabasePath() -> String? {
        guard let containerURL = sharedContainerURL else { return nil }
        let dbURL = containerURL.appendingPathComponent(mainDbName)
        return FileManager.default.fileExists(atPath: dbURL.path) ? dbURL.path : nil
    }

    /// Get path to KJV database in shared container
    func getSharedKJVDatabasePath() -> String? {
        guard let containerURL = sharedContainerURL else { return nil }
        let dbURL = containerURL.appendingPathComponent(kjvDbName)
        return FileManager.default.fileExists(atPath: dbURL.path) ? dbURL.path : nil
    }

    // MARK: - Private Methods

    private func copyMainDatabaseIfNeeded() {
        guard let bundlePath = Bundle.main.path(forResource: "March16DB", ofType: "sqlite"),
              let containerURL = sharedContainerURL else {
            print("[SharedDB] Main database not found in bundle or container unavailable")
            return
        }

        let destinationURL = containerURL.appendingPathComponent(mainDbName)
        copyFileIfNeeded(from: bundlePath, to: destinationURL)
    }

    private func copyFileIfNeeded(from sourcePath: String, to destinationURL: URL) {
        let fileManager = FileManager.default
        let destinationPath = destinationURL.path

        // Get bundle version for comparison
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let fileName = destinationURL.lastPathComponent
        let versionKey = "\(dbVersionKey)_\(fileName)"
        let storedVersion = defaults?.string(forKey: versionKey)

        // Copy if file doesn't exist or version is different
        let shouldCopy = !fileManager.fileExists(atPath: destinationPath) || storedVersion != bundleVersion

        if shouldCopy {
            do {
                // Remove existing file if present
                if fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.removeItem(atPath: destinationPath)
                }

                // Copy new file
                try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)

                // Update version
                defaults?.set(bundleVersion, forKey: versionKey)

                print("[SharedDB] Copied \(fileName) to shared container (version: \(bundleVersion))")
            } catch {
                print("[SharedDB] Failed to copy \(fileName): \(error)")
            }
        } else {
            print("[SharedDB] \(fileName) already up to date in shared container")
        }
    }
}
