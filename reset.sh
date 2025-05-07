#!/bin/bash

echo "🧹 Removing pods..."
cd macos
pod deintegrate

echo "🔄 Reinstalling pods..."
pod install

cd ..

echo "🧹 Cleaning Flutter..."
flutter clean

echo "📦 Building..."
flutter run -d macos
