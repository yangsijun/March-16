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

    var appState = AppState.shared
    var userSettings = UserSettings.shared

    @State private var isCalendarPresented: Bool = false
    @State private var isShareSheetPresented: Bool = false
    @State private var isSettingsPresented: Bool = false
    @State private var calendarDate: Date = Date()
    @State private var selectedDate: Date? = Date()
    @State private var displayedDate: Date = Date()

    var dailyVerse: DailyVerse {
        // Access appState and userSettings to trigger refresh when they change
        _ = appState.isKJVReady
        _ = userSettings.selectedVersion
        return DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: displayedDate) ?? .placeholder
    }

    private var canGoToNextDay: Bool {
        let calendar = Calendar.current
        return !calendar.isDateInToday(displayedDate)
    }

    var isBookmarked: Bool {
        bookmarks.contains { $0.dailyVerseId == dailyVerse.id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    DateView(date: displayedDate)
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
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = value.translation.height

                            // Only handle horizontal swipes
                            guard abs(horizontal) > abs(vertical) else { return }

                            if horizontal > 0 {
                                // Swipe right -> previous day
                                goToPreviousDay()
                            } else {
                                // Swipe left -> next day
                                goToNextDay()
                            }
                        }
                )
                BottomBar(
                    isCalendarPresented: $isCalendarPresented,
                    isBookmarked: isBookmarked,
                    isShareSheetPresented: $isShareSheetPresented,
                    isSettingsPresented: $isSettingsPresented,
                    calendarDate: $calendarDate,
                    selectedDate: $selectedDate,
                    isToday: Calendar.current.isDateInToday(displayedDate),
                    onBookmarkTapped: toggleBookmark,
                    onTodayTapped: goToToday
                )
                CalendarView(isPresented: $isCalendarPresented, date: $calendarDate, selectedDate: $selectedDate)
                    .opacity(isCalendarPresented ? 1 : 0)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareView(date: displayedDate, dailyVerse: dailyVerse)
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        .onChange(of: selectedDate) { _, newDate in
            if let date = newDate {
                displayedDate = date
            }
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

    private func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: displayedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayedDate = newDate
                selectedDate = newDate
                calendarDate = newDate
            }
        }
    }

    private func goToNextDay() {
        guard canGoToNextDay else { return }
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: displayedDate) {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayedDate = newDate
                selectedDate = newDate
                calendarDate = newDate
            }
        }
    }

    private func goToToday() {
        let today = Date()
        guard !Calendar.current.isDateInToday(displayedDate) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            displayedDate = today
            selectedDate = today
            calendarDate = today
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
                .appFont(.dateMonthSmall)
                .frame(height: 32)
            Text(dayString)
                .appFont(.dateDayLarge)
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
