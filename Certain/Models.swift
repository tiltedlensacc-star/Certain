//
//  Models.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import Foundation
import SwiftUI

// MARK: - Item Type
enum ItemType: String, Codable, CaseIterable {
    case lockUnlock = "Lock/Unlock"
    case onOff = "On/Off"

    var confirmActionTitle: String {
        switch self {
        case .lockUnlock:
            return "Mark as Locked"
        case .onOff:
            return "Mark as Off"
        }
    }

    var unconfirmActionTitle: String {
        return "Reset"
    }

    var confirmedIcon: String {
        switch self {
        case .lockUnlock:
            return "lock.fill"
        case .onOff:
            return "power"
        }
    }

    var unconfirmedIcon: String {
        switch self {
        case .lockUnlock:
            return "lock.open.fill"
        case .onOff:
            return "power"
        }
    }
}

// MARK: - Item State
enum ItemState: String, Codable {
    case unconfirmed    // New items, no confirmation yet
    case active         // Unlocked or On
    case confirmed      // Locked or Off

    var color: Color {
        switch self {
        case .unconfirmed:
            return .gray
        case .active:
            return .orange
        case .confirmed:
            return Color(red: 0.0, green: 0.5, blue: 0.0)
        }
    }

    var displayText: String {
        switch self {
        case .unconfirmed:
            return "Unconfirmed"
        case .active:
            return "Unlocked"
        case .confirmed:
            return "Confirmed"
        }
    }
}

// MARK: - Safety Item
struct SafetyItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var room: String
    var itemDescription: String?
    var type: ItemType
    var state: ItemState
    var lastConfirmedDate: Date?
    var photoFilename: String?
    var createdDate: Date

    init(
        id: UUID = UUID(),
        name: String,
        room: String,
        itemDescription: String? = nil,
        type: ItemType,
        state: ItemState = .unconfirmed,
        lastConfirmedDate: Date? = nil,
        photoFilename: String? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.room = room
        self.itemDescription = itemDescription
        self.type = type
        self.state = state
        self.lastConfirmedDate = lastConfirmedDate
        self.photoFilename = photoFilename
        self.createdDate = createdDate
    }

    var actionButtonTitle: String {
        switch state {
        case .unconfirmed, .active:
            return type.confirmActionTitle
        case .confirmed:
            return type.unconfirmActionTitle
        }
    }

    var secondaryActionTitle: String? {
        switch state {
        case .confirmed:
            return type.unconfirmActionTitle
        case .unconfirmed, .active:
            return nil
        }
    }

    var statusIcon: String {
        switch state {
        case .confirmed:
            return type.confirmedIcon
        case .unconfirmed, .active:
            return type.unconfirmedIcon
        }
    }

    var formattedLastConfirmedDate: String {
        guard let date = lastConfirmedDate else {
            return "You haven't confirmed this item before"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Common Rooms
struct Room {
    static let common = [
        "Living Room",
        "Bedroom",
        "Kitchen",
        "Bathroom",
        "Hallway",
        "Front Door",
        "Back Door",
        "Garage",
        "Garden",
        "Office",
        "Other"
    ]
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 115, 108, 237) // Default to #736CED
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
