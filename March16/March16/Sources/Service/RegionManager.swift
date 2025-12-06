//
//  RegionManager.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import Foundation
import StoreKit

final class RegionManager {
    static let shared = RegionManager()

    private(set) var storefrontCountryCode: String?
    private var hasCheckedStorefront = false

    private init() {}

    var isUK: Bool {
        storefrontCountryCode == "GBR"
    }

    func fetchStorefront() async {
        guard !hasCheckedStorefront else { return }
        hasCheckedStorefront = true

        do {
            if let storefront = await Storefront.current {
                storefrontCountryCode = storefront.countryCode
            }
        }
    }

    func fetchStorefrontSync(completion: @escaping (String?) -> Void) {
        Task {
            await fetchStorefront()
            await MainActor.run {
                completion(storefrontCountryCode)
            }
        }
    }
}
