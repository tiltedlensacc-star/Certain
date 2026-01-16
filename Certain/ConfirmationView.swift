//
//  ConfirmationView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI
import UIKit
import PostHog

struct ConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var persistenceManager = PersistenceManager.shared

    let item: SafetyItem
    let isUpdate: Bool

    @State private var showingConfirmDialog = false
    @State private var showingCamera = false
    @State private var showingPhotoConfirmation = false
    @State private var capturedImage: UIImage?
    @State private var confirmationCompleted = false
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // Purple gradient background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#E8E0F7"), location: 0.0),
                    .init(color: Color(hex: "#FEFEFE"), location: 0.4),
                    .init(color: Color(hex: "#FEFEFE"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
                    .padding()
                }

                Spacer(minLength: 20)

                // Confirmation message
                VStack(spacing: 12) {
                    if isUpdate {
                        Text("Update Confirmation")
                            .font(.headline)

                        Text("Are you sure you want to overwrite the previous confirmation?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        if let lastDate = item.lastConfirmedDate {
                            Text("Last confirmed: \(lastDate, style: .relative) ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        let statusText = item.type == .lockUnlock ? "locked" : "switched off"
                        Text("Are you ready to mark this item as \(statusText)?")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#555555"))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)

                // Item info
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#736CED").opacity(0.1))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isPulsing ? 1.15 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isPulsing
                            )

                        Image(systemName: item.type.confirmedIcon)
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#736CED"))
                    }
                    .onAppear {
                        isPulsing = true
                    }

                    VStack(spacing: 8) {
                        Text(item.name)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.caption)
                                .foregroundColor(.blue.opacity(0.7))
                            Text(item.room)
                                .font(.subheadline)
                                .foregroundColor(.blue.opacity(0.7))
                        }

                        Text("A date and time stamp of this action will be recorded for your peace of mind.")
                            .font(.body)
                            .foregroundColor(Color(.darkGray))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 20)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo & Confirm")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#736CED"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: {
                        confirmWithoutPhoto()
                    }) {
                        Text("Confirm Without Photo")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#736CED").opacity(0.1))
                            .foregroundColor(Color(hex: "#736CED"))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .presentationDetents([.large])
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .onDisappear {
                    if capturedImage != nil {
                        showingPhotoConfirmation = true
                    }
                }
        }
        .alert("Use This Photo?", isPresented: $showingPhotoConfirmation) {
            Button("Retake", role: .cancel) {
                capturedImage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingCamera = true
                }
            }
            Button("Use Photo") {
                confirmWithPhoto()
            }
        } message: {
            Text("Do you want to use this photo for confirmation?")
        }
    }

    private func confirmWithPhoto() {
        let _ = persistenceManager.confirmItem(item, photo: capturedImage)

        // Track confirmation with photo
        PostHogSDK.shared.capture("item_confirmed", properties: [
            "item_type": item.type.rawValue,
            "with_photo": true,
            "is_update": isUpdate
        ])

        dismiss()
    }

    private func confirmWithoutPhoto() {
        let _ = persistenceManager.confirmItem(item, photo: nil)

        // Track confirmation without photo
        PostHogSDK.shared.capture("item_confirmed", properties: [
            "item_type": item.type.rawValue,
            "with_photo": false,
            "is_update": isUpdate
        ])

        dismiss()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    var sourceType: UIImagePickerController.SourceType = .camera

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ConfirmationView(
        item: SafetyItem(
            name: "Front Door",
            room: "Hallway",
            type: .lockUnlock
        ),
        isUpdate: false
    )
}
