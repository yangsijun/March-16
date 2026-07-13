//
//  BibleVersion.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation

enum BibleVersion: String, CaseIterable {
    case nkrv = "NKRV"
    case webbe = "WEBBE"
    case kjv = "KJV"

    var code: String {
        rawValue
    }

    static var current: BibleVersion {
        // User preference takes priority
        if let userSelected = UserSettings.shared.selectedVersion {
            return userSelected
        }

        // Default based on language and region
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return version(for: languageCode)
    }

    static func version(for languageCode: String) -> BibleVersion {
        switch languageCode {
        case "ko":
            return .nkrv
        default:
            // Non-Korean defaults to WEBBE. KJV is intentionally excluded: it is
            // not seeded into CloudKit and is not offered in the settings picker.
            return .webbe
        }
    }
}
