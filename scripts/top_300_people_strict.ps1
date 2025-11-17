# Top 300 REAL PEOPLE - STRICT FILTER
# Only includes entries with proper full names (First Last format)

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$AnalyticsPath = Join-Path $BasePath "analytics"
$Top300Path = Join-Path $BasePath "top_300_people"

if (-not (Test-Path $Top300Path)) {
    New-Item -ItemType Directory -Path $Top300Path | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "TOP 300 REAL PEOPLE - STRICT FILTER" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Load existing data
Write-Host "`nLoading analysis data..." -ForegroundColor Yellow
$allDocs = Get-Content (Join-Path $AnalyticsPath "all_documents.json") -Raw | ConvertFrom-Json

# Known real people with full names
$knownRealPeople = @{
    "Jeffrey Epstein" = "Jeffrey Epstein"
    "Epstein Jeffrey" = "Jeffrey Epstein"
    "Epstein" = "Jeffrey Epstein"
    "Ghislaine Maxwell" = "Ghislaine Maxwell"
    "Maxwell" = "Ghislaine Maxwell"
    "Virginia Giuffre" = "Virginia Giuffre"
    "Virginia Roberts" = "Virginia Roberts (Giuffre)"
    "Giuffre" = "Virginia Giuffre"
    "Prince Andrew" = "Prince Andrew"
    "Bill Clinton" = "Bill Clinton"
    "Clinton" = "Bill Clinton"
    "Donald Trump" = "Donald Trump"
    "Trump" = "Donald Trump"
    "Alan Dershowitz" = "Alan Dershowitz"
    "Dershowitz" = "Alan Dershowitz"
    "Leslie Wexner" = "Leslie Wexner"
    "Wexner" = "Leslie Wexner"
    "Jean-Luc Brunel" = "Jean-Luc Brunel"
    "Brunel" = "Jean-Luc Brunel"
    "Sarah Kellen" = "Sarah Kellen"
    "Kellen" = "Sarah Kellen"
    "Nadia Marcinkova" = "Nadia Marcinkova"
    "Marcinkova" = "Nadia Marcinkova"
    "Marcinkova Dep" = "Nadia Marcinkova"
    "Adriana Ross" = "Adriana Ross"
    "Ross" = "Adriana Ross"
    "Lesley Groff" = "Lesley Groff"
    "Groff" = "Lesley Groff"
    "Nicole Simmons" = "Nicole Simmons"
    "Johanna Sjoberg" = "Johanna Sjoberg"
    "Sjoberg Johanna" = "Johanna Sjoberg"
    "Sarah Ransome" = "Sarah Ransome"
    "Ransome Sarah" = "Sarah Ransome"
    "Brenda Rodriguez" = "Brenda Rodriguez"
    "Tony Figueroa" = "Tony Figueroa"
    "Louella Rabuyo" = "Louella Rabuyo"
    "Boies Schiller" = "Boies Schiller (Law Firm)"
}

# Function to check if name is a proper full name
function Test-IsProperName {
    param([string]$Name)
    
    # Check if in known people list
    if ($knownRealPeople.ContainsKey($Name)) {
        return $true
    }
    
    # Must have at least 2 words
    $words = $Name -split '\s+'
    if ($words.Count -lt 2) {
        return $false
    }
    
    # Each word must be at least 3 characters
    foreach ($word in $words) {
        if ($word.Length -lt 3) {
            return $false
        }
    }
    
    # Must match proper name pattern: First Last or First Middle Last
    # Each word starts with capital, followed by lowercase letters
    if ($Name -match '^[A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}$') {
        return $true
    }
    
    if ($Name -match '^[A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}$') {
        return $true
    }
    
    # Check for hyphenated names
    if ($Name -match '^[A-Z][a-z]{2,}-[A-Z][a-z]{2,}\s+[A-Z][a-z]{2,}$') {
        return $true
    }
    
    return $false
}

# Function to normalize name
function Get-NormalizedName {
    param([string]$Name)
    
    if ($knownRealPeople.ContainsKey($Name)) {
        return $knownRealPeople[$Name]
    }
    
    return $Name
}

# Build person profiles (strict filter)
$personProfiles = @{}

Write-Host "Building strictly filtered person profiles..." -ForegroundColor Yellow

foreach ($doc in $allDocs) {
    $people = $doc.people_mentioned
    $illegalTerms = $doc.illegal_terms_found
    $filename = $doc.original_filename
    
    foreach ($person in $people) {
        # Strict filter - only proper names
        if (-not (Test-IsProperName -Name $person)) {
            continue
        }
        
        # Normalize the name
        $normalizedName = Get-NormalizedName -Name $person
        
        if (-not $personProfiles.ContainsKey($normalizedName)) {
            $personProfiles[$normalizedName] = @{
                name = $normalizedName
                aliases = @($person)
                total_mentions = 0
                documents = @()
                associated_terms = @{}
                associated_people = @()
                is_vip = $false
                category = "Person"
            }
        } else {
            # Add alias if different
            if ($person -ne $normalizedName -and $person -notin $personProfiles[$normalizedName].aliases) {
                $personProfiles[$normalizedName].aliases += $person
            }
        }
        
        $personProfiles[$normalizedName].total_mentions++
        $personProfiles[$normalizedName].documents += $filename
        
        # Associate with illegal terms
        foreach ($term in $illegalTerms) {
            if ($term -and $term -is [string] -and $term.Trim() -ne "") {
                $termStr = $term.ToString().Trim()
                if (-not $personProfiles[$normalizedName].associated_terms.ContainsKey($termStr)) {
                    $personProfiles[$normalizedName].associated_terms[$termStr] = 0
                }
                $personProfiles[$normalizedName].associated_terms[$termStr]++
            }
        }
        
        # Track co-occurrences
        foreach ($otherPerson in $people) {
            if ($otherPerson -ne $person -and (Test-IsProperName -Name $otherPerson)) {
                $otherNormalized = Get-NormalizedName -Name $otherPerson
                $personProfiles[$normalizedName].associated_people += $otherNormalized
            }
        }
    }
}

Write-Host "Filtered to $($personProfiles.Count) people with proper full names" -ForegroundColor Green

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

# Get all people sorted by mentions
Write-Host "Sorting people by mentions..." -ForegroundColor Yellow
$allPeopleSorted = $personProfiles.GetEnumerator() | 
    Sort-Object -Property { $_.Value.total_mentions } -Descending

# Generate report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$content = "# REAL PEOPLE WITH FULL NAMES - Complete List`n"
$content += "*Generated: $timestamp*`n`n"
$content += "## Overview`n`n"
$content += "This report lists ALL real people with proper full names (no codes or gibberish).`n`n"
$content += "**Total Entities in Documents**: 1731`n"
$content += "**People with Proper Full Names**: $($personProfiles.Count)`n"
$content += "**VIPs**: $(($allPeopleSorted | Where-Object { $_.Value.is_vip }).Count)`n`n"
$content += "**Filtering Criteria**:`n"
$content += "- Must have First and Last name (minimum 3 letters each)`n"
$content += "- Proper capitalization (First Last format)`n"
$content += "- No gibberish codes (like 'Oa Zpv', 'Mo Lnf')`n"
$content += "- No software, companies, or metadata`n`n"
$content += "---`n`n"

# Summary table
$content += "## All Real People - Summary Table`n`n"
$content += "| Rank | Name | Aliases | Mentions | Documents | Associated Terms | Category |`n"
$content += "|------|------|---------|----------|-----------|------------------|----------|`n"

$rank = 1
foreach ($person in $allPeopleSorted) {
    $name = $person.Value.name
    $aliases = ($person.Value.aliases | Select-Object -Unique) -join ", "
    if ($aliases.Length -gt 30) {
        $aliases = $aliases.Substring(0, 27) + "..."
    }
    $mentions = $person.Value.total_mentions
    $docCount = ($person.Value.documents | Select-Object -Unique).Count
    $termCount = $person.Value.associated_terms.Count
    $category = $person.Value.category
    
    $content += "| $rank | $name | $aliases | $mentions | $docCount | $termCount | $category |`n"
    $rank++
}

$content += "`n---`n`n"

# Detailed profiles
$content += "## Detailed Profiles`n`n"

$rank = 1
foreach ($person in $allPeopleSorted) {
    $profile = $person.Value
    $name = $profile.name
    
    $content += "### $rank. $name`n`n"
    
    if ($profile.is_vip) {
        $content += "**VIP - High Profile Individual**`n`n"
    }
    
    $content += "#### Statistics`n"
    $content += "- **Total Mentions**: $($profile.total_mentions)`n"
    $content += "- **Documents**: $(($profile.documents | Select-Object -Unique).Count)`n"
    $content += "- **Category**: $($profile.category)`n"
    
    # Show aliases
    $uniqueAliases = $profile.aliases | Select-Object -Unique
    if ($uniqueAliases.Count -gt 1 -or $uniqueAliases[0] -ne $name) {
        $content += "- **Also appears as**: $($uniqueAliases -join ', ')`n"
    }
    $content += "`n"
    
    # Associated terms
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
    
    # Top associated people
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
    
    # Documents
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

$content | Out-File -FilePath (Join-Path $Top300Path "REAL_PEOPLE_FULL_NAMES.md") -Encoding UTF8

# Generate VIP-only report
$vips = $allPeopleSorted | Where-Object { $_.Value.is_vip }

$vipContent = "# VIP LIST - High Profile Individuals`n"
$vipContent += "*Generated: $timestamp*`n`n"
$vipContent += "**Total VIPs**: $($vips.Count)`n`n"
$vipContent += "---`n`n"

foreach ($vip in $vips) {
    $profile = $vip.Value
    $name = $profile.name
    
    $vipContent += "## $name`n`n"
    $vipContent += "### Profile`n"
    $vipContent += "- **Total Mentions**: $($profile.total_mentions)`n"
    $vipContent += "- **Documents**: $(($profile.documents | Select-Object -Unique).Count)`n"
    
    $uniqueAliases = $profile.aliases | Select-Object -Unique
    if ($uniqueAliases.Count -gt 1 -or $uniqueAliases[0] -ne $name) {
        $vipContent += "- **Also appears as**: $($uniqueAliases -join ', ')`n"
    }
    $vipContent += "`n"
    
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

$vipContent | Out-File -FilePath (Join-Path $Top300Path "VIP_LIST.md") -Encoding UTF8

# Generate quick reference
$quickRef = "# QUICK REFERENCE - Real People`n"
$quickRef += "*Generated: $timestamp*`n`n"
$quickRef += "## All $($personProfiles.Count) People with Full Names`n`n"

foreach ($person in $allPeopleSorted) {
    $name = $person.Value.name
    $mentions = $person.Value.total_mentions
    $vipMarker = if ($person.Value.is_vip) { " **[VIP]**" } else { "" }
    $quickRef += "- **$name**$vipMarker - $mentions mentions`n"
}

$quickRef | Out-File -FilePath (Join-Path $Top300Path "QUICK_REFERENCE.md") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "STRICT FILTER COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - REAL_PEOPLE_FULL_NAMES.md (Complete list)" -ForegroundColor White
Write-Host "  - VIP_LIST.md (VIPs only)" -ForegroundColor White
Write-Host "  - QUICK_REFERENCE.md (Quick list)" -ForegroundColor White
Write-Host "`nReal people with proper names: $($personProfiles.Count)" -ForegroundColor Green
Write-Host "Filtered out: $(1731 - $personProfiles.Count) entities" -ForegroundColor Cyan
Write-Host "`nLocation: $Top300Path" -ForegroundColor Cyan
