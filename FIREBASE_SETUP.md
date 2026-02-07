# Firebase Setup Guide for Trivia Game

## Quick Start

This guide will help you configure Firebase for your Trivia Game Flutter app.

## Step-by-Step Instructions

### 1. Create Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add Project"**
3. Enter project name: `trivia-game` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click **"Create Project"**

### 2. Add Android App

1. In Firebase Console, click the **Android icon**
2. Android package name: `com.example.trivia_game` (or your package)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 3. Add iOS App (Optional)

1. Click the **iOS icon**
2. iOS bundle ID: `com.example.triviaGame`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Click **Email/Password**
3. Toggle **Enable**
4. Click **Save**

### 5. Create Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode**
4. Select location (choose closest to your users)
5. Click **Enable**

### 6. Configure Firestore Rules

Click on the **Rules** tab and paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // User Profiles - users can only access their own profile
    match /user_profiles/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false;
    }

    // Games - users can only access their own games
    match /games/{gameId} {
      allow read: if isSignedIn() &&
                    resource.data.user_id == request.auth.uid;
      allow create: if isSignedIn() &&
                      request.resource.data.user_id == request.auth.uid;
      allow update: if isSignedIn() &&
                      resource.data.user_id == request.auth.uid;
      allow delete: if isSignedIn() &&
                      resource.data.user_id == request.auth.uid;
    }

    // Main Categories - public read only
    match /main_categories/{categoryId} {
      allow read: if true;
      allow write: if false;
    }

    // Sub Categories - public read only
    match /sub_categories/{subCategoryId} {
      allow read: if true;
      allow write: if false;
    }

    // Questions - public read only
    match /questions/{questionId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

Click **Publish** to save the rules.

### 7. Use FlutterFire CLI (Recommended)

The easiest way to configure Firebase:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure it's in your PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Configure Firebase for your Flutter app
flutterfire configure
```

Follow the prompts:
- Select your Firebase project
- Select platforms (Android, iOS, Web, etc.)
- This will automatically create/update `lib/firebase_options.dart`

### 8. Manual Configuration (Alternative)

If you can't use FlutterFire CLI, you need to manually update `lib/firebase_options.dart`:

1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps" section
3. For each platform, copy the configuration values

**For Web:**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIza...', // Copy from Firebase Console
  appId: '1:123...',
  messagingSenderId: '123...',
  projectId: 'your-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

**For Android:**
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIza...',
  appId: '1:123...',
  messagingSenderId: '123...',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 9. Add Sample Data to Firestore

You need to add categories, subcategories, and questions. Here's how:

#### Using Firebase Console:

1. Go to **Firestore Database** → **Data** tab
2. Click **Start collection**
3. Collection ID: `main_categories`
4. Add documents with this structure:

**main_categories** (8 documents):

| Field | Type | Value Example |
|-------|------|---------------|
| name | string | "History" |
| name_ar | string | "التاريخ" |
| is_active | boolean | true |
| order_num | number | 1 |

Create documents for:
- History (التاريخ)
- Science (العلوم)
- Geography (الجغرافيا)
- Sports (الرياضة)
- Islamic Studies (الدراسات الإسلامية)
- Literature (الأدب)
- Technology (التكنولوجيا)
- Arts (الفنون)

5. Create `sub_categories` collection (24 documents - 3 per category):

| Field | Type | Value Example |
|-------|------|---------------|
| main_category_id | string | (ID from main_categories) |
| name | string | "Ancient History" |
| name_ar | string | "التاريخ القديم" |
| icon | string | "history" |
| is_active | boolean | true |
| order_num | number | 1 |

6. Create `questions` collection (144 documents - 6 per subcategory):

| Field | Type | Value Example |
|-------|------|---------------|
| sub_category_id | string | (ID from sub_categories) |
| question_text | string | "Who built the pyramids?" |
| question_text_ar | string | "من بنى الأهرامات؟" |
| answer | string | "Ancient Egyptians" |
| answer_ar | string | "المصريون القدماء" |
| points | number | 200 (or 400, 600) |
| is_active | boolean | true |
| order_num | number | 1 |
| media_url | string | null |
| media_type | string | null |

### 10. Test Your Setup

1. Run the app:
```bash
flutter run
```

2. Try to register a new user
3. Check Firestore Console to see if user_profile was created
4. Check Authentication tab to see if user appears

## Common Issues

### "DefaultFirebaseOptions have not been configured"
- Run `flutterfire configure` again
- Make sure `firebase_options.dart` exists in `lib/` folder

### "google-services.json not found"
- Download from Firebase Console → Project Settings → Android app
- Place in `android/app/` directory
- Make sure filename is exactly `google-services.json`

### Authentication not working
- Check Firebase Console → Authentication → Sign-in method
- Make sure Email/Password is enabled
- Check Firestore rules allow user creation

### Can't read categories/questions
- Make sure you've added sample data to Firestore
- Check collection names match exactly: `main_categories`, `sub_categories`, `questions`
- Verify Firestore rules allow read access

## Next Steps

After Firebase is configured:

1. ✅ Test authentication (register/login)
2. ✅ Add sample data to Firestore
3. ✅ Test loading categories
4. ✅ Test creating a game
5. ✅ Implement remaining screens

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
