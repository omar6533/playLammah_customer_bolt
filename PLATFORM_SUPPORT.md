# 📱 Platform & Orientation Support Guide

Your Flutter Trivia Game now supports **Web, iOS, and Android** with dynamic orientation handling!

## 🎯 Supported Platforms

### ✅ Mobile Apps
- **Android** - Phones and Tablets
- **iOS** - iPhone and iPad

### ✅ Web
- Desktop browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers
- Progressive Web App (PWA) ready

## 🔄 Orientation Support

### Dynamic Orientation
The app supports **both portrait and landscape** modes with intelligent layouts:

- **Portrait Mode** - Default for browsing, menus, and setup
- **Landscape Mode** - Optimized for gameplay on mobile devices
- **Auto-rotation** - Seamlessly switches between orientations
- **Responsive Layouts** - UI adapts to screen size and orientation

### Game Screens
Game screens are designed to work beautifully in landscape mode for the best gameplay experience on mobile devices.

## 🚀 Running on Different Platforms

### Android

```bash
# Development build
flutter run -d android

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

**Device Requirements:**
- Android 5.0 (API 21) or higher
- ARM64 or x86_64 processor

### iOS

```bash
# Development build
flutter run -d ios

# Release build
flutter build ios --release
```

**Device Requirements:**
- iOS 12.0 or higher
- iPhone 6 or newer
- iPad (all models with iOS 12+)

**Prerequisites:**
- Mac with Xcode installed
- Apple Developer account (for device testing)
- CocoaPods installed

### Web

```bash
# Development server
flutter run -d chrome

# Production build
flutter build web --release
```

**Browser Support:**
- Chrome 57+
- Firefox 52+
- Safari 11+
- Edge 79+

## 📐 Responsive Design Features

### Device Detection
The app automatically detects device type and adjusts UI:

```dart
import 'package:trivia_game/utils/responsive_helper.dart';

// Check device type
final isMobile = ResponsiveHelper.isMobile();
final isTablet = ResponsiveHelper.isMediumScreen(context);
final isDesktop = ResponsiveHelper.isLargeScreen(context);

// Check orientation
final isLandscape = ResponsiveHelper.isLandscape(context);
final isPortrait = ResponsiveHelper.isPortrait(context);
```

### Responsive Layouts

#### 1. ResponsiveLayout Widget
Provides different layouts for different device types:

```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

#### 2. OrientationLayout Widget
Provides different layouts based on orientation:

```dart
OrientationLayout(
  portrait: PortraitLayout(),
  landscape: LandscapeLayout(),
)
```

#### 3. ResponsiveConstrainedBox
Centers content with max width for large screens:

```dart
ResponsiveConstrainedBox(
  maxWidth: 1200,
  child: YourContent(),
)
```

### Responsive Values

Get responsive sizes based on device type:

```dart
// Font sizes
final fontSize = ResponsiveHelper.getResponsiveFontSize(
  context,
  mobile: 16,
  tablet: 18,
  desktop: 20,
);

// Spacing
final spacing = ResponsiveHelper.getResponsiveValue(
  context,
  mobile: 16,
  tablet: 24,
  desktop: 32,
);

// Grid columns
final columns = ResponsiveHelper.getCrossAxisCount(
  context,
  mobile: 2,
  tablet: 3,
  desktop: 4,
);
```

## 🎮 Game Screen Orientation

### Landscape Mode for Gameplay
Game screens automatically support landscape mode for optimal gameplay:

```dart
import 'package:trivia_game/utils/orientation_manager.dart';

// Wrap game screen with GameScreenWrapper
GameScreenWrapper(
  preferLandscape: true,
  child: YourGameScreen(),
)
```

### Orientation Controls

#### Lock Portrait
```dart
await OrientationManager.lockPortrait();
```

#### Lock Landscape
```dart
await OrientationManager.lockLandscape();
```

#### Unlock All
```dart
await OrientationManager.unlockAll();
```

## 📱 Platform-Specific Features

### Mobile (iOS & Android)

**Features:**
- ✅ Native performance
- ✅ Auto-rotation support
- ✅ Touch gestures
- ✅ Offline support
- ✅ Push notifications (ready for integration)
- ✅ Native navigation
- ✅ Biometric authentication (ready)

