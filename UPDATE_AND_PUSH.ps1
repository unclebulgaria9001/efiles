# Update All Analysis and Push to Git

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "UPDATE ALL ANALYSIS AND PUSH TO GIT" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Step 1: Wait for extraction to complete if still running
Write-Host "`nStep 1: Checking extraction status..." -ForegroundColor Yellow

$extractionPath = Join-Path $BasePath "complete_extraction"
$masterIndex = Join-Path $extractionPath "MASTER_INDEX.md"

if (-not (Test-Path $masterIndex)) {
    Write-Host "  Waiting for extraction to complete..." -ForegroundColor Yellow
    Write-Host "  This may take a while if extraction is still running..." -ForegroundColor Cyan
    
    $timeout = 3600  # 1 hour timeout
    $elapsed = 0
    $interval = 30  # Check every 30 seconds
    
    while (-not (Test-Path $masterIndex) -and $elapsed -lt $timeout) {
        Start-Sleep -Seconds $interval
        $elapsed += $interval
        Write-Host "  Still waiting... ($elapsed seconds)" -ForegroundColor Gray
    }
    
    if (-not (Test-Path $masterIndex)) {
        Write-Host "  ERROR: Extraction did not complete in time!" -ForegroundColor Red
        Write-Host "  Please run EXTRACT_AND_PROCESS_ALL.ps1 first" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "  Extraction complete!" -ForegroundColor Green

# Step 2: Run analysis update
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 2: Updating all analysis..." -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\update_all_analysis.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Update script not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nRunning analysis update..." -ForegroundColor Yellow
& python $scriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Analysis update failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nAnalysis update complete!" -ForegroundColor Green

# Step 3: Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 3: Committing and pushing to Git..." -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

# Check git status
Write-Host "`nChecking git status..." -ForegroundColor Yellow
& git status --short

# Add all updated files
Write-Host "`nAdding files to git..." -ForegroundColor Yellow

$filesToAdd = @(
    "complete_extraction/",
    "analytics/",
    "top_300_people/",
    "extracted_emails_organized/",
    "extracted_text_files/",
    "analysis/",
    "scripts/extract_all_content.py",
    "scripts/update_all_analysis.py",
    "RUN_COMPLETE_EXTRACTION.ps1",
    "EXTRACT_AND_PROCESS_ALL.ps1",
    "UPDATE_AND_PUSH.ps1",
    "COMPLETE_EXTRACTION_GUIDE.md",
    "UPDATE_STATUS.md",
    "README.md"
)

foreach ($file in $filesToAdd) {
    $fullPath = Join-Path $BasePath $file
    if (Test-Path $fullPath) {
        Write-Host "  Adding: $file" -ForegroundColor Gray
        & git add $file
    }
}

# Check if there are changes to commit
$status = & git status --porcelain
if (-not $status) {
    Write-Host "`nNo changes to commit" -ForegroundColor Yellow
    exit 0
}

# Commit changes
Write-Host "`nCommitting changes..." -ForegroundColor Yellow
$commitMessage = "Update all analysis: person counts, dashboards, reports from complete extraction of 388 PDFs"
& git commit -m $commitMessage

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: Commit failed!" -ForegroundColor Red
    exit 1
}

Write-Host "  Committed successfully!" -ForegroundColor Green

# Push to remote
Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
& git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Pushed successfully!" -ForegroundColor Green
}
else {
    Write-Host "  WARNING: Push failed!" -ForegroundColor Yellow
    Write-Host "  You may need to push manually" -ForegroundColor Cyan
    Write-Host "  Run: git push origin main" -ForegroundColor White
}

# Summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "ALL UPDATES COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nUpdated files:" -ForegroundColor Cyan
Write-Host "  - analytics/DASHBOARD.md" -ForegroundColor White
Write-Host "  - analytics/person_counts.md" -ForegroundColor White
Write-Host "  - analytics/vip_tracking.md" -ForegroundColor White
Write-Host "  - analytics/STATISTICS.md" -ForegroundColor White
Write-Host "  - top_300_people/TOP_300_PEOPLE.md" -ForegroundColor White
Write-Host "  - top_300_people/STATISTICS.md" -ForegroundColor White
Write-Host "  - JSON data files" -ForegroundColor White

Write-Host "`nGit status:" -ForegroundColor Cyan
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Changes committed and pushed to GitHub" -ForegroundColor Green
}
else {
    Write-Host "  ✓ Changes committed locally" -ForegroundColor Yellow
    Write-Host "  ✗ Push to GitHub failed - manual push required" -ForegroundColor Yellow
}

Write-Host "`nPress any key to view dashboard..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$dashboardPath = Join-Path $BasePath "analytics\DASHBOARD.md"
if (Test-Path $dashboardPath) {
    Start-Process $dashboardPath
}
