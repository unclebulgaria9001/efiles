@echo off
echo ====================================================================
echo SIMPLE INSTALLATION - OCR TOOLS
echo ====================================================================
echo.
echo This will install Tesseract OCR and ImageMagick using Chocolatey.
echo.
echo IMPORTANT: This window will close and reopen with admin rights.
echo            Click YES when the UAC prompt appears.
echo.
pause

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :admin
) else (
    goto :elevate
)

:elevate
echo Requesting administrator privileges...
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:admin
echo Running with administrator privileges...
echo.

:: Install Chocolatey
echo Step 1: Installing Chocolatey...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

:: Refresh environment
call refreshenv.cmd 2>nul

echo.
echo Step 2: Installing Tesseract OCR...
choco install tesseract -y

echo.
echo Step 3: Installing ImageMagick...
choco install imagemagick -y

echo.
echo ====================================================================
echo INSTALLATION COMPLETE!
echo ====================================================================
echo.
echo Software installed. You can now run the OCR extraction.
echo.
echo Next steps:
echo 1. Close this window
echo 2. Open a NEW PowerShell window (regular, not admin)
echo 3. Run: cd "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
echo 4. Run: .\ocr_extraction.ps1
echo.
pause