**Optimizations:**
- Landscape mode for gameplay
- Safe area handling
- Platform-specific UI elements
- Haptic feedback ready

### Web

**Features:**
- ✅ Responsive design
- ✅ Cross-browser compatibility
- ✅ PWA support
- ✅ Deep linking
- ✅ SEO friendly
- ✅ Fast load times

**Optimizations:**
- Adaptive layouts for desktop/mobile browsers
- Keyboard shortcuts support
- Mouse and touch interactions
- Centered content on large screens

## 🎨 UI Adaptations

### Screen Size Breakpoints

```dart
// Small (Mobile Portrait)
width < 600px
- Single column layouts
- Compact navigation
- Full-width content
- Stacked elements

// Medium (Mobile Landscape / Tablet Portrait)
600px <= width < 1024px
- Two column layouts
- Side navigation option
- Wider content areas
- Grid layouts

// Large (Tablet Landscape / Desktop)
width >= 1024px
- Multi-column layouts
- Persistent side navigation
- Max-width centered content
- Advanced grid layouts
```

### Orientation-Specific Layouts

#### Portrait Mode
- Vertical scrolling
- Stacked components
- Bottom navigation
- Tall aspect ratios

#### Landscape Mode
- Horizontal layouts
- Side-by-side components
- More content visible
- Wide aspect ratios
- Ideal for gameplay

## 🔧 Configuration

### Platform Configuration Files

**Android:**
- `android/app/build.gradle` - Min SDK 21, Target SDK 34
- `android/app/src/main/AndroidManifest.xml` - Permissions & features

**iOS:**
- `ios/Runner/Info.plist` - App permissions & settings
- `ios/Podfile` - iOS 12.0+ target

**Web:**
- `web/index.html` - PWA configuration
- `web/manifest.json` - App metadata

### Orientation Configuration

Main app configuration in `lib/main.dart`:

```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

## 📊 Layout Examples

### Game Grid - Responsive Columns

```dart
final columns = ResponsiveHelper.getQuestionGridColumns(context);
// Portrait Mobile: 3 columns
// Portrait Tablet: 4 columns
// Portrait Desktop: 5 columns
// Landscape Mobile: 5 columns
// Landscape Tablet: 6 columns

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
  ),
  itemBuilder: (context, index) => QuestionCard(),
)
```

### Team Score Display - Landscape Optimized

```dart
OrientationLayout(
  portrait: Column(
    children: [
      TeamScoreCard(team: leftTeam),
      QuestionArea(),
      TeamScoreCard(team: rightTeam),
    ],
  ),
  landscape: Row(
    children: [
      TeamScoreCard(team: leftTeam),
      Expanded(child: QuestionArea()),
      TeamScoreCard(team: rightTeam),
    ],
  ),
)
```

### Category Selection - Responsive Grid

```dart
final crossAxisCount = ResponsiveHelper.getCrossAxisCount(
  context,
  mobile: 2,
  tablet: 3,
  desktop: 4,
);

GridView.count(
  crossAxisCount: crossAxisCount,
  children: categories.map((cat) => CategoryCard(cat)).toList(),
)
```

## 🧪 Testing Platforms

### Testing on Android

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Android emulator
flutter emulators --launch <emulator_name>
flutter run -d emulator-5554
```

### Testing on iOS

```bash
# List iOS simulators
flutter emulators

# Launch simulator
flutter emulators --launch <simulator_id>

# Run on simulator
flutter run -d iPhone-14

# Run on physical device
flutter run -d <device_id>
```

### Testing on Web

```bash
# Chrome
flutter run -d chrome

# Chrome with specific port
flutter run -d web-server --web-port 8080

# Test different screen sizes
# Use Chrome DevTools device emulation
```

### Testing Orientations

1. **Android Emulator:**
   - Ctrl + F11 (Windows/Linux)
   - Cmd + Left/Right (Mac)

2. **iOS Simulator:**
   - Cmd + Left/Right arrows

3. **Chrome DevTools:**
   - Toggle device toolbar
   - Rotate device icon

## 🚀 Deployment

