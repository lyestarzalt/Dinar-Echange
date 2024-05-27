#!/bin/bash

set -e

# Ensure Dart and Flutter are available
if ! command -v dart &> /dev/null; then
    echo "Dart could not be found, please install it!"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "Flutter could not be found, please install it!"
    exit 1
fi

echo "Cleaning build..."
flutter clean

echo "Running ARB generator..."
dart run arb_generator

echo "Generating localized messages..."
flutter gen-l10n

echo "Getting dependencies..."
flutter pub get

echo "Generating build runner files..."
dart run build_runner build --delete-conflicting-outputs

echo "Getting dependencies again..."
flutter pub get

echo "Creating native splash..."
dart run flutter_native_splash:create

echo "Generating launcher icons..."
flutter pub run flutter_launcher_icons


# silly temp fix for 3.22
dart run build_runner build --delete-conflicting-outputs
flutter pub get
dart run build_runner build --delete-conflicting-outputs
# silly temp fix for 3.22
echo "Build completed successfully!"
