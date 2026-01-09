//
//  SubscriptionManager.swift
//  Certain
//
//  Created by Ink Duangsri on 29/12/2025.
//

import Foundation
import SwiftUI
import StoreKit

// Product IDs - these MUST match what you create in App Store Connect
enum SubscriptionProduct: String, CaseIterable {
    case monthly = "com.junkle.certain.premium.monthly"
    case yearly = "com.junkle.certain.premium.yearly"
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isPremium: Bool = false
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []

    let freeItemLimit = 5

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // Listen for transaction updates
    func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    // Load products from App Store
    func loadProducts() async {
        do {
            let productIDs = SubscriptionProduct.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // Check subscription status
    func updateSubscriptionStatus() async {
        var validSubscription = false

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check if it's one of our subscription products and not expired
                if transaction.productType == .autoRenewable {
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        validSubscription = true
                        purchasedProductIDs.insert(transaction.productID)
                    }
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }

        isPremium = validSubscription
    }

    // Purchase a product
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction

        case .userCancelled, .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // Restore purchases
    func restorePurchases() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }

    // Check if user can add more items
    func canAddMoreItems(currentCount: Int) -> Bool {
        if isPremium {
            return true
        }
        return currentCount < freeItemLimit
    }

    // Verify transaction
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // Helper methods for UI
    func purchaseMonthly() {
        Task {
            guard let product = products.first(where: { $0.id == SubscriptionProduct.monthly.rawValue }) else {
                print("Monthly product not found")
                return
            }
            do {
                _ = try await purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }

    func purchaseYearly() {
        Task {
            guard let product = products.first(where: { $0.id == SubscriptionProduct.yearly.rawValue }) else {
                print("Yearly product not found")
                return
            }
            do {
                _ = try await purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

// StoreKit Errors
enum StoreError: Error {
    case failedVerification
}
