#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

if ! command -v dart &> /dev/null
then
    echo "Dart could not be found, please install it!"
    exit
fi

if ! command -v flutter &> /dev/null
then
    echo "Flutter could not be found, please install it!"
    exit
fi

echo "Creating native splash..."
dart run flutter_native_splash:create

echo "Generating launcher icons..."
flutter pub run flutter_launcher_icons

echo "Running ARB generator..."
dart run arb_generator

echo "Generating localized messages..."
flutter gen-l10n

echo "Build completed successfully!"
