# Epstein Document Analysis Tool - PowerShell Version
# Extracts metadata, identifies people, tracks terms, and builds analytics

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$ErrorActionPreference = "Continue"

# Initialize paths
$ExtractedPath = Join-Path $BasePath "extracted"
$AnalyticsPath = Join-Path $BasePath "analytics"

# Create analytics directory
if (-not (Test-Path $AnalyticsPath)) {
    New-Item -ItemType Directory -Path $AnalyticsPath | Out-Null
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "EPSTEIN DOCUMENT ANALYSIS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Initialize data structures
$script:Documents = @()
$script:PersonCounts = @{}
$script:TermCounts = @{}
$script:VIPMentions = @{}
$script:IllegalQuotes = @()
$script:Interactions = @{}

# VIP list
$VIPs = @(
    "donald trump", "trump",
    "prince andrew", "andrew",
    "bill clinton", "clinton",
    "bill gates", "gates",
    "stephen hawking", "hawking",
    "alan dershowitz", "dershowitz",
    "ghislaine maxwell", "maxwell",
    "virginia giuffre", "giuffre", "virginia roberts",
    "jean luc brunel", "brunel",
    "leslie wexner", "wexner",
    "naomi campbell", "campbell",
    "kevin spacey", "spacey",
    "chris tucker", "tucker",
    "larry summers", "summers",
    "marvin minsky", "minsky",
    "glenn dubin", "dubin",
    "eva dubin",
    "sarah kellen", "kellen",
    "nadia marcinkova", "marcinkova",
    "adriana ross", "ross",
    "lesley groff", "groff",
    "jeffrey epstein", "epstein"
)

# Illegal activity keywords
$IllegalTerms = @(
    "sex", "sexual", "massage", "naked", "nude", "underage",
    "minor", "young girl", "teenage", "prostitute", "prostitution",
    "trafficking", "abuse", "molest", "rape", "assault",
    "drug", "cocaine", "heroin", "pills", "prescription",
    "illegal", "crime", "criminal", "victim", "exploit"
)

function Extract-TextFromPDF {
    param([string]$PdfPath)
    
    try {
        # Try using iTextSharp if available, otherwise use basic text extraction
        # For now, we'll use a simple approach with Get-Content for text-based PDFs
        
        # This is a simplified version - actual PDF text extraction requires specialized libraries
        # We'll extract what we can and note the limitation
        
        $content = ""
        $metadata = @{
            filename = (Split-Path $PdfPath -Leaf)
            path = $PdfPath
            size = (Get-Item $PdfPath).Length
            created = (Get-Item $PdfPath).CreationTime
            modified = (Get-Item $PdfPath).LastWriteTime
        }
        
        # Try to read as text (will work for some PDFs)
        try {
            $bytes = [System.IO.File]::ReadAllBytes($PdfPath)
            $content = [System.Text.Encoding]::ASCII.GetString($bytes)
            
            # Clean up binary junk, keep readable text
            $content = $content -replace '[^\x20-\x7E\r\n]', ' '
            $content = $content -replace '\s+', ' '
        }
        catch {
            Write-Host "  Warning: Could not extract text from $($metadata.filename)" -ForegroundColor Yellow
        }
        
        return @{
            content = $content
            metadata = $metadata
        }
    }
    catch {
        Write-Host "  Error reading $PdfPath : $_" -ForegroundColor Red
        return $null
    }
}

function Find-Emails {
    param([string]$Text)
    
    $emailPattern = '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    $matches = [regex]::Matches($Text, $emailPattern)
    return ($matches | ForEach-Object { $_.Value } | Select-Object -Unique)
}

function Find-PhoneNumbers {
    param([string]$Text)
    
    $phonePattern = '\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\b\(\d{3}\)\s*\d{3}[-.]?\d{4}\b'
    $matches = [regex]::Matches($Text, $phonePattern)
    return ($matches | ForEach-Object { $_.Value } | Select-Object -Unique)
}

function Find-People {
    param([string]$Text)
    
    # Find capitalized names (First Last or First Middle Last)
    $namePattern = '\b[A-Z][a-z]+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\b'
    $matches = [regex]::Matches($Text, $namePattern)
    
    # Filter out common false positives
    $excludeWords = @('United States', 'New York', 'Palm Beach', 'Virgin Islands', 
                      'District Court', 'Southern District', 'Federal Bureau')
    
    $names = $matches | ForEach-Object { $_.Value } | Where-Object { $_ -notin $excludeWords } | Select-Object -Unique
    return $names
}

function Find-VIPs {
    param([string]$Text)
    
    $textLower = $Text.ToLower()
    $foundVIPs = @{}
    
    foreach ($vip in $VIPs) {
        $pattern = [regex]::Escape($vip)
        $matches = [regex]::Matches($textLower, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($matches.Count -gt 0) {
            $foundVIPs[$vip] = $matches.Count
        }
    }
    
    return $foundVIPs
}

function Find-IllegalActivityQuotes {
    param([string]$Text, [string]$Filename)
    
    $quotes = @()
    $lines = $Text -split "`n"
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $lineLower = $line.ToLower()
        
        foreach ($term in $IllegalTerms) {
            if ($lineLower -match [regex]::Escape($term) -and $line.Trim().Length -gt 20) {
                $contextStart = [Math]::Max(0, $i - 1)
                $contextEnd = [Math]::Min($lines.Count, $i + 2)
                $context = ($lines[$contextStart..$contextEnd] -join ' ').Trim()
                
                $quotes += @{
                    file = $Filename
                    term = $term
                    quote = $line.Trim()
                    context = $context.Substring(0, [Math]::Min(500, $context.Length))
                }
                break
            }
        }
    }
    
    return $quotes
}

function Process-Document {
    param([string]$PdfPath)
    
    $filename = Split-Path $PdfPath -Leaf
    Write-Host "Processing: $filename" -ForegroundColor Gray
    
    $result = Extract-TextFromPDF -PdfPath $PdfPath
    if (-not $result) { return }
    
    $text = $result.content
    $metadata = $result.metadata
    
    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host "  No text extracted" -ForegroundColor Yellow
        return
    }
    
    # Extract elements
    $emails = Find-Emails -Text $text
    $phones = Find-PhoneNumbers -Text $text
    $people = Find-People -Text $text
    $vips = Find-VIPs -Text $text
    $illegalQuotes = Find-IllegalActivityQuotes -Text $text -Filename $filename
    
    # Generate summary
    $summary = $text.Substring(0, [Math]::Min(200, $text.Length)).Trim()
    
    # Update counters
    foreach ($person in $people) {
        if ($script:PersonCounts.ContainsKey($person)) {
            $script:PersonCounts[$person]++
        } else {
            $script:PersonCounts[$person] = 1
        }
    }
    
    foreach ($vip in $vips.Keys) {
        if ($script:PersonCounts.ContainsKey($vip)) {
            $script:PersonCounts[$vip] += $vips[$vip]
        } else {
            $script:PersonCounts[$vip] = $vips[$vip]
        }
        
        if (-not $script:VIPMentions.ContainsKey($vip)) {
            $script:VIPMentions[$vip] = @()
        }
        $script:VIPMentions[$vip] += @{
            file = $filename
            count = $vips[$vip]
        }
    }
    
    # Track illegal quotes
    $script:IllegalQuotes += $illegalQuotes
    
    # Document record
    $docRecord = @{
        original_filename = $filename
        path = $PdfPath
        metadata = $metadata
        summary = $summary
        emails = $emails
        phones = $phones
        people_mentioned = $people
        vip_mentions = $vips
        word_count = ($text -split '\s+').Count
        illegal_terms_found = ($IllegalTerms | Where-Object { $text.ToLower() -match [regex]::Escape($_) })
    }
    
    $script:Documents += $docRecord
}

