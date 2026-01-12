//
//  CertainPlusView.swift
//  Certain
//
//  Created by Ink Duangsri on 29/12/2025.
//  Updated to use RevenueCat backend with custom UI
//

import SwiftUI
import RevenueCat

struct CertainPlusView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var revenueCatManager = RevenueCatManager.shared
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showRestoreSuccess = false
    @State private var packages: [Package] = []

    enum SubscriptionPlan {
        case monthly
        case yearly
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#EFE0F7"), location: 0.0),
                    .init(color: Color(hex: "#FDFCFD"), location: 0.4),
                    .init(color: Color(hex: "#F5E5D5"), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#736CED"))
                    }
                    .padding()
                }

                ScrollView {
                    VStack(spacing: 24) {
                        // Icon and title
                        VStack(spacing: 16) {
                            Image("ChoosePlanIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)

                            (Text("Add ")
                                .fontWeight(.regular)
                                .foregroundColor(Color(hex: "#736CED")) +
                             Text("Unlimited")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#5B54D6")) +
                             Text(" Items and Photos with Certain Plus")
                                .fontWeight(.regular)
                                .foregroundColor(Color(hex: "#736CED")))
                                .font(.system(size: 32, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)

                            Text("For ultimate peace of mind and reassurance")
                                .font(.body)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 20)

                        // Pricing options
                        VStack(spacing: 12) {
                            // Annual
                            if let yearlyPackage = packages.first(where: { $0.storeProduct.productIdentifier.contains("yearly") }) {
                                CertainPlusPlanButton(
                                    title: "Annual",
                                    price: yearlyPackage.localizedPriceString,
                                    savings: "Save 41%",
                                    isSelected: selectedPlan == .yearly,
                                    action: { selectedPlan = .yearly }
                                )
                            } else {
                                CertainPlusPlanButton(
                                    title: "Annual",
                                    price: "£6.99/year",
                                    savings: "Save 41%",
                                    isSelected: selectedPlan == .yearly,
                                    action: { selectedPlan = .yearly }
                                )
                            }

                            // Monthly
                            if let monthlyPackage = packages.first(where: { $0.storeProduct.productIdentifier.contains("monthly") }) {
                                CertainPlusPlanButton(
                                    title: "Monthly",
                                    price: monthlyPackage.localizedPriceString,
                                    savings: nil,
                                    isSelected: selectedPlan == .monthly,
                                    action: { selectedPlan = .monthly }
                                )
                            } else {
                                CertainPlusPlanButton(
                                    title: "Monthly",
                                    price: "£0.99/month",
                                    savings: nil,
                                    isSelected: selectedPlan == .monthly,
                                    action: { selectedPlan = .monthly }
                                )
                            }
                        }
                        .padding(.horizontal, 24)

                        // Subscribe button
                        Button(action: {
                            Task {
                                await handlePurchase()
                            }
                        }) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                    Text("Processing...")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                } else {
                                    Text("Unlock Ultimate Peace of Mind")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isPurchasing ? Color(hex: "#736CED").opacity(0.7) : Color(hex: "#736CED"))
                            .cornerRadius(12)
                        }
                        .disabled(isPurchasing)
                        .padding(.horizontal, 24)

                        // Restore purchases
                        Button(action: {
                            Task {
                                await handleRestore()
                            }
                        }) {
                            HStack(spacing: 6) {
                                if isRestoring {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#736CED")))
                                        .scaleEffect(0.8)
                                }
                                Text(isRestoring ? "Restoring..." : "Restore Purchases")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(Color(hex: "#736CED"))
                        }
                        .disabled(isRestoring || isPurchasing)
                        .padding(.top, 12)

                        // Subscription Terms
                        VStack(spacing: 12) {
                            Text("Certain Plus is an auto-renewable subscription. Your subscription will automatically renew at the end of each billing period unless cancelled at least 24 hours before the renewal date.")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)

                            Text("Cancel anytime in your App Store account settings.")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                                .opacity(0.7)
                                .multilineTextAlignment(.center)

                            // Legal links
                            HStack(spacing: 8) {
                                Button(action: {
                                    if let url = URL(string: "https://tiltedlensacc-star.github.io/Certain/privacy-policy.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Privacy Policy")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#736CED"))
                                        .underline()
                                }

                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#4A4A4A"))
                                    .opacity(0.5)

                                Button(action: {
                                    if let url = URL(string: "https://tiltedlensacc-star.github.io/Certain/terms-of-use.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Terms of Use")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#736CED"))
                                        .underline()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .task {
            await loadOfferings()
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Restore Successful", isPresented: $showRestoreSuccess) {
            Button("OK", role: .cancel) {
                if revenueCatManager.isPremium {
                    dismiss()
                }
            }
        } message: {
            Text(revenueCatManager.isPremium ? "Your subscription has been restored!" : "No previous purchases found.")
        }
    }

    private func loadOfferings() async {
        do {
            if let offering = try await revenueCatManager.getCurrentOffering() {
                packages = offering.availablePackages
                print("📦 Loaded \(packages.count) packages from RevenueCat:")
                for package in packages {
                    print("  - \(package.storeProduct.productIdentifier): \(package.localizedPriceString)")
                }
            } else {
                print("⚠️ No current offering found in RevenueCat")
            }
        } catch {
            print("❌ Failed to load offerings: \(error)")
        }
    }

    private func handlePurchase() async {
        isPurchasing = true

        do {
            // Find the selected package
            let packageToPurchase: Package?
            switch selectedPlan {
            case .monthly:
                packageToPurchase = packages.first(where: { $0.storeProduct.productIdentifier.contains("monthly") })
            case .yearly:
                packageToPurchase = packages.first(where: { $0.storeProduct.productIdentifier.contains("yearly") })
            }

            guard let package = packageToPurchase else {
                errorMessage = "Product not available. Please try again later."
                showError = true
                isPurchasing = false
                return
            }

            _ = try await revenueCatManager.purchase(package: package)

            isPurchasing = false

            // Dismiss if purchase was successful
            if revenueCatManager.isPremium {
                dismiss()
            }
        } catch {
            isPurchasing = false
            errorMessage = "Purchase failed. Please try again."
            showError = true
        }
    }

    private func handleRestore() async {
        isRestoring = true

        do {
            _ = try await revenueCatManager.restorePurchases()
        } catch {
            errorMessage = "Failed to restore purchases."
            showError = true
        }

        isRestoring = false
        showRestoreSuccess = true
    }
}

// MARK: - Plan Button Component
struct CertainPlusPlanButton: View {
    let title: String
    let price: String
    let savings: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#736CED"))

                    if let savings = savings {
                        Text(savings)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                Text(price)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#736CED"))

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? Color(hex: "#736CED") : Color(hex: "#736CED").opacity(0.3))
            }
            .padding()
            .background(isSelected ? Color(hex: "#E8E7FC") : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "#736CED") : Color(hex: "#E0E0E0"), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CertainPlusView()
}
