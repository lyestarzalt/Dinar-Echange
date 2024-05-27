@echo off
setlocal

REM Check for Dart
where dart >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Dart could not be found, please install it!
    exit /b 1
)

REM Check for Flutter
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Flutter could not be found, please install it!
    exit /b 1
)

echo Cleaning build...
flutter clean


echo Getting dependencies...
flutter pub get

echo Creating native splash...
dart run flutter_native_splash:create

echo Generating launcher icons...
flutter pub run flutter_launcher_icons

echo Running ARB generator...
dart run arb_generator

echo Generating localized messages...
flutter gen-l10n



echo Build completed successfully!
