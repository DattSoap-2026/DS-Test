# Firebase Warehouse Backend Deployment Script
# Deploys Firestore rules and indexes for warehouse management system

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DattSoap Warehouse Backend Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseVersion = firebase --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Firebase CLI not found!" -ForegroundColor Red
    Write-Host "Install it with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Firebase CLI found: $firebaseVersion" -ForegroundColor Green
Write-Host ""

# Check if logged in
Write-Host "Checking Firebase authentication..." -ForegroundColor Yellow
$loginCheck = firebase projects:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not logged in to Firebase!" -ForegroundColor Red
    Write-Host "Run: firebase login" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Authenticated" -ForegroundColor Green
Write-Host ""

# Confirm deployment
Write-Host "This will deploy:" -ForegroundColor Yellow
Write-Host "  1. Firestore Security Rules (warehouses, warehouse_transfers)" -ForegroundColor White
Write-Host "  2. Firestore Indexes (4 new composite indexes)" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}
Write-Host ""

# Deploy Firestore Rules
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploying Firestore Rules" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

firebase deploy --only firestore:rules
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to deploy Firestore rules!" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "✓ Firestore rules deployed successfully" -ForegroundColor Green
Write-Host ""

# Deploy Firestore Indexes
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deploying Firestore Indexes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

firebase deploy --only firestore:indexes
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to deploy Firestore indexes!" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "✓ Firestore indexes deployed successfully" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Go to Firebase Console → Firestore Database" -ForegroundColor White
Write-Host "  2. Check 'Rules' tab to verify warehouse rules" -ForegroundColor White
Write-Host "  3. Check 'Indexes' tab - 4 new indexes will be building" -ForegroundColor White
Write-Host "  4. Wait for indexes to finish building (may take a few minutes)" -ForegroundColor White
Write-Host "  5. Test warehouse transfer functionality in the app" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: WAREHOUSE_BACKEND_CONFIG.md" -ForegroundColor Cyan
Write-Host ""
