# Process Additional Downloaded Documents
# Extracts text, updates analysis, and pushes to git

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump",
    [string]$AdditionalDocsPath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump\additional_downloads"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "PROCESS ADDITIONAL DOCUMENTS" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Check if additional docs exist
if (-not (Test-Path $AdditionalDocsPath)) {
    Write-Host "`nERROR: Additional documents folder not found!" -ForegroundColor Red
    Write-Host "Please run DOWNLOAD_ADDITIONAL_DOCS.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Get PDF files
$pdfFiles = Get-ChildItem -Path $AdditionalDocsPath -Filter "*.pdf"

if ($pdfFiles.Count -eq 0) {
    Write-Host "`nNo PDF files found to process" -ForegroundColor Yellow
    exit 0
}

Write-Host "`nFound $($pdfFiles.Count) PDF files to process" -ForegroundColor Green

# Copy PDFs to extracted folder
$extractedPath = Join-Path $BasePath "extracted"
Write-Host "`nCopying PDFs to extracted folder..." -ForegroundColor Yellow

foreach ($pdf in $pdfFiles) {
    $destPath = Join-Path $extractedPath $pdf.Name
    
    if (-not (Test-Path $destPath)) {
        Copy-Item -Path $pdf.FullName -Destination $destPath
        Write-Host "  Copied: $($pdf.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "  Skipped (exists): $($pdf.Name)" -ForegroundColor Gray
    }
}

# Run complete extraction
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "RUNNING COMPLETE EXTRACTION" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$extractScript = Join-Path $BasePath "scripts\extract_all_content.py"

if (Test-Path $extractScript) {
    Write-Host "`nExtracting text from all PDFs (including new ones)..." -ForegroundColor Yellow
    & python $extractScript
}
else {
    Write-Host "  WARNING: Extraction script not found, skipping..." -ForegroundColor Yellow
}

# Run analysis update
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "UPDATING ANALYSIS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$analysisScript = Join-Path $BasePath "scripts\update_all_analysis.py"

if (Test-Path $analysisScript) {
    Write-Host "`nUpdating person counts, dashboards, and reports..." -ForegroundColor Yellow
    & python $analysisScript
}
else {
    Write-Host "  WARNING: Analysis script not found, skipping..." -ForegroundColor Yellow
}

# Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "COMMITTING TO GIT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

Write-Host "`nAdding files to git..." -ForegroundColor Yellow
& git add additional_downloads/
& git add complete_extraction/
& git add analytics/
& git add top_300_people/
& git add extracted/

Write-Host "`nCommitting changes..." -ForegroundColor Yellow
$commitMsg = "Add additional Epstein documents (Little Black Book, Flight Logs) and update analysis"
& git commit -m $commitMsg

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Committed successfully!" -ForegroundColor Green
    
    Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
    & git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Pushed successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "  WARNING: Push failed - may need manual push" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  No changes to commit" -ForegroundColor Gray
}

Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "PROCESSING COMPLETE" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nAdditional documents processed and added to analysis!" -ForegroundColor Cyan
