//
//  VerseView.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct VerseView: View {
    var dailyVerse: DailyVerse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dailyVerse.content)
                .appFont(.verseContent)
                .italic()
                .lineSpacing(1)
                .foregroundStyle(AppColor.primary)
            Text(dailyVerse.referenceString)
                .appFont(.verseReference)
                .foregroundStyle(AppColor.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

struct MiniVerseView: View {
    var dailyVerse: DailyVerse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dailyVerse.content)
                .appFont(.verseContentMini)
                .italic()
                .lineSpacing(1)
                .foregroundStyle(AppColor.primary)
            Text(dailyVerse.referenceString)
                .appFont(.verseReference)
                .foregroundStyle(AppColor.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}
