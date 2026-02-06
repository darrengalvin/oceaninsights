# Push Notifications Setup

This app uses **local notifications** for daily affirmation reminders. No server/Firebase required.

## How It Works

1. User enables notifications in Settings
2. App schedules a daily notification at user's chosen time
3. A random affirmation from the app's collection is shown
4. Notification repeats daily at the same time

## What's Already Done

- ✅ Flutter notification service (`lib/core/services/notification_service.dart`)
- ✅ Settings screen (`lib/features/settings/screens/notification_settings_screen.dart`)
- ✅ Link from home screen footer
- ✅ Packages added to `pubspec.yaml`

## iOS Setup Required

### 1. Add Background Modes Capability

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select the Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Background Modes"
6. Check "Background fetch" and "Remote notifications"

### 2. Verify Info.plist

The `ios/Runner/Info.plist` should already have:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3. Request Permission at Runtime

The app automatically requests permission when the user enables notifications.
The system will show iOS's permission dialog.

## Android Setup Required

### 1. Notification Permission (Android 13+)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### 2. Create Notification Channel

The app automatically creates a notification channel named "Daily Affirmations".

## Testing

1. Run the app
2. Go to Settings (scroll to footer) → Notifications
3. Enable "Daily Notifications"
4. Accept the permission request
5. Tap "Send Test Notification" to verify

## User Experience

### Settings Screen Features

- **Toggle**: Enable/disable daily notifications
- **Time Picker**: Choose when to receive affirmation (default 8:00 AM)
- **Test Button**: Send immediate test notification

### Notification Content

Each notification includes:
- **Title**: "Daily Affirmation 🌊"
- **Body**: Random affirmation from the app's collection
- **Sound**: Default system sound
- **Badge**: None (non-intrusive)

## Privacy

- 100% local - no server communication
- No tracking of notification interactions
- User can disable anytime
- Time preference stored only on device

## Troubleshooting

### Notifications Not Appearing

1. Check device notification settings for the app
2. Ensure "Do Not Disturb" is off
3. For Android: Check notification channel isn't muted
4. For iOS: Check notification settings in Settings app

### Permission Issues

If permission was denied:
1. User must go to device Settings
2. Find Below the Surface app
3. Enable notifications manually
4. Return to app and toggle setting

## Future Enhancements (Optional)

- [ ] Multiple notification types (morning motivation, evening reflection)
- [ ] Custom affirmation categories preference
- [ ] Notification snooze option
- [ ] Weekly summary notification
