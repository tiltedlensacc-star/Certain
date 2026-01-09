//
//  AddItemView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var persistenceManager = PersistenceManager.shared
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var editingItem: SafetyItem?
    var onItemSaved: ((ItemType) -> Void)?
    var defaultType: ItemType?

    @State private var name: String = ""
    @State private var selectedRoom: String = Room.common[0]
    @State private var customRoom: String = ""
    @State private var showCustomRoom: Bool = false
    @State private var itemDescription: String = ""
    @State private var selectedType: ItemType = .lockUnlock

    init(editingItem: SafetyItem? = nil, defaultType: ItemType? = nil, onItemSaved: ((ItemType) -> Void)? = nil) {
        self.editingItem = editingItem
        self.defaultType = defaultType
        self.onItemSaved = onItemSaved

        if let item = editingItem {
            _name = State(initialValue: item.name)
            _selectedRoom = State(initialValue: item.room)
            _itemDescription = State(initialValue: item.itemDescription ?? "")
            _selectedType = State(initialValue: item.type)

            // Check if room is custom
            if !Room.common.contains(item.room) {
                _showCustomRoom = State(initialValue: true)
                _customRoom = State(initialValue: item.room)
                _selectedRoom = State(initialValue: "Other")
            }
        } else if let type = defaultType {
            // For new items, use the provided default type
            _selectedType = State(initialValue: type)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Name")) {
                    TextField("Item Name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section(header: Text("Item Type")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose the type of item you're tracking:")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        (Text("• ").font(.caption).foregroundColor(.secondary) +
                         Text("Lock/Unlock").font(.caption).fontWeight(.bold).foregroundColor(.secondary) +
                         Text(": For doors, windows, or anything that can be secured").font(.caption).foregroundColor(.secondary))

                        (Text("• ").font(.caption).foregroundColor(.secondary) +
                         Text("On/Off").font(.caption).fontWeight(.bold).foregroundColor(.secondary) +
                         Text(": For lights, gas hobs, appliances, or electrical devices").font(.caption).foregroundColor(.secondary))
                    }
                    .padding(.vertical, 4)

                    Picker("Type", selection: $selectedType) {
                        ForEach(ItemType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section(header: Text("Location")) {
                    Picker("Room", selection: $selectedRoom) {
                        ForEach(Room.common, id: \.self) { room in
                            Text(room).tag(room)
                        }
                    }
                    .onChange(of: selectedRoom) { _, newValue in
                        showCustomRoom = newValue == "Other"
                    }

                    if showCustomRoom {
                        TextField("Custom Room Name", text: $customRoom)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section(header: Text("Description (Optional)")) {
                    TextEditor(text: $itemDescription)
                        .frame(minHeight: 80)
                }

                if editingItem == nil {
                    Section {
                        Text("New items start unconfirmed. You'll need to confirm each item by locking or switching them off.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if !subscriptionManager.isPremium && persistenceManager.items.count >= subscriptionManager.freeItemLimit - 1 {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Free Tier Limit")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("You have \(subscriptionManager.freeItemLimit - persistenceManager.items.count) item\(subscriptionManager.freeItemLimit - persistenceManager.items.count == 1 ? "" : "s") remaining. Upgrade to Certain Plus for unlimited items.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingItem == nil ? "Add" : "Save") {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveItem() {
        let finalRoom = showCustomRoom ? customRoom : selectedRoom
        let finalDescription = itemDescription.trimmingCharacters(in: .whitespaces)

        if let existingItem = editingItem {
            // Edit existing item
            var updatedItem = existingItem
            updatedItem.name = name.trimmingCharacters(in: .whitespaces)
            updatedItem.room = finalRoom
            updatedItem.itemDescription = finalDescription.isEmpty ? nil : finalDescription
            updatedItem.type = selectedType

            persistenceManager.updateItem(updatedItem)
        } else {
            // Create new item - check limit first
            if !subscriptionManager.canAddMoreItems(currentCount: persistenceManager.items.count) {
                // Should not reach here as the UI should prevent this, but just in case
                return
            }

            let newItem = SafetyItem(
                name: name.trimmingCharacters(in: .whitespaces),
                room: finalRoom,
                itemDescription: finalDescription.isEmpty ? nil : finalDescription,
                type: selectedType
            )

            persistenceManager.addItem(newItem)
            onItemSaved?(selectedType)
        }

        dismiss()
    }
}

#Preview {
    AddItemView()
}
