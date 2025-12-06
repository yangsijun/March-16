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
        guard !isKJVAvailable && !isDownloading else {
            completion(isKJVAvailable)
            return
        }

        let tags: Set<String> = [Self.kjvDatabaseTag]
        kjvRequest = NSBundleResourceRequest(tags: tags)

        // First check if already downloaded (cached)
        kjvRequest?.conditionallyBeginAccessingResources { [weak self] isAvailable in
            DispatchQueue.main.async {
                if isAvailable {
                    self?.isKJVAvailable = true
                    completion(true)
                } else {
                    // Not cached, need to download
                    self?.downloadKJVDatabase(completion: completion)
                }
            }
        }
    }

    private func downloadKJVDatabase(completion: @escaping (Bool) -> Void) {
        isDownloading = true
        kjvRequest?.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent

        kjvRequest?.beginAccessingResources { [weak self] error in
            DispatchQueue.main.async {
                self?.isDownloading = false

                if let error = error {
                    print("Failed to download KJV database: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                self?.isKJVAvailable = true
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
