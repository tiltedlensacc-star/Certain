//
//  InfoView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct InfoView: View {
    @State private var showCertainPlus = false
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#ADA9F5"), location: 0.0),
                    .init(color: Color(hex: "#7E7CE8"), location: 0.2),
                    .init(color: Color(hex: "#4845B8"), location: 0.4),
                    .init(color: Color(hex: "#4845B8"), location: 1.0)
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Content area
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon
                        Image("HowItWorksIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding(.top, 8)

                        // Upgrade button
                        if !subscriptionManager.isPremium {
                            Button(action: {
                                showCertainPlus = true
                            }) {
                                Text("Upgrade to Certain Plus")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "#736CED"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(hex: "#736CED").opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }

                        // About section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Certain is designed to help reduce anxiety and doubt by giving you the ability to confirm that you completed important safety tasks before leaving home.")
                                .font(.body)
                                .foregroundColor(Color(hex: "#4A4A4A"))

                            Text("You can record actions like locking doors and windows or switching off lights, gas hobs, and appliances with date + timestamps and photos for peace of mind.")
                                .font(.body)
                                .foregroundColor(Color(hex: "#4A4A4A"))

                            Text("Certain aims to helps reassure you in everyday life, as well as on vacations.")
                                .font(.body)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()

                        // Feature steps
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureStep(
                                number: "1",
                                title: "Create Items",
                                description: "Add the things you want to record - doors, lights, gas hobs, appliances, windows, etc."
                            )

                            FeatureStep(
                                number: "2",
                                title: "Confirm Actions",
                                description: "When you lock or switch off each item, log that action in this app and record it with an optional photo."
                            )

                            FeatureStep(
                                number: "3",
                                title: "Find Reassurance",
                                description: "Review your logged confirmations anytime to ease your mind."
                            )

                            Text("Certain is a logging tool and does not physically lock or control any items.")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#4A4A4A"))
                                .opacity(0.5)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Certain Plus info
                        VStack(alignment: .leading, spacing: 16) {
                            (Text("Add ")
                                .fontWeight(.regular)
                                .foregroundColor(Color(hex: "#736CED")) +
                             Text("Unlimited")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#5B54D6")) +
                             Text(" Items and Photos with Certain Plus")
                                .fontWeight(.regular)
                                .foregroundColor(Color(hex: "#736CED")))
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Divider()

                            Text("£0.99/month or £6.99/year for unlimited items, photos and access to future features.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            if !subscriptionManager.isPremium {
                                Divider()

                                Button(action: {
                                    showCertainPlus = true
                                }) {
                                    Text("Upgrade to Certain Plus")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color(hex: "#736CED"))
                                        .cornerRadius(12)
                                }

                                // Restore Purchases button
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
                                .disabled(isRestoring)
                                .padding(.top, 8)
                            } else {
                                Divider()

                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                    Text("You have Certain Plus!")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#736CED").opacity(0.15), lineWidth: 1)
                        )
                        .padding(.vertical, 8)

                        // Legal & Support links
                        VStack(spacing: 16) {
                            Text("Legal & Support")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(hex: "#736CED"))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                LinkButton(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    url: "https://tiltedlensacc-star.github.io/Certain/support.html"
                                )

                                LinkButton(
                                    icon: "envelope.fill",
                                    title: "Contact Us",
                                    url: "https://tiltedlensacc-star.github.io/Certain/contact.html"
                                )

                                LinkButton(
                                    icon: "doc.text.fill",
                                    title: "Privacy Policy",
                                    url: "https://tiltedlensacc-star.github.io/Certain/privacy-policy.html"
                                )

                                LinkButton(
                                    icon: "checkmark.shield.fill",
                                    title: "Terms of Use",
                                    url: "https://tiltedlensacc-star.github.io/Certain/terms-of-use.html"
                                )
                            }
                        }

                        // Privacy section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .foregroundColor(Color(hex: "#736CED"))
                                Text("Your Privacy Matters")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }

                            Text("All your data stays on your device. No cloud storage, no tracking, no accounts required. Your confirmations are yours alone.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Reset buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                resetSplashScreen()
                            }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Show Splash Animation Again")
                                }
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#736CED"))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#736CED").opacity(0.1))
                                .cornerRadius(10)
                            }

                            Button(action: {
                                resetOnboarding()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Show Onboarding Again")
                                }
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#736CED"))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#736CED").opacity(0.1))
                                .cornerRadius(10)
                            }
                        }

                        // Version info
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 80)
                    }
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $showCertainPlus) {
            CertainPlusView()
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreMessage)
        }
    }

    private func handleRestore() async {
        isRestoring = true
        await subscriptionManager.restorePurchases()
        isRestoring = false

        restoreMessage = subscriptionManager.isPremium ? "Your subscription has been restored!" : "No previous purchases found."
        showRestoreAlert = true
    }

    private func resetSplashScreen() {
        UserDefaults.standard.set(false, forKey: "hasSeenSplashScreen")
        UserDefaults.standard.set(false, forKey: "hasAnimatedEmptyState")
        // Show an alert to inform the user
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            let alert = UIAlertController(
                title: "Splash Screen Reset",
                message: "Close and reopen the app to see the splash animation again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            window.rootViewController?.present(alert, animated: true)
        }
    }

    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(false, forKey: "hasAnimatedEmptyState")
        // Need to restart the app to see the onboarding
        // Show an alert to inform the user
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first {
            let alert = UIAlertController(
                title: "Onboarding Reset",
                message: "Close and reopen the app to see the onboarding again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            window.rootViewController?.present(alert, animated: true)
        }
    }

    private var headerView: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("About")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Learn more about Certain")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                if subscriptionManager.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .padding(.trailing, 16)
                } else {
                    Button(action: {
                        showCertainPlus = true
                    }) {
                        Image(systemName: "crown.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

struct FeatureStep: View {
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

struct LinkButton: View {
    let icon: String
    let title: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#736CED"))
                    .frame(width: 24)

                Text(title)
                    .font(.body)
                    .foregroundColor(Color(hex: "#4A4A4A"))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(hex: "#736CED").opacity(0.05))
            .cornerRadius(10)
        }
    }
}

#Preview {
    InfoView()
}
