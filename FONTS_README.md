# Fonts Setup - Tajawal Font Family

This app uses the **Tajawal** font family for Arabic and English text support.

## Required Font Files

You need to download and add the following Tajawal font files to your project:

### Font Files Needed:

1. `Tajawal-Regular.ttf` (Weight: 400)
2. `Tajawal-Medium.ttf` (Weight: 500)
3. `Tajawal-Bold.ttf` (Weight: 700)
4. `Tajawal-ExtraBold.ttf` (Weight: 800)

## Where to Get Tajawal Fonts

### Option 1: Google Fonts (Recommended)

1. Visit [Google Fonts - Tajawal](https://fonts.google.com/specimen/Tajawal)
2. Click **"Download family"**
3. Extract the ZIP file
4. You'll find these font files:
   - `Tajawal-Regular.ttf`
   - `Tajawal-Medium.ttf`
   - `Tajawal-Bold.ttf`
   - `Tajawal-ExtraBold.ttf`

### Option 2: Direct Links

Download directly from Google Fonts repository:
- [Tajawal on GitHub](https://github.com/google/fonts/tree/main/ofl/tajawal)

## Installation Steps

1. **Create fonts directory:**
```bash
mkdir -p assets/fonts
```

2. **Copy font files:**
Place the 4 `.ttf` files in `assets/fonts/` directory:
```
assets/
└── fonts/
    ├── Tajawal-Regular.ttf
    ├── Tajawal-Medium.ttf
    ├── Tajawal-Bold.ttf
    └── Tajawal-ExtraBold.ttf
```

3. **Verify pubspec.yaml:**
The fonts are already configured in `pubspec.yaml`:
```yaml
fonts:
  - family: Tajawal
    fonts:
      - asset: assets/fonts/Tajawal-Regular.ttf
        weight: 400
      - asset: assets/fonts/Tajawal-Medium.ttf
        weight: 500
      - asset: assets/fonts/Tajawal-Bold.ttf
        weight: 700
      - asset: assets/fonts/Tajawal-ExtraBold.ttf
        weight: 800
```

4. **Run flutter pub get:**
```bash
flutter pub get
```

5. **Restart your app:**
```bash
flutter run
```

## Alternative: Use google_fonts Package

If you don't want to manually download fonts, you can use the `google_fonts` package (already included in dependencies).

**Update** `lib/theme/app_text_styles.dart`:

```dart
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Example using Google Fonts package
  static TextStyle smallTv = GoogleFonts.tajawal(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w400,
  );

  // ... rest of styles
}
```

**Note:** Using `google_fonts` package requires internet connection on first run to download fonts.

## Verification

To verify fonts are working:

1. Run the app
2. Check if Arabic text displays correctly
3. Look for different font weights (regular, medium, bold, extra bold)
4. If you see default system font, fonts are not loaded properly

## Troubleshooting

### Fonts not showing
- Make sure font files are in `assets/fonts/`
- Check filenames match exactly (case-sensitive)
- Run `flutter clean` then `flutter pub get`
- Restart the app

### Arabic text rendering issues
- Tajawal supports Arabic properly
- Make sure you're using RTL text direction for Arabic

### Build errors
- Check `pubspec.yaml` indentation (YAML is sensitive)
- Ensure font files exist in the specified paths

## Font License

Tajawal is licensed under the [Open Font License (OFL)](https://scripts.sil.org/OFL)
- ✅ Free for personal and commercial use
- ✅ Can be bundled with app
- ✅ No attribution required (but appreciated)