function Generate-MasterDashboard {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# Epstein Documents Analysis Dashboard
*Generated: $timestamp*

## Overview Statistics

- **Total Documents Processed**: $($script:Documents.Count)
- **Unique People Identified**: $($script:PersonCounts.Count)
- **VIP Mentions**: $($script:VIPMentions.Count)
- **Illegal Activity Quotes**: $($script:IllegalQuotes.Count)

## Top 20 Most Mentioned People

| Rank | Name | Mentions |
|------|------|----------|
"@
    
    $topPeople = $script:PersonCounts.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First 20
    $rank = 1
    foreach ($person in $topPeople) {
        $content += "| $rank | $($person.Key) | $($person.Value) |`n"
        $rank++
    }
    
    $content += @"

## VIP Summary

| VIP | Total Mentions | Documents |
|-----|----------------|-----------|
"@
    
    foreach ($vip in ($script:VIPMentions.Keys | Sort-Object)) {
        $mentions = $script:VIPMentions[$vip]
        $total = ($mentions | ForEach-Object { $_.count } | Measure-Object -Sum).Sum
        $docCount = $mentions.Count
        $content += "| $vip | $total | $docCount |`n"
    }
    
    $content += @"

## Quick Links

- [Person Counts Report](person_counts.md)
- [VIP Tracking Report](vip_tracking.md)
- [Illegal Activity Report](illegal_activity.md)
- [Document Index](document_index.md)
- [Term Frequency Report](term_frequency.md)
"@
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "DASHBOARD.md") -Encoding UTF8
}

