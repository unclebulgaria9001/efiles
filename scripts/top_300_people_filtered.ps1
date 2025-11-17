# Top 300 REAL PEOPLE Analysis - Filtered
# Excludes companies, software, and metadata artifacts

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$AnalyticsPath = Join-Path $BasePath "analytics"
$Top300Path = Join-Path $BasePath "top_300_people"

if (-not (Test-Path $Top300Path)) {
    New-Item -ItemType Directory -Path $Top300Path | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "TOP 300 REAL PEOPLE ANALYSIS (FILTERED)" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Load existing data
Write-Host "`nLoading analysis data..." -ForegroundColor Yellow
$allDocs = Get-Content (Join-Path $AnalyticsPath "all_documents.json") -Raw | ConvertFrom-Json

# Exclusion lists - companies, software, metadata
$excludePatterns = @(
    # Software and fonts
    "Liberation Sans", "Times New Roman", "Courier New", "Microsoft Word", 
    "Microsoft Outlook", "Adobe Acrobat", "Acrobat Distiller", "Aspose Ltd",
    "Paper Capture Plug",
    
    # Court/legal metadata
    "United States Courts", "Administrative Office", "Southern District",
    "District Court", "Federal Bureau",
    
    # Document metadata
    "Memo Style", "Depo Limit", "Discovery Requests", "Second Set",
    "Defts Motn", "Windows User", "Extend Discovery",
    
    # Gibberish/codes (2-3 letter combinations)
    "^[A-Z][a-z] [A-Z][a-z]$",  # Like "Ju Nd", "Hb Kq"
    "^[A-Z][a-z][a-z]? [A-Z][a-z]$",  # Like "Pe Qa"
    
    # Empty or single character
    "^$", "^ $", "^  $"
)

# Known real people (to ensure they're included)
$knownRealPeople = @(
    "Jeffrey Epstein", "Epstein Jeffrey", "Epstein",
    "Ghislaine Maxwell", "Maxwell",
    "Virginia Giuffre", "Virginia Roberts", "Giuffre",
    "Prince Andrew", "Andrew",
    "Bill Clinton", "Clinton",
    "Donald Trump", "Trump",
    "Alan Dershowitz", "Dershowitz",
    "Leslie Wexner", "Wexner",
    "Jean-Luc Brunel", "Brunel",
    "Sarah Kellen", "Kellen",
    "Nadia Marcinkova", "Marcinkova",
    "Adriana Ross", "Ross",
    "Lesley Groff", "Groff",
    "Nicole Simmons",
    "Johanna Sjoberg", "Sjoberg Johanna",
    "Sarah Ransome", "Ransome Sarah",
    "Brenda Rodriguez"
)

# Function to check if name is likely a real person
function Test-IsRealPerson {
    param([string]$Name)
    
    # Check if in known real people list
    foreach ($known in $knownRealPeople) {
        if ($Name -eq $known) {
            return $true
        }
    }
    
    # Check against exclusion patterns
    foreach ($pattern in $excludePatterns) {
        if ($Name -match $pattern) {
            return $false
        }
    }
    
    # Filter out obvious non-people patterns
    # Single word that's all caps (likely acronym)
    if ($Name -match "^[A-Z]+$" -and $Name.Length -lt 5) {
        return $false
    }
    
    # Contains numbers
    if ($Name -match "\d") {
        return $false
    }
    
    # Too short (less than 5 characters total)
    if ($Name.Length -lt 5) {
        return $false
    }
    
    # Contains common software/company words
    $companyWords = @("Inc", "Ltd", "LLC", "Corp", "Company", "Software", "Systems", "Office", "Bureau")
    foreach ($word in $companyWords) {
        if ($Name -match $word) {
            return $false
        }
    }
    
    # If it has a proper name structure (First Last or First Middle Last), likely real
    if ($Name -match "^[A-Z][a-z]+ [A-Z][a-z]+$") {
        return $true
    }
    
    if ($Name -match "^[A-Z][a-z]+ [A-Z][a-z]+ [A-Z][a-z]+$") {
        return $true
    }
    
    # Default: if we're not sure, exclude it (conservative approach)
    return $false
}

# Build person profiles (filtered)
$personProfiles = @{}

Write-Host "Building filtered person profiles..." -ForegroundColor Yellow

foreach ($doc in $allDocs) {
    $people = $doc.people_mentioned
    $illegalTerms = $doc.illegal_terms_found
    $filename = $doc.original_filename
    
    foreach ($person in $people) {
        # Filter out non-people
        if (-not (Test-IsRealPerson -Name $person)) {
            continue
        }
        
        if (-not $personProfiles.ContainsKey($person)) {
            $personProfiles[$person] = @{
                name = $person
                total_mentions = 0
                documents = @()
                associated_terms = @{}
                associated_people = @()
                is_vip = $false
                category = "Person"
            }
        }
        
        $personProfiles[$person].total_mentions++
        $personProfiles[$person].documents += $filename
        
        # Associate with illegal terms
        foreach ($term in $illegalTerms) {
            if ($term -and $term.Trim() -ne "") {
                if (-not $personProfiles[$person].associated_terms.ContainsKey($term)) {
                    $personProfiles[$person].associated_terms[$term] = 0
                }
                $personProfiles[$person].associated_terms[$term]++
            }
        }
        
        # Track co-occurrences (only with other real people)
        foreach ($otherPerson in $people) {
            if ($otherPerson -ne $person -and (Test-IsRealPerson -Name $otherPerson)) {
                $personProfiles[$person].associated_people += $otherPerson
            }
        }
    }
}

Write-Host "Filtered to $($personProfiles.Count) real people (from 1731 total)" -ForegroundColor Green

# Mark VIPs
$vipNames = @("epstein", "maxwell", "giuffre", "virginia", "trump", "clinton", 
              "prince andrew", "andrew", "dershowitz", "wexner", "brunel",
              "kellen", "marcinkova", "ross", "groff")

foreach ($person in $personProfiles.Keys) {
    foreach ($vip in $vipNames) {
        if ($person.ToLower() -match $vip) {
            $personProfiles[$person].is_vip = $true
            $personProfiles[$person].category = "VIP"
            break
        }
    }
}

# Get top 300 real people
Write-Host "Selecting top 300 real people..." -ForegroundColor Yellow
$top300 = $personProfiles.GetEnumerator() | 
    Sort-Object -Property { $_.Value.total_mentions } -Descending | 
    Select-Object -First 300

# Generate report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$content = "# TOP 300 REAL PEOPLE - Filtered Analysis`n"
$content += "*Generated: $timestamp*`n`n"
$content += "## Overview`n`n"
$content += "This report profiles the top 300 real people (excluding companies, software, and metadata).`n`n"
$content += "**Total Entities Analyzed**: 1731`n"
$content += "**Real People Identified**: $($personProfiles.Count)`n"
$content += "**Top 300 Selected**: 300`n"
$content += "**VIPs in Top 300**: $(($top300 | Where-Object { $_.Value.is_vip }).Count)`n`n"
$content += "**Filtered Out**: Companies, software names, court metadata, gibberish codes`n`n"
$content += "---`n`n"

# Summary table
$content += "## Top 300 Real People - Summary Table`n`n"
$content += "| Rank | Name | Mentions | Documents | Associated Terms | Category |`n"
$content += "|------|------|----------|-----------|------------------|----------|`n"

$rank = 1
foreach ($person in $top300) {
    $name = $person.Value.name
    $mentions = $person.Value.total_mentions
    $docCount = ($person.Value.documents | Select-Object -Unique).Count
    $termCount = $person.Value.associated_terms.Count
    $category = $person.Value.category
    
    $content += "| $rank | $name | $mentions | $docCount | $termCount | $category |`n"
    $rank++
}

$content += "`n---`n`n"

# Detailed profiles
$content += "## Detailed Profiles`n`n"

$rank = 1
foreach ($person in $top300) {
    $profile = $person.Value
    $name = $profile.name
    
    $content += "### $rank. $name`n`n"
    
    if ($profile.is_vip) {
        $content += "**VIP - High Profile Individual**`n`n"
    }
    
    $content += "#### Statistics`n"
    $content += "- **Total Mentions**: $($profile.total_mentions)`n"
    $content += "- **Documents**: $(($profile.documents | Select-Object -Unique).Count)`n"
    $content += "- **Category**: $($profile.category)`n`n"
    
    # Associated terms (filter out empty)
    $validTerms = $profile.associated_terms.GetEnumerator() | Where-Object { $_.Key -and $_.Key.Trim() -ne "" }
    if ($validTerms) {
        $content += "#### Associated with Illegal/Sensitive Terms`n`n"
        $content += "| Term | Co-occurrences |`n"
        $content += "|------|----------------|`n"
        
        $sortedTerms = $validTerms | Sort-Object -Property Value -Descending
        foreach ($term in $sortedTerms) {
            $content += "| $($term.Key) | $($term.Value) |`n"
        }
        $content += "`n"
    }
    
    # Top associated people (filter and deduplicate)
    if ($profile.associated_people.Count -gt 0) {
        $topAssociates = $profile.associated_people | 
            Group-Object | 
            Sort-Object -Property Count -Descending | 
            Select-Object -First 10
        
        if ($topAssociates) {
            $content += "#### Most Frequently Mentioned With`n`n"
            foreach ($assoc in $topAssociates) {
                $content += "- **$($assoc.Name)** ($($assoc.Count) times)`n"
            }
            $content += "`n"
        }
    }
    
    # Documents (show first 20)
    $uniqueDocs = $profile.documents | Select-Object -Unique | Select-Object -First 20
    $content += "#### Documents Mentioning $name`n`n"
    foreach ($doc in $uniqueDocs) {
        $content += "- ````$doc````  `n"
    }
    
    $totalDocs = ($profile.documents | Select-Object -Unique).Count
    if ($totalDocs -gt 20) {
        $remaining = $totalDocs - 20
        $content += "`n*... and $remaining more documents*`n"
    }
    
    $content += "`n---`n`n"
    $rank++
}

$content | Out-File -FilePath (Join-Path $Top300Path "TOP_300_REAL_PEOPLE.md") -Encoding UTF8

# Generate VIP subset
$vips = $top300 | Where-Object { $_.Value.is_vip }

$vipContent = "# VIP SUBSET - High Profile Individuals (Filtered)`n"
$vipContent += "*Generated: $timestamp*`n`n"
$vipContent += "**Total VIPs in Top 300**: $($vips.Count)`n`n"
$vipContent += "---`n`n"

foreach ($vip in $vips) {
    $profile = $vip.Value
    $name = $profile.name
    
    $vipContent += "## $name`n`n"
    $vipContent += "### Profile`n"
    $vipContent += "- **Total Mentions**: $($profile.total_mentions)`n"
    $vipContent += "- **Documents**: $(($profile.documents | Select-Object -Unique).Count)`n`n"
    
    $validTerms = $profile.associated_terms.GetEnumerator() | Where-Object { $_.Key -and $_.Key.Trim() -ne "" }
    if ($validTerms) {
        $vipContent += "### Associated Terms`n`n"
        $sortedTerms = $validTerms | Sort-Object -Property Value -Descending
        foreach ($term in $sortedTerms) {
            $vipContent += "- **$($term.Key)**: $($term.Value) co-occurrences`n"
        }
        $vipContent += "`n"
    }
    
    $vipContent += "---`n`n"
}

$vipContent | Out-File -FilePath (Join-Path $Top300Path "VIP_SUBSET_FILTERED.md") -Encoding UTF8

# Generate statistics
$statsContent = "# TOP 300 REAL PEOPLE - STATISTICS (Filtered)`n"
$statsContent += "*Generated: $timestamp*`n`n"

$statsContent += "## Filtering Results`n`n"
$statsContent += "- **Total Entities Found**: 1731`n"
$statsContent += "- **Filtered Out**: $(1731 - $personProfiles.Count) (companies, software, metadata)`n"
$statsContent += "- **Real People Identified**: $($personProfiles.Count)`n"
$statsContent += "- **Top 300 Selected**: 300`n"
$statsContent += "- **VIPs in Top 300**: $(($top300 | Where-Object { $_.Value.is_vip }).Count)`n`n"

$statsContent += "## What Was Filtered Out`n`n"
$statsContent += "- Software names (Adobe, Microsoft, etc.)`n"
$statsContent += "- Font names (Liberation Sans, Times New Roman, etc.)`n"
$statsContent += "- Court metadata (United States Courts, Administrative Office, etc.)`n"
$statsContent += "- Document codes (2-3 letter gibberish like 'Ju Nd', 'Hb Kq')`n"
$statsContent += "- Company names (Ltd, Inc, Corp, etc.)`n`n"

$statsContent += "## Mention Distribution`n`n"
$mentionRanges = @(
    @{min=1; max=5; label="1-5 mentions"},
    @{min=6; max=20; label="6-20 mentions"},
    @{min=21; max=50; label="21-50 mentions"},
    @{min=51; max=100; label="51-100 mentions"},
    @{min=101; max=999999; label="100+ mentions"}
)

foreach ($range in $mentionRanges) {
    $count = ($top300 | Where-Object { 
        $_.Value.total_mentions -ge $range.min -and $_.Value.total_mentions -le $range.max 
    }).Count
    $statsContent += "- **$($range.label)**: $count people`n"
}

$statsContent += "`n## Term Association Statistics`n`n"
$peopleWithTerms = ($top300 | Where-Object { $_.Value.associated_terms.Count -gt 0 }).Count
$statsContent += "- **People associated with illegal/sensitive terms**: $peopleWithTerms`n"
$statsContent += "- **People with no term associations**: $(300 - $peopleWithTerms)`n"

$statsContent | Out-File -FilePath (Join-Path $Top300Path "STATISTICS_FILTERED.md") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "FILTERED ANALYSIS COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - TOP_300_REAL_PEOPLE.md (Filtered profiles)" -ForegroundColor White
Write-Host "  - VIP_SUBSET_FILTERED.md (VIPs only)" -ForegroundColor White
Write-Host "  - STATISTICS_FILTERED.md (Stats)" -ForegroundColor White
Write-Host "`nFiltered out: $(1731 - $personProfiles.Count) non-people entities" -ForegroundColor Cyan
Write-Host "Real people identified: $($personProfiles.Count)" -ForegroundColor Green
Write-Host "`nLocation: $Top300Path" -ForegroundColor Cyan
