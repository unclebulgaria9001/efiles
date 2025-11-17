# Extract ZIP files and process all content

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "EXTRACT AND PROCESS ALL CONTENT" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Step 1: Extract ZIP files
Write-Host "`nStep 1: Extracting ZIP files..." -ForegroundColor Yellow

$zipFiles = Get-ChildItem -Path $BasePath -Filter "*.zip"
$extractedPath = Join-Path $BasePath "extracted"

if (-not (Test-Path $extractedPath)) {
    New-Item -ItemType Directory -Path $extractedPath | Out-Null
}

$totalPDFs = 0

foreach ($zipFile in $zipFiles) {
    Write-Host "`n  Extracting: $($zipFile.Name)" -ForegroundColor Cyan
    
    try {
        # Create temp extraction folder
        $tempFolder = Join-Path $BasePath "temp_extract_$($zipFile.BaseName)"
        
        # Extract ZIP
        Expand-Archive -Path $zipFile.FullName -DestinationPath $tempFolder -Force
        
        # Find all PDFs in extracted content
        $pdfs = Get-ChildItem -Path $tempFolder -Filter "*.pdf" -Recurse
        
        Write-Host "    Found $($pdfs.Count) PDFs" -ForegroundColor Green
        
        # Move PDFs to extracted folder
        foreach ($pdf in $pdfs) {
            $destPath = Join-Path $extractedPath $pdf.Name
            
            # Handle duplicates
            $counter = 1
            while (Test-Path $destPath) {
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($pdf.Name)
                $extension = [System.IO.Path]::GetExtension($pdf.Name)
                $destPath = Join-Path $extractedPath "$baseName`_$counter$extension"
                $counter++
            }
            
            Copy-Item -Path $pdf.FullName -Destination $destPath
            $totalPDFs++
        }
        
        # Clean up temp folder
        Remove-Item -Path $tempFolder -Recurse -Force
        
        Write-Host "    Extracted successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "    ERROR: $_" -ForegroundColor Red
    }
}

Write-Host "`n  Total PDFs extracted: $totalPDFs" -ForegroundColor Green

if ($totalPDFs -eq 0) {
    Write-Host "`nERROR: No PDFs found in ZIP files!" -ForegroundColor Red
    exit 1
}

# Step 2: Run complete extraction
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "Step 2: Processing all PDFs..." -ForegroundColor Yellow
Write-Host ("=" * 80) -ForegroundColor Cyan

# Check Python
Write-Host "`nChecking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "  $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR: Python not found!" -ForegroundColor Red
    Write-Host "  Please install Python from python.org" -ForegroundColor Yellow
    exit 1
}

# Install requirements
Write-Host "`nInstalling Python packages..." -ForegroundColor Yellow
$packages = @("pdfplumber", "PyPDF2", "Pillow")

foreach ($package in $packages) {
    Write-Host "  Installing $package..." -ForegroundColor Gray
    & python -m pip install $package --quiet --upgrade
}

# Run extraction script
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "EXTRACTING ALL CONTENT" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\extract_all_content.py"

Write-Host "`nProcessing $totalPDFs PDFs..." -ForegroundColor Yellow
Write-Host "This may take 30-60 minutes...`n" -ForegroundColor Cyan

& python $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n" + ("=" * 80) -ForegroundColor Green
    Write-Host "ALL PROCESSING COMPLETE!" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor Green
    
    $outputPath = Join-Path $BasePath "complete_extraction"
    
    Write-Host "`nResults:" -ForegroundColor Cyan
    Write-Host "  - PDFs extracted: $totalPDFs" -ForegroundColor White
    Write-Host "  - Location: $outputPath" -ForegroundColor White
    
    Write-Host "`nGenerated:" -ForegroundColor Yellow
    Write-Host "  - MASTER_INDEX.md" -ForegroundColor White
    Write-Host "  - all_documents/ ($totalPDFs text files)" -ForegroundColor White
    Write-Host "  - extracted_images/ (all images)" -ForegroundColor White
    Write-Host "  - timeline_data/COMPLETE_TIMELINE.md" -ForegroundColor White
    
    # Git add and commit
    Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
    Write-Host "Step 3: Committing to Git..." -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Cyan
    
    Set-Location $BasePath
    
    Write-Host "`nAdding files to git..." -ForegroundColor Yellow
    & git add complete_extraction/
    & git add scripts/extract_all_content.py
    & git add RUN_COMPLETE_EXTRACTION.ps1
    & git add EXTRACT_AND_PROCESS_ALL.ps1
    
    Write-Host "Committing..." -ForegroundColor Yellow
    & git commit -m "Complete content extraction: all PDFs, images, timeline integration"
    
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    & git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nSuccessfully pushed to GitHub!" -ForegroundColor Green
    }
    else {
        Write-Host "`nWARNING: Git push failed - may need to push manually" -ForegroundColor Yellow
    }
    
    Write-Host "`nPress any key to open results..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Start-Process explorer.exe -ArgumentList $outputPath
}
else {
    Write-Host "`nERROR: Extraction failed!" -ForegroundColor Red
    exit 1
}
