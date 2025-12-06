//
//  CalendarView.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var isPresented: Bool
    @State var date: Date
    @State var selectedDate: Date? = Date()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    MonthView(date: date)
                    MonthCalendar(currentMonth: date, selectedDate: $selectedDate)
                        .padding(.vertical, 8)
                    CalendarBottomBar(date: $date)
                    if let selectedDate = selectedDate {
                        MiniVerseView(dailyVerse: DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: selectedDate) ?? .placeholder)
                    } else {
                        MiniVerseView(dailyVerse: .placeholder)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            CalendarTopBar(isCalendarPresented: $isPresented)
        }
        .background(AppColor.background)
    }
}

struct MonthView: View {
    var date: Date
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    var monthString: String {
        let formatter = DateFormatter()
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
                    Label("Dismiss", systemImage: "xmark")
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
    let date = Date()
    CalendarView(isPresented: .constant(true), date: date)
}
