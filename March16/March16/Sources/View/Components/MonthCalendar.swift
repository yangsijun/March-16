//
//  MonthCalendar.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI
import SwiftData

struct MonthCalendar: View {
    @Query private var bookmarks: [Bookmark]

    @State var currentMonth: Date
    @Binding private var selectedDate: Date?
    private var displayDays: [[Date?]]

    private var bookmarkedDailyVerseIds: Set<Int> {
        Set(bookmarks.map { $0.dailyVerseId })
    }

    init(currentMonth: Date, selectedDate: Binding<Date?>) {
        self.currentMonth = currentMonth
        self._selectedDate = selectedDate
        self.displayDays = currentMonth.extractCalendarMatrix()
    }

    var body: some View {
        LazyVStack(alignment: .center, spacing: 4) {
            dayOfWeekRow(spacing: 4)
            ForEach(displayDays, id: \.self) { week in
                LazyHStack(spacing: 4) {
                    ForEach(week, id: \.self) { date in
                        DayCell(
                            date: date,
                            selectedDate: $selectedDate,
                            bookmarkedDailyVerseIds: bookmarkedDailyVerseIds
                        )
                    }
                }
                Divider()
                    .background(AppColor.tertiary)
                    .frame(width: 44 * 7 + 4 * 6)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

struct dayOfWeekRow: View {
    var spacing: CGFloat = 4
    let days: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: spacing) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundColor(AppColor.secondary)
                        .frame(width: 44)
                }
            }
            Divider()
                .background(AppColor.tertiary)
                .frame(width: 44 * 7 + 4 * 6)
        }
    }
}

struct DayCell: View {
    var date: Date?
    var isToday: Bool {
        guard let date else { return false }
        return date.isSameDay(as: Date())
    }
    @Binding var selectedDate: Date?
    var isSelected: Bool {
        guard let date, let selectedDate else { return false }
        return date.isSameDay(as: selectedDate)
    }
    var bookmarkedDailyVerseIds: Set<Int> = []
    var isBookmarked: Bool {
        guard let date else { return false }
        guard let dailyVerse = DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: date) else { return false }
        return bookmarkedDailyVerseIds.contains(dailyVerse.id)
    }
    var isFuture: Bool {
        guard let date else { return false }
        return date.timeIntervalSinceNow > 0
    }
    
    var dayString: String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Group {
            if let date {
                Button {
                    selectedDate = date
                } label: {
                    VStack(spacing: 0) {
                        Text(dayString)
                            .font(.system(size: 17, weight: isToday ? .heavy : .medium, design: .serif))
                            .frame(maxWidth: .infinity)
                            .background(isSelected ? AppColor.primary : Color.clear)
                            .clipShape(.capsule)
                            .padding(.horizontal, 2)
                            .foregroundStyle(isSelected ? AppColor.background : isFuture ? AppColor.quaternary : AppColor.primary)
                        Spacer()
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColor.tertiary)
                            .opacity(isBookmarked ? 1 : 0)
                    }
                    .padding(.vertical, 4)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .disabled(isFuture)
            } else {
                Color.clear
            }
        }
        .frame(width: 44, height: 44)
    }
}

#Preview {
    @Previewable @State var selectedDate: Date? = Date()
    let date = Date()

    MonthCalendar(currentMonth: date, selectedDate: $selectedDate)
        .padding(24)
        .background(AppColor.background)
        .modelContainer(for: Bookmark.self, inMemory: true)
}
