# 📱 Mobile Platform Setup (Android & iOS)

Your Firebase web configuration is already set up! To run on Android or iOS, you'll need to add platform-specific configuration files.

## 🤖 Android Setup (5 minutes)

### Step 1: Register Android App in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **allmahgame**
3. Click the **Android icon** to add an Android app
4. Enter Android package name: `com.example.trivia_game`
   - (Or your custom package name from `android/app/build.gradle`)
5. Click **Register app**

### Step 2: Download google-services.json

1. Click **Download google-services.json**
2. Place the file in: `android/app/google-services.json`

### Step 3: Update Android Build Files

The necessary Gradle configuration should already be in place, but verify:

**`android/build.gradle`** should have:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**`android/app/build.gradle`** should have:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 4: Test Android

```bash
flutter run -d android
```

## 🍎 iOS Setup (10 minutes)

### Step 1: Register iOS App in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **allmahgame**
3. Click the **iOS icon** to add an iOS app
4. Enter iOS bundle ID: `com.example.triviaGame`
   - (Or your custom bundle ID from Xcode)
5. Click **Register app**

### Step 2: Download GoogleService-Info.plist

1. Click **Download GoogleService-Info.plist**
2. Open your project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Right-click on `Runner` folder in Xcode
4. Select **Add Files to "Runner"**
5. Select `GoogleService-Info.plist`
6. Make sure **Copy items if needed** is checked
7. Make sure **Runner** target is selected

### Step 3: Update iOS Configuration

The Podfile should already be configured, but verify:

**`ios/Podfile`** should have:
```ruby
platform :ios, '12.0'
```

### Step 4: Install Pods

```bash
cd ios
pod install
cd ..
```

### Step 5: Test iOS

```bash
flutter run -d ios
```

## 🌐 Web Setup (Already Done!)

Your web configuration is already set up in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
  appId: '1:564436165702:web:e5835d1939d8122cab9647',
  messagingSenderId: '564436165702',
  projectId: 'allmahgame',
  authDomain: 'allmahgame.firebaseapp.com',
  storageBucket: 'allmahgame.firebasestorage.app',
  measurementId: 'G-STJQ93CRJL',
);
```

To run on web:
```bash
flutter run -d chrome
```

## 🔧 Alternative: Use FlutterFire CLI (Recommended)

The easiest way to configure all platforms:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure all platforms automatically
flutterfire configure
```

This will:
- Create/update `google-services.json` for Android
- Create/update `GoogleService-Info.plist` for iOS
- Update `lib/firebase_options.dart` with all platform configs

## 📋 Verification Checklist

### Android
- ✅ `google-services.json` in `android/app/`
- ✅ Google services plugin in `android/build.gradle`
- ✅ Plugin applied in `android/app/build.gradle`
- ✅ Test: `flutter run -d android`

### iOS
- ✅ `GoogleService-Info.plist` in Xcode Runner folder
- ✅ Pods installed: `cd ios && pod install`
- ✅ Bundle ID matches Firebase console
- ✅ Test: `flutter run -d ios`

### Web
- ✅ Configuration in `lib/firebase_options.dart` (Already done!)
- ✅ Test: `flutter run -d chrome`

## 🐛 Troubleshooting

### Android: "google-services.json not found"
- Make sure the file is in `android/app/` (not `android/`)
- File name must be exactly `google-services.json`

### iOS: "GoogleService-Info.plist not found"
- Make sure you added it through Xcode (not just copied to folder)
- Check that "Copy items if needed" was selected
- Verify in Xcode that the file appears under Runner folder

### iOS: Pod install fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install
cd ..
```

### FlutterFire CLI not found
```bash
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

## 🎯 Platform-Specific App IDs

After registering your apps in Firebase, update `firebase_options.dart`:

```dart
// Android
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
  appId: '1:564436165702:android:YOUR_ANDROID_APP_ID', // Update this
  messagingSenderId: '564436165702',
  projectId: 'allmahgame',
  storageBucket: 'allmahgame.firebasestorage.app',
);

// iOS
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyDCxMT_ouWkmcSNw015ANi-MwvsDryHqlE',
  appId: '1:564436165702:ios:YOUR_IOS_APP_ID', // Update this
  messagingSenderId: '564436165702',
  projectId: 'allmahgame',
  storageBucket: 'allmahgame.firebasestorage.app',
  iosBundleId: 'com.example.triviaGame',
);
```

## 📞 Need Help?

Check Firebase documentation:
- [Add Firebase to Android](https://firebase.google.com/docs/android/setup)
- [Add Firebase to iOS](https://firebase.google.com/docs/ios/setup)
- [FlutterFire Setup](https://firebase.flutter.dev/docs/overview)

Your app is ready to run on web immediately. For mobile, follow the steps above!
