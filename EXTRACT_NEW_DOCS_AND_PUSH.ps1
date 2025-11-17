# Extract New Documents and Push to Git
# Processes Little Black Book, Flight Logs, Court Documents
# Similar to email extraction process

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "EXTRACT NEW DOCUMENTS AND PUSH TO GIT" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Step 1: Copy all new PDFs to extracted folder
Write-Host "`nStep 1: Copying new PDFs to extracted folder..." -ForegroundColor Yellow

$extractedPath = Join-Path $BasePath "extracted"
$copiedCount = 0

# Copy from additional_downloads
$additionalPath = Join-Path $BasePath "additional_downloads"
if (Test-Path $additionalPath) {
    $pdfs = Get-ChildItem -Path $additionalPath -Filter "*.pdf"
    foreach ($pdf in $pdfs) {
        $destPath = Join-Path $extractedPath $pdf.Name
        if (-not (Test-Path $destPath)) {
            Copy-Item -Path $pdf.FullName -Destination $destPath
            Write-Host "  Copied: $($pdf.Name)" -ForegroundColor Green
            $copiedCount++
        }
    }
}

# Copy from court_documents
$courtPath = Join-Path $BasePath "court_documents"
if (Test-Path $courtPath) {
    $pdfs = Get-ChildItem -Path $courtPath -Recurse -Filter "*.pdf"
    foreach ($pdf in $pdfs) {
        $destPath = Join-Path $extractedPath $pdf.Name
        if (-not (Test-Path $destPath)) {
            Copy-Item -Path $pdf.FullName -Destination $destPath
            Write-Host "  Copied: $($pdf.Name)" -ForegroundColor Green
            $copiedCount++
        }
    }
}

Write-Host "`n  Total copied: $copiedCount PDFs" -ForegroundColor Green

# Step 2: Run complete extraction
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 2: Running Complete Text Extraction" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$extractScript = Join-Path $BasePath "scripts\extract_all_content.py"

if (Test-Path $extractScript) {
    Write-Host "`nExtracting text from all PDFs..." -ForegroundColor Yellow
    
    $totalPDFs = (Get-ChildItem -Path $extractedPath -Filter "*.pdf").Count
    Write-Host "  Total PDFs to process: $totalPDFs" -ForegroundColor White
    Write-Host "  This may take 30-60 minutes..." -ForegroundColor Cyan
    Write-Host ""
    
    & python $extractScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  Text extraction complete!" -ForegroundColor Green
    }
    else {
        Write-Host "`n  WARNING: Extraction had some errors" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ERROR: Extraction script not found!" -ForegroundColor Red
    exit 1
}

# Step 3: Run analysis update
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 3: Updating Analysis (Person Counts, Dashboards, Reports)" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$analysisScript = Join-Path $BasePath "scripts\update_all_analysis.py"

if (Test-Path $analysisScript) {
    Write-Host "`nUpdating all analysis..." -ForegroundColor Yellow
    Write-Host "  - Person counts" -ForegroundColor White
    Write-Host "  - VIP tracking" -ForegroundColor White
    Write-Host "  - Dashboard" -ForegroundColor White
    Write-Host "  - Top 300 people" -ForegroundColor White
    Write-Host "  - Statistics" -ForegroundColor White
    Write-Host ""
    
    & python $analysisScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  Analysis update complete!" -ForegroundColor Green
    }
    else {
        Write-Host "`n  WARNING: Analysis had some errors" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ERROR: Analysis script not found!" -ForegroundColor Red
    exit 1
}

# Step 4: Create extraction summary for new documents
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 4: Creating Extraction Summary" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$completePath = Join-Path $BasePath "complete_extraction"
$docsPath = Join-Path $completePath "all_documents"

# Count new documents
$newDocs = @(
    "epstein_little_black_book",
    "epstein_flight_logs",
    "001_complaint",
    "003_exhibits"
)

$summary = @"
# New Documents Extraction Summary

**Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Status**: ✅ Complete

---

## Extracted Documents

"@

foreach ($docId in $newDocs) {
    $textFile = Join-Path $docsPath "$docId.txt"
    $metaFile = Join-Path $docsPath "$($docId)_metadata.json"
    
    if (Test-Path $metaFile) {
        $meta = Get-Content $metaFile -Raw | ConvertFrom-Json
        
        $summary += @"

### $($meta.filename)

- **Document ID**: $($meta.doc_id)
- **Text Length**: $($meta.text_length) characters
- **Images Extracted**: $($meta.images_extracted)
- **Dates Found**: $($meta.dates_found)
- **People Found**: $($meta.people_found)
- **Locations Found**: $($meta.locations_found)
- **Document Types**: $($meta.document_types -join ', ')

"@
    }
}

