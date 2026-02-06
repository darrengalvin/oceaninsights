# Below the Surface - iOS Deployment Guide

**App Name:** Below the Surfaces Cert  
**Bundle ID:** com.ocean.darrengalvin  
**SKU:** com.ocean.darrengalvin  
**Apple ID:** 6758065156  

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Configure Flutter Project](#2-configure-flutter-project)
3. [Xcode Configuration](#3-xcode-configuration)
4. [Create App Icons](#4-create-app-icons)
5. [Build for Testing](#5-build-for-testing)
6. [App Store Connect Setup](#6-app-store-connect-setup)
7. [TestFlight Beta Testing](#7-testflight-beta-testing)
8. [Submit for Review](#8-submit-for-review)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

### 1.1 Apple Developer Account

✅ You need an Apple Developer account ($99/year)
- Sign up at: https://developer.apple.com/programs/
- Or use your existing account

### 1.2 Development Tools

✅ Xcode (latest version) - **You have this installed**
✅ Flutter SDK installed
✅ CocoaPods installed

**Check your setup:**

```bash
# Check Flutter
flutter doctor

# Check Xcode command line tools
xcode-select -p

# Check CocoaPods
pod --version
```

### 1.3 Apple Certificates & Provisioning

You'll need to create:
- **Development Certificate** - For testing on devices
- **Distribution Certificate** - For App Store submission
- **App ID** - Already created: com.ocean.darrengalvin
- **Provisioning Profiles** - For development and distribution

---

## 2. Configure Flutter Project

### 2.1 Update pubspec.yaml

Open `pubspec.yaml` and ensure you have:

```yaml
name: deep_dive
description: Below the Surface - Mental Health Companion for Military Personnel
version: 1.0.0+1  # version+build number
```

**Version format:** `MAJOR.MINOR.PATCH+BUILD`
- Example: `1.0.0+1` means version 1.0.0, build 1
- Increment build number for each submission

### 2.2 Update iOS Bundle Identifier

Open `ios/Runner.xcodeproj` in Xcode or edit directly:

```bash
# Open project in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** (top of file list)
2. Select **Runner** target
3. Go to **"Signing & Capabilities"** tab
4. Set **Bundle Identifier** to: `com.ocean.darrengalvin`
5. Select your **Team** (Apple Developer account)
6. Enable **"Automatically manage signing"**

### 2.3 Update Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Name -->
    <key>CFBundleDisplayName</key>
    <string>Below the Surface</string>
    
    <key>CFBundleName</key>
    <string>Below the Surface</string>
    
    <!-- Bundle Identifier -->
    <key>CFBundleIdentifier</key>
    <string>com.ocean.darrengalvin</string>
    
    <!-- Version -->
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    
    <key>CFBundleVersion</key>
    <string>1</string>
    
    <!-- Privacy Descriptions (required by App Store) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app does not access your photo library.</string>
    
    <key>NSCameraUsageDescription</key>
    <string>This app does not access your camera.</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app does not access your location.</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>This app does not access your microphone.</string>
    
    <!-- Background Modes for Audio -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
    
    <!-- Supported Interface Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
    </array>
    
    <!-- Minimum iOS Version -->
    <key>MinimumOSVersion</key>
    <string>13.0</string>
    
    <!-- Other required keys -->
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    
    <key>LSRequiresIPhoneOS</key>
    <true/>
    
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
</dict>
</plist>
```

---

## 3. Xcode Configuration

### 3.1 Open Project in Xcode

```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive
open ios/Runner.xcworkspace
```

⚠️ **Important:** Always open `.xcworkspace`, NOT `.xcodeproj`

### 3.2 Configure Signing

In Xcode:

1. **Select Runner** (project navigator)
2. **Select Runner target**
3. **Go to "Signing & Capabilities" tab**

**For Debug (Development):**
- Team: Select your Apple Developer account
- Bundle Identifier: `com.ocean.darrengalvin`
- Provisioning Profile: Automatic
- Signing Certificate: Apple Development

**For Release (Distribution):**
- Team: Select your Apple Developer account
- Bundle Identifier: `com.ocean.darrengalvin`
- Provisioning Profile: Automatic
- Signing Certificate: Apple Distribution

4. **Enable "Automatically manage signing"** ✅

### 3.3 Set Deployment Target

1. Select **Runner** target
2. Go to **"General"** tab
3. Set **"Minimum Deployments"** to: **iOS 13.0**

### 3.4 Configure Build Settings

1. Go to **"Build Settings"** tab
2. Search for **"Bitcode"**
3. Set **"Enable Bitcode"** to: **No** (Flutter doesn't support bitcode)

---

## 4. Create App Icons

### 4.1 Icon Requirements

You need icons in these sizes:

| Size | Purpose |
|------|---------|
| 1024×1024 | App Store |
| 180×180 | iPhone (3x) |
| 120×120 | iPhone (2x) |
| 167×167 | iPad Pro |
| 152×152 | iPad (2x) |
| 76×76 | iPad (1x) |
| 40×40 | Spotlight |
| 60×60 | Settings |
| 29×29 | Notifications |

### 4.2 Icon Guidelines

✅ **Must have:**
- No transparency
- Square shape
- No rounded corners (iOS adds these)
- No text or words
- High quality, professional design

### 4.3 Generate Icons

**Option 1: Use online generator**
- Upload your 1024×1024 icon to: https://appicon.co/
- Download the generated asset catalog
- Replace contents of `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Option 2: Manually add in Xcode**
1. Open project in Xcode
2. Select `Runner/Assets.xcassets/AppIcon.appiconset`
3. Drag and drop icons into appropriate slots

### 4.4 Launch Screen

Edit `ios/Runner/Assets.xcassets/LaunchImage.imageset/` for splash screen

---

## 5. Build for Testing

### 5.1 Clean Build

```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Clean iOS specific
cd ios
pod install
cd ..
```

### 5.2 Build for iOS Simulator

```bash
# List available simulators
flutter emulators

# Run on simulator
flutter run -d "iPhone 15 Pro"
```

### 5.3 Build for Physical Device

1. **Connect your iPhone via USB**
2. **Trust the computer** (on iPhone when prompted)

```bash
# List connected devices
flutter devices

# Run on device
flutter run -d <device-id>
```

**If you get "untrusted developer" error on iPhone:**
- Go to: Settings → General → VPN & Device Management
- Trust your developer certificate

### 5.4 Build Release Version

```bash
# Build release IPA (for testing)
flutter build ios --release

# Or build and run on device
flutter run --release
```

---

## 6. App Store Connect Setup

### 6.1 Create App in App Store Connect

1. **Go to:** https://appstoreconnect.apple.com/
2. **Sign in** with your Apple ID
3. Click **"My Apps"**
4. Click **"+"** button → **"New App"**

**Fill in the form:**

| Field | Value |
|-------|-------|
| Platform | iOS |
| Name | Below the Surface |
| Primary Language | English (UK) |
| Bundle ID | com.ocean.darrengalvin |
| SKU | com.ocean.darrengalvin |
| User Access | Full Access |

5. Click **"Create"**

### 6.2 Complete App Information

**App Information:**
- **Subtitle:** Mental health companion for military personnel
- **Category:** Primary: Health & Fitness, Secondary: Lifestyle
- **Age Rating:** 12+ (medical/treatment information)

**Pricing and Availability:**
- **Price:** Free or £2.99 (you decide)
- **Availability:** All countries or specific ones

**App Privacy:**
You'll need to complete the privacy questionnaire:

**Data Collection:**
- ❌ Contact Info: No
- ❌ Health & Fitness: No (mood data stays on device)
- ❌ Financial Info: No
- ❌ Location: No
- ❌ Identifiers: No
- ❌ Usage Data: No
- ✅ Other Data: User-provided name only (not linked to identity)

**Third Party Advertising:** No

### 6.3 Prepare App Store Listing

You'll need:

**Screenshots** (required sizes):

For iPhone 6.7":
- 1290 × 2796 pixels (at least 3 screenshots, max 10)

For iPhone 6.5":
- 1242 × 2688 pixels (at least 3 screenshots)

For iPhone 5.5":
- 1242 × 2208 pixels (at least 3 screenshots)

**Optional but recommended:**
- App Preview Video (up to 30 seconds)

**Take screenshots:**
```bash
# Run on simulator
flutter run -d "iPhone 15 Pro Max"

# Take screenshots in simulator: Cmd + S
# Or use: Cmd + Shift + 4 to capture specific area
```

**Description** (4000 characters max):

```
Below the Surface is a comprehensive mental health and wellbeing companion designed specifically for military personnel, veterans, and their families. Unlike other wellbeing apps, Below the Surface works completely offline – perfect for deployments and environments without internet access.

BUILT FOR SERVICE MEMBERS
Designed with operational security (OPSEC) in mind. No GPS tracking, no camera access, no detailed journaling that could compromise your privacy or security.

KEY FEATURES
🫁 Breathing Exercises – Including Box Breathing (Navy SEAL technique), 4-7-8 Calming, and more with audio guidance
📊 Mood Tracking – Simple, OPSEC-safe daily check-ins with streak tracking
🧠 Navigate – Intelligent guidance across 11 life areas: relationships, family, identity, work, transition, and more
📚 Learn Library – Evidence-based articles on brain science, psychology, and life situations
🎵 Calm Sounds – Embedded relaxing audio including ocean waves and ambient sounds
💭 Daily Affirmations – Positive statements for confidence and resilience
🎯 Goal Setting – Track personal goals privately on your device

PRIVACY FIRST
✅ Works 100% offline after first download
✅ No internet required in use
✅ No GPS or location tracking
✅ No camera access
✅ No advertisements
✅ All data stays on your device
✅ Only collects: first name and age bracket

MILITARY-FOCUSED CONTENT
Understand the unique challenges of military life including deployments, transitions, relationships under pressure, and resettlement. Content tailored for service members, veterans, and partners/families.

EVIDENCE-BASED
Breathing techniques include methods used by Navy SEALs, first responders, and elite athletes. Educational content grounded in neuroscience and psychology.

CHARITABLE IMPACT
£1 from every download goes to the Submariners Charity.

IMPORTANT: This app is not a substitute for professional medical advice. If you're experiencing a mental health crisis, please contact emergency services or a mental health professional.

Made with ❤️ for those who serve beneath the waves and beyond.
```

**Keywords** (100 characters max):
```
military,mental health,breathing,wellbeing,veteran,submarine,offline,mood,mindfulness,calm
```

**Promotional Text** (170 characters):
```
The only mental health app designed for military personnel that works completely offline. Evidence-based tools for stress, sleep, and emotional wellbeing.
```

**Support URL:**
- Create a simple website or use: `https://belowthesurface.app/support`

**Marketing URL** (optional):
- `https://belowthesurface.app`

---

## 7. TestFlight Beta Testing

### 7.1 Build Archive in Xcode

**Option A: Using Xcode (Recommended for first time)**

1. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Target:**
   - At top of Xcode, next to play button
   - Select: **"Any iOS Device (arm64)"**

3. **Create Archive:**
   - Menu: **Product** → **Archive**
   - Wait for build to complete (5-10 minutes)

4. **Upload to App Store Connect:**
   - Archives window opens automatically
   - Select your archive
   - Click **"Distribute App"**
   - Choose: **"App Store Connect"**
   - Click **"Upload"**
   - Click **"Next"** through options
   - Wait for upload to complete

**Option B: Using Flutter Command Line**

```bash
# Clean build
flutter clean
flutter pub get

# Build release
flutter build ios --release

# Then follow Xcode steps 2-4 above
```

**Option C: Using fastlane (Advanced)**

See section 7.5 below for automation setup.

### 7.2 Wait for Processing

After upload:
1. Go to: https://appstoreconnect.apple.com/
2. Go to: **My Apps** → **Below the Surface** → **TestFlight** tab
3. Wait for **"Processing"** to complete (10-60 minutes)
4. You'll receive an email when ready

### 7.3 Complete Beta App Information

While waiting:
1. Go to **TestFlight** tab
2. Fill in **"Test Information"**:
   - Beta App Description
   - Feedback Email
   - What to Test notes

### 7.4 Add Beta Testers

**Internal Testing** (Apple Developer team members):
1. Go to **TestFlight** → **Internal Testing**
2. Click **"+"** to add testers
3. Enter email addresses

**External Testing** (up to 10,000 testers):
1. Go to **TestFlight** → **External Testing**
2. Create a new group
3. Add tester emails
4. Submit for Beta App Review (1-2 days)

### 7.5 Automation with fastlane (Optional)

Install fastlane:
```bash
# Install fastlane
sudo gem install fastlane

# Setup fastlane in iOS folder
cd ios
fastlane init
```

Create `ios/fastlane/Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    # Build app
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    
    # Upload to TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
end
```

**Run beta upload:**
```bash
cd ios
fastlane beta
```

---

## 8. Submit for Review

### 8.1 Prepare for Submission

Before submitting, ensure you have:

- [x] App icons (all sizes)
- [x] Screenshots (at least 3 per size)
- [x] App description
- [x] Keywords
- [x] Support URL
- [x] Privacy policy URL
- [x] Age rating completed
- [x] App category selected
- [x] Pricing set
- [x] Build uploaded and processed

### 8.2 Add Build to Submission

1. Go to **App Store** tab (not TestFlight)
2. Click **"+ Version or Platform"**
3. Enter version: **1.0.0**
4. Scroll to **"Build"** section
5. Click **"+ Add Build"**
6. Select your TestFlight build
7. Click **"Done"**

### 8.3 Complete Version Information

**Version Information:**
- What's New in This Version: "Initial release of Below the Surface..."

**App Review Information:**
- Contact: Your email and phone
- Notes: "This app works fully offline. No account required."
- Demo account: Not required (no login)

**Version Release:**
- Choose: "Automatically release this version" or "Manually release"

### 8.4 Export Compliance

When asked about encryption:
- **Does your app use encryption?** YES
- **Is it exempt?** YES (uses standard iOS encryption only)
- Select: "Your app uses standard encryption"

### 8.5 Submit for Review

1. Click **"Add for Review"** (top right)
2. Review all information
3. Click **"Submit to App Review"**

### 8.6 Review Timeline

- **Initial Review:** 1-3 days typically
- **Status tracking:** App Store Connect → App Store tab

**Possible statuses:**
- **Waiting for Review** - In queue
- **In Review** - Being tested by Apple
- **Pending Developer Release** - Approved, waiting for you to release
- **Ready for Sale** - Live on App Store!
- **Rejected** - See rejection reasons and resubmit

---

## 9. Troubleshooting

### 9.1 Common Build Errors

**Error: "No signing certificate"**
```bash
Solution:
1. Open Xcode
2. Xcode → Preferences → Accounts
3. Select your Apple ID
4. Click "Manage Certificates"
5. Click "+" → "Apple Distribution"
```

**Error: "CocoaPods not installed"**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install pods
cd ios
pod install
cd ..
```

**Error: "The app ID cannot be registered"**
```bash
Solution:
- Your Bundle ID is already registered in App Store Connect
- This is correct! Continue with the process
```

**Error: "Provisioning profile doesn't include signing certificate"**
```bash
Solution:
1. Delete provisioning profiles
2. In Xcode: Product → Clean Build Folder
3. Enable "Automatically manage signing" again
```

### 9.2 TestFlight Issues

**Build not appearing in TestFlight:**
- Wait 30-60 minutes for processing
- Check email for processing errors
- Ensure you agreed to Apple agreements

**"Missing Compliance" warning:**
- Go to TestFlight → Select build
- Answer export compliance questions
- Select "No" or "Standard encryption only"

### 9.3 Rejection Reasons

**Common rejections:**

**2.1 - App Completeness:**
- App crashes on launch
- Features don't work
- Solution: Test thoroughly before submitting

**4.0 - Design:**
- Incomplete app
- Poor UX
- Solution: Ensure all features are polished

**5.1 - Privacy:**
- Missing privacy policy
- Data collection not disclosed
- Solution: Add privacy policy URL, complete questionnaire

**Medical App Requirements:**
- If rejected for medical claims
- Add clear disclaimers
- Emphasise "wellbeing" not "treatment"

### 9.4 Getting Help

**Apple Developer Forums:**
- https://developer.apple.com/forums/

**App Store Connect Support:**
- https://developer.apple.com/contact/

**Flutter iOS Issues:**
- https://github.com/flutter/flutter/issues

---

## 10. Post-Launch Checklist

After your app is **"Ready for Sale"**:

- [ ] Test download from App Store
- [ ] Monitor crash reports (Xcode → Organizer → Crashes)
- [ ] Respond to user reviews
- [ ] Track downloads (App Store Connect → Analytics)
- [ ] Monitor revenue (if paid app)
- [ ] Plan updates and bug fixes

**Update Process:**
1. Fix bugs / add features
2. Increment version number in `pubspec.yaml`
3. Build new archive
4. Upload to TestFlight
5. Create new version in App Store Connect
6. Submit for review

---

## 11. Quick Reference Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get && cd ios && pod install && cd ..

# Run on simulator
flutter run -d "iPhone 15 Pro"

# Run on device
flutter run --release

# Build for release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace

# Check Flutter setup
flutter doctor -v

# List devices
flutter devices
```

---

## 12. Important Files Reference

| File | Purpose |
|------|---------|
| `pubspec.yaml` | App version and dependencies |
| `ios/Runner/Info.plist` | iOS app configuration |
| `ios/Runner.xcodeproj` | Xcode project (don't open directly) |
| `ios/Runner.xcworkspace` | Xcode workspace (open this!) |
| `ios/Podfile` | CocoaPods dependencies |
| `ios/Runner/Assets.xcassets/` | Icons and images |

---

## 13. Your App Details Summary

**For Reference:**

```
App Name: Below the Surface
Display Name: Below the Surface
Bundle ID: com.ocean.darrengalvin
SKU: com.ocean.darrengalvin
Apple ID: 6758065156
Version: 1.0.0
Build: 1
Minimum iOS: 13.0
Team: [Your Apple Developer Team]
```

---

## Need Help?

If you encounter issues:

1. **Check Flutter Doctor:**
   ```bash
   flutter doctor -v
   ```

2. **Check Xcode Build Logs:**
   - Xcode → Report Navigator (⌘9)
   - Look for red errors

3. **Ask for Help:**
   - Flutter Discord: https://discord.gg/flutter
   - Apple Developer Forums
   - Stack Overflow with tags: `ios`, `flutter`, `xcode`

---

**Good luck with your submission! 🚀**

Remember: The first submission might be rejected for minor issues. This is normal! Just address the feedback and resubmit.



