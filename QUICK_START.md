# Quick Start Guide

Get your Trivia Game app running in 15 minutes!

## ⚡ Prerequisites

- Flutter SDK 3.0+ installed
- Firebase account
- Android Studio or VS Code

## 🚀 Steps

### 1. Install Dependencies (2 min)

```bash
cd trivia_game
flutter pub get
```

### 2. Configure Firebase (5 min)

**Option A: FlutterFire CLI (Recommended)**
```bash
# Install CLI
dart pub global activate flutterfire_cli

# Configure
flutterfire configure
```

Select your Firebase project and platforms.

**Option B: Manual Setup**
- See `FIREBASE_SETUP.md` for detailed instructions

### 3. Enable Firebase Services (3 min)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Enable **Authentication** → **Email/Password**
4. Create **Firestore Database** (production mode)
5. Copy security rules from `FIREBASE_SETUP.md`

### 4. Add Fonts (2 min)

```bash
# Create directory
mkdir -p assets/fonts

# Download Tajawal fonts from Google Fonts
# https://fonts.google.com/specimen/Tajawal

# Place these files in assets/fonts/:
# - Tajawal-Regular.ttf
# - Tajawal-Medium.ttf
# - Tajawal-Bold.ttf
# - Tajawal-ExtraBold.ttf
```

### 5. Generate Code (1 min)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App (1 min)

```bash
flutter run
```

### 7. Add Sample Data (Optional - 5 min)

Add at least one category, subcategory, and question to Firestore:

**Collection: `main_categories`**
```json
{
  "name": "History",
  "name_ar": "التاريخ",
  "is_active": true,
  "order_num": 1
}
```

**Collection: `sub_categories`**
```json
{
  "main_category_id": "[CATEGORY_ID]",
  "name": "Ancient History",
  "name_ar": "التاريخ القديم",
  "icon": "history",
  "is_active": true,
  "order_num": 1
}
```

**Collection: `questions`**
```json
{
  "sub_category_id": "[SUBCATEGORY_ID]",
  "question_text": "Who built the pyramids?",
  "question_text_ar": "من بنى الأهرامات؟",
  "answer": "Ancient Egyptians",
  "answer_ar": "المصريون القدماء",
  "points": 200,
  "is_active": true,
  "order_num": 1
}
```

## ✅ Test the App

1. **Register a new user**
   - Open app
   - Click "إنشاء حساب جديد" (Create account)
   - Fill in details
   - Submit

2. **Check Firebase**
   - Go to Firebase Console → Authentication
   - You should see your new user
   - Go to Firestore → Data
   - You should see `user_profiles` collection with your data

3. **Explore the App**
   - You'll see the landing page
   - Try "لعبة جديدة" (New Game) - requires data
   - Try "ألعابي" (My Games)

## 🐛 Troubleshooting

### "firebase_options.dart not found"
```bash
flutterfire configure
```

### "Font not found"
- Make sure fonts are in `assets/fonts/`
- Run `flutter clean && flutter pub get`

### "Build runner failed"
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Can't load categories"
- Add sample data to Firestore
- Check Firestore security rules

## 📚 Next Steps

- Read `PROJECT_STATUS.md` to see what's complete
- Read `FIREBASE_SETUP.md` for detailed Firebase configuration
- Read `README.md` for full documentation
- Implement remaining screens (see `PROJECT_STATUS.md`)

## 🎯 Current Features

✅ User Registration & Login
✅ User Profile with Trials
✅ Landing Page
✅ Beautiful UI with Arabic Support
🔶 Category Selection (placeholder)
🔶 Game Play (placeholder)
🔶 Game History (placeholder)

## 📞 Need Help?

Check the documentation files:
- `README.md` - Full project documentation
- `FIREBASE_SETUP.md` - Firebase configuration
- `FONTS_README.md` - Font installation
- `PROJECT_STATUS.md` - What's done and what's not

Happy coding! 🚀
