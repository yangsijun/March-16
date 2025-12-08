//
//  BottomBar.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct BottomBar: View {
    @Binding var isCalendarPresented: Bool
    var isBookmarked: Bool
    @Binding var isShareSheetPresented: Bool
    @Binding var isSettingsPresented: Bool
    @Binding var calendarDate: Date
    @Binding var selectedDate: Date?
    var isToday: Bool
    var onBookmarkTapped: () -> Void
    var onTodayTapped: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                BottomBarButton {
                    withAnimation {
                        calendarDate = Date()
                        selectedDate = Date()
                        isCalendarPresented = true
                    }
                } label: {
                    Label("Calendar", systemImage: "calendar")
                }

                if !isToday {
                    BottomBarButton {
                        withAnimation {
                            onTodayTapped()
                        }
                    } label: {
                        Label("Today", systemImage: "arrow.uturn.backward")
                    }
                }

                Spacer()

                BottomBarButton {
                    withAnimation {
                        onBookmarkTapped()
                    }
                } label: {
                    Label("Bookmark", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                }
                BottomBarButton {
                    withAnimation {
                        isShareSheetPresented = true
                    }
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                BottomBarButton {
                    isSettingsPresented = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

struct BottomBarButton<Label: View>: View {
    var action: () -> Void
    var label: Label
    
    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(AppColor.background)
                .frame(width: 48, height: 48)
                .overlay(
                    label
                        .labelStyle(.iconOnly)
                        .appFont(.bottomBarIcon)
                )
        }
        .foregroundStyle(AppColor.primary)
    }
}

#Preview {
    @Previewable @State var isCalendarPresented: Bool = false
    @Previewable @State var isBookmarked: Bool = false
    @Previewable @State var isShareSheetPresented: Bool = false
    @Previewable @State var isSettingsPresented: Bool = false
    @Previewable @State var calendarDate: Date = Date()
    @Previewable @State var selectedDate: Date? = Date()

    VStack {
        Spacer()
        BottomBar(
            isCalendarPresented: $isCalendarPresented,
            isBookmarked: isBookmarked,
            isShareSheetPresented: $isShareSheetPresented,
            isSettingsPresented: $isSettingsPresented,
            calendarDate: $calendarDate,
            selectedDate: $selectedDate,
            isToday: false,
            onBookmarkTapped: { isBookmarked.toggle() },
            onTodayTapped: {}
        )
    }
}
