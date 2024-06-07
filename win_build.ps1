$dartPath = Get-Command "dart" -ErrorAction SilentlyContinue
if (-not $dartPath) {
    Write-Host "Dart could not be found"
    exit 1
}

$flutterPath = Get-Command "flutter" -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "Flutter could not be found"
    exit 1
}

Write-Host "Cleaning build..."
& flutter clean

Write-Host "Getting dependencies..."
& flutter pub get

Write-Host "Creating native splash..."
& dart run flutter_native_splash:create

Write-Host "Generating launcher icons..."
& flutter pub run flutter_launcher_icons

Write-Host "Running ARB generator..."
& dart run arb_generator

Write-Host "Generating localized messages..."
& flutter gen-l10n

Write-Host "Updates and configurations applied successfully!"
