//
//  ContentView.swift
//  Certain
//
//  Created by Ink Duangsri on 18/12/2025.
//

import SwiftUI

struct ContentView: View {
    @Binding var justSubscribed: Bool
    @StateObject private var persistenceManager = PersistenceManager.shared
    @State private var showAddItem = false
    @State private var showDeleteAlert = false
    @State private var showUnlockAlert = false
    @State private var selectedItem: SafetyItem?
    @State private var confirmationItem: SafetyItem?
    @State private var itemToDelete: SafetyItem?
    @State private var itemToUnlock: SafetyItem?
    @State private var reassuranceItem: SafetyItem?
    @State private var confirmationMessage = ""
    @State private var isUpdate = false
    @State private var selectedTab: ItemType = .lockUnlock
    @State private var showCertainPlus = false
    @State private var showLimitReachedAlert = false
    @State private var emptyStateOpacity: Double = 1.0
    @State private var hasAnimatedEmptyState = UserDefaults.standard.bool(forKey: "hasAnimatedEmptyState")
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var notificationIcon = ""
    @State private var notificationColor: Color = .green
    @ObservedObject private var subscriptionManager = RevenueCatManager.shared

    var body: some View {
        ZStack {
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "#ADA9F5"), location: 0.0),
                        .init(color: Color(hex: "#7E7CE8"), location: 0.2),
                        .init(color: Color(hex: "#4845B8"), location: 0.4),
                        .init(color: Color(hex: "#4845B8"), location: 1.0)
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Fixed header
                    headerView

