@echo off
echo ========================================
echo Epstein Email Extraction
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0RUN_EMAIL_EXTRACTION.ps1"
pause
