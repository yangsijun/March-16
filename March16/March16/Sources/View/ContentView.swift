//
//  ContentView.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]

    @State private var isCalendarPresented: Bool = false
    @State private var isShareSheetPresented: Bool = false
    @State private var calendarDate: Date = Date()
    @State private var selectedDate: Date? = Date()

    var dailyVerse: DailyVerse {
        DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: Date()) ?? .placeholder
    }

    var isBookmarked: Bool {
        bookmarks.contains { $0.dailyVerseId == dailyVerse.id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    DateView(date: Date())
                    VerseView(dailyVerse: dailyVerse)
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = "[\(dailyVerse.referenceString)] \(dailyVerse.content)"
                            } label: {
                                Label(String(localized: "Copy"), systemImage: "doc.on.doc")
                            }
                        }
                    Spacer()
                }
                .background(AppColor.background)
                BottomBar(
                    isCalendarPresented: $isCalendarPresented,
                    isBookmarked: isBookmarked,
                    isShareSheetPresented: $isShareSheetPresented,
                    calendarDate: $calendarDate,
                    selectedDate: $selectedDate,
                    onBookmarkTapped: toggleBookmark
                )
                CalendarView(isPresented: $isCalendarPresented, date: $calendarDate, selectedDate: $selectedDate)
                    .opacity(isCalendarPresented ? 1 : 0)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareView(date: Date(), dailyVerse: dailyVerse)
        }
    }

    private func toggleBookmark() {
        if let existingBookmark = bookmarks.first(where: { $0.dailyVerseId == dailyVerse.id }) {
            modelContext.delete(existingBookmark)
        } else {
            let bookmark = Bookmark(dailyVerseId: dailyVerse.id)
            modelContext.insert(bookmark)
        }
    }
}

struct DateView: View {
    var date: Date
    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(monthString)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .frame(height: 32)
            Text(dayString)
                .font(.system(size: 128, weight: .black, design: .serif))
                .frame(height: 128)
        }
        .foregroundStyle(AppColor.primary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.top, 48)
        .padding(.bottom, 32)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Bookmark.self, inMemory: true)
}