                    ZStack {
                        Color.white

                        VStack(spacing: 0) {
                            // Tab toggle
                            tabPickerView
                                .padding(.top, 16)

                            // Swipeable content area using native TabView
                            TabView(selection: $selectedTab) {
                                tabContentView(for: .lockUnlock)
                                    .tag(ItemType.lockUnlock)

                                tabContentView(for: .onOff)
                                    .tag(ItemType.onOff)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
                }

                // Floating Add button (only show when items exist)
                if !persistenceManager.items.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                // Check item limit (free tier: 5 items)
                                if !subscriptionManager.canAddMoreItems(currentCount: persistenceManager.items.count) {
                                    showCertainPlus = true
                                } else {
                                    showAddItem = true
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color(hex: "#736CED"))
                                    .clipShape(Circle())
                                    .shadow(color: Color(hex: "#736CED").opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }

                // Notification banner
                if showNotification {
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: notificationIcon)
                                .foregroundColor(.white)
                                .font(.body)

                            Text(notificationMessage)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(notificationColor.opacity(0.85))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.top, 60)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView(defaultType: selectedTab, onItemSaved: { itemType in
                    selectedTab = itemType
                    showNotificationBanner(message: "Item added", icon: "checkmark.circle.fill", color: Color(red: 0.3, green: 0.7, blue: 0.4))
                })
            }
            .sheet(item: $confirmationItem) { item in
                ConfirmationView(
                    item: item,
                    isUpdate: isUpdate
                )
            }
            .sheet(item: $reassuranceItem) { item in
                ReassuranceView(item: item)
            }
            .sheet(item: $selectedItem) { item in
                AddItemView(editingItem: item)
            }
            .alert("Delete Item", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        persistenceManager.deleteItem(item)
                        showNotificationBanner(message: "Item deleted", icon: "trash.fill", color: Color(red: 0.9, green: 0.3, blue: 0.3))
                    }
                }
            } message: {
                Text("Are you sure you want to delete this item? This cannot be undone.")
            }
            .alert("Reset Item", isPresented: $showUnlockAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    if let item = itemToUnlock {
                        handleUnconfirm(item)
                    }
                }
            } message: {
                Text("Are you sure you want to reset this item? This will reset it to unconfirmed status.")
            }
            .sheet(isPresented: $showCertainPlus) {
                CertainPlusView()
            }
            .alert("Free Tier Limit Reached", isPresented: $showLimitReachedAlert) {
                Button("Upgrade to Certain Plus") {
                    showCertainPlus = true
                }
                Button("Maybe Later", role: .cancel) { }
            } message: {
                Text("You've reached the free tier limit of 5 items. Upgrade to Certain Plus for unlimited items at £0.99/month or £6.99/year.")
            }
            .onChange(of: persistenceManager.items.count) { oldValue, newValue in
                if !subscriptionManager.isPremium && newValue == subscriptionManager.freeItemLimit && oldValue < newValue {
                    showLimitReachedAlert = true
                }
            }
            .onAppear {
                if justSubscribed {
                    // Show success notification after a brief delay to ensure smooth transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNotificationBanner(
                            message: "Subscription activated!",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        justSubscribed = false
                    }
                }
            }
    }

    private var headerView: some View {
        ZStack {
            VStack(spacing: 8) {
                Text("Certain")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Peace of mind in your pocket")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                if subscriptionManager.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .padding(.trailing, 16)
                } else {
                    Button(action: {
                        showCertainPlus = true
                    }) {
                        Image(systemName: "crown.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    private var tabPickerView: some View {
        HStack(spacing: 0) {
            ForEach(ItemType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = type
                    }
                }) {
                    Text(type.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selectedTab == type ? .white : Color(hex: "#736CED"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == type ? Color(hex: "#736CED") : Color.clear
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(Color(hex: "#F5F5F5"))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    private func handleUnconfirm(_ item: SafetyItem) {
        let _ = persistenceManager.unconfirmItem(item)
    }

    private func showNotificationBanner(message: String, icon: String, color: Color) {
        notificationMessage = message
        notificationIcon = icon
        notificationColor = color
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showNotification = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showNotification = false
            }
        }
    }

    @ViewBuilder
    private func tabContentView(for type: ItemType) -> some View {
        let items = persistenceManager.items.filter { $0.type == type }
        let emptyTitle = persistenceManager.items.isEmpty ? "No items yet" : (type == .lockUnlock ? "No items to lock yet" : "No items to switch off yet")

        VStack(spacing: 0) {
            if items.isEmpty {
                // Empty state - centered vertically
                Spacer(minLength: 0)
                VStack(spacing: 12) {
                    Image("EmptyStateIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .opacity(emptyStateOpacity)

                    VStack(spacing: 12) {
                        Text(emptyTitle)
                            .font(.title2)
                            .fontWeight(.light)
                            .italic()
                            .foregroundColor(Color(hex: "#4A4A4A"))
                            .opacity(0.6 * emptyStateOpacity)
                    }

                    Button(action: {
                        if !subscriptionManager.canAddMoreItems(currentCount: persistenceManager.items.count) {
                            showCertainPlus = true
                        } else {
                            showAddItem = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 200)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#736CED"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .opacity(emptyStateOpacity)
                    .padding(.top, 16)
                }
                .padding(.bottom, 80) // Account for tab bar height
                .onAppear {
                    // Only animate on first appearance after onboarding
                    if !hasAnimatedEmptyState {
                        emptyStateOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeIn(duration: 0.5)) {
                                emptyStateOpacity = 1.0
                            }
                        }
                        hasAnimatedEmptyState = true
                        UserDefaults.standard.set(true, forKey: "hasAnimatedEmptyState")
                    } else {
                        emptyStateOpacity = 1.0
                    }
                }
                Spacer(minLength: 0)
            } else {
                // Item list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(items) { item in
                            ItemCardView(
                                item: item,
                                onConfirm: {
                                    isUpdate = item.state == .confirmed
                                    confirmationItem = item
                                },
                                onUnconfirm: item.state == .confirmed ? {
                                    itemToUnlock = item
                                    showUnlockAlert = true
                                } : nil,
                                onEdit: {
                                    selectedItem = item
                                },
                                onDelete: {
                                    itemToDelete = item
                                    showDeleteAlert = true
                                },
                                onReassure: {
                                    reassuranceItem = item
                                }
                            )
                        }

                        // Upgrade prompt for free users
                        if !subscriptionManager.isPremium {
                            upgradePromptCard
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var upgradePromptCard: some View {
        let itemsAdded = persistenceManager.items.count

        return Text("\(itemsAdded)/\(subscriptionManager.freeItemLimit) Items Added. Upgrade for Unlimited.")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 8)
    }
}

#Preview {
    ContentView(justSubscribed: .constant(false))
}

// MARK: - View Extension for Specific Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
