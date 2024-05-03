# PowerShell equivalent of the bash script

# Exit on error
$ErrorActionPreference = "Stop"

# Check for Dart
if (-Not (Get-Command "dart" -ErrorAction SilentlyContinue)) {
  Write-Host "Dart could not be found, please install it!"
  Exit
}

# Check for Flutter
if (-Not (Get-Command "flutter" -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter could not be found, please install it!"
  Exit
}

Write-Host "Cleaning build..."
flutter clean

Write-Host "Getting dependencies..."
flutter pub get

Write-Host "Creating native splash..."
dart run flutter_native_splash:create

Write-Host "Generating launcher icons..."
flutter pub run flutter_launcher_icons

Write-Host "Running ARB generator..."
dart run arb_generator

Write-Host "Generating localized messages..."
flutter gen-l10n

Write-Host "Build completed successfully!"
