//
//  CalendarBottomBar.swift
//  March16
//
//  Created by 양시준 on 12/2/25.
//

import SwiftUI

struct CalendarBottomBar: View {
    @Binding var date: Date
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        date = date.plusMonth(-1)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Prev")
                    }
                }
                .frame(height: 48)
                Spacer()
                Button {
                    withAnimation {
                        date = date.plusMonth(1)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(height: 48)
            }
            .font(.system(size: 14, weight: .semibold, design: .serif))
            .foregroundStyle(Color("AppTertiaryColor"))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    @Previewable @State var date: Date = Date()
    CalendarBottomBar(date: $date)
}
