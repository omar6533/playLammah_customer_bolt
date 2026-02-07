# Trivia Game - Flutter Application

A team-based trivia game built with Flutter, Firebase, auto_route, and flutter_bloc.

## 🎮 Features

- **Authentication**: Email/password registration and login
- **Team-Based Gameplay**: Two teams compete by answering questions
- **Multiple Categories**: History, Science, Geography, Sports, and more
- **Bilingual Support**: Arabic and English
- **Game Management**: Create, save, resume, and replay games
- **Trials System**: Track and purchase game trials
- **Game History**: View past games and scores

## 🏗️ Tech Stack

- **Framework**: Flutter 3.0+
- **Backend**: Firebase (Firestore + Firebase Auth)
- **State Management**: flutter_bloc (BLoC pattern)
- **Routing**: auto_route
- **Architecture**: Clean architecture with separation of concerns

## 📋 Prerequisites

- Flutter SDK (3.0 or higher)
- Firebase account
- Android Studio / VS Code
- FlutterFire CLI (optional but recommended)

## 🔧 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Google Analytics (optional)

### Step 2: Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** authentication
3. Save changes

### Step 3: Create Firestore Database

1. Go to **Firestore Database** → **Create database**
2. Start in **production mode**
3. Choose a location close to your users

### Step 4: Set up Firestore Security Rules

Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /user_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Games
    match /games/{gameId} {
      allow read, write: if request.auth != null &&
        resource.data.user_id == request.auth.uid;
      allow create: if request.auth != null;
    }

    // Categories (public read)
    match /main_categories/{categoryId} {
      allow read: if true;
      allow write: if false;
    }

    match /sub_categories/{subCategoryId} {
      allow read: if true;
      allow write: if false;
    }

    match /questions/{questionId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

### Step 5: Configure Firebase for Flutter

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration
flutterfire configure
```

This will automatically generate `lib/firebase_options.dart` with your credentials.

#### Option B: Manual Configuration

1. Download configuration files from Firebase Console:
   - For Android: `google-services.json` → `android/app/`
   - For iOS: `GoogleService-Info.plist` → `ios/Runner/`

2. Update `lib/firebase_options.dart` with your project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

// Similar for iOS and macOS
```

### Step 6: Add Mock Data to Firestore

You need to populate Firestore with categories, subcategories, and questions. Use the Firebase Console to add sample data or create a script.

Example structure:

**main_categories** collection:
```json
{
  "name": "History",
  "name_ar": "التاريخ",
  "is_active": true,
  "order_num": 1
}
```

**sub_categories** collection:
```json
{
  "main_category_id": "CATEGORY_ID",
  "name": "Ancient History",
  "name_ar": "التاريخ القديم",
  "icon": "history",
  "is_active": true,
  "order_num": 1
}
```

**questions** collection:
```json
{
  "sub_category_id": "SUBCATEGORY_ID",
  "question_text": "Who built the pyramids?",
  "question_text_ar": "من بنى الأهرامات؟",
  "answer": "Ancient Egyptians",
  "answer_ar": "المصريون القدماء",
  "points": 200,
  "is_active": true,
  "order_num": 1
}
```

## 📦 Installation

1. Clone the repository
```bash
git clone <your-repo-url>
cd trivia_game
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate code (for auto_route)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── bloc/              # BLoC state management
│   ├── auth/          # Authentication BLoC
│   ├── category/      # Category management
│   ├── game/          # Game logic
│   ├── question/      # Questions management
│   └── user/          # User profile
├── models/            # Data models
├── routes/            # Auto-route configuration
├── screens/           # UI screens
├── services/          # Firebase service layer
├── theme/             # App theme and colors
├── widgets/           # Reusable widgets
├── firebase_options.dart
└── main.dart
```

## 🎨 Design System

### Colors
- Primary Red: `#EC0901`
- Secondary Red: `#FF525B`
- Light Background: `#EDEDED`
- Custom Gray: `#BDBDBD`
- Dark Blue: `#556E78`

### Typography
- Font Family: Tajawal (supports Arabic)
- Sizes: 14sp to 48sp
- Weights: 400, 500, 700, 800

### Spacing
- Base unit: 8dp
- TV spacing: 32dp, 48dp

## 🔐 Authentication Flow

1. User registers with email, mobile, name, and password
2. Firebase Auth creates user account
3. User profile stored in Firestore with 1 trial
4. User logs in with email/password
5. Session persists across app restarts

## 🎯 Game Flow

1. Select categories and subcategories
2. Set up team names
3. Answer questions (alternating turns)
4. Track scores
5. Complete or save game
6. View game history

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 TODO

- [ ] Add Firebase configuration
- [ ] Populate Firestore with sample data
- [ ] Implement complete category selection screen
- [ ] Implement game setup screen
- [ ] Implement question grid screen
- [ ] Implement question display screen
- [ ] Implement my games screen with game history
- [ ] Implement purchase games screen
- [ ] Add payment integration (optional)
- [ ] Add sound effects and animations
- [ ] Add multi-language support (full i18n)

## 🐛 Troubleshooting

### Firebase initialization error
- Make sure you've run `flutterfire configure`
- Check that `firebase_options.dart` has correct credentials
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location

### Build runner issues
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Authentication errors
- Check Firebase Console → Authentication is enabled
- Verify Firestore security rules allow user creation

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributors

Your team / company name

## 📞 Support

For issues and questions, please open an issue on GitHub.
