# Complete Content Extraction - All PDFs, Images, Timeline
# Extracts everything from all 388 PDFs

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "COMPLETE CONTENT EXTRACTION" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Check Python
Write-Host "`nChecking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = & python --version 2>&1
    Write-Host "  Python found: $pythonVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ERROR: Python not found!" -ForegroundColor Red
    Write-Host "  Please install Python 3.8+ from python.org" -ForegroundColor Yellow
    exit 1
}

# Check/Install requirements
Write-Host "`nChecking Python packages..." -ForegroundColor Yellow
$requirements = @(
    "pdfplumber",
    "PyPDF2",
    "Pillow"
)

foreach ($package in $requirements) {
    Write-Host "  Checking $package..." -ForegroundColor Gray
    $installed = & python -c "import $($package.ToLower().Replace('-', '_'))" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    Installing $package..." -ForegroundColor Yellow
        & python -m pip install $package --quiet
    }
    else {
        Write-Host "    $package installed" -ForegroundColor Green
    }
}

# Run extraction
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "STARTING EXTRACTION" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$scriptPath = Join-Path $BasePath "scripts\extract_all_content.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Script not found at $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "`nProcessing 388 PDFs..." -ForegroundColor Yellow
Write-Host "This will take 30-60 minutes depending on your system`n" -ForegroundColor Cyan

& python $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n" + ("=" * 80) -ForegroundColor Green
    Write-Host "EXTRACTION COMPLETE!" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor Green
    
    $outputPath = Join-Path $BasePath "complete_extraction"
    Write-Host "`nResults saved to: $outputPath" -ForegroundColor Cyan
    Write-Host "`nGenerated files:" -ForegroundColor Yellow
    Write-Host "  - MASTER_INDEX.md (index of all documents)" -ForegroundColor White
    Write-Host "  - all_documents/ (388 text files + metadata)" -ForegroundColor White
    Write-Host "  - extracted_images/ (all images from PDFs)" -ForegroundColor White
    Write-Host "  - timeline_data/COMPLETE_TIMELINE.md (chronological timeline)" -ForegroundColor White
    
    Write-Host "`nPress any key to open results folder..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Start-Process explorer.exe -ArgumentList $outputPath
}
else {
    Write-Host "`nERROR: Extraction failed!" -ForegroundColor Red
    exit 1
}
