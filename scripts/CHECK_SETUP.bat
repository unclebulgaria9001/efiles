@echo off
echo ========================================
echo Setup Verification
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0CHECK_SETUP.ps1"
