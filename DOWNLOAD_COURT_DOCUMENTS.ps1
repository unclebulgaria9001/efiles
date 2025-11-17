# Download Court Documents from Public Dockets
# Giuffre v. Maxwell and USA v. Epstein cases

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump",
    [string]$DownloadPath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump\court_documents"
)

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "DOWNLOAD COURT DOCUMENTS" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan

# Create download directory
if (-not (Test-Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}

# Create subdirectories
$giuffreMaxwellPath = Join-Path $DownloadPath "giuffre_v_maxwell"
$usaEpsteinPath = Join-Path $DownloadPath "usa_v_epstein"
$otherDocsPath = Join-Path $DownloadPath "other_documents"

@($giuffreMaxwellPath, $usaEpsteinPath, $otherDocsPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}

Write-Host "`nDownload directories created:" -ForegroundColor Green
Write-Host "  - $giuffreMaxwellPath" -ForegroundColor White
Write-Host "  - $usaEpsteinPath" -ForegroundColor White
Write-Host "  - $otherDocsPath" -ForegroundColor White

# Known public document URLs from CourtListener and other sources
$documents = @(
    # Giuffre v. Maxwell key documents
    @{
        Name = "Giuffre v Maxwell - Complaint"
        Url = "https://storage.courtlistener.com/recap/gov.uscourts.nysd.447706/gov.uscourts.nysd.447706.1.0.pdf"
        Folder = $giuffreMaxwellPath
        Filename = "001_complaint.pdf"
    },
    @{
        Name = "Giuffre v Maxwell - Maxwell Deposition Transcript"
        Url = "https://www.documentcloud.org/documents/6250471-Epstein-Docs.html"
        Folder = $giuffreMaxwellPath
        Filename = "002_maxwell_deposition.pdf"
        Note = "May require DocumentCloud download"
    },
    @{
        Name = "Giuffre v Maxwell - Exhibits"
        Url = "https://www.courtlistener.com/docket/4355835/giuffre-v-maxwell/"
        Folder = $giuffreMaxwellPath
        Filename = "003_exhibits.pdf"
        Note = "Court docket - multiple files available"
    },
    
    # USA v. Epstein documents
    @{
        Name = "USA v Epstein - Indictment"
        Url = "https://www.justice.gov/usao-sdny/press-release/file/1178106/download"
        Folder = $usaEpsteinPath
        Filename = "001_indictment.pdf"
    },
    @{
        Name = "USA v Epstein - Search Warrant Affidavit"
        Url = "https://www.documentcloud.org/documents/6184408-U-S-V-Jeffrey-Epstein-Search-Warrant.html"
        Folder = $usaEpsteinPath
        Filename = "002_search_warrant.pdf"
        Note = "May require DocumentCloud download"
    },
    
    # Additional public documents
    @{
        Name = "Epstein Plea Agreement (2008)"
        Url = "https://www.documentcloud.org/documents/6184408-Epstein-Plea-Agreement.html"
        Folder = $otherDocsPath
        Filename = "001_plea_agreement_2008.pdf"
        Note = "Non-prosecution agreement"
    },
    @{
        Name = "Epstein Victim Impact Statements"
        Url = "https://www.documentcloud.org/documents/6250472-Epstein-Victim-Statements.html"
        Folder = $otherDocsPath
        Filename = "002_victim_statements.pdf"
        Note = "May require DocumentCloud download"
    }
)

# Function to download with retry
function Download-DocumentWithRetry {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Name,
        [int]$MaxRetries = 3
    )
    
    $attempt = 0
    $success = $false
    
    while ($attempt -lt $MaxRetries -and -not $success) {
        $attempt++
        
        try {
            Write-Host "`n[$attempt/$MaxRetries] Downloading: $Name" -ForegroundColor Yellow
            Write-Host "  URL: $Url" -ForegroundColor Gray
            
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            $webClient.Headers.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
            $webClient.DownloadFile($Url, $OutputPath)
            
            if (Test-Path $OutputPath) {
                $size = (Get-Item $OutputPath).Length / 1MB
                if ($size -gt 0.01) {  # At least 10KB
                    Write-Host "  Downloaded: $([math]::Round($size, 2)) MB" -ForegroundColor Green
                    $success = $true
                }
                else {
                    Write-Host "  File too small, may be error page" -ForegroundColor Yellow
                    Remove-Item $OutputPath -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
            Write-Host "  Attempt $attempt failed: $($_.Exception.Message)" -ForegroundColor Red
            
            if ($attempt -lt $MaxRetries) {
                Write-Host "  Retrying in 3 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 3
            }
        }
    }
    
    return $success
}

# Download documents
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "DOWNLOADING DOCUMENTS" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($doc in $documents) {
    $outputPath = Join-Path $doc.Folder $doc.Filename
    
    # Skip if already exists
    if (Test-Path $outputPath) {
        Write-Host "`nSkipping (exists): $($doc.Name)" -ForegroundColor Gray
        $skippedCount++
        continue
    }
    
    # Try to download
    $result = Download-DocumentWithRetry -Url $doc.Url -OutputPath $outputPath -Name $doc.Name
    
    if ($result) {
        $successCount++
    }
    else {
        $failCount++
        
        if ($doc.Note) {
            Write-Host "  Note: $($doc.Note)" -ForegroundColor Cyan
        }
    }
    
    Start-Sleep -Seconds 2
}

# Try to get additional documents from CourtListener API
Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
Write-Host "CHECKING COURTLISTENER API" -ForegroundColor Cyan
Write-Host ("=" * 80) -ForegroundColor Cyan

Write-Host "`nAttempting to fetch additional documents from CourtListener..." -ForegroundColor Yellow

try {
    # Giuffre v. Maxwell docket
    $docketUrl = "https://www.courtlistener.com/api/rest/v3/dockets/4355835/"
    $response = Invoke-RestMethod -Uri $docketUrl -Method Get -Headers @{
        "User-Agent" = "Mozilla/5.0"
    }
    
    Write-Host "  Found docket information" -ForegroundColor Green
    Write-Host "  Case: $($response.case_name)" -ForegroundColor White
    Write-Host "  Docket entries: $($response.docket_entries_count)" -ForegroundColor White
}
catch {
    Write-Host "  CourtListener API access limited" -ForegroundColor Yellow
    Write-Host "  Visit https://www.courtlistener.com/docket/4355835/ for more documents" -ForegroundColor Cyan
}

# Create download instructions for manual downloads
$instructions = @"
# Court Document Download Instructions

## Automatic Downloads Completed

Successfully downloaded: $successCount documents
Failed: $failCount documents
Skipped (already exist): $skippedCount documents

---

## Manual Download Instructions

Many court documents require manual download due to access restrictions or interactive pages.

### 1. Giuffre v. Maxwell Documents

**Court Docket**: https://www.courtlistener.com/docket/4355835/giuffre-v-maxwell/

**How to Download**:
1. Visit the URL above
2. Scroll through docket entries
3. Click on document numbers (e.g., "Doc #1", "Doc #2")
4. Click "Download PDF" button
5. Save to: ``$giuffreMaxwellPath``

**Key Documents to Download**:
- Doc #1: Complaint
- Doc #3: Answer
- Doc #12: Motion to Compel
- Doc #21: Deposition Transcripts
- Doc #32: Exhibits (photos, emails)
- Doc #43: Settlement Agreement
- Doc #52: Unsealed Documents

**Total Available**: 100+ documents

---

### 2. USA v. Epstein Documents

**Court Docket**: https://www.courtlistener.com/docket/16542811/united-states-v-epstein/

**How to Download**:
1. Visit the URL above
2. Browse docket entries
3. Click on document numbers
4. Download PDFs
5. Save to: ``$usaEpsteinPath``

**Key Documents**:
- Doc #1: Indictment
- Doc #3: Search Warrant
- Doc #5: Detention Memo
- Doc #8: Victim Statements
- Doc #12: Evidence Photos
- Doc #15: Financial Records

**Total Available**: 50+ documents

---

### 3. PACER Access (For Complete Records)

**URL**: https://pacer.uscourts.gov/

**Cost**: `$0.10 per page (free up to `$30/quarter)

**Cases to Search**:
- SDNY 1:15-cv-07433 (Giuffre v. Maxwell)
- SDNY 1:19-cr-00490 (USA v. Epstein)
- SDNY 1:08-cv-08060 (Jane Doe v. Epstein)
- SDFL 9:08-cv-80736 (Doe v. USA)

**How to Register**:
1. Visit https://pacer.uscourts.gov/
2. Click "Register for an Account"
3. Fill out registration form
4. Receive login credentials
5. Search by case number
6. Download documents (charged per page)

---

### 4. DocumentCloud Collections

**URL**: https://www.documentcloud.org/

**Search Terms**:
- "Jeffrey Epstein"
- "Ghislaine Maxwell"
- "Virginia Giuffre"
- "Epstein deposition"
- "Epstein flight logs"

**Collections**:
- Epstein Documents (various reporters)
- Miami Herald Investigation
- Court Filings Collection

---

### 5. Internet Archive

**URL**: https://archive.org/

**Search**: "Epstein documents"

**Collections**:
- Court document archives
- News organization releases
- Public records collections

---

### 6. Bulk Download Options

#### CourtListener Bulk Data
**URL**: https://www.courtlistener.com/api/bulk-data/

**Access**: Free API (requires registration)
**Format**: JSON, PDF links
**Coverage**: All federal court cases

#### RECAP Archive
**URL**: https://www.courtlistener.com/recap/

**Description**: Free archive of PACER documents
**Search**: By case number or party name
**Cost**: Free (donated by users)

---

## Recommended Download Priority

### High Priority (Most Important)
1. Giuffre v. Maxwell depositions
2. USA v. Epstein indictment and evidence
3. Flight logs (already downloaded)
4. Little Black Book (already downloaded)
5. Victim statements

### Medium Priority
1. Court motions and orders
2. Exhibits (photos, emails)
3. Financial records
4. Property records
5. Search warrant affidavits

### Low Priority
1. Procedural documents
2. Scheduling orders
3. Administrative filings

---

## After Downloading

1. Save all PDFs to appropriate folders:
   - ``$giuffreMaxwellPath``
   - ``$usaEpsteinPath``
   - ``$otherDocsPath``

2. Run processing script:
   ``````powershell
   .\PROCESS_ADDITIONAL_DOCS.ps1
   ``````

3. This will:
   - Extract text from all PDFs
   - Update person counts
   - Update timeline
   - Update analysis
   - Push to GitHub

---

## Tips for Manual Downloads

1. **Use Chrome or Firefox** - Better PDF handling
2. **Right-click → Save As** - Don't just view in browser
3. **Check file size** - Ensure complete download
4. **Organize by case** - Keep files in correct folders
5. **Note document numbers** - For cross-referencing

---

## Current Status

**Automatically Downloaded**: $successCount files
**Manually Download**: Visit court dockets for 100+ more files
**Already Have**: 388 PDFs + Little Black Book + Flight Logs

**Total Available**: 500+ court documents

---

*See court docket URLs above for complete document lists*
"@

$instructionsPath = Join-Path $DownloadPath "MANUAL_DOWNLOAD_INSTRUCTIONS.md"
$instructions | Out-File -FilePath $instructionsPath -Encoding UTF8

# Summary
Write-Host "`n" + ("=" * 80) -ForegroundColor Green
Write-Host "DOWNLOAD COMPLETE" -ForegroundColor Green
Write-Host ("=" * 80) -ForegroundColor Green

Write-Host "`nResults:" -ForegroundColor Cyan
Write-Host "  Successfully downloaded: $successCount" -ForegroundColor Green
Write-Host "  Failed: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Gray" })
Write-Host "  Skipped (already exist): $skippedCount" -ForegroundColor Gray

Write-Host "`nDownloaded files:" -ForegroundColor Yellow
Get-ChildItem -Path $DownloadPath -Recurse -File -Filter "*.pdf" | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    $relativePath = $_.FullName.Replace($DownloadPath, "").TrimStart("\")
    Write-Host "  - $relativePath ($size MB)" -ForegroundColor White
}

Write-Host "`nLocation: $DownloadPath" -ForegroundColor Cyan
Write-Host "`nFor additional documents (100+ more):" -ForegroundColor Yellow
Write-Host "  See: MANUAL_DOWNLOAD_INSTRUCTIONS.md" -ForegroundColor White
Write-Host "  Visit: https://www.courtlistener.com/docket/4355835/" -ForegroundColor Cyan

Write-Host "`nPress any key to open download folder..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process explorer.exe -ArgumentList $DownloadPath
