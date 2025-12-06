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

    var code: String {
        rawValue
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
            return .webbe
        }
    }
}
