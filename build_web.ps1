# Build script for optimized Flutter web deployment
# This script ensures proper minification and optimization

Write-Host "Building Flutter web with optimizations..." -ForegroundColor Cyan

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build with optimizations
Write-Host "Building for web with optimizations..." -ForegroundColor Yellow
flutter build web `
    --release `
    --source-maps `
    --pwa-strategy offline-first `
    --base-href "/"

Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Output directory: build/web" -ForegroundColor Green
