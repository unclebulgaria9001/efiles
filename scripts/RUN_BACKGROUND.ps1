# Run Email Extraction in Background
# This script starts the extraction process in a separate background window

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Email Extraction - Background Process Launcher" -ForegroundColor Cyan
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
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if dependencies are installed
Write-Host ""
Write-Host "Checking Python dependencies..." -ForegroundColor Yellow
$requiredPackages = @("pdfplumber", "PyPDF2", "pandas", "openpyxl")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    try {
        $null = python -c "import $($package.ToLower().Replace('-', '_'))" 2>&1
        if ($LASTEXITCODE -ne 0) {
            $missingPackages += $package
        }
    } catch {
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "Missing packages detected: $($missingPackages -join ', ')" -ForegroundColor Yellow
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    python -m pip install --upgrade pip --quiet
    python -m pip install -r requirements_email_extraction.txt --quiet
    Write-Host "Dependencies installed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Starting Background Process" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "The extraction will run in a background window." -ForegroundColor White
Write-Host ""
Write-Host "What this means:" -ForegroundColor Yellow
Write-Host "  • A new PowerShell window will open and minimize" -ForegroundColor White
Write-Host "  • The process will continue running in the background" -ForegroundColor White
Write-Host "  • You can continue using your computer normally" -ForegroundColor White
Write-Host "  • Progress is logged to: email_extraction.log" -ForegroundColor White
Write-Host "  • Estimated time: 2-4 hours" -ForegroundColor White
Write-Host ""
Write-Host "To monitor progress:" -ForegroundColor Yellow
Write-Host "  • Open: email_extraction.log (updates in real-time)" -ForegroundColor White
Write-Host "  • Check: extraction_progress.json (shows files processed)" -ForegroundColor White
Write-Host "  • Look for: Background PowerShell window in taskbar" -ForegroundColor White
Write-Host ""
Write-Host "To stop the process:" -ForegroundColor Yellow
Write-Host "  • Find the background PowerShell window" -ForegroundColor White
Write-Host "  • Close it (progress is saved, you can resume later)" -ForegroundColor White
Write-Host ""

$start = Read-Host "Start background extraction now? (y/n)"
if ($start -ne 'y') {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}

# Create a script to run in background
$backgroundScript = @"
Set-Location '$scriptDir'
Write-Host '=' * 80 -ForegroundColor Green
Write-Host 'Email Extraction - Background Process' -ForegroundColor Green
Write-Host '=' * 80 -ForegroundColor Green
Write-Host ''
Write-Host 'Processing 388 PDF files...' -ForegroundColor Cyan
Write-Host 'This window will stay open until processing completes.' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Progress is being logged to: email_extraction.log' -ForegroundColor Yellow
Write-Host 'You can minimize this window and continue working.' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Started at: ' -NoNewline
Write-Host (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -ForegroundColor Cyan
Write-Host ''
Write-Host '=' * 80 -ForegroundColor Green
Write-Host ''

try {
    python extract_emails_to_excel.py
    
    Write-Host ''
    Write-Host '=' * 80 -ForegroundColor Green
    Write-Host 'EXTRACTION COMPLETE!' -ForegroundColor Green
    Write-Host '=' * 80 -ForegroundColor Green
    Write-Host ''
    Write-Host 'Completed at: ' -NoNewline
    Write-Host (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Check the directory for your Excel file:' -ForegroundColor Yellow
    Write-Host '  epstein_emails_*.xlsx' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Log file: email_extraction.log' -ForegroundColor Yellow
    Write-Host ''
    
} catch {
    Write-Host ''
    Write-Host '=' * 80 -ForegroundColor Red
    Write-Host 'ERROR: Extraction failed' -ForegroundColor Red
    Write-Host '=' * 80 -ForegroundColor Red
    Write-Host `$_.Exception.Message -ForegroundColor Red
    Write-Host ''
    Write-Host 'Check email_extraction.log for details' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Press any key to close this window...'
`$null = `$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
"@

$backgroundScriptPath = Join-Path $scriptDir "background_runner.ps1"
$backgroundScript | Out-File -FilePath $backgroundScriptPath -Encoding UTF8

# Start the background process
Write-Host ""
Write-Host "Launching background process..." -ForegroundColor Green
Write-Host ""

Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$backgroundScriptPath`"" -WindowStyle Minimized

Write-Host "=" * 80 -ForegroundColor Green
Write-Host "Background Process Started!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Green
Write-Host ""
Write-Host "The extraction is now running in the background." -ForegroundColor Green
Write-Host ""
Write-Host "Monitor progress:" -ForegroundColor Yellow
Write-Host "  • Open: email_extraction.log" -ForegroundColor White
Write-Host "  • Check: extraction_progress.json" -ForegroundColor White
Write-Host "  • Look for: Minimized PowerShell window in taskbar" -ForegroundColor White
Write-Host ""
Write-Host "Expected completion: 2-4 hours from now" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now close this window and continue working." -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
