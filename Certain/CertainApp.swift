//
//  CertainApp.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

@main
struct CertainApp: App {
    init() {
        // Configure RevenueCat on app launch
        RevenueCatManager.shared.configure()
    }

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
    @State private var justSubscribed = false

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView(isPresented: $showSplash)
                    .transition(.opacity)
            } else if showOnboarding {
                OnboardingView(isPresented: $showOnboarding, justSubscribed: $justSubscribed)
                    .transition(.opacity)
            } else {
                MainTabView(justSubscribed: $justSubscribed)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: showOnboarding)
    }
}