### Android - Google Play Store

```bash
# Build app bundle
flutter build appbundle --release

# Location:
# build/app/outputs/bundle/release/app-release.aab
```

**Requirements:**
- Google Play Developer account
- App signed with release key
- Privacy policy URL
- App screenshots (phone & tablet)

### iOS - App Store

```bash
# Build iOS app
flutter build ios --release

# Open in Xcode for upload
open ios/Runner.xcworkspace
```

**Requirements:**
- Apple Developer Program membership
- App Store Connect setup
- App signed with distribution certificate
- App screenshots (iPhone & iPad)

### Web - Hosting

```bash
# Build web app
flutter build web --release

# Output location:
# build/web/
```

**Hosting Options:**
- Firebase Hosting
- Netlify
- Vercel
- AWS S3 + CloudFront
- GitHub Pages

## 💡 Best Practices

### 1. Always Test on Real Devices
- Emulators don't show real performance
- Touch interactions differ on devices
- Test various screen sizes

### 2. Handle Orientation Changes
- Save game state during rotation
- Use orientation-aware layouts
- Test landscape mode thoroughly

### 3. Responsive Design
- Use ResponsiveHelper utilities
- Avoid fixed pixel values
- Test on small and large screens
- Support tablets explicitly

### 4. Platform-Specific Code
```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
} else if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}
```

### 5. Performance
- Optimize for 60 FPS on mobile
- Lazy load images
- Use const constructors
- Profile on real devices

## 🐛 Common Issues & Solutions

### Issue: Orientation Not Changing

**Solution:**
```dart
// Unlock orientations
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

### Issue: Layout Overflow in Landscape

**Solution:**
```dart
OrientationLayout(
  portrait: YourPortraitLayout(),
  landscape: SingleChildScrollView(
    child: YourLandscapeLayout(),
  ),
)
```

### Issue: Web App Not Responsive

**Solution:**
- Use MediaQuery for responsive sizing
- Test in Chrome DevTools with device emulation
- Add viewport meta tag in web/index.html

### Issue: iOS Safe Area Issues

**Solution:**
```dart
SafeArea(
  child: YourContent(),
)

// Or use MediaQuery padding
final safePadding = MediaQuery.of(context).padding;
```

## 📚 Utility Reference

### ResponsiveHelper Methods

- `isWeb()` - Check if running on web
- `isMobile()` - Check if iOS or Android
- `isAndroid()` - Check if Android
- `isIOS()` - Check if iOS
- `isLandscape(context)` - Check landscape orientation
- `isPortrait(context)` - Check portrait orientation
- `screenWidth(context)` - Get screen width
- `screenHeight(context)` - Get screen height
- `getDeviceType(context)` - Get mobile/tablet/desktop
- `getResponsiveFontSize()` - Get font size by device
- `getResponsiveValue()` - Get value by device
- `getCrossAxisCount()` - Get grid columns
- `getQuestionGridColumns()` - Get game grid columns
- `getScreenPadding()` - Get safe padding

### OrientationManager Methods

- `lockPortrait()` - Lock to portrait only
- `lockLandscape()` - Lock to landscape only
- `unlockAll()` - Allow all orientations
- `hideSystemUI()` - Full-screen mode
- `showSystemUI()` - Show status bar

## 🎯 Summary

Your app is now fully configured for:

✅ **Platforms:**
- Android phones & tablets
- iOS iPhones & iPads
- Web browsers (desktop & mobile)

✅ **Orientations:**
- Portrait mode for menus
- Landscape mode for gameplay
- Dynamic orientation switching
- Responsive layouts

✅ **Features:**
- Platform detection
- Device type detection
- Responsive sizing
- Orientation locking
- Safe area handling
- Cross-platform compatibility

## 🚀 Quick Start

1. **Run on Android:**
   ```bash
   flutter run -d android
   ```

2. **Run on iOS:**
   ```bash
   flutter run -d ios
   ```

3. **Run on Web:**
   ```bash
   flutter run -d chrome
   ```

4. **Test Landscape Mode:**
   - Rotate device/emulator
   - Game screens automatically adapt

Ready to deploy on all platforms! 🎉
