# Pay It Forward - In-App Purchase Setup

## Overview
The "Pay It Forward" feature allows users to cover access for other service personnel. This uses Apple's In-App Purchase (IAP) system.

---

## App Store Connect Setup

### 1. Create In-App Purchase Products

Go to **App Store Connect** → **Your App** → **In-App Purchases** and create **3 consumable products**:

#### Product 1: Monthly Access
- **Product ID:** `com.ocean.darrengalvin.monthly`
- **Reference Name:** Monthly Access (Pay It Forward)
- **Type:** Consumable
- **Price:** £5.00 (Tier 5)
- **Display Name (English - UK):** Cover 1 Month
- **Description:** Pay for one month of access for another service member

#### Product 2: Quarterly Access
- **Product ID:** `com.ocean.darrengalvin.quarterly`
- **Reference Name:** Quarterly Access (Pay It Forward)
- **Type:** Consumable
- **Price:** £15.00 (Tier 15)
- **Display Name (English - UK):** Cover 3 Months
- **Description:** Pay for three months of access for another service member

#### Product 3: Yearly Access
- **Product ID:** `com.ocean.darrengalvin.yearly`
- **Reference Name:** Yearly Access (Pay It Forward)
- **Type:** Consumable
- **Price:** £50.00 (Tier 50)
- **Display Name (English - UK):** Cover 1 Year
- **Description:** Pay for one year of access for another service member

---

## Why "Consumable" Products?

We use **consumable** products (not subscriptions) because:
1. Users are paying **for someone else**, not themselves
2. Each purchase is a one-time contribution
3. No recurring billing
4. Aligns with the "Pay It Forward" model

---

## Testing In-App Purchases

### 1. Create Sandbox Test Users
- Go to **App Store Connect** → **Users and Access** → **Sandbox Testers**
- Create test accounts with UK region
- Use these accounts to test purchases **without being charged**

### 2. Test on Device
1. Sign out of your real Apple ID in **Settings → App Store**
2. Run the app on a physical device (IAP doesn't work on simulator)
3. Tap "Cover someone else's access" on the home screen
4. Select a purchase option
5. Sign in with your **sandbox test account** when prompted
6. Complete the test purchase (no real charge)

### 3. Verify Purchase Flow
- Purchase should complete successfully
- "You Just Covered Someone" dialog should appear
- Console logs should show: `🎉 Someone just covered another person!`

---

## App Review Considerations

When submitting to Apple:

### 1. App Review Information
Add this note in App Review Notes:

```
Pay It Forward Model:
This app is free for all military personnel. The In-App Purchases are 
NOT for users to buy access for themselves. Instead, users can optionally 
pay to cover access for OTHER service members. This aligns with military 
values of looking after each other.

Users who cannot pay can still use 100% of the app - there are no locked 
features. The IAP is purely a contribution mechanism.
```

### 2. Screenshots for Review
Include screenshots showing:
- The "Pay It Forward" screen with clear messaging
- The thank you dialog showing it's for "someone else"
- The app working fully without any purchase required

---

## Code Structure

### Files Created

1. **`lib/features/pay_it_forward/screens/pay_it_forward_screen.dart`**
   - Main UI screen with mission-aligned messaging
   - Purchase option cards
   - "Can't Pay?" section

2. **`lib/features/pay_it_forward/services/iap_service.dart`**
   - Handles IAP initialization
   - Loads products from App Store
   - Processes purchases
   - Falls back to mock data for development

3. **`lib/features/home/screens/home_screen.dart`** (modified)
   - Added "Cover someone else's access" card
   - Styled with ocean theme colors

### Product IDs in Code

Located in `iap_service.dart`:

```dart
static const String monthlyProductId = 'com.ocean.darrengalvin.monthly';
static const String quarterlyProductId = 'com.ocean.darrengalvin.quarterly';
static const String yearlyProductId = 'com.ocean.darrengalvin.yearly';
```

**⚠️ Important:** These must **exactly match** the Product IDs in App Store Connect.

---

## Future Backend Integration

Currently, purchases are logged but don't grant access to specific users. 

### Next Steps (Optional):

1. **Backend Tracking:**
   - Send purchase receipts to your Supabase backend
   - Store in a `pay_it_forward_contributions` table
   - Track total months covered

2. **Access Grants:**
   - Generate access codes
   - Distribute to service members who request free access
   - Redeem codes in the app

3. **Analytics:**
   - Show "X months of access covered" on the home screen
   - Thank contributors
   - Display community impact

**For now:** The system works as a contribution mechanism. All users have full access.

---

## Messaging Philosophy

The copy emphasizes:
- ✅ **Your access is free** (stated first)
- ✅ **Paying for someone else**, not yourself
- ✅ **No guilt** if you can't pay
- ✅ **Alternative contributions** (sharing, reviews)
- ✅ **Military values** (crew, not charity)

This aligns with the mission and reduces friction.

---

## Questions?

If you need to modify product IDs, prices, or messaging:
1. Update App Store Connect first
2. Update `iap_service.dart` product IDs
3. Modify `pay_it_forward_screen.dart` for UI changes