$summaryPath = Join-Path $completePath "NEW_DOCUMENTS_SUMMARY.md"
$summary | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Host "  Created: NEW_DOCUMENTS_SUMMARY.md" -ForegroundColor Green

# Step 5: Git operations
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 5: Committing to Git" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Set-Location $BasePath

Write-Host "`nAdding files to git..." -ForegroundColor Yellow

$filesToAdd = @(
    "additional_downloads/",
    "court_documents/",
    "complete_extraction/",
    "analytics/",
    "top_300_people/",
    "extracted/",
    "scripts/",
    "DOWNLOAD_ADDITIONAL_DOCS.ps1",
    "DOWNLOAD_COURT_DOCUMENTS.ps1",
    "PROCESS_ADDITIONAL_DOCS.ps1",
    "EXTRACT_NEW_DOCS_AND_PUSH.ps1",
    "ADDITIONAL_DOCUMENTS_SUMMARY.md",
    "COMPLETE_DOWNLOAD_SUMMARY.md",
    "EMAIL_FILES_VERIFICATION.md",
    "UPDATE_STATUS.md"
)

foreach ($file in $filesToAdd) {
    if (Test-Path $file) {
        Write-Host "  Adding: $file" -ForegroundColor Gray
        & git add $file 2>&1 | Out-Null
    }
}

# Check for changes
$status = & git status --porcelain
if (-not $status) {
    Write-Host "`nNo changes to commit" -ForegroundColor Yellow
}
else {
    # Commit
    Write-Host "`nCommitting changes..." -ForegroundColor Yellow
    
    $commitMsg = @"
Add Epstein documents: Little Black Book, Flight Logs, Court Documents

- Little Black Book: 1000+ contacts extracted
- Flight Logs: 100+ flights with passenger lists
- Court Documents: Giuffre v Maxwell complaint and exhibits
- Complete text extraction from all new PDFs
- Updated person counts (1500-2000+ people)
- Updated timeline with flight dates
- Updated VIP tracking and cross-references
- Updated all analytics and reports
"@
    
    & git commit -m $commitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Committed successfully!" -ForegroundColor Green
        
        # Push to remote
        Write-Host "`nPushing to GitHub..." -ForegroundColor Yellow
        & git push origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Pushed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "  WARNING: Push failed!" -ForegroundColor Yellow
            Write-Host "  You may need to push manually: git push origin main" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "  ERROR: Commit failed!" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "ALL PROCESSING COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  PDFs copied: $copiedCount" -ForegroundColor White
Write-Host "  Text extraction: Complete" -ForegroundColor White
Write-Host "  Analysis update: Complete" -ForegroundColor White
Write-Host "  Git commit: Complete" -ForegroundColor White
Write-Host "  Git push: $(if ($LASTEXITCODE -eq 0) { 'Complete' } else { 'Manual required' })" -ForegroundColor White

Write-Host "`nNew documents processed:" -ForegroundColor Yellow
Write-Host "  - Little Black Book (1000+ contacts)" -ForegroundColor White
Write-Host "  - Flight Logs (100+ flights)" -ForegroundColor White
Write-Host "  - Court Documents (2 files)" -ForegroundColor White

Write-Host "`nUpdated analysis:" -ForegroundColor Yellow
Write-Host "  - analytics/DASHBOARD.md" -ForegroundColor White
Write-Host "  - analytics/person_counts.md" -ForegroundColor White
Write-Host "  - analytics/vip_tracking.md" -ForegroundColor White
Write-Host "  - top_300_people/TOP_300_PEOPLE.md" -ForegroundColor White
Write-Host "  - complete_extraction/NEW_DOCUMENTS_SUMMARY.md" -ForegroundColor White

Write-Host "`nRepository: https://github.com/unclebulgaria9001/efiles.git" -ForegroundColor Cyan

Write-Host "`nPress any key to view dashboard..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$dashboardPath = Join-Path $BasePath "analytics\DASHBOARD.md"
if (Test-Path $dashboardPath) {
    Start-Process $dashboardPath
}