function Generate-PersonCountsReport {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# Person Mention Counts
*Generated: $timestamp*

Total unique people identified: **$($script:PersonCounts.Count)**

## All People (Sorted by Mention Count)

| Rank | Name | Mentions |
|------|------|----------|
"@
    
    $sortedPeople = $script:PersonCounts.GetEnumerator() | Sort-Object -Property Value -Descending
    $rank = 1
    foreach ($person in $sortedPeople) {
        $content += "| $rank | $($person.Key) | $($person.Value) |`n"
        $rank++
    }
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "person_counts.md") -Encoding UTF8
}

function Generate-VIPReport {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# VIP Tracking Report
*Generated: $timestamp*

## High-Profile Individuals Mentioned

"@
    
    foreach ($vip in ($script:VIPMentions.Keys | Sort-Object)) {
        $mentions = $script:VIPMentions[$vip]
        $total = ($mentions | ForEach-Object { $_.count } | Measure-Object -Sum).Sum
        
        $content += @"

### $($vip.ToUpper())
- **Total Mentions**: $total
- **Documents**: $($mentions.Count)

#### Document List:
"@
        
        foreach ($mention in ($mentions | Sort-Object -Property count -Descending)) {
            $content += "- ``$($mention.file)`` - $($mention.count) mentions`n"
        }
    }
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "vip_tracking.md") -Encoding UTF8
}

function Generate-IllegalActivityReport {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# Illegal Activity References
*Generated: $timestamp*

**Total Quotes Found**: $($script:IllegalQuotes.Count)

## Quotes by Term

"@
    
    # Group by term
    $byTerm = @{}
    foreach ($quote in $script:IllegalQuotes) {
        if (-not $byTerm.ContainsKey($quote.term)) {
            $byTerm[$quote.term] = @()
        }
        $byTerm[$quote.term] += $quote
    }
    
    foreach ($term in ($byTerm.Keys | Sort-Object)) {
        $quotes = $byTerm[$term]
        $content += @"

### $($term.ToUpper()) ($($quotes.Count) references)

"@
        
        foreach ($quote in ($quotes | Select-Object -First 50)) {
            $content += @"

**File**: ``$($quote.file)``

> $($quote.quote)

Context:
``````
$($quote.context)
``````

---

"@
        }
    }
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "illegal_activity.md") -Encoding UTF8
}

