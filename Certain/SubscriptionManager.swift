//
//  SubscriptionManager.swift
//  Certain
//
//  Created by Ink Duangsri on 29/12/2025.
//

import Foundation
import SwiftUI

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isPremium: Bool {
        didSet {
            UserDefaults.standard.set(isPremium, forKey: "isPremium")
        }
    }

    let freeItemLimit = 5

    private init() {
        self.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
    }

    func canAddMoreItems(currentCount: Int) -> Bool {
        if isPremium {
            return true
        }
        return currentCount < freeItemLimit
    }

    func purchaseMonthly() {
        // TODO: Implement actual StoreKit purchase
        // For now, just simulate the purchase
        isPremium = true
    }

    func purchaseYearly() {
        // TODO: Implement actual StoreKit purchase
        // For now, just simulate the purchase
        isPremium = true
    }

    func restorePurchases() {
        // TODO: Implement actual StoreKit restore
        // For now, check UserDefaults
    }
}
