# Download Nobody's Girl by Virginia Roberts Giuffre
# Extract timeline data from the memoir

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump",
    [string]$DownloadPath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump\additional_downloads"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "DOWNLOAD NOBODY'S GIRL MEMOIR" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`nBook Information:" -ForegroundColor Yellow
Write-Host "  Title: Nobody's Girl: A Memoir of Surviving Abuse and Fighting for Justice" -ForegroundColor White
Write-Host "  Author: Virginia Roberts Giuffre" -ForegroundColor White
Write-Host "  Publisher: Penguin Random House" -ForegroundColor White
Write-Host "  Status: #1 New York Times Bestseller" -ForegroundColor White

Write-Host "`nImportance for Timeline:" -ForegroundColor Yellow
Write-Host "  - First-hand account from key witness" -ForegroundColor White
Write-Host "  - Specific dates of incidents" -ForegroundColor White
Write-Host "  - Locations and travel details" -ForegroundColor White
Write-Host "  - People involved with dates" -ForegroundColor White
Write-Host "  - Recruitment and abuse timeline" -ForegroundColor White

# Create download directory
if (-not (Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}

Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "DOWNLOAD OPTIONS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nOption 1: Purchase Legal Copy (Recommended)" -ForegroundColor Green
Write-Host "  Amazon: https://www.amazon.com/Nobodys-Girl-Surviving-Fighting-Justice/dp/0593493125" -ForegroundColor Cyan
Write-Host "  Penguin: https://www.penguinrandomhouse.com/books/712958/nobodys-girl-by-virginia-roberts-giuffre/" -ForegroundColor Cyan
Write-Host "  Price: ~$15-30 (supports Virginia's estate)" -ForegroundColor White

Write-Host "`nOption 2: Library Access" -ForegroundColor Green
Write-Host "  OverDrive: https://maryland.overdrive.com/media/12197524" -ForegroundColor Cyan
Write-Host "  Local library: Check your library's digital collection" -ForegroundColor White
Write-Host "  Libby app: Search for 'Nobody's Girl'" -ForegroundColor White

Write-Host "`nOption 3: Archive.org" -ForegroundColor Yellow
Write-Host "  Search: https://archive.org/search.php?query=nobody%27s+girl+virginia+giuffre" -ForegroundColor Cyan
Write-Host "  Note: May have borrowing limits" -ForegroundColor White

# Attempt to download from Internet Archive
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "ATTEMPTING DOWNLOAD FROM ARCHIVE.ORG" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$archiveUrls = @(
    "https://archive.org/download/nobodys-girl-virginia-giuffre/nobodys-girl.pdf",
    "https://ia801509.us.archive.org/view_archive.php?archive=/35/items/nobodys-girl-virginia-giuffre/nobodys-girl.pdf"
)

$downloaded = $false
$outputPath = Join-Path $DownloadPath "nobodys_girl_virginia_giuffre.pdf"

foreach ($url in $archiveUrls) {
    if ($downloaded) { break }
    
    try {
        Write-Host "`nTrying: $url" -ForegroundColor Yellow
        
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $webClient.DownloadFile($url, $outputPath)
        
        if (Test-Path $outputPath) {
            $size = (Get-Item $outputPath).Length / 1MB
            if ($size -gt 0.1) {
                Write-Host "  Downloaded: $([math]::Round($size, 2)) MB" -ForegroundColor Green
                $downloaded = $true
            }
            else {
                Remove-Item $outputPath -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Host "  Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if (-not $downloaded) {
    Write-Host "`n" + ("=" * 80) -ForegroundColor Yellow
    Write-Host "AUTOMATIC DOWNLOAD NOT AVAILABLE" -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Yellow
    
    Write-Host "`nPlease obtain the book through one of these methods:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Purchase from Amazon or Penguin (supports Virginia's estate)" -ForegroundColor White
    Write-Host "2. Borrow from your local library (Libby/OverDrive)" -ForegroundColor White
    Write-Host "3. Search Archive.org for available copies" -ForegroundColor White
    Write-Host ""
    Write-Host "Once you have the PDF:" -ForegroundColor Yellow
    Write-Host "  1. Save it to: $DownloadPath" -ForegroundColor White
    Write-Host "  2. Name it: nobodys_girl_virginia_giuffre.pdf" -ForegroundColor White
    Write-Host "  3. Run: .\PROCESS_NOBODYS_GIRL.ps1" -ForegroundColor White
    
    # Create manual download instructions
    $instructions = @"
# Nobody's Girl - Manual Download Instructions

## Book Information

**Title**: Nobody's Girl: A Memoir of Surviving Abuse and Fighting for Justice  
**Author**: Virginia Roberts Giuffre  
**Publisher**: Penguin Random House  
**Status**: #1 New York Times Bestseller  

---

## Why This Book is Critical for Timeline

Virginia Roberts Giuffre's memoir provides:

1. **First-hand account** of abuse and trafficking
2. **Specific dates** of incidents and travel
3. **Locations** where events occurred
4. **People involved** with detailed descriptions
5. **Recruitment timeline** (how she was brought in)
6. **Abuse timeline** (specific incidents with dates)
7. **Escape timeline** (how she got away)
8. **Legal battle timeline** (fighting for justice)

This is the **most important primary source** for understanding the timeline from a victim's perspective.

---

## Legal Purchase Options (Recommended)

### Amazon
**URL**: https://www.amazon.com/Nobodys-Girl-Surviving-Fighting-Justice/dp/0593493125  
**Price**: ~`$15-30  
**Format**: Hardcover, Paperback, Kindle, Audiobook  
**Benefit**: Supports Virginia's estate

### Penguin Random House
**URL**: https://www.penguinrandomhouse.com/books/712958/nobodys-girl-by-virginia-roberts-giuffre/  
**Price**: ~`$15-30  
**Format**: All formats available

### Barnes & Noble
**URL**: https://www.barnesandnoble.com/  
**Search**: "Nobody's Girl Virginia Giuffre"

---

## Library Access (Free)

### OverDrive/Libby
**URL**: https://maryland.overdrive.com/media/12197524  
**How to**:
1. Download Libby app
2. Add your library card
3. Search "Nobody's Girl"
4. Borrow digital copy

### Local Library
1. Check your library's website
2. Search digital collection
3. Request if not available
4. Borrow when available

---

## Archive.org (Free, Limited)

**URL**: https://archive.org/  
**Search**: "Nobody's Girl Virginia Giuffre"  
**Note**: May have borrowing limits or waiting lists

---

## After Obtaining the Book

### If PDF Format

1. Save to: ``$DownloadPath``
2. Rename to: ``nobodys_girl_virginia_giuffre.pdf``
3. Run: ``.\PROCESS_NOBODYS_GIRL.ps1``

### If Kindle/EPUB Format

1. Convert to PDF using Calibre
2. Save to download folder
3. Run processing script

### If Physical Book

1. Consider purchasing digital version for analysis
2. Or manually extract timeline data
3. Create timeline entries from reading

---

## What We'll Extract

Once we have the PDF, we'll extract:

### Timeline Data
- **Dates** mentioned in the memoir
- **Ages** (to calculate dates)
- **Locations** of incidents
- **People** involved in each incident
- **Events** in chronological order

### Key Information
- **Recruitment date** (when she met Ghislaine)
- **First abuse date**
- **Travel dates** (flights, trips)
- **Property visits** (Little St. James, Palm Beach, etc.)
- **People encounters** (who she met and when)
- **Escape date** (when she got away)
- **Coming forward date** (when she went public)

### Cross-References
- **Flight logs** (verify her travel claims)
- **Emails** (find related correspondence)
- **Court documents** (match with legal filings)
- **Little Black Book** (verify people mentioned)

---

## Processing Script

Once you have the PDF, run:

``````powershell
.\PROCESS_NOBODYS_GIRL.ps1
``````

This will:
1. Extract all text from the memoir
2. Identify dates and timeline events
3. Extract people and locations
4. Create detailed timeline entries
5. Cross-reference with existing data
6. Add to unified timeline
7. Push to GitHub

---

## Expected Timeline Additions

From the memoir, we expect to add:

- **50-100 specific incident dates**
- **20-30 travel dates**
- **10-20 people introductions**
- **5-10 property visits**
- **Complete recruitment timeline**
- **Complete abuse timeline**
- **Complete escape timeline**

This will be the **most detailed victim timeline** in the analysis.

---

## Legal Note

Please obtain this book through legal channels:
- Purchase supports Virginia's estate
- Library borrowing is legal and free
- Piracy harms the author's legacy

Virginia Roberts Giuffre passed away in 2025. Purchasing her book supports her family and her fight for justice.

---

*Save the PDF to ``$DownloadPath`` as ``nobodys_girl_virginia_giuffre.pdf`` and run ``.\PROCESS_NOBODYS_GIRL.ps1``*
"@

    $instructionsPath = Join-Path $DownloadPath "NOBODYS_GIRL_INSTRUCTIONS.md"
    $instructions | Out-File -FilePath $instructionsPath -Encoding UTF8
    
    Write-Host "`nInstructions saved to: NOBODYS_GIRL_INSTRUCTIONS.md" -ForegroundColor Green
}
else {
    Write-Host "`n" + ("=" * 80) -ForegroundColor Green
    Write-Host "DOWNLOAD COMPLETE!" -ForegroundColor Green
    Write-Host ("=" * 80) -ForegroundColor Green
    
    Write-Host "`nFile saved: $outputPath" -ForegroundColor Cyan
    Write-Host "Size: $([math]::Round((Get-Item $outputPath).Length / 1MB, 2)) MB" -ForegroundColor White
    
    Write-Host "`nNext step: Run processing script" -ForegroundColor Yellow
    Write-Host "  .\PROCESS_NOBODYS_GIRL.ps1" -ForegroundColor Cyan
}

Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
