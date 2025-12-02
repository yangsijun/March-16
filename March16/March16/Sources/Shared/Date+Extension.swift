//
//  Date+Extension.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import Foundation

extension Date {
    // Return the start of the month for the current date
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    // Return the number of days in the month
    func daysInMonth() -> Int {
        return Calendar.current.range(of: .day, in: .month, for: self)!.count
    }
    
    // Return the day of the week (1 = Sunday, 7 = Saturday)
    func dayOfWeek() -> Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    // Add months to the current date
    func plusMonth(_ value: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: value, to: self)!
    }
    
    // Return an array of dates to fill the calendar grid (including padding days)
    func calendarDisplayDays() -> [Date] {
        var days: [Date] = []
        
        let startOfMonth = self.startOfMonth()
        let daysInMonth = self.daysInMonth()
        let firstWeekday = startOfMonth.dayOfWeek()
        
        // Calculate days from previous month to fill the first row
        // If the month starts on Tuesday (3), we need 2 padding days (Sun, Mon)
        let offset = firstWeekday - 1
        
        for dayOffset in 0..<(daysInMonth + offset) {
            if let date = Calendar.current.date(byAdding: .day, value: dayOffset - offset, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Optional: Add days from next month to fill the last row completely (to make it a perfect grid)
        // ... logic can be added here if fixed-height rows are needed
        
        return days
    }
    
    // 해당 월의 모든 날짜를 주 단위([[Date?]])로 반환
    func extractCalendarMatrix() -> [[Date?]] {
        let calendar = Calendar.current
        
        // 1. 해당 월의 첫 번째 날짜 가져오기
        guard let range = calendar.range(of: .day, in: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        // 2. 첫 번째 날짜의 요일 (일요일: 1 ~ 토요일: 7)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 3. 날짜 배열 생성 (앞부분 공백 채우기)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        // 4. 실제 날짜 채우기
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // 5. 주 단위(7일)로 쪼개서 2차원 배열 만들기
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []
        
        for day in days {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        
        // 마지막 주가 7일이 안 되면 nil로 채워서 줄 맞추기 (선택 사항)
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    // Helper to check if two dates are the same day
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}
