# 🎭 Mock Mode Guide - Test Without Firebase!

Your app now supports **MOCK MODE** - you can test the entire app flow with realistic sample data without connecting to Firebase!

## 🎯 What is Mock Mode?

Mock Mode lets you:
- ✅ Test all app screens and functionality
- ✅ See realistic Arabic/English trivia questions
- ✅ Try the complete game flow
- ✅ Verify design and user experience
- ✅ NO Firebase setup required!

Once you're happy with the design and flow, simply switch to **LIVE MODE** to connect to your Firebase project.

## 🚀 Quick Start - Mock Mode (5 Minutes)

### Step 1: Verify Mock Mode is Enabled

Open `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const bool useMockData = true;  // ✅ Make sure this is true
  // ...
}
```

### Step 2: Run the App

```bash
cd /tmp/cc-agent/63479583/project
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Step 3: Test Everything!

**Login**: Use any email/password (mock mode doesn't validate)
- Email: `test@example.com`
- Password: `password123`

**Or Register**: Create a new account with any details

**You'll see:**
- User Profile: Test User with 5 trials remaining
- Main Categories: History, Science, Geography, Sports
- Subcategories: 10 different trivia topics
- Questions: 40+ realistic trivia questions in Arabic/English
- Game History: 2 sample games (one completed, one in progress)

## 📊 Mock Data Included

### Main Categories (4)
1. **التاريخ** (History)
   - التاريخ القديم (Ancient History) - 5 questions
   - التاريخ الحديث (Modern History) - 5 questions
   - التاريخ الإسلامي (Islamic History) - 5 questions

2. **العلوم** (Science)
   - الفيزياء (Physics) - 5 questions
   - الكيمياء (Chemistry) - 5 questions
   - الأحياء (Biology)

3. **الجغرافيا** (Geography)
   - عواصم العالم (World Capitals) - 5 questions
   - الدول العربية (Arab Countries)

4. **الرياضة** (Sports)
   - كرة القدم (Football) - 5 questions
   - الألعاب الأولمبية (Olympics)

### Question Levels
Each question has points:
- 200 points (Easy)
- 400 points (Medium-Easy)
- 600 points (Medium)
- 800 points (Medium-Hard)
- 1000 points (Hard)

### Sample Users
- Email: `test@example.com`
- Name: Test User
- Mobile: +966501234567
- Trials: 5 (starts with 5 free trials in mock mode)

### Sample Games
1. **Classic Game 1**
   - Status: Completed
   - Blue Team: 3200 points
   - Red Team: 2800 points
   - Winner: Blue Team

2. **Science Challenge**
   - Status: In Progress
   - Einstein: 1800 points
   - Newton: 2400 points

## 🔄 Switching Between Mock and Live Mode

### Enable Mock Mode (Testing)

1. Open `lib/config/app_config.dart`
2. Set `useMockData = true`
3. Run the app

```dart
class AppConfig {
  static const bool useMockData = true;  // Mock Mode ✅
}
```

### Enable Live Mode (Production)

1. Open `lib/config/app_config.dart`
2. Set `useMockData = false`
3. Make sure Firebase is configured
4. Run the app

```dart
class AppConfig {
  static const bool useMockData = false;  // Live Mode with Firebase ✅
}
```

## ⚙️ How It Works

### Architecture

```
User Action
    ↓
  BLoC
    ↓
AppService (Decides Mock or Live)
    ↓
