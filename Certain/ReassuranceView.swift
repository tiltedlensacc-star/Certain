//
//  ReassuranceView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct ReassuranceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var persistenceManager = PersistenceManager.shared
    @State private var showFullScreenPhoto = false
    @State private var isPulsing = false

    let item: SafetyItem

    private func timeAgoText(from date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)

        if seconds < 60 {
            return "\(seconds) second\(seconds == 1 ? "" : "s") ago"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = seconds / 86400
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }

    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#EFE0F7"), location: 0.0),
                    .init(color: Color(hex: "#FDFCFD"), location: 0.4),
                    .init(color: Color(hex: "#F5E5D5"), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                // Header
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                // Calm reminder
                VStack(spacing: 8) {
                    Text("You can trust this record")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#333333"))

                    Text("Take a deep breath. Everything is okay.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .padding(.horizontal)

                // Reassuring icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "#40AD7C").opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isPulsing
                        )

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "#40AD7C"))
                }
                .onAppear {
                    isPulsing = true
                }
                .padding(.top, 16)

                // Reassuring messages
                VStack(spacing: 4) {
                    Text("Don't worry.")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#40AD7C"))
                        .multilineTextAlignment(.center)

                    let actionText = item.type == .lockUnlock ? "locked this." : "switched this off."
                    Text("You \(actionText)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#40AD7C"))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 16)

                // Item details
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(item.name)
                            .font(.title2)
                            .foregroundColor(Color(hex: "#333333"))

                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.7))
                            Text(item.room)
                                .font(.subheadline)
                                .foregroundColor(.blue.opacity(0.7))
                        }
                    }

                    Divider()
                        .padding(.horizontal, 40)

                    // Timestamp
                    VStack(spacing: 4) {
                        let messageText = item.type == .lockUnlock ? "You confirmed this as locked at:" : "You confirmed this as switched off at:"
                        Text(messageText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)

                        if let date = item.lastConfirmedDate {
                            Text("\(date.formatted(date: .abbreviated, time: .omitted)) at \(date.formatted(date: .omitted, time: .shortened))")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "#333333"))
                                .padding(.bottom, 4)

                            Text("(\(timeAgoText(from: date)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                    // Photo if available
                    if let filename = item.photoFilename,
                       let photo = persistenceManager.loadPhoto(filename: filename) {
                        Divider()
                            .padding(.horizontal, 40)
                            .padding(.top, 8)

                        VStack(spacing: 12) {
                            Text("Your uploaded Evidence:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)

                            Button(action: {
                                showFullScreenPhoto = true
                            }) {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(maxHeight: 250)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                .padding()
                .padding(.horizontal)

                Spacer(minLength: 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreenPhoto) {
            if let filename = item.photoFilename,
               let photo = persistenceManager.loadPhoto(filename: filename) {
                FullScreenPhotoView(photo: photo)
            }
        }
    }
}

#Preview {
    ReassuranceView(
        item: SafetyItem(
            name: "Front Door",
            room: "Hallway",
            type: .lockUnlock,
            state: .confirmed,
            lastConfirmedDate: Date()
        )
    )
}
