//
//  MainTabView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct MainTabView: View {
    @Binding var justSubscribed: Bool
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(justSubscribed: $justSubscribed)
                .tabItem {
                    Label("Items", systemImage: "checklist")
                }
                .tag(0)

            InfoView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(1)
        }
        .accentColor(Color(hex: "#736CED"))
    }
}

#Preview {
    MainTabView(justSubscribed: .constant(false))
}
