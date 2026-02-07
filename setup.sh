#!/bin/bash

echo "🚀 Setting up Trivia Game Flutter App..."
echo ""

echo "1️⃣ Installing dependencies..."
flutter pub get

echo ""
echo "2️⃣ Generating auto_route code..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 To run the app:"
echo "   flutter run"
echo ""
echo "⚠️  Important: Before running the app:"
echo "   1. Download Tajawal fonts from Google Fonts"
echo "   2. Place fonts in assets/fonts/ directory"
echo "   3. Add sample data to Firestore"
echo "   4. Enable Email/Password authentication in Firebase Console"
echo ""
echo "📚 Check QUICK_START.md for detailed instructions"
