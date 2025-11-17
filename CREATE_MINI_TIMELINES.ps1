# Create Mini-Timelines for VIPs
# Individual timeline files with YYYYMMDD-to-YYYYMMDD date ranges

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "CREATE MINI-TIMELINES FOR VIPS" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`nThis will create individual timeline files for each VIP with:" -ForegroundColor Yellow
Write-Host "  - Date range in filename (YYYYMMDD_to_YYYYMMDD)" -ForegroundColor White
Write-Host "  - Complete chronological events" -ForegroundColor White
Write-Host "  - Content snippets and links" -ForegroundColor White
Write-Host "  - Summary statistics" -ForegroundColor White

# Run Python script
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "GENERATING MINI-TIMELINES" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\create_mini_timelines.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Script not found at $scriptPath" -ForegroundColor Red
    exit 1
}

& python $scriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Mini-timeline creation failed!" -ForegroundColor Red
    exit 1
}

# Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "COMMITTING TO GIT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

Write-Host "`nAdding files to git..." -ForegroundColor Yellow
& git add mini_timelines/
& git add scripts/create_mini_timelines.py
& git add CREATE_MINI_TIMELINES.ps1

$status = & git status --porcelain
if (-not $status) {
    Write-Host "  No changes to commit" -ForegroundColor Yellow
}
else {
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    
    $commitMsg = @"
Create mini-timelines for VIPs with date ranges

- Individual timeline for each VIP (10+ events)
- Filename format: name_YYYYMMDD_to_YYYYMMDD.md
- Shows complete interaction period
- Includes all events chronologically
- Content snippets and full text links
- Summary statistics per VIP
- Index with all timelines
"@
    
    & git commit -m $commitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Committed successfully!" -ForegroundColor Green
        
        Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
        & git push origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Pushed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "  WARNING: Push failed!" -ForegroundColor Yellow
        }
    }
}

# Summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "MINI-TIMELINES COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

$miniTimelinesPath = Join-Path $BasePath "mini_timelines"

Write-Host "`nLocation: $miniTimelinesPath" -ForegroundColor Cyan

if (Test-Path $miniTimelinesPath) {
    $files = Get-ChildItem -Path $miniTimelinesPath -Filter "*.md" | Where-Object { $_.Name -ne "INDEX.md" }
    
    Write-Host "`nCreated $($files.Count) mini-timelines:" -ForegroundColor Yellow
    
    # Show top 10
    $files | Select-Object -First 10 | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
    
    if ($files.Count -gt 10) {
        Write-Host "  ... and $($files.Count - 10) more" -ForegroundColor Gray
    }
}

Write-Host "`nIndex: mini_timelines/INDEX.md" -ForegroundColor Cyan
Write-Host "Repository: https://github.com/unclebulgaria9001/efiles.git" -ForegroundColor Cyan

Write-Host "`nPress any key to open index..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$indexPath = Join-Path $miniTimelinesPath "INDEX.md"
if (Test-Path $indexPath) {
    Start-Process $indexPath
}
