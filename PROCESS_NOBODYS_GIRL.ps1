# Process Nobody's Girl Memoir
# Extract timeline data and add to unified timeline

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "PROCESS NOBODY'S GIRL MEMOIR" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Check if PDF exists
$pdfPath = Join-Path $BasePath "additional_downloads\nobodys_girl_virginia_giuffre.pdf"

if (-not (Test-Path $pdfPath)) {
    Write-Host "`nERROR: PDF not found!" -ForegroundColor Red
    Write-Host "Expected location: $pdfPath" -ForegroundColor Yellow
    Write-Host "`nPlease download the book first:" -ForegroundColor Cyan
    Write-Host "  Run: .\DOWNLOAD_NOBODYS_GIRL.ps1" -ForegroundColor White
    Write-Host "  Or manually save PDF to the location above" -ForegroundColor White
    exit 1
}

Write-Host "`nFound PDF: nobodys_girl_virginia_giuffre.pdf" -ForegroundColor Green
$size = (Get-Item $pdfPath).Length / 1MB
Write-Host "Size: $([math]::Round($size, 2)) MB" -ForegroundColor White

# Run processing script
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "EXTRACTING TIMELINE DATA" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\process_nobodys_girl.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Processing script not found!" -ForegroundColor Red
    exit 1
}

Write-Host "`nProcessing memoir..." -ForegroundColor Yellow
Write-Host "  - Extracting all text" -ForegroundColor White
Write-Host "  - Finding dates and events" -ForegroundColor White
Write-Host "  - Identifying people and locations" -ForegroundColor White
Write-Host "  - Creating timeline entries" -ForegroundColor White
Write-Host ""

& python $scriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nERROR: Processing failed!" -ForegroundColor Red
    exit 1
}

# Integrate with unified timeline
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "ADDING TO UNIFIED TIMELINE" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nRe-generating unified timeline with memoir data..." -ForegroundColor Yellow

$timelineScript = Join-Path $BasePath "scripts\create_unified_timeline.py"
if (Test-Path $timelineScript) {
    & python $timelineScript
}

# Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "COMMITTING TO GIT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

Write-Host "`nAdding files to git..." -ForegroundColor Yellow
& git add nobodys_girl_timeline/
& git add unified_timeline/
& git add scripts/process_nobodys_girl.py
& git add DOWNLOAD_NOBODYS_GIRL.ps1
& git add PROCESS_NOBODYS_GIRL.ps1

$status = & git status --porcelain
if (-not $status) {
    Write-Host "  No changes to commit" -ForegroundColor Yellow
}
else {
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    
    $commitMsg = @"
Add Nobody's Girl memoir timeline analysis

- Extracted timeline data from Virginia Giuffre's memoir
- Identified dates, events, people, and locations
- Created detailed timeline entries
- Integrated with unified timeline
- First-hand victim account added to analysis
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
Write-Host "PROCESSING COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

$outputPath = Join-Path $BasePath "nobodys_girl_timeline"

Write-Host "`nCreated files:" -ForegroundColor Cyan
if (Test-Path $outputPath) {
    Get-ChildItem -Path $outputPath | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
}

Write-Host "`nLocation: $outputPath" -ForegroundColor Cyan

Write-Host "`nTimeline files:" -ForegroundColor Yellow
Write-Host "  - NOBODYS_GIRL_TIMELINE.md (memoir timeline)" -ForegroundColor White
Write-Host "  - nobodys_girl_data.json (JSON data)" -ForegroundColor White
Write-Host "  - nobodys_girl_full_text.txt (full text)" -ForegroundColor White

Write-Host "`nUnified timeline updated with memoir data!" -ForegroundColor Green
Write-Host "  See: unified_timeline/UNIFIED_TIMELINE.md" -ForegroundColor Cyan

Write-Host "`nRepository: https://github.com/unclebulgaria9001/efiles.git" -ForegroundColor Cyan

Write-Host "`nPress any key to open memoir timeline..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$timelinePath = Join-Path $outputPath "NOBODYS_GIRL_TIMELINE.md"
if (Test-Path $timelinePath) {
    Start-Process $timelinePath
}
