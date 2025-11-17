# Monitor Email Extraction Progress
# Real-time monitoring of the background extraction process

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$logFile = Join-Path $scriptDir "email_extraction.log"
$progressFile = Join-Path $scriptDir "extraction_progress.json"

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Email Extraction - Progress Monitor" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

# Check if log file exists
if (-not (Test-Path $logFile)) {
    Write-Host "No extraction process detected." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The log file doesn't exist yet." -ForegroundColor Yellow
    Write-Host "This means either:" -ForegroundColor Yellow
    Write-Host "  • The extraction hasn't started yet" -ForegroundColor White
    Write-Host "  • The extraction hasn't been run" -ForegroundColor White
    Write-Host ""
    Write-Host "To start extraction:" -ForegroundColor Cyan
    Write-Host "  • Run: START_BACKGROUND.bat" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

# Display current status
Write-Host "Current Status:" -ForegroundColor Yellow
Write-Host ""

# Check progress file
if (Test-Path $progressFile) {
    try {
        $progress = Get-Content $progressFile | ConvertFrom-Json
        $processedCount = $progress.processed_files.Count
        $totalEmails = $progress.total_emails
        $lastUpdated = $progress.last_updated
        
        Write-Host "  Files Processed: " -NoNewline -ForegroundColor White
        Write-Host "$processedCount / 388" -ForegroundColor Cyan
        
        Write-Host "  Emails Extracted: " -NoNewline -ForegroundColor White
        Write-Host $totalEmails -ForegroundColor Cyan
        
        Write-Host "  Last Updated: " -NoNewline -ForegroundColor White
        Write-Host $lastUpdated -ForegroundColor Cyan
        
        # Calculate percentage
        $percentage = [math]::Round(($processedCount / 388) * 100, 1)
        Write-Host "  Progress: " -NoNewline -ForegroundColor White
        Write-Host "$percentage%" -ForegroundColor Green
        
        # Estimate time remaining (rough estimate: 30 seconds per file average)
        $remaining = 388 - $processedCount
        $estimatedMinutes = [math]::Round(($remaining * 30) / 60, 0)
        Write-Host "  Estimated Time Remaining: " -NoNewline -ForegroundColor White
        if ($estimatedMinutes -gt 60) {
            $hours = [math]::Floor($estimatedMinutes / 60)
            $mins = $estimatedMinutes % 60
            Write-Host "$hours hours $mins minutes" -ForegroundColor Yellow
        } else {
            Write-Host "$estimatedMinutes minutes" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "  Could not read progress file" -ForegroundColor Red
    }
} else {
    Write-Host "  Progress file not found (extraction may be starting)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Recent Log Entries (last 20 lines):" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

# Show last 20 lines of log
Get-Content $logFile -Tail 20 | ForEach-Object {
    if ($_ -match "ERROR") {
        Write-Host $_ -ForegroundColor Red
    } elseif ($_ -match "WARNING") {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($_ -match "Processing") {
        Write-Host $_ -ForegroundColor Cyan
    } elseif ($_ -match "Complete|Success") {
        Write-Host $_ -ForegroundColor Green
    } else {
        Write-Host $_ -ForegroundColor White
    }
}

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Options:" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "[1] Watch log in real-time (live updates)" -ForegroundColor White
Write-Host "[2] Refresh status" -ForegroundColor White
Write-Host "[3] Open log file in notepad" -ForegroundColor White
Write-Host "[4] Open progress file" -ForegroundColor White
Write-Host "[5] Check for output Excel file" -ForegroundColor White
Write-Host "[Q] Quit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Select option"

switch ($choice.ToUpper()) {
    "1" {
        Write-Host ""
        Write-Host "Starting live log viewer..." -ForegroundColor Green
        Write-Host "Press Ctrl+C to stop watching" -ForegroundColor Yellow
        Write-Host ""
        Get-Content $logFile -Wait -Tail 50
    }
    "2" {
        Write-Host ""
        Write-Host "Refreshing..." -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        & $MyInvocation.MyCommand.Path
    }
    "3" {
        Write-Host ""
        Write-Host "Opening log file..." -ForegroundColor Cyan
        notepad $logFile
    }
    "4" {
        if (Test-Path $progressFile) {
            Write-Host ""
            Write-Host "Opening progress file..." -ForegroundColor Cyan
            notepad $progressFile
        } else {
            Write-Host ""
            Write-Host "Progress file not found" -ForegroundColor Red
        }
    }
    "5" {
        Write-Host ""
        Write-Host "Looking for Excel output files..." -ForegroundColor Cyan
        $excelFiles = Get-ChildItem -Path $scriptDir -Filter "epstein_emails_*.xlsx"
        if ($excelFiles.Count -gt 0) {
            Write-Host ""
            Write-Host "Found $($excelFiles.Count) Excel file(s):" -ForegroundColor Green
            foreach ($file in $excelFiles) {
                Write-Host "  • $($file.Name)" -ForegroundColor Cyan
                Write-Host "    Size: $([math]::Round($file.Length / 1MB, 2)) MB" -ForegroundColor White
                Write-Host "    Created: $($file.CreationTime)" -ForegroundColor White
            }
            Write-Host ""
            $open = Read-Host "Open the most recent file? (y/n)"
            if ($open -eq 'y') {
                $latest = $excelFiles | Sort-Object CreationTime -Descending | Select-Object -First 1
                Start-Process $latest.FullName
            }
        } else {
            Write-Host ""
            Write-Host "No Excel output files found yet" -ForegroundColor Yellow
            Write-Host "The file will be created when extraction completes" -ForegroundColor Yellow
        }
        Write-Host ""
        Read-Host "Press Enter to continue"
    }
    default {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Cyan
    }
}
