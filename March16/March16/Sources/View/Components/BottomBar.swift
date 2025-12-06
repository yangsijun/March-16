//
//  BottomBar.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct BottomBar: View {
    @Binding var isCalendarPresented: Bool
    @Binding var isBookmarked: Bool
    @Binding var isShareSheetPresented: Bool
    @Binding var calendarDate: Date
    @Binding var selectedDate: Date?

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
                
                Spacer()
                
                BottomBarButton {
                    withAnimation {
                        isBookmarked.toggle()
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
                        .font(.system(size: 22, weight: .semibold))
                )
        }
        .foregroundStyle(AppColor.primary)
    }
}

#Preview {
    @Previewable @State var isCalendarPresented: Bool = false
    @Previewable @State var isBookmarked: Bool = false
    @Previewable @State var isShareSheetPresented: Bool = false
    @Previewable @State var calendarDate: Date = Date()
    @Previewable @State var selectedDate: Date? = Date()

    VStack {
        Spacer()
        BottomBar(isCalendarPresented: $isCalendarPresented, isBookmarked: $isBookmarked, isShareSheetPresented: $isShareSheetPresented, calendarDate: $calendarDate, selectedDate: $selectedDate)
    }
}
