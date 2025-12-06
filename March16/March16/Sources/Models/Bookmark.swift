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
    var dailyVerseId: Int
    var createdAt: Date

    init(dailyVerseId: Int, createdAt: Date = Date()) {
        self.dailyVerseId = dailyVerseId
        self.createdAt = createdAt
    }
}
