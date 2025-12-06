//
//  March16App.swift
//  March16
//
//  Created by 양시준 on 12/1/25.
//

import SwiftUI
import SwiftData

@main
struct March16App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Bookmark.self)
    }
}
