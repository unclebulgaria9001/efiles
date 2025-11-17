# Python Installation Helper Script

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Python Installation Helper" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

# Check if Python is already installed
Write-Host "Checking for existing Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python") {
        Write-Host "✓ Python is already installed: $pythonVersion" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now run the extraction!" -ForegroundColor Green
        Write-Host "  Double-click: START_BACKGROUND.bat" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 0
    }
} catch {
    Write-Host "✗ Python not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "Python Installation Options" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host ""

# Check if winget is available
Write-Host "Checking for Windows Package Manager (winget)..." -ForegroundColor Yellow
try {
    $wingetVersion = winget --version 2>&1
    $hasWinget = $true
    Write-Host "✓ winget is available" -ForegroundColor Green
} catch {
    $hasWinget = $false
    Write-Host "✗ winget not available" -ForegroundColor Red
}

Write-Host ""
Write-Host "Choose installation method:" -ForegroundColor Cyan
Write-Host ""

if ($hasWinget) {
    Write-Host "[1] Install via winget (Recommended - Automatic)" -ForegroundColor Green
    Write-Host "    • Fastest method" -ForegroundColor White
    Write-Host "    • Automatically adds to PATH" -ForegroundColor White
    Write-Host "    • No manual steps" -ForegroundColor White
    Write-Host ""
}

Write-Host "[2] Download from Python.org (Manual)" -ForegroundColor Yellow
Write-Host "    • Opens download page in browser" -ForegroundColor White
Write-Host "    • You run the installer" -ForegroundColor White
Write-Host "    • MUST check 'Add Python to PATH'" -ForegroundColor White
Write-Host ""

Write-Host "[3] View detailed instructions" -ForegroundColor Cyan
Write-Host ""
Write-Host "[Q] Quit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Select option"

switch ($choice) {
    "1" {
        if (-not $hasWinget) {
            Write-Host ""
            Write-Host "winget is not available on this system" -ForegroundColor Red
            Write-Host "Please choose option 2 instead" -ForegroundColor Yellow
            Write-Host ""
            Read-Host "Press Enter to exit"
            exit 1
        }
        
        Write-Host ""
        Write-Host "=" * 80 -ForegroundColor Green
        Write-Host "Installing Python via winget..." -ForegroundColor Green
        Write-Host "=" * 80 -ForegroundColor Green
        Write-Host ""
        Write-Host "This may take a few minutes..." -ForegroundColor Yellow
        Write-Host ""
        
        try {
            winget install Python.Python.3.11 --silent --accept-package-agreements --accept-source-agreements
            
            Write-Host ""
            Write-Host "=" * 80 -ForegroundColor Green
            Write-Host "Python Installation Complete!" -ForegroundColor Green
            Write-Host "=" * 80 -ForegroundColor Green
            Write-Host ""
            Write-Host "IMPORTANT: You must restart PowerShell/Command Prompt" -ForegroundColor Yellow
            Write-Host "Or restart your computer for PATH changes to take effect" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "After restart:" -ForegroundColor Cyan
            Write-Host "  1. Run CHECK_SETUP.bat to verify" -ForegroundColor White
            Write-Host "  2. Run START_BACKGROUND.bat to begin extraction" -ForegroundColor White
            Write-Host ""
            
        } catch {
            Write-Host ""
            Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "Please try option 2 (manual download)" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "=" * 80 -ForegroundColor Cyan
        Write-Host "Opening Python download page..." -ForegroundColor Cyan
        Write-Host "=" * 80 -ForegroundColor Cyan
        Write-Host ""
        Write-Host "CRITICAL STEPS:" -ForegroundColor Red
        Write-Host ""
        Write-Host "1. Download the installer" -ForegroundColor Yellow
        Write-Host "2. Run the installer" -ForegroundColor Yellow
        Write-Host "3. ✓ CHECK THE BOX: 'Add Python to PATH'" -ForegroundColor Red
        Write-Host "   (This is at the BOTTOM of the installer window)" -ForegroundColor Red
        Write-Host "4. Click 'Install Now'" -ForegroundColor Yellow
        Write-Host "5. Wait for installation to complete" -ForegroundColor Yellow
        Write-Host "6. Restart PowerShell or your computer" -ForegroundColor Yellow
        Write-Host ""
        
        Start-Process "https://www.python.org/downloads/"
        
        Write-Host "Browser opened with Python download page" -ForegroundColor Green
        Write-Host ""
        Write-Host "After installing Python:" -ForegroundColor Cyan
        Write-Host "  1. Restart PowerShell/Command Prompt" -ForegroundColor White
        Write-Host "  2. Run CHECK_SETUP.bat to verify" -ForegroundColor White
        Write-Host "  3. Run START_BACKGROUND.bat to begin extraction" -ForegroundColor White
        Write-Host ""
    }
    
    "3" {
        Write-Host ""
        Write-Host "=" * 80 -ForegroundColor Cyan
        Write-Host "Detailed Installation Instructions" -ForegroundColor Cyan
        Write-Host "=" * 80 -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Step 1: Download Python" -ForegroundColor Yellow
        Write-Host "  • Go to: https://www.python.org/downloads/" -ForegroundColor White
        Write-Host "  • Click the big yellow 'Download Python 3.x.x' button" -ForegroundColor White
        Write-Host "  • Save the installer file" -ForegroundColor White
        Write-Host ""
        Write-Host "Step 2: Run the Installer" -ForegroundColor Yellow
        Write-Host "  • Double-click the downloaded file" -ForegroundColor White
        Write-Host "  • Windows may ask for admin permission - click Yes" -ForegroundColor White
        Write-Host ""
        Write-Host "Step 3: CRITICAL - Add to PATH" -ForegroundColor Red
        Write-Host "  • At the BOTTOM of the installer window" -ForegroundColor White
        Write-Host "  • Find the checkbox: 'Add Python to PATH'" -ForegroundColor White
        Write-Host "  • ✓ CHECK THIS BOX (very important!)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Step 4: Install" -ForegroundColor Yellow
        Write-Host "  • Click 'Install Now'" -ForegroundColor White
        Write-Host "  • Wait for installation (2-5 minutes)" -ForegroundColor White
        Write-Host "  • Click 'Close' when done" -ForegroundColor White
        Write-Host ""
        Write-Host "Step 5: Restart" -ForegroundColor Yellow
        Write-Host "  • Close all PowerShell/Command Prompt windows" -ForegroundColor White
        Write-Host "  • Or restart your computer" -ForegroundColor White
        Write-Host ""
        Write-Host "Step 6: Verify" -ForegroundColor Yellow
        Write-Host "  • Run CHECK_SETUP.bat" -ForegroundColor White
        Write-Host "  • Should show Python is installed" -ForegroundColor White
        Write-Host ""
        Write-Host "Step 7: Run Extraction" -ForegroundColor Yellow
        Write-Host "  • Double-click START_BACKGROUND.bat" -ForegroundColor White
        Write-Host ""
        
        $openBrowser = Read-Host "Open Python download page now? (y/n)"
        if ($openBrowser -eq 'y') {
            Start-Process "https://www.python.org/downloads/"
            Write-Host ""
            Write-Host "Browser opened!" -ForegroundColor Green
        }
    }
    
    default {
        Write-Host ""
        Write-Host "Cancelled" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Read-Host "Press Enter to exit"
