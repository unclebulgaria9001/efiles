# Complete Installation and OCR Extraction
# This script will prompt for admin access and install everything

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "=" * 70 -ForegroundColor Red
    Write-Host "ADMINISTRATOR ACCESS REQUIRED" -ForegroundColor Red
    Write-Host "=" * 70 -ForegroundColor Red
    Write-Host "`nThis script needs to install software and requires administrator privileges." -ForegroundColor Yellow
    Write-Host "`nRestarting with administrator access..." -ForegroundColor Cyan
    Write-Host "Please click 'Yes' on the UAC prompt that appears.`n" -ForegroundColor Yellow
    
    # Restart script with admin privileges
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "=" * 70 -ForegroundColor Green
Write-Host "RUNNING WITH ADMINISTRATOR ACCESS" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Green

Write-Host "`nThis process will:" -ForegroundColor Cyan
Write-Host "  1. Install Chocolatey package manager" -ForegroundColor White
Write-Host "  2. Install Tesseract OCR" -ForegroundColor White
Write-Host "  3. Install ImageMagick" -ForegroundColor White
Write-Host "  4. Extract text from all 388 PDFs using OCR" -ForegroundColor White
Write-Host "  5. Run comprehensive reanalysis" -ForegroundColor White
Write-Host "`nEstimated time: 3-6 hours (mostly OCR extraction)" -ForegroundColor Yellow
Write-Host "`nPress any key to continue or Ctrl+C to cancel..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Step 1: Install Chocolatey
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STEP 1: Installing Chocolatey Package Manager" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

try {
    $chocoTest = Get-Command choco -ErrorAction SilentlyContinue
    if ($chocoTest) {
        Write-Host "Chocolatey already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "Chocolatey installed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error installing Chocolatey: $_" -ForegroundColor Red
    Write-Host "Please install manually from: https://chocolatey.org/install" -ForegroundColor Yellow
    exit 1
}

# Step 2: Install Tesseract OCR
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STEP 2: Installing Tesseract OCR" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

try {
    $tesseractTest = Get-Command tesseract -ErrorAction SilentlyContinue
    if ($tesseractTest) {
        Write-Host "Tesseract already installed!" -ForegroundColor Green
        & tesseract --version
    }
    else {
        Write-Host "Installing Tesseract OCR (this may take 5-10 minutes)..." -ForegroundColor Yellow
        & choco install tesseract -y
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "Tesseract installed successfully!" -ForegroundColor Green
        & tesseract --version
    }
}
catch {
    Write-Host "Error installing Tesseract: $_" -ForegroundColor Red
    Write-Host "Please install manually from: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
    exit 1
}

# Step 3: Install ImageMagick
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STEP 3: Installing ImageMagick" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

try {
    $magickTest = Get-Command magick -ErrorAction SilentlyContinue
    if ($magickTest) {
        Write-Host "ImageMagick already installed!" -ForegroundColor Green
        & magick --version
    }
    else {
        Write-Host "Installing ImageMagick (this may take 3-5 minutes)..." -ForegroundColor Yellow
        & choco install imagemagick -y
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "ImageMagick installed successfully!" -ForegroundColor Green
        & magick --version
    }
}
catch {
    Write-Host "Error installing ImageMagick: $_" -ForegroundColor Red
    Write-Host "Please install manually from: https://imagemagick.org/script/download.php" -ForegroundColor Yellow
    exit 1
}

# Step 4: Run OCR Extraction
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STEP 4: Running OCR Extraction on 388 PDFs" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nThis will take 3-6 hours. Progress will be shown." -ForegroundColor Yellow
Write-Host "You can minimize this window and do other work." -ForegroundColor Cyan
Write-Host "`nStarting in 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

$ocrScript = Join-Path $BasePath "ocr_extraction.ps1"
if (Test-Path $ocrScript) {
    try {
        & powershell.exe -ExecutionPolicy Bypass -File $ocrScript
        Write-Host "`nOCR extraction completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during OCR extraction: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Error: ocr_extraction.ps1 not found!" -ForegroundColor Red
    exit 1
}

# Step 5: Run Comprehensive Reanalysis
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STEP 5: Running Comprehensive Reanalysis" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nAnalyzing OCR-extracted text..." -ForegroundColor Yellow

$reanalysisScript = Join-Path $BasePath "comprehensive_reanalysis.ps1"
if (Test-Path $reanalysisScript) {
    try {
        & powershell.exe -ExecutionPolicy Bypass -File $reanalysisScript
        Write-Host "`nReanalysis completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during reanalysis: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "Error: comprehensive_reanalysis.ps1 not found!" -ForegroundColor Red
    exit 1
}

# Final Summary
Write-Host "`n" + ("=" * 70) -ForegroundColor Green
Write-Host "ALL PROCESSES COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green

Write-Host "`nResults are available in:" -ForegroundColor Cyan
Write-Host "  - reanalysis/COMPLETE_ANALYSIS.md (All people with details)" -ForegroundColor White
Write-Host "  - reanalysis/VIP_ANALYSIS.md (High-profile individuals)" -ForegroundColor White
Write-Host "  - reanalysis/STATISTICS.md (Summary statistics)" -ForegroundColor White
Write-Host "  - ocr_extracted/ (All OCR-extracted text files)" -ForegroundColor White

Write-Host "`nPress any key to open the results folder..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$reanalysisPath = Join-Path $BasePath "reanalysis"
if (Test-Path $reanalysisPath) {
    Start-Process explorer.exe -ArgumentList $reanalysisPath
}

Write-Host "`nDone! You can close this window." -ForegroundColor Green
