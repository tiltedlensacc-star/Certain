//
//  RevenueCatManager.swift
//  Certain
//
//  Created by Claude Code on 12/01/2026.
//

import Foundation
import SwiftUI
import RevenueCat

/// Manages all RevenueCat subscription and entitlement functionality
class RevenueCatManager: NSObject, ObservableObject {
    static let shared = RevenueCatManager()

    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var customerInfo: CustomerInfo?

    // MARK: - Constants
    let freeItemLimit = 5
    private let apiKey = "test_VFcPHQInZhFydKjJoqyULfPWFZM"
    private let entitlementIdentifier = "Certain Plus"

    // MARK: - Debug Settings
    // Set this to true to bypass purchases and test premium features
    // REMEMBER TO SET TO FALSE BEFORE APP STORE SUBMISSION!
    private let debugBypassPurchases = false // Change to true for testing

    // MARK: - Initialization
    private override init() {
        super.init()
        // Configuration happens in configure()
    }

    // MARK: - Configuration
    /// Configure RevenueCat on app launch
    func configure() {
        Purchases.logLevel = .debug // Set to .info or .error in production
        Purchases.configure(withAPIKey: apiKey)

        // Set up delegate
        Purchases.shared.delegate = self

        // Initial fetch of customer info
        Task { @MainActor in
            await fetchCustomerInfo()
        }
    }

    // MARK: - Customer Info
    /// Fetch current customer info and update entitlement status
    @MainActor
    func fetchCustomerInfo() async {
        isLoading = true

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.customerInfo = customerInfo
            self.isPremium = customerInfo.entitlements[entitlementIdentifier]?.isActive == true
            self.isLoading = false
        } catch {
            print("Failed to fetch customer info: \(error.localizedDescription)")
            self.isPremium = false
            self.isLoading = false
        }
    }

    // MARK: - Purchases
    /// Purchase a specific package
    @MainActor
    func purchase(package: Package) async throws -> CustomerInfo {
        isLoading = true

        do {
            let result = try await Purchases.shared.purchase(package: package)
            let customerInfo = result.customerInfo

            self.customerInfo = customerInfo
            self.isPremium = customerInfo.entitlements[entitlementIdentifier]?.isActive == true
            self.isLoading = false

            return customerInfo
        } catch let error as ErrorCode {
            print("❌ Purchase Error Code: \(error.errorCode)")
            print("❌ Purchase Error: \(error.localizedDescription)")
            self.isLoading = false
            throw error
        } catch {
            print("❌ Purchase Error: \(error.localizedDescription)")
            self.isLoading = false
            throw error
        }
    }

    // MARK: - Restore Purchases
    /// Restore previously purchased subscriptions
    @MainActor
    func restorePurchases() async throws -> CustomerInfo {
        isLoading = true

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()

            self.customerInfo = customerInfo
            self.isPremium = customerInfo.entitlements[entitlementIdentifier]?.isActive == true
            self.isLoading = false

            return customerInfo
        } catch {
            self.isLoading = false
            throw error
        }
    }

    // MARK: - Offerings
    /// Get current offerings
    func getCurrentOffering() async throws -> Offering? {
        let offerings = try await Purchases.shared.offerings()
        return offerings.current
    }

    // MARK: - Item Limit
    /// Check if user can add more items
    func canAddMoreItems(currentCount: Int) -> Bool {
        if isPremium {
            return true
        }
        return currentCount < freeItemLimit
    }

    // MARK: - Subscription Status
    /// Get a user-friendly subscription status string
    func getSubscriptionStatus() -> String {
        guard let customerInfo = customerInfo else {
            return "Not subscribed"
        }

        if let entitlement = customerInfo.entitlements[entitlementIdentifier], entitlement.isActive {
            if let expirationDate = entitlement.expirationDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Active until \(formatter.string(from: expirationDate))"
            }
            return "Active"
        }

        return "Not subscribed"
    }

    // MARK: - User Management
    /// Log in a user with a custom user ID (optional)
    @MainActor
    func login(userId: String) async throws {
        _ = try await Purchases.shared.logIn(userId)
        await fetchCustomerInfo()
    }

    /// Log out the current user
    @MainActor
    func logout() async throws {
        _ = try await Purchases.shared.logOut()
        self.isPremium = false
        self.customerInfo = nil
    }
}

// MARK: - PurchasesDelegate
extension RevenueCatManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.isPremium = customerInfo.entitlements[entitlementIdentifier]?.isActive == true
        }
    }
}
