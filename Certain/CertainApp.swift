//
//  CertainApp.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

@main
struct CertainApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @State private var showSplash = !UserDefaults.standard.bool(forKey: "hasSeenSplashScreen")
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        Group {
            if showSplash {
                SplashScreenView(isPresented: $showSplash)
            } else if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
            } else {
                MainTabView()
            }
        }
    }
}
