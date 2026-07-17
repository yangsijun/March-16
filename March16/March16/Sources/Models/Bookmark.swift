//
//  Bookmark.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation
import SwiftData

@Model
final class Bookmark {
    /// Date-based key in `yyyyMMdd` form (e.g. 20260717). Derived from the
    /// displayed date, not from the verse record, so it stays stable across
    /// launches and works even before the verse has loaded.
    var dateId: Int = 0
    var createdAt: Date = Date()

    init(dateId: Int, createdAt: Date = Date()) {
        self.dateId = dateId
        self.createdAt = createdAt
    }

    static func dateId(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return (components.year ?? 0) * 10_000 + (components.month ?? 0) * 100 + (components.day ?? 0)
    }
}
