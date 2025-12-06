//
//  ContentView.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isCalendarPresented: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var isShareSheetPresented: Bool = false
    
    var dailyVerse: DailyVerse {
        DailyVerseRepositoryImpl.shared.fetchDailyVerse(date: Date()) ?? .placeholder
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    DateView(date: Date())
                    VerseView(dailyVerse: dailyVerse)
                    Spacer()
                }
                .background(AppColor.background)
                BottomBar(
                    isCalendarPresented: $isCalendarPresented,
                    isBookmarked: $isBookmarked,
                    isShareSheetPresented: $isShareSheetPresented
                )
                CalendarView(isPresented: $isCalendarPresented, date: Date())
                    .opacity(isCalendarPresented ? 1 : 0)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            Text("ShareView")
        }
    }
}

struct DateView: View {
    var date: Date
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
    var dayString: String {
        let formatter = DateFormatter()
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
}
