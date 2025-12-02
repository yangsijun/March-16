//
//  MonthCalendar.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct MonthCalendar: View {
    @State var currentMonth: Date
    @Binding private var selectedDate: Date?
    private var displayDays: [[Date?]]
    
    init(currentMonth: Date, selectedDate: Binding<Date?>) {
        self.currentMonth = currentMonth
        self._selectedDate = selectedDate
        self.displayDays = currentMonth.extractCalendarMatrix()
    }
    
    var body: some View {
        LazyVStack(alignment: .center, spacing: 4) {
            dayOfWeekRow()
            ForEach(displayDays, id: \.self) { week in
                LazyHStack(spacing: 8) {
                    ForEach(week, id: \.self) { date in
                        DayCell(
                            date: date,
                            selectedDate: $selectedDate
                        )
                    }
                }
                Divider()
                    .background(Color("AppTertiaryColor"))
            }
        }
    }
}

struct dayOfWeekRow: View {
    let days: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color("AppSecondaryColor"))
                        .frame(minWidth: 44, maxWidth: 44)
                }
            }
            Divider()
                .background(Color("AppTertiaryColor"))
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
    var isBookmarked: Bool = false
    
    var dayString: String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Group {
            if let date {
                Button(action: {
                    selectedDate = date
                }) {
                    VStack(spacing: 0) {
                        Text(dayString)
                            .font(.system(size: 17, weight: isToday ? .heavy : .medium, design: .serif))
                            .frame(maxWidth: .infinity)
                            .background(isSelected ? Color("AppPrimaryColor") : Color.clear)
                            .clipShape(.capsule)
                            .padding(.horizontal, 2)
                            .foregroundStyle(isSelected ? Color("AppBackgroundColor") : Color("AppPrimaryColor"))
                        Spacer()
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("AppTertiaryColor"))
                            .opacity(isBookmarked ? 1 : 0)
                    }
                    .padding(.vertical, 4)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
            }
        }
        .frame(minWidth: 44, maxWidth: 44, minHeight: 44, maxHeight: 44)
    }
}

#Preview {
    @Previewable @State var selectedDate: Date? = Date()
    let date = Date()
    
    MonthCalendar(currentMonth: date, selectedDate: $selectedDate)
        .padding(24)
        .background(Color("AppBackgroundColor"))
}
