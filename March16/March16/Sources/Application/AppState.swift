//
//  AppState.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

@Observable
final class AppState {
    static let shared = AppState()

    var isKJVReady: Bool = false

    private init() {}

    func markKJVReady() {
        isKJVReady = true
    }
}
