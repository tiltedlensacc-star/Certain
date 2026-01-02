//
//  SplashScreenView.swift
//  Certain
//
//  Created by Ink Duangsri on 02/01/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isPresented: Bool
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var colorProgress: Double = 0.0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#ADA9F5").opacity(colorProgress), location: 0.0),
                    .init(color: Color(hex: "#7E7CE8").opacity(colorProgress), location: 0.2),
                    .init(color: Color(hex: "#4845B8").opacity(colorProgress), location: 0.4),
                    .init(color: Color(hex: "#4845B8").opacity(colorProgress), location: 1.0)
                ]),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .ignoresSafeArea()

            // App icon with animation
            VStack(spacing: 24) {
                Image("AboutPageIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .opacity(opacity)
                    .scaleEffect(scale)

                Text("Certain")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text("Peace of mind in your pocket")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // First phase: Fade in icon and scale
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1.0
            scale = 1.0
        }

        // Second phase: Add purple color
        withAnimation(.easeIn(duration: 0.8).delay(0.5)) {
            colorProgress = 1.0
        }

        // Dismiss after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
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
