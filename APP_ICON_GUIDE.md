# Lammh App Icon Guide

This guide will help you create the iOS and Android app icons for the Lammh app based on the brand identity.

## Design Specifications

### Primary Icon Design
- **Background**: Solid pink/red gradient (#E84855 to #F06292)
- **Logo**: White brain/maze pattern from the brand identity
- **Style**: Rounded square with white logo centered

## Option 1: Use SVG to Generate Icon (Recommended)

Save the following SVG code as `lammh_icon.svg`:

```svg
<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Background gradient -->
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#E84855;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#EC0901;stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="1024" height="1024" fill="url(#bgGradient)" rx="180"/>

  <!-- Logo paths (simplified brain maze pattern) -->
  <g transform="translate(312, 312)" stroke="white" stroke-width="60" stroke-linecap="round" stroke-linejoin="round" fill="none">
    <!-- Top left curve -->
    <path d="M 50 50 Q 0 50 0 100 Q 0 150 50 150"/>

    <!-- Top right curve -->
    <path d="M 350 50 Q 400 50 400 100 Q 400 150 350 150"/>

    <!-- Bottom left curve -->
    <path d="M 50 250 Q 0 250 0 300 Q 0 350 50 350"/>

    <!-- Bottom right curve -->
    <path d="M 350 250 Q 400 250 400 300 Q 400 350 350 350"/>
  </g>
</svg>
```

### Using the SVG:

1. **Online Tool (Easiest)**:
   - Go to https://appicon.co or https://makeappicon.com
   - Upload the SVG file
   - Download all the generated icon sizes for iOS and Android

2. **Using Figma/Sketch/Adobe XD**:
   - Import the SVG file
   - Export at required sizes (1024x1024 for iOS, etc.)

## Option 2: Use Flutter Package (Automated)

Install the `flutter_launcher_icons` package:

### Step 1: Add to `pubspec.yaml`

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  # For iOS
  ios_background_color: "#E84855"
  # For Android
  adaptive_icon_background: "#E84855"
  adaptive_icon_foreground: "assets/icon/foreground_icon.png"
```

### Step 2: Create Icon Assets

1. Create a folder: `assets/icon/`
2. Create a 1024x1024 PNG version of the logo (use the SVG above)
3. Save as `app_icon.png` in the `assets/icon/` folder

### Step 3: Generate Icons

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Option 3: Manual Icon Creation

### Required Sizes for iOS:

Create PNG files at these exact sizes and place them in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:

- 20x20 (@1x)
- 40x40 (@2x)
- 60x60 (@3x)
- 29x29 (@1x)
- 58x58 (@2x)
- 87x87 (@3x)
- 40x40 (@1x)
- 80x80 (@2x)
- 120x120 (@3x)
- 76x76 (@1x)
- 152x152 (@2x)
- 167x167 (@2x)
- 1024x1024 (App Store)

### Required Sizes for Android:

Place in `android/app/src/main/res/`:

- `mipmap-mdpi/ic_launcher.png` (48x48)
- `mipmap-hdpi/ic_launcher.png` (72x72)
- `mipmap-xhdpi/ic_launcher.png` (96x96)
- `mipmap-xxhdpi/ic_launcher.png` (144x144)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192)

## Design Tips

1. **Keep it Simple**: The logo should be recognizable even at small sizes
2. **Test on Device**: Always preview on actual devices
3. **Safe Area**: Keep important elements within 80% of the icon canvas
4. **Contrast**: Ensure the white logo stands out against the pink background

## Color Reference

From the brand identity PDF:

- **Primary Pink/Red**: #E84855
- **Secondary Pink**: #F06292
- **Logo Color**: White (#FFFFFF)
- **Alternative Background**: Pink gradient (from brand PDF page 2)

## Recommended Tools

- **AppIcon.co**: Free online icon generator
- **MakeAppIcon.com**: Generates all required sizes
- **Figma**: Professional design tool (free tier available)
- **Adobe XD**: For precise control

## Quick Start (Fastest Method)

1. Use the SVG code above
2. Go to https://appicon.co
3. Upload the SVG
4. Download the generated icons
5. Extract and replace the icon folders in your Flutter project
6. Clean build: `flutter clean && flutter build ios/android`

That's it! Your app will now have the Lammh branded icon.
