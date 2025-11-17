# Comprehensive Reanalysis with OCR-Extracted Text
# Uses improved text extraction and strict filtering for real people

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$OCRPath = Join-Path $BasePath "ocr_extracted"
$ReanalysisPath = Join-Path $BasePath "reanalysis"

if (-not (Test-Path $ReanalysisPath)) {
    New-Item -ItemType Directory -Path $ReanalysisPath | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "COMPREHENSIVE REANALYSIS WITH OCR DATA" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Check if OCR extraction exists
if (-not (Test-Path $OCRPath)) {
    Write-Host "`nERROR: OCR extraction not found!" -ForegroundColor Red
    Write-Host "Please run ocr_extraction.ps1 first" -ForegroundColor Yellow
    exit 1
}

# Known real people database (expanded)
$KnownPeople = @{
    "Jeffrey Epstein" = @{
        aliases = @("Epstein", "Jeffrey", "Jeff Epstein", "JE", "Epstein Jeffrey")
        role = "Primary Subject"
        category = "Key Figure"
    }
    "Ghislaine Maxwell" = @{
        aliases = @("Maxwell", "Ghislaine", "GM", "G Maxwell")
        role = "Associate/Recruiter"
        category = "Key Figure"
    }
    "Virginia Giuffre" = @{
        aliases = @("Virginia Roberts", "Giuffre", "Roberts", "Virginia", "V Giuffre", "V Roberts")
        role = "Victim/Witness"
        category = "Victim"
    }
    "Prince Andrew" = @{
        aliases = @("Andrew", "Duke of York", "Prince Andrew", "HRH Andrew")
        role = "Associate"
        category = "Royal/Political"
    }
    "Bill Clinton" = @{
        aliases = @("Clinton", "William Clinton", "President Clinton", "Bill")
        role = "Associate"
        category = "Political"
    }
    "Donald Trump" = @{
        aliases = @("Trump", "Donald J Trump", "President Trump", "Donald")
        role = "Associate"
        category = "Political"
    }
    "Alan Dershowitz" = @{
        aliases = @("Dershowitz", "Alan", "A Dershowitz")
        role = "Attorney"
        category = "Legal"
    }
    "Leslie Wexner" = @{
        aliases = @("Wexner", "Les Wexner", "L Wexner")
        role = "Financial Backer"
        category = "Financial"
    }
    "Jean-Luc Brunel" = @{
        aliases = @("Brunel", "Jean Luc Brunel", "JL Brunel")
        role = "Associate/Recruiter"
        category = "Associate"
    }
    "Sarah Kellen" = @{
        aliases = @("Kellen", "Sarah", "S Kellen")
        role = "Assistant"
        category = "Associate"
    }
    "Nadia Marcinkova" = @{
        aliases = @("Marcinkova", "Nadia", "N Marcinkova", "Marcinkova Dep")
        role = "Associate"
        category = "Associate"
    }
    "Adriana Ross" = @{
        aliases = @("Ross", "Adriana", "A Ross")
        role = "Assistant"
        category = "Associate"
    }
    "Lesley Groff" = @{
        aliases = @("Groff", "Lesley", "L Groff")
        role = "Assistant"
        category = "Associate"
    }
    "Johanna Sjoberg" = @{
        aliases = @("Sjoberg", "Johanna", "J Sjoberg", "Sjoberg Johanna")
        role = "Victim/Witness"
        category = "Victim"
    }
    "Sarah Ransome" = @{
        aliases = @("Ransome", "Sarah", "S Ransome", "Ransome Sarah")
        role = "Victim/Witness"
        category = "Victim"
    }
    "Nicole Simmons" = @{
        aliases = @("Simmons", "Nicole", "N Simmons")
        role = "Staff"
        category = "Staff"
    }
    "Brenda Rodriguez" = @{
        aliases = @("Rodriguez", "Brenda", "B Rodriguez")
        role = "Staff"
        category = "Staff"
    }
    "Tony Figueroa" = @{
        aliases = @("Figueroa", "Tony", "T Figueroa")
        role = "Court Personnel"
        category = "Legal"
    }
    "Alfredo Rodriguez" = @{
        aliases = @("Rodriguez", "Alfredo", "A Rodriguez")
        role = "Former Butler"
        category = "Staff"
    }
}

# Illegal/sensitive terms
$SensitiveTerms = @(
    "sex", "sexual", "sexually", "massage", "massages",
    "nude", "naked", "undress", "undressed",
    "minor", "minors", "underage", "young girl", "young girls",
    "trafficking", "trafficked", "recruit", "recruited",
    "abuse", "abused", "assault", "assaulted",
    "victim", "victims", "rape", "raped",
    "drug", "drugs", "cocaine", "pills", "ecstasy",
    "orgy", "orgies", "prostitute", "prostitution"
)

# Function to find people in text
function Find-PeopleInText {
    param([string]$Text)
    
    $foundPeople = @{}
    $textLower = $Text.ToLower()
    
    foreach ($person in $KnownPeople.Keys) {
        $info = $KnownPeople[$person]
        $allNames = @($person) + $info.aliases
        
        foreach ($name in $allNames) {
            $pattern = [regex]::Escape($name.ToLower())
            if ($textLower -match $pattern) {
                if (-not $foundPeople.ContainsKey($person)) {
                    $foundPeople[$person] = @{
                        count = 0
                        contexts = @()
                        role = $info.role
                        category = $info.category
                    }
                }
                
                # Count occurrences
                $matches = [regex]::Matches($textLower, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                $foundPeople[$person].count += $matches.Count
                
                # Extract context (first 3 occurrences)
                $lines = $Text -split "`n"
                $contextCount = 0
                foreach ($line in $lines) {
                    if ($line -match $name -and $contextCount -lt 3) {
                        $context = $line.Trim()
                        if ($context.Length -gt 200) {
                            $context = $context.Substring(0, 197) + "..."
                        }
                        $foundPeople[$person].contexts += $context
                        $contextCount++
                    }
                }
                
                break
            }
        }
    }
    
    return $foundPeople
}

# Function to find sensitive terms
function Find-SensitiveTerms {
    param([string]$Text)
    
    $found = @{}
    $textLower = $Text.ToLower()
    
    foreach ($term in $SensitiveTerms) {
        $pattern = "\b$([regex]::Escape($term))\w*\b"
        $matches = [regex]::Matches($textLower, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        
        if ($matches.Count -gt 0) {
            $found[$term] = $matches.Count
        }
    }
    
    return $found
}

# Process all OCR-extracted documents
Write-Host "`nLoading OCR-extracted documents..." -ForegroundColor Yellow

$ocrFiles = Get-ChildItem -Path $OCRPath -Filter "*.md" | Where-Object { $_.Name -ne "INDEX.md" }
Write-Host "Found $($ocrFiles.Count) OCR-extracted documents`n" -ForegroundColor Green

$allPeople = @{}
$allDocuments = @()
$peopleDocuments = @{}

$processed = 0

foreach ($file in $ocrFiles) {
    $processed++
    
    if ($processed % 50 -eq 0) {
        Write-Host "  Processed $processed / $($ocrFiles.Count)..." -ForegroundColor Gray
    }
    
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Find people
        $people = Find-PeopleInText -Text $content
        
        # Find sensitive terms
        $terms = Find-SensitiveTerms -Text $content
        
        # Store document info
        $docInfo = @{
            filename = $file.BaseName
            people = $people.Keys
            people_details = $people
            sensitive_terms = $terms
            has_sensitive = $terms.Count -gt 0
        }
        
        $allDocuments += $docInfo
        
        # Aggregate people data
        foreach ($person in $people.Keys) {
            if (-not $allPeople.ContainsKey($person)) {
                $allPeople[$person] = @{
                    total_mentions = 0
                    documents = @()
                    contexts = @()
                    sensitive_cooccurrences = @{}
                    role = $people[$person].role
                    category = $people[$person].category
                }
            }
            
            $allPeople[$person].total_mentions += $people[$person].count
            $allPeople[$person].documents += $file.BaseName
            $allPeople[$person].contexts += $people[$person].contexts
            
            # Track sensitive term co-occurrences
            foreach ($term in $terms.Keys) {
                if (-not $allPeople[$person].sensitive_cooccurrences.ContainsKey($term)) {
                    $allPeople[$person].sensitive_cooccurrences[$term] = 0
                }
                $allPeople[$person].sensitive_cooccurrences[$term]++
            }
        }
    }
    catch {
        Write-Host "  Error processing $($file.Name): $_" -ForegroundColor Red
    }
}

Write-Host "`nAnalysis complete!" -ForegroundColor Green
Write-Host "  Documents processed: $($allDocuments.Count)" -ForegroundColor White
Write-Host "  People found: $($allPeople.Count)" -ForegroundColor White

# Generate comprehensive report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$report = @"
# COMPREHENSIVE REANALYSIS - OCR-Based Extraction
*Generated: $timestamp*

## Overview

This analysis uses **Tesseract OCR** to extract text from all PDFs, providing much better coverage than basic text extraction.

**Documents Analyzed**: $($allDocuments.Count)  
**Real People Found**: $($allPeople.Count)  
**Documents with Sensitive Terms**: $(($allDocuments | Where-Object { $_.has_sensitive }).Count)

---

## All People Found (Sorted by Mentions)

| Rank | Name | Total Mentions | Documents | Sensitive Co-occurrences | Category |
|------|------|----------------|-----------|--------------------------|----------|
"@

$rank = 1
$sortedPeople = $allPeople.GetEnumerator() | Sort-Object -Property { $_.Value.total_mentions } -Descending

foreach ($person in $sortedPeople) {
    $name = $person.Key
    $data = $person.Value
    $mentions = $data.total_mentions
    $docCount = ($data.documents | Select-Object -Unique).Count
    $sensitiveCount = ($data.sensitive_cooccurrences.Values | Measure-Object -Sum).Sum
    $category = $data.category
    
    $report += "`n| $rank | $name | $mentions | $docCount | $sensitiveCount | $category |"
    $rank++
}

$report += "`n`n---`n`n## Detailed Profiles`n`n"

$rank = 1
foreach ($person in $sortedPeople) {
    $name = $person.Key
    $data = $person.Value
    
    $report += "### $rank. $name`n`n"
    $report += "**Role**: $($data.role)  `n"
    $report += "**Category**: $($data.category)  `n"
    $report += "**Total Mentions**: $($data.total_mentions)  `n"
    $report += "**Documents**: $(($data.documents | Select-Object -Unique).Count)  `n`n"
    
    # Sensitive term co-occurrences
    if ($data.sensitive_cooccurrences.Count -gt 0) {
        $report += "#### Associated with Sensitive Terms`n`n"
        $report += "| Term | Documents with Co-occurrence |`n"
        $report += "|------|------------------------------|`n"
        
        $sortedTerms = $data.sensitive_cooccurrences.GetEnumerator() | Sort-Object -Property Value -Descending
        foreach ($term in $sortedTerms) {
            $report += "| $($term.Key) | $($term.Value) |`n"
        }
        $report += "`n"
    }
    
    # Sample contexts
    if ($data.contexts.Count -gt 0) {
        $report += "#### Sample Mentions`n`n"
        $uniqueContexts = $data.contexts | Select-Object -Unique | Select-Object -First 5
        foreach ($context in $uniqueContexts) {
            $report += "> $context`n`n"
        }
    }
    
    # Documents
    $uniqueDocs = $data.documents | Select-Object -Unique | Select-Object -First 20
    $report += "#### Documents ($($uniqueDocs.Count) shown)`n`n"
    foreach ($doc in $uniqueDocs) {
        $report += "- ````$doc````  `n"
    }
    
    $totalDocs = ($data.documents | Select-Object -Unique).Count
    if ($totalDocs -gt 20) {
        $report += "`n*... and $(($totalDocs - 20)) more documents*`n"
    }
    
    $report += "`n---`n`n"
    $rank++
}

$report | Out-File -FilePath (Join-Path $ReanalysisPath "COMPLETE_ANALYSIS.md") -Encoding UTF8

# Generate VIP-only report
$vips = $sortedPeople | Where-Object { $_.Value.category -in @("Key Figure", "Royal/Political", "Political") }

$vipReport = "# VIP ANALYSIS - High-Profile Individuals`n"
$vipReport += "*Generated: $timestamp*`n`n"
$vipReport += "**Total VIPs Found**: $($vips.Count)`n`n"
$vipReport += "---`n`n"

foreach ($vip in $vips) {
    $name = $vip.Key
    $data = $vip.Value
    
    $vipReport += "## $name`n`n"
    $vipReport += "- **Role**: $($data.role)`n"
    $vipReport += "- **Total Mentions**: $($data.total_mentions)`n"
    $vipReport += "- **Documents**: $(($data.documents | Select-Object -Unique).Count)`n"
    
    if ($data.sensitive_cooccurrences.Count -gt 0) {
        $vipReport += "- **Sensitive Term Co-occurrences**: $(($data.sensitive_cooccurrences.Values | Measure-Object -Sum).Sum)`n"
        $vipReport += "`n**Terms**:`n"
        $sortedTerms = $data.sensitive_cooccurrences.GetEnumerator() | Sort-Object -Property Value -Descending
        foreach ($term in $sortedTerms) {
            $vipReport += "  - $($term.Key): $($term.Value) documents`n"
        }
    }
    
    $vipReport += "`n---`n`n"
}

$vipReport | Out-File -FilePath (Join-Path $ReanalysisPath "VIP_ANALYSIS.md") -Encoding UTF8

# Generate statistics
$stats = @"
# REANALYSIS STATISTICS
*Generated: $timestamp*

## Extraction Method

**OCR-Based Extraction** using Tesseract OCR
- Converts PDF pages to images
- Runs OCR on each image
- Much better than basic text extraction
- Can extract from scanned documents

## Results

### Documents
- **Total Analyzed**: $($allDocuments.Count)
- **With Sensitive Terms**: $(($allDocuments | Where-Object { $_.has_sensitive }).Count)
- **With People Mentions**: $(($allDocuments | Where-Object { $_.people.Count -gt 0 }).Count)

### People
- **Total Real People Found**: $($allPeople.Count)
- **Key Figures**: $(($sortedPeople | Where-Object { $_.Value.category -eq "Key Figure" }).Count)
- **Victims/Witnesses**: $(($sortedPeople | Where-Object { $_.Value.category -eq "Victim" }).Count)
- **Associates**: $(($sortedPeople | Where-Object { $_.Value.category -eq "Associate" }).Count)
- **Political Figures**: $(($sortedPeople | Where-Object { $_.Value.category -in @("Political", "Royal/Political") }).Count)

### Top 10 Most Mentioned

"@

$top10 = $sortedPeople | Select-Object -First 10
$rank = 1
foreach ($person in $top10) {
    $stats += "$rank. **$($person.Key)** - $($person.Value.total_mentions) mentions`n"
    $rank++
}

$stats | Out-File -FilePath (Join-Path $ReanalysisPath "STATISTICS.md") -Encoding UTF8

# Save JSON data
$jsonData = @{
    timestamp = $timestamp
    documents_analyzed = $allDocuments.Count
    people_found = $allPeople.Count
    people = @{}
}

foreach ($person in $allPeople.Keys) {
    $jsonData.people[$person] = @{
        mentions = $allPeople[$person].total_mentions
        documents = ($allPeople[$person].documents | Select-Object -Unique)
        role = $allPeople[$person].role
        category = $allPeople[$person].category
        sensitive_terms = $allPeople[$person].sensitive_cooccurrences
    }
}

$jsonData | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $ReanalysisPath "analysis_data.json") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "REANALYSIS COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - COMPLETE_ANALYSIS.md (All people with details)" -ForegroundColor White
Write-Host "  - VIP_ANALYSIS.md (High-profile individuals)" -ForegroundColor White
Write-Host "  - STATISTICS.md (Summary statistics)" -ForegroundColor White
Write-Host "  - analysis_data.json (Raw data)" -ForegroundColor White
Write-Host "`nLocation: $ReanalysisPath" -ForegroundColor Cyan
