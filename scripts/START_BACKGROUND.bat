@echo off
echo ========================================
echo Email Extraction - Background Mode
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0RUN_BACKGROUND.ps1"
