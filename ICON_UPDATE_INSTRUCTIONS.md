# App Icon Update Instructions

## What Changed
Your app icon has been updated from simple horizontal lines to **realistic ocean waves** with:
- Multiple layered waves with natural, flowing curves
- Foam/spray effects on wave crests
- Depth and motion through color gradients
- A central meditation circle (representing calm/mindfulness)
- More visual richness and ocean-like appearance

## Old Icon Backup
Your original icon files have been backed up to:
```
backups/old-app-icons/AppIcon.appiconset/
```

## How to Generate the New Icon

### Option 1: Using the HTML Generator (Recommended)
1. Open `app-icon-generator.html` in **Safari** or **Chrome**
2. You'll see the new wave-based icon design
3. Right-click the icon and select **"Save Image As..."**
4. Save as `below-the-surface-icon-1024.png`
5. Go to https://appicon.co/
6. Upload the PNG file
7. Download the generated assets
8. Replace the contents of `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Option 2: Using Browser Developer Tools
1. Open `app-icon-generator.html` in a browser
2. Click the **"Download as PNG"** button
3. The icon will download automatically as `below-the-surface-icon-1024x1024.png`
4. Follow steps 5-8 from Option 1 above

### Option 3: Manual Extract from HTML
1. Open `app-icon-generator.html` in Safari
2. Open Developer Tools (Cmd + Option + I)
3. Take a screenshot of just the icon area
4. Use Preview to crop to exactly 1024x1024 pixels
5. Follow steps 5-8 from Option 1 above

## What the New Design Looks Like

The icon now features:
- **Back wave** - Larger, slower curve with darker blue-green (#3A7BC8)
- **Middle wave** - Medium dynamic curve with lighter teal (#4A90E2)
- **Front wave** - Active crests with foam effects (#5BA3E8)
- **Foam highlights** - Small ellipses on wave crests for texture
- **Central breathing circle** - Concentric circles representing mindfulness
- **Ripple rings** - Subtle awareness/meditation rings
- **Ocean gradient background** - Deep blue (#1E3A5F) to lighter ocean (#2C5F8D)

## Verification
Once you've replaced the icons:
1. Clean build in Xcode (Cmd + Shift + K)
2. Build and run (Cmd + R)
3. Check the app icon on the simulator home screen
4. Verify it looks like ocean waves, not just lines

## Need Help?
If you have issues, the SVG source is embedded in `app-icon-generator.html` and can be extracted or modified as needed.
