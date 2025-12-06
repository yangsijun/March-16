//
//  DailyVerse.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

struct DailyVerse: Identifiable, Codable {
    let id: Int
    let month: Int
    let day: Int
    let book: String
    let chapter: Int
    let startVerse: Int
    let endVerse: Int?
    let content: String
    
    init(id: Int, month: Int, day: Int, book: String, chapter: Int, startVerse: Int, endVerse: Int? = nil, content: String) {
        self.id = id
        self.month = month
        self.day = day
        self.book = book
        self.chapter = chapter
        self.startVerse = startVerse
        self.endVerse = endVerse
        self.content = content
    }
    
    var referenceString: String {
        if let end = endVerse, end > startVerse {
            return "\(book) \(chapter):\(startVerse)-\(end)"
        } else {
            return "\(book) \(chapter):\(startVerse)"
        }
    }

    static let placeholder = DailyVerse(
        id: 0,
        month: 0,
        day: 0,
        book: "John",
        chapter: 3,
        startVerse: 16,
        content: "For God so loved the world, that he gave his only born Son, that whoever believes in him should not perish, but have eternal life."
    )
}
