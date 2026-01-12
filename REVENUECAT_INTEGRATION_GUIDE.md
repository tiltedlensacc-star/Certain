# RevenueCat Integration Guide for Certain App

This guide explains the complete RevenueCat integration for the Certain app.

## Step 1: Install RevenueCat SDK

### Via Xcode (Required):

1. Open `Certain.xcodeproj` in Xcode
2. Go to **File → Add Package Dependencies**
3. Paste: `https://github.com/RevenueCat/purchases-ios-spm.git`
4. Click "Add Package"
5. Select both:
   - **RevenueCat** (core SDK)
   - **RevenueCatUI** (for Paywall and Customer Center)
6. Click "Add Package"

## Step 2: Configure RevenueCat in App Store Connect

### Create Products in App Store Connect:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Monetization → Subscriptions**
4. Create two subscription products:
   - **Monthly Subscription**
     - Product ID: `com.junkle.certain.premium.monthly`
     - Price: £0.99/month
   - **Yearly Subscription**
     - Product ID: `com.junkle.certain.premium.yearly`
     - Price: £6.99/year

### Configure RevenueCat Dashboard:

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create a new project for "Certain"
3. Add your iOS app:
   - Bundle ID: `Junkle.Certain`
   - App-Specific Shared Secret from App Store Connect
4. Create Products:
   - Add both product IDs from App Store Connect
5. Create an Offering:
   - Name: "Default"
   - Offering ID: **ofrngc82acdea03** (already configured)
   - Add packages:
     - **Monthly**: monthly subscription
     - **Yearly**: yearly subscription (mark as default)
   - Mark this offering as "Current" in the dashboard
6. Create an Entitlement:
   - Name: **"Certain Plus"**
   - Attach both products to this entitlement

## Step 3: Configured Constants

The following constants are already configured in `RevenueCatManager.swift`:

```swift
private let apiKey = "test_VFcPHQInZhFydKjJoqyULfPWFZM"
private let entitlementIdentifier = "Certain Plus"
private let offeringIdentifier = "ofrngc82acdea03"
```

**For production:**
1. Get your production API key from RevenueCat Dashboard
2. Replace the test key in `RevenueCatManager.swift`
3. Set log level to `.info` or `.error` instead of `.debug`
4. Verify the offering ID matches your production offering in RevenueCat Dashboard

## Step 4: Configure Paywall (Optional Customization)

RevenueCat automatically fetches your configured Offering and displays it in the Paywall.

### To customize the paywall appearance:

1. Go to RevenueCat Dashboard → **Paywalls**
2. Create a new paywall template
3. Customize colors, fonts, and layout
4. Attach the paywall to your Default Offering

The paywall will automatically display your configured packages (Monthly/Yearly).

## Implementation Overview

### Files Created/Modified:

#### New Files:
1. **RevenueCatManager.swift** - Main subscription manager
   - Configures RevenueCat SDK
   - Handles purchases and restores
   - Checks entitlements
   - Manages customer info

2. **RevenueCatPaywallView.swift** - Paywall wrapper
   - Displays RevenueCat's pre-built paywall
   - Handles purchase completion
   - Shows restore purchases button
   - Links to privacy policy and terms

3. **CustomerCenterView.swift** - Subscription management
   - Pre-built UI for managing subscriptions
   - Allows users to cancel, change plans
   - View billing history

#### Modified Files:
1. **CertainApp.swift** - Initialize RevenueCat on app launch
2. **CertainPlusView.swift** - Simplified to use RevenueCat Paywall
3. **InfoView.swift** - Added Customer Center access
4. **OnboardingView.swift** - Integrated paywall in onboarding
5. **ContentView.swift** - Use RevenueCatManager for item limits
6. **AddItemView.swift** - Use RevenueCatManager for item limits

## Usage Examples

### Check if user is premium:
```swift
@ObservedObject private var revenueCatManager = RevenueCatManager.shared

if revenueCatManager.isPremium {
    // User has Certain Plus
}
```

### Check if user can add more items:
```swift
let canAdd = revenueCatManager.canAddMoreItems(
    currentCount: persistenceManager.items.count
)
```

### Show the paywall:
```swift
@State private var showPaywall = false

Button("Upgrade") {
    showPaywall = true
}
.sheet(isPresented: $showPaywall) {
    RevenueCatPaywallView(justSubscribed: $justSubscribed)
}
```

