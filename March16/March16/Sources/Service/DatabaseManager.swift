//
//  DatabaseManager.swift
//  March16
//
//  Created by 양시준 on 12/6/25.
//

import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let dbQueue: DatabaseQueue
    private(set) var isKJVAttached = false

    private init() {
        guard let dbPath = Bundle.main.path(forResource: "March16DB", ofType: "sqlite") else {
            fatalError("March16DB.sqlite not found in bundle")
        }

        do {
            var config = Configuration()
            config.readonly = true
            dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
        } catch {
            fatalError("Failed to open database: \(error)")
        }
    }

    func attachKJVDatabase() {
        guard !isKJVAttached else { return }
        guard let kjvPath = ODRManager.shared.getKJVDatabasePath() else { return }

        do {
            try dbQueue.write { db in
                try db.execute(sql: "ATTACH DATABASE ? AS kjv", arguments: [kjvPath])
            }
            isKJVAttached = true
        } catch {
            print("Failed to attach KJV database: \(error)")
        }
    }

    func read<T>(_ block: (Database) throws -> T) throws -> T {
        try dbQueue.read(block)
    }
}
