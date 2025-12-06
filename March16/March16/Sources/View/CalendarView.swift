//
//  CalendarView.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [Bookmark]

    @Binding var isPresented: Bool
    @Binding var date: Date
    @Binding var selectedDate: Date?

    @State private var isShareSheetPresented: Bool = false

    private var selectedDailyVerse: DailyVerse {
        guard let selectedDate else { return .placeholder }
        return DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: selectedDate) ?? .placeholder
    }

    private var isBookmarked: Bool {
        bookmarks.contains { $0.dailyVerseId == selectedDailyVerse.id }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    MonthView(date: date)
                    MonthCalendar(currentMonth: date, selectedDate: $selectedDate)
                    CalendarBottomBar(date: $date)
                    MiniVerseView(dailyVerse: selectedDailyVerse)
                        .contextMenu {
                            Button {
                                toggleBookmark()
                            } label: {
                                Label(
                                    isBookmarked ? String(localized: "Remove Bookmark") : String(localized: "Add Bookmark"),
                                    systemImage: isBookmarked ? "bookmark.slash" : "bookmark"
                                )
                            }
                            Divider()
                            Button {
                                isShareSheetPresented = true
                            } label: {
                                Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                            }
                            Button {
                                UIPasteboard.general.string = "[\(selectedDailyVerse.referenceString)] \(selectedDailyVerse.content)"
                            } label: {
                                Label(String(localized: "Copy"), systemImage: "doc.on.doc")
                            }
                        }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            CalendarTopBar(isCalendarPresented: $isPresented)
        }
        .background(AppColor.background)
        .sheet(isPresented: $isShareSheetPresented) {
            if let selectedDate {
                ShareView(date: selectedDate, dailyVerse: selectedDailyVerse)
            }
        }
    }

    private func toggleBookmark() {
        if let existingBookmark = bookmarks.first(where: { $0.dailyVerseId == selectedDailyVerse.id }) {
            modelContext.delete(existingBookmark)
        } else {
            let bookmark = Bookmark(dailyVerseId: selectedDailyVerse.id)
            modelContext.insert(bookmark)
        }
    }
}

struct MonthView: View {
    var date: Date
    var yearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(yearString)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .frame(height: 28)
            Text(monthString)
                .font(.system(size: 90, weight: .black, design: .serif))
                .frame(height: 90)
        }
        .foregroundStyle(AppColor.primary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.top, 48)
        .padding(.bottom, 32)
    }
}

struct CalendarTopBar: View {
    @Binding var isCalendarPresented: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                BottomBarButton {
                    withAnimation {
                        isCalendarPresented = false
                    }
                } label: {
                    Label(String(localized: "Dismiss"), systemImage: "xmark")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var date = Date()
    @Previewable @State var selectedDate: Date? = Date()
    CalendarView(isPresented: .constant(true), date: $date, selectedDate: $selectedDate)
        .modelContainer(for: Bookmark.self, inMemory: true)
}