MockFirebaseService  OR  FirebaseService
```

### AppService Layer

The `AppService` class automatically routes requests to either:
- **MockFirebaseService** - In-memory data with simulated delays
- **FirebaseService** - Real Firebase Firestore and Auth

### Simulated Delays

Mock mode includes realistic 500ms delays to simulate network requests, making the testing experience authentic.

## 🧪 Testing Guide

### Test Authentication Flow

1. **Registration**
   - Enter any email (e.g., user@test.com)
   - Enter any password
   - Enter name and mobile
   - Click "Create Account"
   - ✅ You're logged in!

2. **Login**
   - Use any previously registered email
   - Or use default: test@example.com
   - ✅ Instant login!

3. **Logout**
   - Click logout button
   - ✅ Returns to login screen

### Test Category Selection

1. Navigate to "New Game"
2. See 4 main categories
3. Select a category (e.g., History)
4. See subcategories appear
5. Select subcategories (multi-select)
6. ✅ Ready to create game!

### Test Game Creation

1. After selecting categories
2. Enter game name
3. Enter team names
4. Click "Start Game"
5. ✅ Game created, trials decremented!

### Test Gameplay

1. See question grid (subcategories)
2. Click a subcategory
3. See questions by points (200-1000)
4. Click a question
5. See question and answer
6. Award points to team
7. ✅ Score updates!

### Test Game History

1. Navigate to "My Games"
2. See list of games
3. Click "Resume" on in-progress game
4. Click "Replay" on completed game
5. ✅ Game loads!

### Test Purchase Flow

1. Navigate to "Purchase Trials"
2. See packages (5, 10, 20 games)
3. Select a package
4. ✅ Trials added instantly!

## 📝 Mock Data Customization

Want to add your own mock data? Edit `lib/services/mock_data.dart`:

### Add a Category

```dart
const MainCategory(
  id: 'cat_custom',
  name: 'Custom Category',
  nameAr: 'فئة مخصصة',
  isActive: true,
  order: 5,
),
```

### Add a Subcategory

```dart
const SubCategory(
  id: 'sub_custom',
  mainCategoryId: 'cat_custom',
  name: 'Custom Subcategory',
  nameAr: 'فئة فرعية مخصصة',
  icon: '🎯',
  isActive: true,
  order: 1,
),
```

### Add a Question

```dart
const Question(
  id: 'q_custom_1',
  subCategoryId: 'sub_custom',
  questionText: 'Your question?',
  questionTextAr: 'سؤالك؟',
  answer: 'Your answer',
  answerAr: 'إجابتك',
  points: 200,
  isActive: true,
  order: 1,
),
```

## 🎨 Use Cases for Mock Mode

### 1. Design Review
Test UI/UX without backend setup. Perfect for:
- Reviewing color schemes
- Testing Arabic RTL layout
- Validating button placements
- Checking responsive design

### 2. Demo Presentations
Show the app to stakeholders without:
- Internet connection
- Firebase credentials
- Real user data

### 3. Development Testing
Rapid iteration without:
- Firebase quota limits
- Network latency
- Authentication complexity

### 4. Integration Testing
Write tests using mock data:
- Predictable data
- No external dependencies
- Fast test execution

## 🚀 Going Live - Transition to Firebase

When you're ready to go live:

### Step 1: Prepare Firebase

1. Enable Authentication (Email/Password)
2. Create Firestore Database
3. Set up security rules
4. Add initial data (optional)

See `NEXT_STEPS.md` for detailed Firebase setup.

### Step 2: Switch to Live Mode

```dart
// lib/config/app_config.dart
static const bool useMockData = false;
```

### Step 3: Test Live Mode

1. Run the app
2. Register a real user
3. Add categories to Firestore
4. Test end-to-end flow
5. ✅ You're live!

## 🐛 Troubleshooting

### Mock Mode Not Working?

**Check 1**: Verify `useMockData = true` in `app_config.dart`

**Check 2**: Restart the app after changing config

**Check 3**: Clear app data and restart

### Data Not Persisting?

**Expected Behavior**: Mock data resets on app restart. This is normal!

**Solution**: Switch to Live Mode for persistent data

### Want Different Mock Data?

Edit `lib/services/mock_data.dart` and add your own questions/categories.

## 📊 Mock Mode Features

✅ Full authentication flow
✅ Category browsing
✅ Subcategory selection
✅ Game creation
✅ Question display
✅ Score tracking
✅ Game history
✅ Trial management
✅ User profiles
✅ Realistic delays
✅ Error simulation
✅ 40+ sample questions
✅ Arabic/English support

## 💡 Pro Tips

1. **Use Mock Mode First**: Test your UI/UX before Firebase setup
2. **Customize Mock Data**: Add questions relevant to your domain
3. **Test Edge Cases**: Mock mode makes it easy to test different scenarios
4. **Demo Ready**: Show stakeholders without Firebase credentials
5. **Rapid Iteration**: Make changes and see them instantly

## 🎉 Benefits of Mock Mode

### For Developers
- ⚡ Faster development cycles
- 🧪 Easy testing
- 🔒 No Firebase quota concerns
- 📱 Offline development

### For Designers
- 🎨 Test UI/UX immediately
- 🖼️ See realistic data
- 📐 Validate layouts
- 🎭 Demo-ready anytime

### For Product Managers
- 👀 Review features early
- 🗣️ Share with stakeholders
- ✅ Validate requirements
- 🚀 Faster feedback loops

## 📚 Next Steps

1. **Test in Mock Mode**: Run the app and try everything
2. **Customize Data**: Add your own questions if needed
3. **Review Design**: Make sure UI/UX meets your needs
4. **Setup Firebase**: When ready, follow `NEXT_STEPS.md`
5. **Switch to Live**: Change `useMockData` to `false`
6. **Deploy**: Your app is ready for production!

## 🎯 Summary

You now have a **fully functional trivia game** that works in two modes:

**Mock Mode** (Currently Active):
- Test everything instantly
- No Firebase required
- 40+ sample questions
- Perfect for development

**Live Mode** (When Ready):
- Connect to your Firebase
- Real user authentication
- Persistent data
- Production-ready

**Switch anytime** by changing one line in `app_config.dart`!

Happy testing! 🚀