function Generate-DocumentIndex {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $content = @"
# Document Index
*Generated: $timestamp*

Total documents: **$($script:Documents.Count)**

## All Documents

"@
    
    $i = 1
    foreach ($doc in $script:Documents) {
        $vipList = if ($doc.vip_mentions.Count -gt 0) { 
            ($doc.vip_mentions.Keys -join ', ') 
        } else { 
            'None' 
        }
        
        $illegalTermsList = if ($doc.illegal_terms_found.Count -gt 0) {
            ($doc.illegal_terms_found | Select-Object -First 5) -join ', '
        } else {
            'None'
        }
        
        $content += @"

### $i. $($doc.original_filename)

- **Summary**: $($doc.summary)
- **People Mentioned**: $($doc.people_mentioned.Count)
- **VIPs**: $vipList
- **Emails Found**: $($doc.emails.Count)
- **Phones Found**: $($doc.phones.Count)
- **Word Count**: $($doc.word_count)
- **Illegal Terms**: $illegalTermsList

---

"@
        $i++
    }
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "document_index.md") -Encoding UTF8
}

function Generate-TermFrequencyReport {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $termCounts = @{}
    foreach ($doc in $script:Documents) {
        foreach ($term in $doc.illegal_terms_found) {
            if ($termCounts.ContainsKey($term)) {
                $termCounts[$term]++
            } else {
                $termCounts[$term] = 1
            }
        }
    }
    
    $content = @"
# Term Frequency Report
*Generated: $timestamp*

## Illegal/Sensitive Terms Frequency

| Rank | Term | Documents |
|------|------|-----------|
"@
    
    $sortedTerms = $termCounts.GetEnumerator() | Sort-Object -Property Value -Descending
    $rank = 1
    foreach ($term in $sortedTerms) {
        $content += "| $rank | $($term.Key) | $($term.Value) |`n"
        $rank++
    }
    
    $content | Out-File -FilePath (Join-Path $AnalyticsPath "term_frequency.md") -Encoding UTF8
}

# Main execution
Write-Host "`nFinding PDF files..." -ForegroundColor Cyan
$pdfFiles = Get-ChildItem -Path $ExtractedPath -Recurse -Filter "*.pdf"
Write-Host "Found $($pdfFiles.Count) PDF files`n" -ForegroundColor Green

Write-Host "=== Processing Documents ===" -ForegroundColor Cyan
foreach ($pdf in $pdfFiles) {
    Process-Document -PdfPath $pdf.FullName
}

Write-Host "`nProcessed $($script:Documents.Count) documents successfully`n" -ForegroundColor Green

Write-Host "=== Generating Reports ===" -ForegroundColor Cyan
Generate-MasterDashboard
Write-Host "  Generated DASHBOARD.md" -ForegroundColor Gray

Generate-PersonCountsReport
Write-Host "  Generated person_counts.md" -ForegroundColor Gray

Generate-VIPReport
Write-Host "  Generated vip_tracking.md" -ForegroundColor Gray

Generate-IllegalActivityReport
Write-Host "  Generated illegal_activity.md" -ForegroundColor Gray

Generate-DocumentIndex
Write-Host "  Generated document_index.md" -ForegroundColor Gray

Generate-TermFrequencyReport
Write-Host "  Generated term_frequency.md" -ForegroundColor Gray

# Save JSON data
Write-Host "`n=== Saving JSON Data ===" -ForegroundColor Cyan
$script:Documents | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $AnalyticsPath "all_documents.json") -Encoding UTF8
$script:PersonCounts | ConvertTo-Json | Out-File -FilePath (Join-Path $AnalyticsPath "person_counts.json") -Encoding UTF8
$script:VIPMentions | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $AnalyticsPath "vip_mentions.json") -Encoding UTF8

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "ANALYSIS COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "`nResults saved to: $AnalyticsPath" -ForegroundColor Yellow
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - DASHBOARD.md (Main overview)" -ForegroundColor White
Write-Host "  - person_counts.md" -ForegroundColor White
Write-Host "  - vip_tracking.md" -ForegroundColor White
Write-Host "  - illegal_activity.md" -ForegroundColor White
Write-Host "  - document_index.md" -ForegroundColor White
Write-Host "  - term_frequency.md" -ForegroundColor White
Write-Host "  - *.json (Raw data files)" -ForegroundColor White
