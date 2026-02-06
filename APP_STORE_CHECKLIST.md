# App Store Submission Checklist

Complete guide for getting Below the Surface approved on Apple App Store and Google Play Store.

---

## ✅ Code Changes Completed

- [x] Android INTERNET permission added
- [x] Android BILLING permission added  
- [x] Android app label fixed to "Below the Surface"
- [x] Terms of Service screen created
- [x] Support screen with FAQ and crisis resources
- [x] Links added to home screen (About, Privacy, Terms, Support)

---

## 🔴 REQUIRED: Before Submission

### 1. Create Web-Hosted Legal Pages

Both stores REQUIRE publicly accessible URLs for:

**Privacy Policy URL** (REQUIRED)
- Host at: `https://belowthesurface.app/privacy`
- Must match in-app content
- Include: data collection, third-party sharing, user rights

**Terms of Service URL** (REQUIRED)
- Host at: `https://belowthesurface.app/terms`
- Must cover: medical disclaimer, purchases, liability

**Support URL** (REQUIRED)
- Host at: `https://belowthesurface.app/support`
- Or use email: `support@belowthesurface.app`

> **Quick Option:** Use a free service like Notion, Carrd, or GitHub Pages to host these

### 2. Update URLs in Code

Edit `lib/features/settings/screens/support_screen.dart`:
```dart
static const String supportEmail = 'your-actual-email@domain.com';
static const String websiteUrl = 'https://your-actual-website.com';
static const String privacyPolicyUrl = 'https://your-actual-website.com/privacy';
static const String termsUrl = 'https://your-actual-website.com/terms';
```

### 3. App Store Screenshots

Prepare screenshots for ALL required sizes:

**iPhone:**
- 6.7" (iPhone 14 Pro Max): 1290 x 2796
- 6.5" (iPhone 11 Pro Max): 1242 x 2688
- 5.5" (iPhone 8 Plus): 1242 x 2208

**iPad:**
- 12.9" iPad Pro: 2048 x 2732

**Android:**
- Phone: 1080 x 1920 (minimum)
- Tablet: 1200 x 1920 (recommended)

**Screenshot Content Ideas:**
1. Welcome/Home screen
2. Breathing exercise
3. Mood tracking
4. Learn/Navigate content
5. Games (Block Stacking/Zen Garden)
6. Affirmations
7. Rituals/Daily check-ins

### 4. App Store Metadata

**App Name:** Below the Surface  
**Subtitle:** Mental Wellbeing for Service Members

**Description (First paragraph is crucial):**
```
Below the Surface is your personal mental wellbeing companion, designed specifically for military personnel, veterans, and their families. Whether you're at sea, on deployment, or at home, access powerful tools that work completely offline.

Features include guided breathing exercises, mood tracking, educational content about brain function and psychology, goal setting, daily rituals, affirmations, and calming soundscapes.

IMPORTANT: This app is for general wellbeing support only and is NOT a substitute for professional medical advice.

A portion of every purchase supports mental health charities for serving personnel and veterans.
```

**Keywords (100 character limit):**
```
mental health,wellbeing,military,veteran,breathing,meditation,mood,anxiety,stress,offline,submarine
```

### 5. Age Rating Questionnaire

Answer these in App Store Connect / Google Play Console:

| Question | Answer for Below the Surface |
|----------|-------------------------|
| Violence | None |
| Sexual Content | None |
| Profanity | None |
| Drugs/Alcohol | None |
| Gambling | None |
| Horror/Fear | None |
| Medical/Treatment Info | Yes - General Reference |
| User Generated Content | No |
| In-App Purchases | Yes |

**Expected Rating:** 4+ (iOS) / Everyone (Android)

---

## 📱 Apple App Store Specific

### App Store Connect Setup

1. **App Information**
   - Primary Category: Health & Fitness
   - Secondary Category: Lifestyle
   - Content Rights: Yes, I own or have rights

2. **Pricing & Availability**
   - Price: £24.99 (or Tier 26)
   - All territories (or select specific)

3. **In-App Purchases** (if Pay It Forward is active)
   - Add all donation tiers
   - Submit for review with app

