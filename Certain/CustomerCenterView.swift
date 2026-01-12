//
//  CustomerCenterView.swift
//  Certain
//
//  Created by Claude Code on 12/01/2026.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct CustomerCenterView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        RevenueCatUI.CustomerCenterView()
            .onRestoreCompleted { customerInfo in
                // Handle restore completion if needed
                print("Restore completed with customer info: \(customerInfo)")
            }
    }
}

#Preview {
    CustomerCenterView()
}
