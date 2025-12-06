//
//  AppFont.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import SwiftUI

enum AppFont {
    // Date Display
    case dateYear
    case dateMonthLarge
    case dateMonthSmall
    case dateDayLarge
    case dateDayMedium

    // Verse
    case verseContent
    case verseContentMini
    case verseContentShare
    case verseReference

    // Calendar
    case calendarDayOfWeek
    case calendarDay(isToday: Bool)
    case calendarBookmarkIcon
    case calendarBottomBar

    // Button
    case shareButton
    case bottomBarIcon

    var font: Font {
        let isKorean = BibleVersion.current == .nkrv

        switch self {
        case .dateYear:
            return .system(size: 28, weight: .bold, design: .serif)

        case .dateMonthLarge:
            return .system(size: 90, weight: .black, design: .serif)

        case .dateMonthSmall:
            return .system(size: 32, weight: .bold, design: .serif)

        case .dateDayLarge:
            return .system(size: 128, weight: .black, design: .serif)

        case .dateDayMedium:
            return .system(size: 120, weight: .black, design: .serif)

        case .verseContent:
            return isKorean
                ? .custom("KoPubBatangPM", size: 21)
                : .system(size: 24, weight: .regular, design: .serif)

        case .verseContentMini:
            return isKorean
                ? .custom("KoPubBatangPM", size: 16)
                : .system(size: 17, weight: .regular, design: .serif)

        case .verseContentShare:
            return isKorean
                ? .custom("KoPubBatangPM", size: 18)
                : .system(size: 20, weight: .regular, design: .serif)

        case .verseReference:
            return .system(size: 14, weight: .regular)

        case .calendarDayOfWeek:
            return .system(size: 17, weight: .bold, design: .serif)

        case .calendarDay(let isToday):
            return .system(size: 17, weight: isToday ? .heavy : .medium, design: .serif)

        case .calendarBookmarkIcon:
            return .system(size: 12, weight: .medium)

        case .calendarBottomBar:
            return isKorean
                ? .custom("KoPubBatangPM", size: 13)
                : .system(size: 14, weight: .semibold, design: .serif)

        case .shareButton:
            return .system(size: 17, weight: .semibold)

        case .bottomBarIcon:
            return .system(size: 22, weight: .semibold)
        }
    }
}

extension View {
    func appFont(_ appFont: AppFont) -> some View {
        self.font(appFont.font)
    }
}
