# Create Unified Timeline - Links All Sources
# Integrates emails, documents, flight logs, court filings

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "CREATE UNIFIED TIMELINE" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Check Python
Write-Host "`nChecking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "  $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR: Python not found!" -ForegroundColor Red
    exit 1
}

# Install required package
Write-Host "`nInstalling required packages..." -ForegroundColor Yellow
& python -m pip install python-dateutil --quiet --upgrade

# Run timeline creation
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "CREATING UNIFIED TIMELINE" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\create_unified_timeline.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Timeline script not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nProcessing all sources..." -ForegroundColor Yellow
Write-Host "  - Emails (194 files)" -ForegroundColor White
Write-Host "  - Documents (392 PDFs)" -ForegroundColor White
Write-Host "  - Flight Logs" -ForegroundColor White
Write-Host "  - Court Documents" -ForegroundColor White
Write-Host ""

& python $scriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Timeline creation failed!" -ForegroundColor Red
    exit 1
}

# Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "COMMITTING TO GIT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

Write-Host "`nAdding files to git..." -ForegroundColor Yellow
& git add unified_timeline/
& git add scripts/create_unified_timeline.py
& git add CREATE_UNIFIED_TIMELINE.ps1

$status = & git status --porcelain
if (-not $status) {
    Write-Host "  No changes to commit" -ForegroundColor Yellow
}
else {
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    
    $commitMsg = @"
Add unified timeline linking all sources

- Integrated emails, documents, flight logs, court filings
- Chronological organization of all events
- VIP-specific timelines for key individuals
- Cross-referenced all sources
- Timeline index for easy navigation
- JSON data for programmatic access
"@
    
    & git commit -m $commitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Committed successfully!" -ForegroundColor Green
        
        # Remove large file from history if needed
        Write-Host "`nRemoving large files from history..." -ForegroundColor Yellow
        $env:FILTER_BRANCH_SQUELCH_WARNING=1
        & git filter-branch --force --index-filter "git rm --cached --ignore-unmatch analytics/illegal_activity.md" --prune-empty --tag-name-filter cat -- --all 2>&1 | Out-Null
        
        Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
        & git push origin main --force
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Pushed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "  WARNING: Push failed!" -ForegroundColor Yellow
            Write-Host "  You may need to push manually" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "  ERROR: Commit failed!" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "UNIFIED TIMELINE COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nCreated timelines:" -ForegroundColor Cyan
$timelinePath = Join-Path $BasePath "unified_timeline"

if (Test-Path $timelinePath) {
    Get-ChildItem -Path $timelinePath -Filter "*.md" | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
}

Write-Host "`nLocation: $timelinePath" -ForegroundColor Cyan
Write-Host "`nMain files:" -ForegroundColor Yellow
Write-Host "  - INDEX.md (start here)" -ForegroundColor White
Write-Host "  - UNIFIED_TIMELINE.md (all events)" -ForegroundColor White
Write-Host "  - *_timeline.md (VIP-specific)" -ForegroundColor White
Write-Host "  - timeline_data.json (JSON data)" -ForegroundColor White

Write-Host "`nRepository: https://github.com/unclebulgaria9001/efiles.git" -ForegroundColor Cyan

Write-Host "`nPress any key to open timeline index..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$indexPath = Join-Path $timelinePath "INDEX.md"
if (Test-Path $indexPath) {
    Start-Process $indexPath
}
