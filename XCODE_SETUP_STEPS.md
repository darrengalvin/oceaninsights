# Xcode Setup - Next Steps

**✅ Completed So Far:**
- iOS folder created
- CocoaPods installed
- Info.plist configured
- Xcode workspace opened

---

## Steps to Do in Xcode RIGHT NOW

### Step 1: Configure Bundle ID and Signing (5 minutes)

1. **In Xcode (should be open now):**
   - Look at the left sidebar (Project Navigator)
   - Click on **"Runner"** (the blue icon at the top)
   - You'll see the project settings open

2. **Select the Runner TARGET** (not project):
   - In the main area, under "TARGETS", click on **"Runner"**

3. **Go to "Signing & Capabilities" tab:**
   - Click the tab at the top that says "Signing & Capabilities"

4. **Configure Signing:**
   - **Team:** Click the dropdown and select your Apple Developer account
     - If you don't see it, click "Add Account" and sign in
   - **Bundle Identifier:** Change from `com.example.deepDive` to: **`com.ocean.darrengalvin`**
   - **Provisioning Profile:** Set to "Automatic"
   - ✅ Check **"Automatically manage signing"**

5. **Do this for BOTH Debug and Release:**
   - At the top you'll see "Debug" and "Release" sections
   - Make sure both have the same settings

### Step 2: Set Deployment Target

1. **Still in the "General" tab:**
   - Scroll to find **"Minimum Deployments"**
   - Set **iOS** to: **13.0**

### Step 3: Disable Bitcode (Required for Flutter)

1. **Go to "Build Settings" tab:**
   - Click "Build Settings" at the top
   - In the search box, type: **"bitcode"**
   - Find **"Enable Bitcode"**
   - Set it to: **NO**

### Step 4: Build & Run on Simulator

1. **At the top of Xcode:**
   - Next to the Play ▶️ button, click the device selector
   - Choose: **iPhone 17 Pro** (or any iPhone simulator)

2. **Click the Play button ▶️** (or press Cmd+R)
   - First build will take 5-10 minutes
   - Watch the progress bar at the top

3. **If successful:**
   - The simulator will launch
   - Your app should appear!

### Step 5: Build for Device (If you have an iPhone)

1. **Connect iPhone via USB cable**
2. **On iPhone:** Trust the computer when prompted
3. **In Xcode:** Select your iPhone from the device dropdown
4. **Click Play ▶️**
5. **On iPhone after build:**
   - If "Untrusted Developer" error:
   - Go to: Settings → General → VPN & Device Management
   - Tap your developer certificate
   - Tap "Trust"

---

## Common Issues & Solutions

### Issue: "Failed to register bundle identifier"
**Solution:** The Bundle ID is already registered in App Store Connect (this is good!). Just continue.

### Issue: "No signing certificate"
**Solution:**
1. Xcode → Preferences (Cmd+,)
2. Accounts tab
3. Select your Apple ID
4. "Manage Certificates"
5. Click "+" → "Apple Development"

### Issue: "Team not found"
**Solution:**
- You need an Apple Developer account ($99/year)
- Sign up at: https://developer.apple.com/programs/

### Issue: Build fails with Pod errors
**Solution:**
```bash
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive/ios
rm -rf Pods Podfile.lock
export LANG=en_US.UTF-8
pod install
```

---

## After Successful Simulator Build

Once the app runs successfully on the simulator:

### ✅ **What Works:**
- You've confirmed the app builds correctly
- iOS configuration is complete
- Ready for next steps

### 📱 **Next: Create Archive for App Store**

1. **In Xcode device selector:**
   - Choose: **"Any iOS Device (arm64)"**

2. **Menu: Product → Archive**
   - This creates a build for App Store
   - Takes 10-15 minutes
   - Wait for "Archives" window to open

3. **In Archives window:**
   - Select your archive
   - Click **"Distribute App"**
   - Choose: **"App Store Connect"**
   - Click **"Upload"**
   - Follow the prompts

4. **Wait for processing:**
   - Go to: https://appstoreconnect.apple.com/
   - App will appear in TestFlight after 10-60 minutes
   - You'll get an email when ready

---

## Quick Commands Reference

If you need to rebuild from terminal:

```bash
# Clean and rebuild
cd /Users/darrengalvin/Documents/GIT\ PROJECTS/deepdive
flutter clean
flutter pub get
export LANG=en_US.UTF-8
cd ios && pod install && cd ..

# Run on simulator
flutter run -d "iPhone 17 Pro"

# Build release
flutter build ios --release
```

---

## Your App Details

**Bundle ID:** com.ocean.darrengalvin  
**App Name:** Below the Surface  
**SKU:** com.ocean.darrengalvin  
**Apple ID:** 6758065156  
**Min iOS:** 13.0

---

## Need Help?

**Check Flutter setup:**
```bash
flutter doctor -v
```

**See build errors:**
- Xcode → Report Navigator (⌘9)
- Look for red errors

**Full guide:** See `IOS_DEPLOYMENT_GUIDE.md` in project root

---

**CURRENT STATUS:** ✅ Project configured, Xcode open, ready to set Bundle ID and build!



