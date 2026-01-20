# Deep Dive - Setup Guide

## Quick Start

### Prerequisites

1. Install Flutter SDK (3.2.0 or higher)
   - Download from: https://docs.flutter.dev/get-started/install
   - Run `flutter doctor` to verify installation

2. IDE Setup (optional but recommended)
   - VS Code with Flutter extension
   - Or Android Studio with Flutter plugin

### Running the App

```bash
# Navigate to project directory
cd deepdive

# Get dependencies
flutter pub get

# Run on web (for client demos)
flutter run -d chrome

# Run on iOS Simulator (macOS only)
flutter run -d ios

# Run on Android Emulator
flutter run -d android
```

## Deploying Web Version for Client Demos

### Option 1: Vercel (Recommended - Easiest)

1. Build the web version:
   ```bash
   flutter build web --release
   ```

2. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

3. Deploy:
   ```bash
   vercel --prod
   ```

4. Share the URL with your client!

### Option 2: Netlify

1. Build the web version:
   ```bash
   flutter build web --release
   ```

2. Drag and drop the `build/web` folder to Netlify's dashboard at https://app.netlify.com/drop

### Option 3: Firebase Hosting

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login and initialise:
   ```bash
   firebase login
   firebase init hosting
   ```

3. Build and deploy:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

## Adding Audio Files

The app expects audio files in `assets/audio/`. Add relaxing sound files:

Required files (or update the code to match your files):
- ocean_waves.mp3
- rain_forest.mp3
- night_crickets.mp3
- stream.mp3
- deep_space.mp3
- submarine.mp3
- soft_hum.mp3
- singing_bowl.mp3
- binaural.mp3
- wind_chimes.mp3

Recommended sources for royalty-free sounds:
- https://freesound.org
- https://mixkit.co/free-sound-effects/
- https://pixabay.com/sound-effects/

## Building for App Stores

### iOS (App Store)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update Bundle Identifier and signing
3. Build: `flutter build ios --release`
4. Archive and upload to App Store Connect

### Android (Play Store)

1. Create a keystore for signing
2. Update `android/app/build.gradle` with signing config
3. Build: `flutter build appbundle --release`
4. Upload to Google Play Console

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── theme/                   # App theme and styling
│   │   ├── app_theme.dart       # Colours, typography
│   │   └── app_spacing.dart     # Spacing constants
│   └── providers/               # State management
│       ├── user_provider.dart   # User profile data
│       └── mood_provider.dart   # Mood tracking
└── features/
    ├── onboarding/              # First-time user flow
    ├── home/                    # Main dashboard
    ├── breathing/               # Breathing exercises
    ├── affirmations/            # Daily affirmations
    ├── assessment/              # Mood self-assessment
    ├── music/                   # Calm sounds player
    ├── learn/                   # Educational content
    └── quotes/                  # Inspirational quotes
```

## Customisation

### Changing Colours

Edit `lib/core/theme/app_theme.dart` to modify the colour palette.

### Adding More Content

- Affirmations: `lib/features/affirmations/data/affirmations_data.dart`
- Quotes: `lib/features/quotes/data/quotes_data.dart`
- Educational Articles: `lib/features/learn/data/learn_content.dart`

### Changing the Font

The app uses "Outfit" from Google Fonts. To change it:
1. Update the `google_fonts` calls in `app_theme.dart`
2. Choose any font from https://fonts.google.com

## Privacy & Data

This app stores all data locally on the device using Hive:
- User profile (name, age bracket)
- Mood entries
- App settings

No data is sent to any server. Perfect for offline use.

