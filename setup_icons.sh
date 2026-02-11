#!/bin/bash

echo "🎨 Setting up Lammh app icons..."
echo ""

# Check if icon exists
if [ ! -f "assets/icon/app_icon.png" ]; then
    echo "❌ Error: Icon file not found!"
    echo ""
    echo "📥 Please place your 1024x1024 icon at:"
    echo "   assets/icon/app_icon.png"
    echo ""
    echo "You can get it from your appicon.co download."
    echo "Look for the 1024x1024 PNG file (iTunesArtwork@2x.png)"
    exit 1
fi

echo "✓ Icon file found!"
echo ""

echo "📦 Installing dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi

echo ""
echo "🖼️  Generating all icon sizes for iOS and Android..."
flutter pub run flutter_launcher_icons
if [ $? -ne 0 ]; then
    echo "❌ Failed to generate icons"
    exit 1
fi

echo ""
echo "🧹 Cleaning build cache..."
flutter clean

echo ""
echo "📦 Refreshing dependencies..."
flutter pub get

echo ""
echo "✅ Icons generated successfully!"
echo ""
echo "📱 Next steps:"
echo "   1. Update display names in Info.plist (iOS) and AndroidManifest.xml (Android)"
echo "   2. Run 'flutter run' to test on your device"
echo ""
echo "🎉 Your app icon is ready!"
