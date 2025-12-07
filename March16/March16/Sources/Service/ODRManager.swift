//
//  ODRManager.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

final class ODRManager {
    static let shared = ODRManager()

    static let kjvDatabaseTag = "kjv_db"

    private var kjvRequest: NSBundleResourceRequest?
    private(set) var isKJVAvailable = false
    private(set) var isDownloading = false

    private init() {}

    func requestKJVDatabase(completion: @escaping (Bool) -> Void) {
        print("[ODR] requestKJVDatabase called, isKJVAvailable: \(isKJVAvailable), isDownloading: \(isDownloading)")
        guard !isKJVAvailable && !isDownloading else {
            print("[ODR] Already available or downloading, returning: \(isKJVAvailable)")
            completion(isKJVAvailable)
            return
        }

        let tags: Set<String> = [Self.kjvDatabaseTag]
        kjvRequest = NSBundleResourceRequest(tags: tags)
        print("[ODR] Created NSBundleResourceRequest with tags: \(tags)")

        // First check if already downloaded (cached)
        kjvRequest?.conditionallyBeginAccessingResources { [weak self] isAvailable in
            print("[ODR] conditionallyBeginAccessingResources result: \(isAvailable)")
            DispatchQueue.main.async {
                if isAvailable {
                    self?.isKJVAvailable = true
                    // Copy to shared container for widget access
                    SharedDatabaseManager.shared.copyKJVDatabaseToSharedContainer()
                    completion(true)
                } else {
                    // Not cached, need to download
                    print("[ODR] Not cached, starting download...")
                    self?.downloadKJVDatabase(completion: completion)
                }
            }
        }
    }

    private func downloadKJVDatabase(completion: @escaping (Bool) -> Void) {
        isDownloading = true
        kjvRequest?.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
        print("[ODR] Starting beginAccessingResources...")

        kjvRequest?.beginAccessingResources { [weak self] error in
            DispatchQueue.main.async {
                self?.isDownloading = false

                if let error = error {
                    print("[ODR] Failed to download KJV database: \(error.localizedDescription)")
                    print("[ODR] Error details: \(error)")
                    completion(false)
                    return
                }

                print("[ODR] Download successful")
                self?.isKJVAvailable = true
                // Copy to shared container for widget access
                SharedDatabaseManager.shared.copyKJVDatabaseToSharedContainer()
                completion(true)
            }
        }
    }

    func getKJVDatabasePath() -> String? {
        guard isKJVAvailable else { return nil }
        return Bundle.main.path(forResource: "March16DB_KJV", ofType: "sqlite")
    }

    func endAccessingKJVResources() {
        kjvRequest?.endAccessingResources()
        kjvRequest = nil
        isKJVAvailable = false
    }
}
