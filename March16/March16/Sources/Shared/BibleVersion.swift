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

    /// Returns true if this version requires KJV database (ODR)
    var requiresKJVDatabase: Bool {
        self == .kjv
    }

    static var current: BibleVersion {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return version(for: languageCode)
    }

    static func version(for languageCode: String) -> BibleVersion {
        switch languageCode {
        case "ko":
            return .nkrv
        default:
            // For non-Korean: UK uses WEBBE, others use KJV (if available)
            if RegionManager.shared.isUK {
                return .webbe
            } else {
                // Fall back to WEBBE if KJV database is not yet available
                return DatabaseManager.shared.isKJVAttached ? .kjv : .webbe
            }
        }
    }
}
