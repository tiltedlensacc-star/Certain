//
//  RevenueCatPaywallView.swift
//  Certain
//
//  Created by Claude Code on 12/01/2026.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var revenueCatManager = RevenueCatManager.shared
    @Binding var justSubscribed: Bool

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        PaywallView()
            .onPurchaseCompleted { customerInfo in
                // Purchase completed successfully
                if customerInfo.entitlements["Certain Plus"]?.isActive == true {
                    justSubscribed = true
                    dismiss()
                }
            }
            .onRestoreCompleted { customerInfo in
                // Restore completed
                if customerInfo.entitlements["Certain Plus"]?.isActive == true {
                    justSubscribed = true
                    dismiss()
                }
            }
            .paywallFooter {
                // Custom footer with legal links
                VStack(spacing: 16) {
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
                    .padding(.bottom, 20)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
    }
}

#Preview {
    RevenueCatPaywallView(justSubscribed: .constant(false))
}
