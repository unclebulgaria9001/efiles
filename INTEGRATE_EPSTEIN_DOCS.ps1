# Integrate Epstein-Docs.GitHub.io Archive
# Download and merge 8,175 additional documents into our timeline

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump",
    [string]$ArchivePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump\epstein-docs-archive"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "INTEGRATE EPSTEIN-DOCS.GITHUB.IO ARCHIVE" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`nThis will integrate the epstein-docs.github.io archive:" -ForegroundColor Yellow
Write-Host "  - 8,175 documents (vs our current 586)" -ForegroundColor White
Write-Host "  - 12,243 people identified" -ForegroundColor White
Write-Host "  - 5,709 organizations" -ForegroundColor White
Write-Host "  - 3,211 locations" -ForegroundColor White
Write-Host "  - 11,020 dates extracted" -ForegroundColor White
Write-Host "  - 8,186 AI-generated summaries" -ForegroundColor White

# Check if git is available
$gitAvailable = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitAvailable) {
    Write-Host "`nERROR: Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Clone repository
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "STEP 1: CLONE REPOSITORY" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

if (Test-Path $ArchivePath) {
    Write-Host "`nArchive already exists at: $ArchivePath" -ForegroundColor Yellow
    Write-Host "Do you want to update it? (Y/N)" -ForegroundColor Cyan
    $response = Read-Host
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host "`nUpdating repository..." -ForegroundColor Yellow
        Set-Location $ArchivePath
        & git pull origin main
        Set-Location $BasePath
    }
}
else {
    Write-Host "`nCloning repository..." -ForegroundColor Yellow
    Write-Host "This may take several minutes (large repository)..." -ForegroundColor Gray
    
    & git clone https://github.com/epstein-docs/epstein-docs.github.io.git $ArchivePath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nERROR: Failed to clone repository" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "  Cloned successfully!" -ForegroundColor Green
}

# Analyze repository structure
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "STEP 2: ANALYZE REPOSITORY" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nAnalyzing repository structure..." -ForegroundColor Yellow

if (Test-Path "$ArchivePath\results") {
    $jsonFiles = Get-ChildItem -Path "$ArchivePath\results" -Filter "*.json" -Recurse
    Write-Host "  Found $($jsonFiles.Count) JSON files" -ForegroundColor Green
    
    # Sample a few files
    Write-Host "`nSample files:" -ForegroundColor Cyan
    $jsonFiles | Select-Object -First 5 | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
}
else {
    Write-Host "  WARNING: No results folder found" -ForegroundColor Yellow
}

# Create integration summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "INTEGRATION SUMMARY" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nRepository Location: $ArchivePath" -ForegroundColor Cyan

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Run: python scripts\parse_epstein_docs_json.py" -ForegroundColor White
Write-Host "     (Parse all JSON files and extract timeline data)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Run: python scripts\merge_timelines.py" -ForegroundColor White
Write-Host "     (Merge with our existing timeline)" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Run: python scripts\create_unified_timeline.py" -ForegroundColor White
Write-Host "     (Generate enhanced timeline with all data)" -ForegroundColor Gray

Write-Host "`nExpected Results:" -ForegroundColor Yellow
Write-Host "  - Timeline events: 3,739 → 15,000+" -ForegroundColor White
Write-Host "  - Documents: 586 → 8,175" -ForegroundColor White
Write-Host "  - People tracked: ~100 → 12,243" -ForegroundColor White
Write-Host "  - Dates: ~3,728 → 11,020" -ForegroundColor White

Write-Host "`nDocumentation: EPSTEIN_DOCS_INTEGRATION.md" -ForegroundColor Cyan

Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
