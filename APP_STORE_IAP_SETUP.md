# App Store In-App Purchase Setup Guide

## 🚀 Setting Up Monthly Support Subscriptions

You need to create **2 auto-renewable subscription products** in App Store Connect.

---

## 📋 Step-by-Step Instructions

### 1. Go to App Store Connect
1. Visit https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Select **"Ocean Insight"** (or your app)
4. Go to **"In-App Purchases"** tab

---

### 2. Create a Subscription Group

Before creating subscriptions, you need a **Subscription Group**:

1. Click **"+"** to create a new In-App Purchase
2. Select **"Auto-Renewable Subscription"**
3. You'll be prompted to create a **Subscription Group** first
4. **Subscription Group Name**: `Ocean Insight Support`
5. Click **"Create"**

---

### 3. Create Subscription #1: £5/month

#### **Reference Name** (internal only):
```
Monthly Support £5
```

#### **Product ID** (MUST match exactly):
```
com.ocean.darrengalvin.sub.monthly5
```

#### **Subscription Duration**:
- Select: **1 month**

#### **Subscription Prices**:
1. Click **"Add Subscription Price"**
2. Select **Base Territory**: United Kingdom (UK)
3. **Price**: £5.00
4. Click **"Next"** and review
5. Click **"Add"**

#### **Subscription Localizations**:
- **Display Name** (shown to users): `Monthly Support`
- **Description**: `Cover 1 person's access every month. Cancel anytime.`

---

### 4. Create Subscription #2: £10/month

#### **Reference Name**:
```
Monthly Support £10
```

#### **Product ID** (MUST match exactly):
```
com.ocean.darrengalvin.sub.monthly10
```

#### **Subscription Duration**:
- Select: **1 month**

#### **Subscription Prices**:
1. Click **"Add Subscription Price"**
2. Select **Base Territory**: United Kingdom (UK)
3. **Price**: £10.00
4. Click **"Next"** and review
5. Click **"Add"**

#### **Subscription Localizations**:
- **Display Name**: `Premium Monthly Support`
- **Description**: `Cover 2 people's access every month. Cancel anytime.`

---

## 🧪 Testing with Sandbox

### Create Sandbox Tester Account:
1. In App Store Connect, go to **"Users and Access"**
2. Click **"Sandbox Testers"**
3. Click **"+"** to add a new tester
4. Fill in:
   - **Email**: Create a unique test email (e.g., `test@yourdomain.com`)
   - **Password**: Create a strong password
   - **Country/Region**: United Kingdom
5. **Save**

### Test on Device:
1. **Sign out** of your real Apple ID in **Settings → App Store**
2. Run the app from Xcode
3. Tap a subscription option
4. When prompted, **sign in with your Sandbox Tester account**
5. Complete the test purchase (you won't be charged)

---

## ✅ What Happens in the App

Once the products are set up in App Store Connect:

### **Payment Cards Show Real Prices:**
- The app will fetch the actual prices from Apple (£5/month, £10/month)
- Cards display as:
  - **£5/month** - "Cover 1 person every month" (MOST IMPACT badge)
  - **£10/month** - "Cover 2 people every month"

### **When User Taps a Card:**
1. Apple's payment sheet appears
2. User authenticates (Face ID / Touch ID / Password)
3. Subscription starts
4. Success dialog shows: "You're Now Covering Others"

### **User Can Cancel Anytime:**
- In **Settings → Apple ID → Subscriptions**
- Or through the App Store app

---

## ⚠️ Important Notes

### **Product IDs MUST Match Exactly:**
The Product IDs in App Store Connect must match these **exactly**:
- `com.ocean.darrengalvin.sub.monthly5`
- `com.ocean.darrengalvin.sub.monthly10`

### **Review Process:**
- Apple reviews IAP products separately from the app
- First submission takes 1-3 days
- Include clear screenshots showing the purchase flow
- Explain the "Pay It Forward" model in review notes

### **Subscription Terms:**
Apple requires you to have clear terms. The app shows:
- **"Cancel anytime. No hidden fees."** ✅
- Monthly billing info is displayed ✅
- User controls cancellation through Apple ✅

---

## 🎯 Testing Checklist

Before submitting to Apple:

- [ ] Both subscriptions created in App Store Connect
- [ ] Product IDs match exactly
- [ ] Prices set to £5 and £10
- [ ] Sandbox tester account created
- [ ] Test purchase on physical device
- [ ] Verify success dialog appears
- [ ] Test cancellation flow
- [ ] Verify "Can't Pay?" section displays correctly

---

## 📱 How Users See It

1. **Open Pay It Forward screen**
2. **See 2 subscription options:**
   - £5/month (with "MOST IMPACT" badge)
   - £10/month
3. **Tap to select**
4. **Apple payment sheet appears**
5. **Confirm with Face ID / Touch ID**
6. **Success! They're now supporting others**

---

## 🆘 Troubleshooting

**"Unable to connect to iTunes Store"**
- Make sure you're signed in with a Sandbox Tester account on device
- Check internet connection

**"Product not found"**
- Product IDs must match exactly (case-sensitive)
- Products can take 30 minutes to sync after creation

**"This In-App Purchase has already been bought"**
- Sandbox subscriptions auto-renew rapidly
- Go to Settings → App Store → Sandbox Account → Manage → Cancel

**"Cannot connect to App Store"**
- Sign out of your real Apple ID in Settings → App Store
- Only sign in when the app prompts for purchase

---

## 🚀 Ready to Launch

Once everything works in Sandbox:
1. Submit app for review
2. Include IAP screenshots in App Review Information
3. Note: "Pay It Forward subscription model - users cover access for others"
4. Apple typically approves within 1-3 days

---

Good luck! 🎉

