# 🚀 Responsive Design - Quick Start

## Run on Any Platform

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

## Using Responsive Utilities

### Check Device & Orientation

```dart
import 'package:trivia_game/utils/responsive_helper.dart';

// Platform
ResponsiveHelper.isWeb()
ResponsiveHelper.isMobile()
ResponsiveHelper.isAndroid()
ResponsiveHelper.isIOS()

// Orientation
ResponsiveHelper.isLandscape(context)
ResponsiveHelper.isPortrait(context)

// Screen Size
ResponsiveHelper.screenWidth(context)
ResponsiveHelper.screenHeight(context)
ResponsiveHelper.isSmallScreen(context)  // < 600
ResponsiveHelper.isMediumScreen(context) // 600-1024
ResponsiveHelper.isLargeScreen(context)  // >= 1024
```

### Responsive Layouts

```dart
// Different layouts per device type
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

// Different layouts per orientation
OrientationLayout(
  portrait: PortraitLayout(),
  landscape: LandscapeLayout(),
)

// Constrained width for large screens
ResponsiveConstrainedBox(
  maxWidth: 1200,
  child: YourContent(),
)
```

### Responsive Values

```dart
// Font sizes
final fontSize = ResponsiveHelper.getResponsiveFontSize(
  context,
  mobile: 16,
  tablet: 20,
  desktop: 24,
);

// Spacing/Sizes
final padding = ResponsiveHelper.getResponsiveValue(
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

## Orientation Management

### For Game Screens

```dart
import 'package:trivia_game/utils/orientation_manager.dart';

// Wrap your game screen
GameScreenWrapper(
  preferLandscape: true,
  child: YourGameScreen(),
)
```

### Lock Orientation

```dart
// Portrait only
await OrientationManager.lockPortrait();

// Landscape only
await OrientationManager.lockLandscape();

// Allow all
await OrientationManager.unlockAll();
```

## Example: Game Grid

```dart
final columns = ResponsiveHelper.getQuestionGridColumns(context);
// Returns appropriate columns based on device and orientation

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
  ),
  itemBuilder: (context, index) => QuestionCard(),
)
```

## Example: Landscape-Optimized Layout

```dart
OrientationLayout(
  portrait: Column(
    children: [
      LeftTeam(),
      QuestionArea(),
      RightTeam(),
    ],
  ),
  landscape: Row(
    children: [
      LeftTeam(),
      Expanded(child: QuestionArea()),
      RightTeam(),
    ],
  ),
)
```

## Testing

### Rotate Device/Emulator
- **Android:** Ctrl+F11 (Win/Linux), Cmd+Left/Right (Mac)
- **iOS:** Cmd+Left/Right arrows
- **Chrome:** DevTools device toolbar

### Test Different Sizes
```bash
# Chrome with DevTools for different screen sizes
flutter run -d chrome
# Then use Chrome DevTools to emulate devices
```

## Quick Reference

| Feature | Mobile Portrait | Mobile Landscape | Tablet | Desktop |
|---------|----------------|------------------|---------|---------|
| Grid Columns | 2-3 | 5 | 3-4 | 4-5 |
| Padding | 16px | 16px | 24px | 32px |
| Max Width | Full | Full | 800px | 1200px |
| Font Scale | 1.0x | 1.0x | 1.2x | 1.4x |

## Complete Documentation

For detailed information, see:
- `PLATFORM_SUPPORT.md` - Complete platform & orientation guide
- `lib/utils/responsive_helper.dart` - All utility methods
- `lib/utils/orientation_manager.dart` - Orientation control

---

**Ready to build responsive, cross-platform apps!** 🚀