4. **App Privacy (Nutrition Labels)**

   | Data Type | Collected | Linked to Identity | Used for Tracking |
   |-----------|-----------|-------------------|-------------------|
   | Usage Data | Yes | No | No |
   | Diagnostics | Optional | No | No |
   
   Select: "Data Not Linked to You"

5. **Review Notes for Apple**
   ```
   Below the Surface is a mental wellbeing app for military personnel. 
   
   Key points for review:
   - No account/login required
   - All data stored locally on device
   - Content syncs from our servers (Supabase) for scenarios/protocols
   - Audio playback for breathing exercises and ambient sounds
   - In-app purchases are optional "Pay It Forward" donations
   
   Medical Disclaimer: This app is NOT a substitute for professional 
   medical advice and includes clear disclaimers throughout.
   ```

### Common Apple Rejection Reasons to Avoid

- [ ] Ensure no placeholder content
- [ ] App must be fully functional (no "coming soon")
- [ ] All links must work
- [ ] No crashes (test thoroughly!)
- [ ] Medical disclaimer must be prominent
- [ ] In-app purchases must work correctly
- [ ] Background audio must have legitimate use

---

## 🤖 Google Play Store Specific

### Play Console Setup

1. **App Category**
   - Application Type: App
   - Category: Health & Fitness

2. **Store Listing**
   - Short description (80 chars): "Mental wellbeing companion for military personnel & families"
   - Full description: (same as Apple)
   - Feature graphic: 1024 x 500

3. **Content Rating**
   - Complete IARC questionnaire
   - Expected: PEGI 3 / Everyone

4. **Data Safety Section**

   | Question | Answer |
   |----------|--------|
   | Does app collect data? | Yes |
   | Is data encrypted? | Yes |
   | Can users request deletion? | Yes (delete app) |
   | Data shared with third parties? | No |
   
   **Data Types:**
   - App activity (stored locally)
   - App info and performance (analytics)

5. **Target Audience**
   - NOT primarily for children
   - Age: 18+ (due to mental health content)

6. **Sensitive App Categories**
   - May be flagged as "Health" app
   - Ensure medical disclaimer is prominent

---

## 💰 In-App Purchase Setup

### Apple App Store
1. Go to App Store Connect → In-App Purchases
2. Create Consumable products for donations:
   - `donation_5` - £5 donation
   - `donation_10` - £10 donation
   - `donation_25` - £25 donation
3. Add localised descriptions
4. Submit with app review

### Google Play
1. Go to Play Console → Monetize → Products
2. Create managed products for donations
3. Match product IDs with iOS
4. Activate products

---

## 🧪 Pre-Submission Testing

### Functionality Checklist
- [ ] App launches without crash
- [ ] All navigation works
- [ ] Breathing exercises complete properly
- [ ] Audio plays correctly
- [ ] Mood logging saves/displays
- [ ] Settings save and persist
- [ ] Works fully offline (airplane mode)
- [ ] Content syncs when online
- [ ] All screens are accessible
- [ ] No placeholder text/images

### Performance Checklist
- [ ] App loads in < 3 seconds
- [ ] Smooth scrolling (60fps)
- [ ] No memory leaks
- [ ] Battery usage reasonable
- [ ] Works on older devices

### Accessibility Checklist
- [ ] VoiceOver/TalkBack works
- [ ] Text scales with system settings
- [ ] Sufficient color contrast
- [ ] Touch targets ≥ 44pt

---

## 📝 Final Submission Steps

### Apple App Store
1. Archive app in Xcode
2. Upload to App Store Connect
3. Fill in all metadata
4. Submit for Review
5. Wait 24-48 hours (typically)

### Google Play
1. Build release APK/AAB
2. Upload to Play Console
3. Fill in all metadata
4. Complete Data Safety
5. Submit for Review
6. Wait 1-7 days

---

## 🆘 If Rejected

### Apple
- Read rejection reason carefully
- Fix the specific issue
- Reply in Resolution Center
- Resubmit

### Google
- Check Policy Status page
- Address cited policies
- Appeal if you disagree
- Resubmit

---

## Resources

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Policy Center](https://play.google.com/console/about/guides/releasewithconfidence/)
- [Apple App Privacy](https://developer.apple.com/app-store/app-privacy-details/)
- [Google Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)

---

*Last updated: January 2026*
