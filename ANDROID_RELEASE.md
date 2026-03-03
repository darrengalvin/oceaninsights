# Android release – Below the Surface

You have an Android developer account and Android Studio. Follow these steps once, then you can build and upload whenever you need.

---

## 1. Accept Android SDK licenses (one-time)

In a terminal (with `flutter` on PATH):

```powershell
flutter doctor --android-licenses
```

Accept all prompts with `y`.

---

## 2. Create your upload keystore (one-time)

Run this in PowerShell **from your project root** (`oceaninsights`):

```powershell
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- You’ll be asked for a **keystore password** and a **key password** (you can use the same).
- Fill in your name/organization when prompted.
- **Back up** the `.jks` file and passwords somewhere safe. You need them for every future release.

---

## 3. Add `key.properties` (one-time)

1. In the `android` folder, copy the example file:
   - Copy `android/key.properties.example` to `android/key.properties`.

2. Open `android/key.properties` and set:

   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=app/upload-keystore.jks
   ```

   Use the same passwords and alias you used when creating the keystore.  
   `key.properties` is gitignored; don’t commit it.

---

## 4. Build the App Bundle (for Play Store)

From the project root:

```powershell
flutter build appbundle
```

The signed bundle will be at:

`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Upload to Google Play Console

1. Open [Google Play Console](https://play.google.com/console).
2. Select (or create) the app **Below the Surface** with package name `com.ocean.darrengalvin`.
3. Go to **Release** → **Production** (or a testing track).
4. **Create new release** → upload `app-release.aab`.
5. Complete the listing (description, screenshots, etc.) if you haven’t already.
6. Submit for review.

---

## Version and package

- **Version:** `pubspec.yaml` has `version: 1.1.0+2` (version 1.1.0, build 2). For each new store upload, increase the build number (e.g. `1.1.0+3`).
- **Package name:** `com.ocean.darrengalvin` (must match the app in Play Console).

---

## If you don’t have `key.properties` yet

Release builds still work: they’re signed with the **debug** key so you can test. For Play Store you **must** complete steps 2 and 3 and then run `flutter build appbundle` again.
