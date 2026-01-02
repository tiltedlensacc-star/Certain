//
//  TestConfirmationView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct TestConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let item: SafetyItem

    var body: some View {
        VStack(spacing: 20) {
            Text("TEST VIEW")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Item: \(item.name)")
                .font(.headline)

            Text("Room: \(item.room)")
                .font(.subheadline)

            Button("Close") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
    }
}
