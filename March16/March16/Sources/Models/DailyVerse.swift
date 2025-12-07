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

    static var placeholder: DailyVerse {
        let isKorean = BibleVersion.current == .nkrv
        return DailyVerse(
            id: 0,
            month: 0,
            day: 0,
            book: isKorean ? "요한복음" : "John",
            chapter: 3,
            startVerse: 16,
            content: isKorean
                ? "하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라"
                : "For God so loved the world, that he gave his only born Son, that whoever believes in him should not perish, but have eternal life."
        )
    }
}
