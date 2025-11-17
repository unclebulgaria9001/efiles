# Setup Verification Script
# Checks if all requirements are met before running the extraction

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Email Extraction - Setup Verification" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: Python
Write-Host "[1/4] Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python (\d+)\.(\d+)") {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        if ($major -ge 3 -and $minor -ge 8) {
            Write-Host "  ✓ Python $major.$minor found" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Python version too old: $pythonVersion" -ForegroundColor Red
            Write-Host "    Need Python 3.8 or later" -ForegroundColor Red
            $allGood = $false
        }
    }
} catch {
    Write-Host "  ✗ Python not found" -ForegroundColor Red
    Write-Host "    Install from: https://www.python.org/downloads/" -ForegroundColor Red
    Write-Host "    Make sure to check 'Add Python to PATH'" -ForegroundColor Red
    $allGood = $false
}

# Check 2: pip
Write-Host ""
Write-Host "[2/4] Checking pip..." -ForegroundColor Yellow
try {
    $null = python -m pip --version 2>&1
    Write-Host "  ✓ pip found" -ForegroundColor Green
} catch {
    Write-Host "  ✗ pip not found" -ForegroundColor Red
    Write-Host "    Run: python -m ensurepip --upgrade" -ForegroundColor Red
    $allGood = $false
}

# Check 3: Tesseract (optional)
Write-Host ""
Write-Host "[3/4] Checking Tesseract OCR (optional)..." -ForegroundColor Yellow
try {
    $null = tesseract --version 2>&1
    Write-Host "  ✓ Tesseract found" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Tesseract not found (optional)" -ForegroundColor Yellow
    Write-Host "    OCR will not work for image-based PDFs" -ForegroundColor Yellow
    Write-Host "    Most PDFs should work fine without it" -ForegroundColor Yellow
    Write-Host "    Install from: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
}

# Check 4: PDF files
Write-Host ""
Write-Host "[4/4] Checking PDF files..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$extractedDir = Join-Path $scriptDir "extracted"
if (Test-Path $extractedDir) {
    $pdfCount = (Get-ChildItem -Path $extractedDir -Filter "*.pdf" -Recurse).Count
    Write-Host "  ✓ Found $pdfCount PDF files in extracted directory" -ForegroundColor Green
} else {
    Write-Host "  ✗ Extracted directory not found" -ForegroundColor Red
    Write-Host "    Expected: $extractedDir" -ForegroundColor Red
    $allGood = $false
}

# Summary
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
if ($allGood) {
    Write-Host "Setup Verification: PASSED" -ForegroundColor Green
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You're ready to run the extraction!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  1. Double-click START_EXTRACTION.bat" -ForegroundColor White
    Write-Host "  2. Or run: .\RUN_EMAIL_EXTRACTION.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Setup Verification: FAILED" -ForegroundColor Red
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please fix the issues above before running the extraction" -ForegroundColor Red
    Write-Host ""
    Write-Host "See SETUP_GUIDE.md for detailed instructions" -ForegroundColor Yellow
    Write-Host ""
}

# Check if dependencies are installed
Write-Host "Checking Python dependencies..." -ForegroundColor Yellow
$requiredPackages = @("pdfplumber", "PyPDF2", "pytesseract", "Pillow", "pandas", "openpyxl")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    try {
        $null = python -c "import $($package.ToLower().Replace('-', '_'))" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $package installed" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $package not installed" -ForegroundColor Red
            $missingPackages += $package
        }
    } catch {
        Write-Host "  ✗ $package not installed" -ForegroundColor Red
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing packages detected!" -ForegroundColor Yellow
    Write-Host "Run this command to install them:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  python -m pip install -r requirements_email_extraction.txt" -ForegroundColor Cyan
    Write-Host ""
    $install = Read-Host "Install missing packages now? (y/n)"
    if ($install -eq 'y') {
        Write-Host ""
        Write-Host "Installing packages..." -ForegroundColor Yellow
        python -m pip install --upgrade pip
        python -m pip install -r requirements_email_extraction.txt
        Write-Host ""
        Write-Host "Installation complete!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
