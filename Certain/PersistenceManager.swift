//
//  PersistenceManager.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import Foundation
import UIKit

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()

    @Published var items: [SafetyItem] = []

    private let itemsKey = "certainSafetyItems"
    private let photoDirectory = "CertainPhotos"

    private init() {
        loadItems()
        setupPhotoDirectory()
    }

    // MARK: - Items Management

    func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: itemsKey) else {
            items = []
            return
        }

        do {
            items = try JSONDecoder().decode([SafetyItem].self, from: data)
        } catch {
            print("Failed to load items: \(error)")
            items = []
        }
    }

    func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: itemsKey)
            objectWillChange.send()
        } catch {
            print("Failed to save items: \(error)")
        }
    }

    func addItem(_ item: SafetyItem) {
        items.append(item)
        saveItems()
    }

    func updateItem(_ item: SafetyItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }

    func deleteItem(_ item: SafetyItem) {
        // Delete associated photo if exists
        if let filename = item.photoFilename {
            deletePhoto(filename: filename)
        }

        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func confirmItem(_ item: SafetyItem, photo: UIImage?) -> SafetyItem {
        var updatedItem = item
        updatedItem.state = .confirmed
        updatedItem.lastConfirmedDate = Date()

        // Save photo if provided
        if let photo = photo {
            // Delete old photo if exists
            if let oldFilename = item.photoFilename {
                deletePhoto(filename: oldFilename)
            }

            let filename = "\(item.id.uuidString)_\(Date().timeIntervalSince1970).jpg"
            if savePhoto(photo, filename: filename) {
                updatedItem.photoFilename = filename
            }
        }

        updateItem(updatedItem)
        return updatedItem
    }

    func unconfirmItem(_ item: SafetyItem) -> SafetyItem {
        var updatedItem = item
        updatedItem.state = .unconfirmed
        updatedItem.lastConfirmedDate = nil

        // Delete the photo when unlocking
        if let filename = item.photoFilename {
            deletePhoto(filename: filename)
            updatedItem.photoFilename = nil
        }

        updateItem(updatedItem)
        return updatedItem
    }

    // MARK: - Photo Management

    private func setupPhotoDirectory() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let photoDirectoryURL = documentsURL.appendingPathComponent(photoDirectory)

        if !fileManager.fileExists(atPath: photoDirectoryURL.path) {
            try? fileManager.createDirectory(at: photoDirectoryURL, withIntermediateDirectories: true)
        }
    }

    func savePhoto(_ image: UIImage, filename: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }

        let photoDirectoryURL = documentsURL.appendingPathComponent(photoDirectory)
        let fileURL = photoDirectoryURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Failed to save photo: \(error)")
            return false
        }
    }

    func loadPhoto(filename: String) -> UIImage? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let photoDirectoryURL = documentsURL.appendingPathComponent(photoDirectory)
        let fileURL = photoDirectoryURL.appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    func deletePhoto(filename: String) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let photoDirectoryURL = documentsURL.appendingPathComponent(photoDirectory)
        let fileURL = photoDirectoryURL.appendingPathComponent(filename)

        try? FileManager.default.removeItem(at: fileURL)
    }
}
