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

echo "Getting dependencies..."
flutter pub get

echo "Running ARB generator..."
dart run arb_generator

echo "Generating localized messages..."
flutter gen-l10n

echo "Creating native splash..."
dart run flutter_native_splash:create

echo "Generating launcher icons..."
flutter pub run flutter_launcher_icons

echo "Updates and configurations applied successfully!"
