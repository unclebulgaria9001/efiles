# Epstein Email Extraction - Installation and Execution Script
# This script will install dependencies and run the email extraction process

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Epstein Email PDF Extraction Script" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Check if Python is installed
Write-Host "Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python from https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}

# Check if Tesseract is installed (for OCR)
Write-Host ""
Write-Host "Checking Tesseract OCR installation..." -ForegroundColor Yellow
try {
    $null = tesseract --version 2>&1
    Write-Host "Found: Tesseract OCR" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Tesseract OCR is not installed" -ForegroundColor Yellow
    Write-Host "OCR functionality will be limited without Tesseract" -ForegroundColor Yellow
    Write-Host "To install Tesseract:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor Yellow
    Write-Host "  2. Install and add to PATH" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue without OCR? (y/n)"
    if ($continue -ne 'y') {
        exit 1
    }
}

# Install Python dependencies
Write-Host ""
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

try {
    python -m pip install --upgrade pip
    python -m pip install -r requirements_email_extraction.txt
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Display information
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Ready to Start Extraction" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "This process will:" -ForegroundColor White
Write-Host "  - Process 388 PDF files" -ForegroundColor White
Write-Host "  - Extract email content (subject, date, body, replies)" -ForegroundColor White
Write-Host "  - Perform OCR on image-based PDFs" -ForegroundColor White
Write-Host "  - Save results to Excel spreadsheet" -ForegroundColor White
Write-Host "  - Save progress every 10 files (resumable if interrupted)" -ForegroundColor White
Write-Host ""
Write-Host "Estimated time: 2-4 hours (depending on system)" -ForegroundColor Yellow
Write-Host ""

$start = Read-Host "Start extraction now? (y/n)"
if ($start -ne 'y') {
    Write-Host "Extraction cancelled" -ForegroundColor Yellow
    exit 0
}

# Run the extraction
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Green
Write-Host "Starting Email Extraction Process..." -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Green
Write-Host ""
Write-Host "Progress will be logged to: email_extraction.log" -ForegroundColor Cyan
Write-Host "You can monitor progress in real-time by opening the log file" -ForegroundColor Cyan
Write-Host ""

try {
    python extract_emails_to_excel.py
    
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Green
    Write-Host "Extraction Complete!" -ForegroundColor Green
    Write-Host "=" * 80 -ForegroundColor Green
    Write-Host ""
    Write-Host "Check the output Excel file in this directory" -ForegroundColor Green
    Write-Host "Log file: email_extraction.log" -ForegroundColor Cyan
    
} catch {
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Red
    Write-Host "ERROR: Extraction failed" -ForegroundColor Red
    Write-Host "=" * 80 -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Check email_extraction.log for details" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
