//
//  OnboardingView.swift
//  Certain
//
//  Created by Ink Duangsri on 29/12/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    enum SubscriptionPlan {
        case monthly
        case yearly
        case free
    }

    var body: some View {
        ZStack {
            // Subtle gradient background
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
                TabView(selection: $currentPage) {
                    // Page 1: What is Certain
                    OnboardingPage1()
                        .tag(0)

                    // Page 2: How it works
                    OnboardingPage2()
                        .tag(1)

                    // Page 3: Choose Your Plan
                    OnboardingPage3(selectedPlan: $selectedPlan)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom buttons
                VStack(spacing: 12) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color(hex: "#736CED") : Color(hex: "#736CED").opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }
                    .padding(.bottom, 8)

                    if currentPage < 2 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#736CED"))
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            handleContinue()
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#736CED"))
                                .cornerRadius(12)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: currentPage)
                .padding()
                .padding(.bottom, 8)
            }
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }

    private func handlePurchase() {
        switch selectedPlan {
        case .monthly:
            subscriptionManager.purchaseMonthly()
        case .yearly:
            subscriptionManager.purchaseYearly()
        case .free:
            break
        }
    }

    private func handleContinue() {
        switch selectedPlan {
        case .monthly:
            subscriptionManager.purchaseMonthly()
        case .yearly:
            subscriptionManager.purchaseYearly()
        case .free:
            completeOnboarding()
        }
    }
}

// MARK: - Page 1: What is Certain
struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image("AboutPageIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                VStack(spacing: 8) {
                    (Text("Welcome to ")
                        .fontWeight(.regular) +
                     Text("Certain")
                        .fontWeight(.bold))
                        .font(.system(size: 32, design: .rounded))
                        .foregroundColor(Color(hex: "#736CED"))
                        .multilineTextAlignment(.center)

                    Text("Peace of mind in your pocket")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "#736CED"))
                        .multilineTextAlignment(.center)
                }
            }

            VStack(spacing: 16) {

                (Text("Certain helps ")
                    .fontWeight(.regular) +
                 Text("reduce anxiety and doubt")
                    .fontWeight(.bold) +
                 Text(" by giving you the ability to ")
                    .fontWeight(.regular) +
                 Text("confirm that you completed important safety tasks")
                    .fontWeight(.bold) +
                 Text(" before leaving home.")
                    .fontWeight(.regular))
                    .font(.body)
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .opacity(0.7)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

// MARK: - Page 2: How it works
struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image("HowItWorksIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("How It Works")
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "#736CED"))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 24) {
                OnboardingStep(
                    number: "1",
                    title: "Create Items",
                    description: "Add the things you want to record - doors, lights, gas hobs, appliances, windows, etc."
                )

                OnboardingStep(
                    number: "2",
                    title: "Confirm Actions",
                    description: "When you lock or switch off each item, log that action in this app and record it with an optional photo."
                )

                OnboardingStep(
                    number: "3",
                    title: "Find Reassurance",
                    description: "Review your logged confirmations anytime to ease your mind."
                )

                Text("Certain is a logging tool and does not physically lock or control any items.")
                    .font(.caption)
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .opacity(0.5)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

// MARK: - Page 3: Choose Your Plan
struct OnboardingPage3: View {
    @Binding var selectedPlan: OnboardingView.SubscriptionPlan

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

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

            // Plan options
            VStack(spacing: 12) {
                // Annual
                PlanButton(
                    title: "Annual",
                    price: "£6.99/year",
                    savings: "Save £4.89",
                    isSelected: selectedPlan == .yearly,
                    action: { selectedPlan = .yearly }
                )

                // Monthly
                PlanButton(
                    title: "Monthly",
                    price: "£0.99/month",
                    savings: nil,
                    isSelected: selectedPlan == .monthly,
                    action: { selectedPlan = .monthly }
                )

                Text("or")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#4A4A4A"))
                    .opacity(0.6)

                // Free
                Button(action: {
                    selectedPlan = .free
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Free")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#736CED"))

                            Text("Track up to 5 items")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                        }

                        Spacer()

                        Image(systemName: selectedPlan == .free ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(selectedPlan == .free ? Color(hex: "#736CED") : Color(hex: "#736CED").opacity(0.3))
                    }
                    .padding()
                    .background(selectedPlan == .free ? Color(hex: "#E8E7FC") : Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPlan == .free ? Color(hex: "#736CED") : Color(hex: "#E0E0E0"), lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 24)

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
            .padding(.top, 12)

            Spacer()
        }
    }
}

// MARK: - Onboarding Feature Row Component
struct OnboardingFeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Text("•")
                .foregroundColor(Color(hex: "#4A4A4A"))
            Text(text)
                .font(.body)
                .foregroundColor(Color(hex: "#4A4A4A"))
        }
    }
}

// MARK: - Plan Button Component
struct PlanButton: View {
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

// MARK: - Onboarding Step Component
struct OnboardingStep: View {
    let number: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#E8E7FC"))
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#736CED"))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#736CED"))

                Text(description)
                    .font(.body)
                    .foregroundColor(Color(hex: "#4A4A4A"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
