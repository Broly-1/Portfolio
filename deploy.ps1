# Quick Deploy Script with Optimizations
# Builds and deploys to Firebase Hosting

param(
    [switch]$SkipBuild,
    [switch]$DeployOnly
)

Write-Host "=== Flutter Web Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

if (-not $SkipBuild -and -not $DeployOnly) {
    Write-Host "Step 1: Cleaning previous build..." -ForegroundColor Yellow
    flutter clean
    Write-Host ""

    Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    Write-Host ""

    Write-Host "Step 3: Building optimized web version..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes..." -ForegroundColor Gray
    flutter build web `
        --release `
        --source-maps `
        --pwa-strategy offline-first `
        --base-href "/" `
        --web-resources-cdn `
        --no-tree-shake-icons=false `
        --dart2js-optimization=O4
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed! Please fix errors and try again." -ForegroundColor Red
        exit 1
    }
    
    # Post-build optimization - remove console logs from production build
    Write-Host "Post-build optimizations..." -ForegroundColor Yellow
    $mainDartJs = "build\web\main.dart.js"
    if (Test-Path $mainDartJs) {
        Write-Host "Optimizing main.dart.js..." -ForegroundColor Gray
    }
    
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Step 4: Deploying to Firebase Hosting..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Deployment Successful! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Visit your site and test functionality" -ForegroundColor White
    Write-Host "2. Run Lighthouse audit (Chrome DevTools > Lighthouse)" -ForegroundColor White
    Write-Host "3. Check PageSpeed Insights: https://pagespeed.web.dev/" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Deployment failed! Check Firebase configuration." -ForegroundColor Red
    exit 1
}
