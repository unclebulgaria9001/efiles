# Download Additional Epstein Documents
# Including the birthday book and other released documents

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump",
    [string]$DownloadPath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump\additional_downloads"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "DOWNLOAD ADDITIONAL EPSTEIN DOCUMENTS" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Create download directory
if (-not (Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
    Write-Host "`nCreated download directory: $DownloadPath" -ForegroundColor Green
}

# Known document sources
$documents = @(
    @{
        Name = "Epstein Birthday Book (Little Black Book)"
        Url = "https://www.documentcloud.org/documents/1508273-jeffrey-epsteins-little-black-book-redacted.html"
        Description = "Contact list with names and phone numbers"
        Type = "PDF"
    },
    @{
        Name = "Epstein Flight Logs"
        Url = "https://www.documentcloud.org/documents/1507315-epstein-flight-manifests.html"
        Description = "Flight manifests showing passengers"
        Type = "PDF"
    },
    @{
        Name = "Maxwell Deposition Documents"
        Url = "https://www.courtlistener.com/docket/4355835/giuffre-v-maxwell/"
        Description = "Court documents from Giuffre v. Maxwell case"
        Type = "Court Docket"
    },
    @{
        Name = "Epstein Case Documents - SDNY"
        Url = "https://www.courtlistener.com/docket/16542811/united-states-v-epstein/"
        Description = "Southern District of New York case documents"
        Type = "Court Docket"
    }
)

Write-Host "`nAvailable Documents:" -ForegroundColor Yellow
for ($i = 0; $i -lt $documents.Count; $i++) {
    Write-Host "  $($i+1). $($documents[$i].Name)" -ForegroundColor White
    Write-Host "     $($documents[$i].Description)" -ForegroundColor Gray
    Write-Host "     URL: $($documents[$i].Url)" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "DOWNLOADING DOCUMENTS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

# Function to download file
function Download-Document {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Name
    )
    
    Write-Host "`nDownloading: $Name" -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
    try {
        # Try to download
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $webClient.DownloadFile($Url, $OutputPath)
        
        if (Test-Path $OutputPath) {
            $size = (Get-Item $OutputPath).Length / 1MB
            Write-Host "  Downloaded: $([math]::Round($size, 2)) MB" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        return $false
    }
    
    return $false
}

# Direct download links (these are known public sources)
$directDownloads = @(
    @{
        Name = "Epstein Little Black Book"
        Url = "https://assets.documentcloud.org/documents/1508273/jeffrey-epsteins-little-black-book-redacted.pdf"
        Filename = "epstein_little_black_book.pdf"
    },
    @{
        Name = "Epstein Flight Logs"
        Url = "https://assets.documentcloud.org/documents/1507315/epstein-flight-manifests.pdf"
        Filename = "epstein_flight_logs.pdf"
    }
)

$successCount = 0
$failCount = 0

foreach ($doc in $directDownloads) {
    $outputPath = Join-Path $DownloadPath $doc.Filename
    
    if (Test-Path $outputPath) {
        Write-Host "`n$($doc.Name) already exists, skipping..." -ForegroundColor Yellow
        $successCount++
        continue
    }
    
    $result = Download-Document -Url $doc.Url -OutputPath $outputPath -Name $doc.Name
    
    if ($result) {
        $successCount++
    }
    else {
        $failCount++
    }
    
    Start-Sleep -Seconds 2
}

# Create info file about court dockets
$courtInfo = @"
# Court Docket Information

The following court dockets contain additional Epstein documents that can be downloaded:

## 1. Giuffre v. Maxwell (SDNY Case 1:15-cv-07433)
**URL**: https://www.courtlistener.com/docket/4355835/giuffre-v-maxwell/
**Description**: Civil case with extensive depositions and exhibits
**Documents**: 1000+ files available

### How to Access:
1. Visit the URL above
2. Scroll through the docket entries
3. Click on document numbers to download PDFs
4. Key documents include:
   - Depositions (Giuffre, Maxwell, others)
   - Exhibits (photos, emails, flight logs)
   - Court orders and motions

## 2. United States v. Epstein (SDNY Case 1:19-cr-00490)
**URL**: https://www.courtlistener.com/docket/16542811/united-states-v-epstein/
**Description**: Criminal case documents
**Documents**: 100+ files available

### How to Access:
1. Visit the URL above
2. Browse docket entries
3. Download available documents
4. Key documents include:
   - Indictment
   - Search warrants
   - Victim statements
   - Evidence exhibits

## 3. Additional Sources

### PACER (Public Access to Court Electronic Records)
**URL**: https://pacer.uscourts.gov/
**Cost**: $0.10 per page (free up to $30/quarter)
**Access**: Requires account registration
**Cases**:
- SDNY 1:15-cv-07433 (Giuffre v. Maxwell)
- SDNY 1:19-cr-00490 (USA v. Epstein)
- SDNY 1:08-cv-08060 (Jane Doe v. Epstein)

### DocumentCloud
**URL**: https://www.documentcloud.org/
**Search**: "Jeffrey Epstein"
**Documents**: Various court filings, depositions, exhibits

### Internet Archive
**URL**: https://archive.org/
**Search**: "Epstein documents"
**Documents**: Archived court documents and news reports

## 4. Bulk Download Options

### Court Listener Bulk Data
**URL**: https://www.courtlistener.com/api/bulk-data/
**Format**: JSON, PDF
**Access**: Free API access

### RECAP Archive
**URL**: https://www.courtlistener.com/recap/
**Description**: Free archive of PACER documents
**Search**: Case numbers or party names

## Notes

- Many documents are already in the `extracted/` folder (388 PDFs)
- The "Little Black Book" and "Flight Logs" are being downloaded automatically
- Court dockets require manual browsing and selection
- Some documents may require PACER account ($0.10/page)
- Always verify document authenticity from official sources

"@

$courtInfoPath = Join-Path $DownloadPath "COURT_DOCKET_INFO.md"
$courtInfo | Out-File -FilePath $courtInfoPath -Encoding UTF8

Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "DOWNLOAD COMPLETE" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nResults:" -ForegroundColor Cyan
Write-Host "  Successfully downloaded: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })

Write-Host "`nDownloaded files:" -ForegroundColor Yellow
Get-ChildItem -Path $DownloadPath -File | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  - $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host "`nLocation: $DownloadPath" -ForegroundColor Cyan
Write-Host "`nSee COURT_DOCKET_INFO.md for additional document sources" -ForegroundColor Yellow

# Ask if user wants to extract and process these files
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "NEXT STEPS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nWould you like to:" -ForegroundColor Yellow
Write-Host "  1. Extract text from downloaded PDFs" -ForegroundColor White
Write-Host "  2. Add to complete extraction and analysis" -ForegroundColor White
Write-Host "  3. Update person counts and reports" -ForegroundColor White
Write-Host "  4. Push to GitHub" -ForegroundColor White

Write-Host "`nTo process these files, run:" -ForegroundColor Cyan
Write-Host "  .\PROCESS_ADDITIONAL_DOCS.ps1" -ForegroundColor White

Write-Host "`nPress any key to open download folder..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process explorer.exe -ArgumentList $DownloadPath
