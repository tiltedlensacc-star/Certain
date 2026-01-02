//
//  ItemCardView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct ItemCardView: View {
    let item: SafetyItem
    let onConfirm: () -> Void
    let onUnconfirm: (() -> Void)?
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onReassure: () -> Void

    @ObservedObject private var persistenceManager = PersistenceManager.shared
    @State private var showFullScreenPhoto = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 19, weight: .semibold))

                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.7))
                        Text(item.room)
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.7))
                    }
                }

                Spacer()

                // Status indicator
                HStack(spacing: 8) {
                    VStack(spacing: 4) {
                        Image(systemName: item.statusIcon)
                            .font(.title2)
                            .foregroundColor(item.state.color)
                            .opacity(item.state == .unconfirmed ? 0.3 : 1.0)

                        if item.state == .active {
                            Text(item.state.displayText)
                                .font(.caption)
                                .foregroundColor(item.state.color)
                        }
                    }

                    if item.state == .confirmed {
                        Text(item.type == .lockUnlock ? "Locked" : "Turned Off")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(item.state.color)
                    }
                }
            }

            // Description if available
            if let description = item.itemDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Photo thumbnail if available
            if let filename = item.photoFilename,
               let photo = persistenceManager.loadPhoto(filename: filename) {
                Button(action: {
                    showFullScreenPhoto = true
                }) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Last confirmed date
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(item.state == .confirmed ? .primary.opacity(0.85) : .secondary)
                if item.state == .confirmed {
                    let messageText = item.type == .lockUnlock ? "You locked this item on" : "You turned this item off on"
                    Text("\(messageText) \(item.formattedLastConfirmedDate)")
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.85))
                } else {
                    Text(item.formattedLastConfirmedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Action buttons
            VStack(spacing: 10) {
                // Primary action button
                Button(action: {
                    if item.state == .confirmed {
                        onUnconfirm?()
                    } else {
                        onConfirm()
                    }
                }) {
                    Text(item.actionButtonTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(item.state == .confirmed ? Color(hex: "#736CED").opacity(0.1) : Color(hex: "#736CED"))
                        .foregroundColor(item.state == .confirmed ? Color(hex: "#736CED") : .white)
                        .cornerRadius(10)
                }

                HStack(spacing: 10) {
                    // Reassure Me button (only if confirmed)
                    if item.state == .confirmed {
                        Button(action: onReassure) {
                            Text("Reassure Me")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#F9F5F2"))
                                .foregroundColor(.primary.opacity(0.7))
                                .cornerRadius(8)
                        }
                    }

                    // Edit button (only show when not confirmed)
                    if item.state != .confirmed {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                        }
                        .background(Color(hex: "#F9F5F2"))
                        .foregroundColor(.primary.opacity(0.7))
                        .cornerRadius(8)
                    }

                    // Delete button
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                    }
                    .background(Color(hex: "#F9F5F2"))
                    .foregroundColor(.red.opacity(0.7))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            Group {
                if item.state == .confirmed {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#F5EEFA"), location: 0.0),
                            .init(color: Color(hex: "#FDFCFD"), location: 0.5),
                            .init(color: Color(hex: "#FAF3EB"), location: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    Color(.systemBackground)
                }
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.state.color.opacity(item.state == .confirmed ? 0.2 : 0.3), lineWidth: item.state == .confirmed ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .fullScreenCover(isPresented: $showFullScreenPhoto) {
            if let filename = item.photoFilename,
               let photo = persistenceManager.loadPhoto(filename: filename) {
                FullScreenPhotoView(photo: photo)
            }
        }
    }
}

// MARK: - Full Screen Photo View
struct FullScreenPhotoView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: UIImage

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(1 - Double(abs(dragOffset) / 500))

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                }

                Spacer()

                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: dragOffset)
                    .scaleEffect(1 - abs(dragOffset) / 2000)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                isDragging = false
                                if abs(value.translation.height) > 150 {
                                    dismiss()
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )

                Spacer()
            }
        }
    }
}
