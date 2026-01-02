//
//  CertainPlusView.swift
//  Certain
//
//  Created by Ink Duangsri on 29/12/2025.
//

import SwiftUI

struct CertainPlusView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan = .monthly

    enum SubscriptionPlan {
        case monthly
        case yearly

        var price: String {
            switch self {
            case .monthly: return "£0.99"
            case .yearly: return "£6.99"
            }
        }

        var period: String {
            switch self {
            case .monthly: return "month"
            case .yearly: return "year"
            }
        }

        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save £4.89"
            }
        }
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
                            CertainPlusPlanButton(
                                title: "Annual",
                                price: "£6.99/year",
                                savings: "Save £4.89",
                                isSelected: selectedPlan == .yearly,
                                action: { selectedPlan = .yearly }
                            )

                            // Monthly
                            CertainPlusPlanButton(
                                title: "Monthly",
                                price: "£0.99/month",
                                savings: nil,
                                isSelected: selectedPlan == .monthly,
                                action: { selectedPlan = .monthly }
                            )
                        }
                        .padding(.horizontal, 24)

                        // Subscribe button
                        Button(action: {
                            handlePurchase()
                        }) {
                            Text("Unlock Ultimate Peace of Mind")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#736CED"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)

                        // Restore purchases
                        Button(action: {
                            subscriptionManager.restorePurchases()
                        }) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#736CED"))
                        }
                        .padding(.top, 8)

                        // Terms
                        Text("Subscription auto-renews. Cancel anytime.")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#4A4A4A"))
                            .opacity(0.6)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func handlePurchase() {
        switch selectedPlan {
        case .monthly:
            subscriptionManager.purchaseMonthly()
        case .yearly:
            subscriptionManager.purchaseYearly()
        }
        dismiss()
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