### Restore purchases:
```swift
Task {
    do {
        let customerInfo = try await revenueCatManager.restorePurchases()
        if revenueCatManager.isPremium {
            print("Restored successfully!")
        }
    } catch {
        print("Restore failed: \(error)")
    }
}
```

### Show Customer Center:
```swift
@State private var showCustomerCenter = false

Button("Manage Subscription") {
    showCustomerCenter = true
}
.sheet(isPresented: $showCustomerCenter) {
    CustomerCenterView()
}
```

## Key Features Implemented

✅ **Subscription Management**
- Monthly and Yearly plans
- Automatic entitlement checking
- Real-time subscription status updates

✅ **Paywall Integration**
- Pre-built, customizable paywall UI
- Displays offerings from RevenueCat Dashboard
- Handles purchase flow automatically

✅ **Restore Purchases**
- Available in multiple locations:
  - Onboarding (Page 3)
  - Subscription screen
  - About page (Legal & Support)

✅ **Customer Center**
- Pre-built subscription management UI
- Available to premium users in About page
- Allows cancellation, plan changes, etc.

✅ **Item Limit Enforcement**
- Free users: 5 items maximum
- Premium users: Unlimited items
- Checks before allowing item creation

✅ **Entitlement Checking**
- Entitlement name: "Certain Plus"
- Automatically syncs across devices
- Works with Family Sharing

## Testing

### Test Subscription Flow:

1. Run app in simulator or test device
2. Complete onboarding → Click "See Premium Plans"
3. Purchase using sandbox test account
4. Verify premium features unlock
5. Test restore purchases

### Test Sandbox Account:

1. Go to App Store Connect → Users and Access → Sandbox Testers
2. Create a test account
3. Sign in with this account on your device (Settings → App Store → Sandbox Account)
4. Make test purchases (they won't charge)

### Test Scenarios:

- [ ] New user purchases monthly subscription
- [ ] New user purchases yearly subscription
- [ ] User restores previous purchase
- [ ] Premium user accesses Customer Center
- [ ] Free user hits 5-item limit
- [ ] Premium user creates unlimited items

## Migrating from StoreKit 2

The old `SubscriptionManager.swift` has been replaced with `RevenueCatManager.swift`.

### Key Differences:

| Old (StoreKit 2) | New (RevenueCat) |
|------------------|------------------|
| Manual product loading | Automatic via Offerings |
| Manual transaction handling | Handled by SDK |
| Custom paywall UI | Pre-built Paywall UI |
| No analytics | Built-in analytics |
| Manual receipt validation | Server-side validation |
| No Customer Center | Pre-built Customer Center |

You can safely delete `SubscriptionManager.swift` once you verify RevenueCat is working.

## App Store Submission

### Requirements:

1. ✅ Restore Purchases button (implemented in 3 places)
2. ✅ Privacy Policy link (in paywall and onboarding)
3. ✅ Terms of Use link (in paywall and onboarding)
4. ✅ Subscription terms disclosure (in paywall)
5. ✅ Customer Center for managing subscriptions

### Before Submission:

1. Replace test API key with production key
2. Set log level to `.error`
3. Test thoroughly with TestFlight
4. Verify all links work (Privacy, Terms, Support)

## Troubleshooting

### Paywall not showing products:

- Check RevenueCat Dashboard has products configured
- Verify Offering is set as "Current"
- Check API key is correct
- Ensure products exist in App Store Connect

### Entitlement not activating:

- Verify entitlement name is exactly "Certain Plus"
- Check products are attached to entitlement
- Force refresh customer info:
  ```swift
  await revenueCatManager.fetchCustomerInfo()
  ```

### Sandbox purchases not working:

- Sign out of real App Store account
- Sign in with sandbox test account
- Ensure app is in sandbox mode (not production)

## Next Steps

1. ✅ Add RevenueCat SDK via Xcode
2. Configure products in App Store Connect
3. Set up RevenueCat Dashboard
4. Test subscription flow
5. Configure paywall design (optional)
6. Test thoroughly
7. Submit to App Store

## Support

- **RevenueCat Documentation**: https://www.revenuecat.com/docs
- **RevenueCat Dashboard**: https://app.revenuecat.com
- **RevenueCat Community**: https://community.revenuecat.com

---

**Implementation completed on 2026-01-12**
