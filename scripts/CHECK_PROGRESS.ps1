# Check Progress of OCR Extraction and Analysis

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$OCRPath = Join-Path $BasePath "ocr_extracted"
$ReanalysisPath = Join-Path $BasePath "reanalysis"

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "PROGRESS CHECK" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Check if installation is complete
Write-Host "`nChecking software installation..." -ForegroundColor Yellow

$tesseractInstalled = $false
$imageMagickInstalled = $false

try {
    $null = & tesseract --version 2>&1
    $tesseractInstalled = $true
    Write-Host "  Tesseract OCR: INSTALLED" -ForegroundColor Green
} catch {
    Write-Host "  Tesseract OCR: NOT INSTALLED" -ForegroundColor Red
}

try {
    $null = & magick --version 2>&1
    $imageMagickInstalled = $true
    Write-Host "  ImageMagick: INSTALLED" -ForegroundColor Green
} catch {
    Write-Host "  ImageMagick: NOT INSTALLED" -ForegroundColor Red
}

# Check OCR extraction progress
Write-Host "`nChecking OCR extraction..." -ForegroundColor Yellow

if (Test-Path $OCRPath) {
    $ocrFiles = Get-ChildItem -Path $OCRPath -Filter "*.md" | Where-Object { $_.Name -ne "INDEX.md" }
    $totalPDFs = 388
    $extracted = $ocrFiles.Count
    $percentage = [math]::Round(($extracted / $totalPDFs) * 100, 1)
    
    Write-Host "  OCR Extracted: $extracted / $totalPDFs ($percentage%)" -ForegroundColor Cyan
    
    if ($extracted -eq $totalPDFs) {
        Write-Host "  Status: COMPLETE" -ForegroundColor Green
    } elseif ($extracted -gt 0) {
        Write-Host "  Status: IN PROGRESS" -ForegroundColor Yellow
        $remaining = $totalPDFs - $extracted
        Write-Host "  Remaining: $remaining files" -ForegroundColor White
    } else {
        Write-Host "  Status: NOT STARTED" -ForegroundColor Red
    }
} else {
    Write-Host "  OCR folder not found - extraction not started" -ForegroundColor Red
}

# Check reanalysis
Write-Host "`nChecking reanalysis..." -ForegroundColor Yellow

if (Test-Path $ReanalysisPath) {
    $analysisFile = Join-Path $ReanalysisPath "COMPLETE_ANALYSIS.md"
    if (Test-Path $analysisFile) {
        $fileInfo = Get-Item $analysisFile
        Write-Host "  Reanalysis: COMPLETE" -ForegroundColor Green
        Write-Host "  Generated: $($fileInfo.LastWriteTime)" -ForegroundColor White
        Write-Host "  File size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor White
    } else {
        Write-Host "  Reanalysis: NOT COMPLETE" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Reanalysis folder not found - not started" -ForegroundColor Red
}

# Overall status
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "OVERALL STATUS" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

if ($tesseractInstalled -and $imageMagickInstalled) {
    Write-Host "Software: READY" -ForegroundColor Green
} else {
    Write-Host "Software: INCOMPLETE - Run INSTALL_AND_RUN.ps1 as Administrator" -ForegroundColor Red
}

if (Test-Path $OCRPath) {
    $ocrFiles = Get-ChildItem -Path $OCRPath -Filter "*.md" | Where-Object { $_.Name -ne "INDEX.md" }
    if ($ocrFiles.Count -eq 388) {
        Write-Host "OCR Extraction: COMPLETE" -ForegroundColor Green
    } elseif ($ocrFiles.Count -gt 0) {
        Write-Host "OCR Extraction: IN PROGRESS ($($ocrFiles.Count)/388)" -ForegroundColor Yellow
    } else {
        Write-Host "OCR Extraction: NOT STARTED" -ForegroundColor Red
    }
} else {
    Write-Host "OCR Extraction: NOT STARTED" -ForegroundColor Red
}

if (Test-Path (Join-Path $ReanalysisPath "COMPLETE_ANALYSIS.md")) {
    Write-Host "Reanalysis: COMPLETE" -ForegroundColor Green
    Write-Host "`nResults available in: $ReanalysisPath" -ForegroundColor Cyan
} else {
    Write-Host "Reanalysis: NOT COMPLETE" -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "Run this script again to check progress" -ForegroundColor White
Write-Host ("=" * 70) -ForegroundColor Cyan
