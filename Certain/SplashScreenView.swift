//
//  SplashScreenView.swift
//  Certain
//
//  Created by Ink Duangsri on 02/01/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isPresented: Bool
    @State private var iconOpacity: Double = 0.0
    @State private var iconScale: CGFloat = 0.85
    @State private var gradientOpacity: Double = 0.0
    @State private var splashOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea()

            // Subtle purple gradient overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#EFE0F7"), location: 0.0),
                    .init(color: Color(hex: "#FDFCFD"), location: 0.4),
                    .init(color: Color(hex: "#F5E5D5"), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(gradientOpacity)
            .ignoresSafeArea()

            // App icon - centered
            Image("AboutPageIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .opacity(iconOpacity)
                .scaleEffect(iconScale)
        }
        .opacity(splashOpacity)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Phase 1: Slower fade in and scale the icon
        withAnimation(.easeOut(duration: 1.6)) {
            iconOpacity = 1.0
            iconScale = 1.0
        }

        // Phase 2: Subtle gradient fade in
        withAnimation(.easeIn(duration: 1.2).delay(0.6)) {
            gradientOpacity = 0.6
        }

        // Dismiss after shorter total duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                splashOpacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                markSplashAsShown()
                isPresented = false
            }
        }
    }

    private func markSplashAsShown() {
        UserDefaults.standard.set(true, forKey: "hasSeenSplashScreen")
    }
}

#Preview {
    SplashScreenView(isPresented: .constant(true))
}
