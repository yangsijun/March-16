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
                .font(.system(size: 24, weight: .regular, design: .serif))
                .italic()
                .lineSpacing(1)
                .foregroundStyle(Color("AppPrimaryColor"))
            Text(dailyVerse.referenceString)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("AppTertiaryColor"))
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
                .font(.system(size: 17, weight: .regular, design: .serif))
                .italic()
                .lineSpacing(1)
                .foregroundStyle(Color("AppPrimaryColor"))
            Text(dailyVerse.referenceString)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color("AppTertiaryColor"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}
