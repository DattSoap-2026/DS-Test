# scripts/check_firestore_rules.ps1
Write-Host "Checking for missing Firestore rules..." -ForegroundColor Cyan

# Find all collections referenced in Dart code: .collection('name')
$codeCollections = Get-ChildItem -Path "lib" -Recurse -Include "*.dart" | 
    Select-String -Pattern "\.collection\('([^']+)'\)" | 
    ForEach-Object { $_.Matches.Groups[1].Value } | 
    Sort-Object | Get-Unique

# Find all collections in firestore.rules: match /name/
$rulesCollections = Get-Content "firestore.rules" | 
    Select-String -Pattern "match /([^/]+)/" | 
    ForEach-Object { $_.Matches.Groups[1].Value } | 
    Sort-Object | Get-Unique

Write-Host "`nCollections found in code:"
Write-Output $codeCollections

Write-Host "`nCollections found in rules:"
Write-Output $rulesCollections

Write-Host "`n========================================="
Write-Host "MISSING FROM RULES:" -ForegroundColor Yellow

# Compare the two lists and find what's in code but not in rules
$missing = Compare-Object -ReferenceObject $rulesCollections -DifferenceObject $codeCollections | 
    Where-Object { $_.SideIndicator -eq "=>" } | 
    Select-Object -ExpandProperty InputObject

if ($missing) {
    Write-Host "The following collections exist in code but have NO rules:" -ForegroundColor Red
    foreach ($item in $missing) {
        Write-Host " - $item" -ForegroundColor Red
    }
    Write-Host "`nAction: Add these collections to firestore.rules to prevent permission-denied errors.`n"
    exit 1
} else {
    Write-Host "ALL GOOD! 0 missing collections found.`n" -ForegroundColor Green
    exit 0
}
