# Top 300 People Analysis - Detailed Profiles
# Identifies top 300 people and what they have done

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$AnalyticsPath = Join-Path $BasePath "analytics"
$InvestigationPath = Join-Path $BasePath "investigation"
$Top300Path = Join-Path $BasePath "top_300_people"

# Create output directory
if (-not (Test-Path $Top300Path)) {
    New-Item -ItemType Directory -Path $Top300Path | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "TOP 300 PEOPLE ANALYSIS" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Load existing data
Write-Host "`nLoading analysis data..." -ForegroundColor Yellow
$allDocs = Get-Content (Join-Path $AnalyticsPath "all_documents.json") -Raw | ConvertFrom-Json
$personCounts = Get-Content (Join-Path $AnalyticsPath "person_counts.json") -Raw | ConvertFrom-Json

# Build comprehensive person profiles
$personProfiles = @{}

Write-Host "Building person profiles..." -ForegroundColor Yellow

foreach ($doc in $allDocs) {
    $people = $doc.people_mentioned
    $vips = $doc.vip_mentions
    $illegalTerms = $doc.illegal_terms_found
    $filename = $doc.original_filename
    
    # Process each person
    foreach ($person in $people) {
        if (-not $personProfiles.ContainsKey($person)) {
            $personProfiles[$person] = @{
                name = $person
                total_mentions = 0
                documents = @()
                associated_terms = @{}
                associated_people = @()
                contexts = @()
                is_vip = $false
                category = "Unknown"
            }
        }
        
        $personProfiles[$person].total_mentions++
        $personProfiles[$person].documents += $filename
        
        # Associate with illegal terms
        foreach ($term in $illegalTerms) {
            if (-not $personProfiles[$person].associated_terms.ContainsKey($term)) {
                $personProfiles[$person].associated_terms[$term] = 0
            }
            $personProfiles[$person].associated_terms[$term]++
        }
        
        # Track co-occurrences
        foreach ($otherPerson in $people) {
            if ($otherPerson -ne $person) {
                $personProfiles[$person].associated_people += $otherPerson
            }
        }
    }
}

# Mark VIPs
$vipNames = @("epstein", "maxwell", "giuffre", "virginia giuffre", "ghislaine maxwell", 
              "trump", "clinton", "prince andrew", "bill gates", "dershowitz")

foreach ($person in $personProfiles.Keys) {
    foreach ($vip in $vipNames) {
        if ($person.ToLower() -match $vip) {
            $personProfiles[$person].is_vip = $true
            $personProfiles[$person].category = "VIP"
            break
        }
    }
}

# Get top 300
Write-Host "Selecting top 300 people..." -ForegroundColor Yellow
$top300 = $personProfiles.GetEnumerator() | 
    Sort-Object -Property { $_.Value.total_mentions } -Descending | 
    Select-Object -First 300

# Generate comprehensive report
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$content = "# TOP 300 PEOPLE - Comprehensive Analysis`n"
$content += "*Generated: $timestamp*`n`n"
$content += "## Overview`n`n"
$content += "This report profiles the top 300 most-mentioned individuals in the Epstein documents.`n`n"
$content += "**Total People Analyzed**: $($personProfiles.Count)`n"
$content += "**Top 300 Selected**: 300`n"
$content += "**VIPs in Top 300**: $(($top300 | Where-Object { $_.Value.is_vip }).Count)`n`n"
$content += "---`n`n"

# Summary table
$content += "## Top 300 Summary Table`n`n"
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
    
    # Associated terms
    if ($profile.associated_terms.Count -gt 0) {
        $content += "#### Associated with Illegal/Sensitive Terms`n`n"
        $content += "| Term | Co-occurrences |`n"
        $content += "|------|----------------|`n"
        
        $sortedTerms = $profile.associated_terms.GetEnumerator() | Sort-Object -Property Value -Descending
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
        
        $content += "#### Most Frequently Mentioned With`n`n"
        foreach ($assoc in $topAssociates) {
            $content += "- **$($assoc.Name)** ($($assoc.Count) times)`n"
        }
        $content += "`n"
    }
    
    # Documents
    $uniqueDocs = $profile.documents | Select-Object -Unique | Select-Object -First 20
    $content += "#### Documents Mentioning $name`n`n"
    foreach ($doc in $uniqueDocs) {
        $content += "- ````$doc````  `n"
    }
    
    if (($profile.documents | Select-Object -Unique).Count -gt 20) {
        $remaining = ($profile.documents | Select-Object -Unique).Count - 20
        $content += "`n*... and $remaining more documents*`n"
    }
    
    $content += "`n---`n`n"
    $rank++
}

$content | Out-File -FilePath (Join-Path $Top300Path "TOP_300_PEOPLE.md") -Encoding UTF8

# Generate VIP subset
$vips = $top300 | Where-Object { $_.Value.is_vip }

$vipContent = "# VIP SUBSET - High Profile Individuals`n"
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
    
    if ($profile.associated_terms.Count -gt 0) {
        $vipContent += "### Associated Terms`n`n"
        $sortedTerms = $profile.associated_terms.GetEnumerator() | Sort-Object -Property Value -Descending
        foreach ($term in $sortedTerms) {
            $vipContent += "- **$($term.Key)**: $($term.Value) co-occurrences`n"
        }
        $vipContent += "`n"
    }
    
    $vipContent += "---`n`n"
}

$vipContent | Out-File -FilePath (Join-Path $Top300Path "VIP_SUBSET.md") -Encoding UTF8

# Generate statistics summary
$statsContent = "# TOP 300 STATISTICS`n"
$statsContent += "*Generated: $timestamp*`n`n"

$statsContent += "## Category Breakdown`n`n"
$categories = $top300 | Group-Object -Property { $_.Value.category }
foreach ($cat in $categories) {
    $statsContent += "- **$($cat.Name)**: $($cat.Count) people`n"
}

$statsContent += "`n## Mention Distribution`n`n"
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

$statsContent | Out-File -FilePath (Join-Path $Top300Path "STATISTICS.md") -Encoding UTF8

# Save JSON data
$top300Data = @()
foreach ($person in $top300) {
    $top300Data += @{
        rank = $top300Data.Count + 1
        name = $person.Value.name
        mentions = $person.Value.total_mentions
        documents = ($person.Value.documents | Select-Object -Unique)
        associated_terms = $person.Value.associated_terms
        is_vip = $person.Value.is_vip
        category = $person.Value.category
    }
}

$top300Data | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $Top300Path "top_300_data.json") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "TOP 300 ANALYSIS COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - TOP_300_PEOPLE.md (Complete profiles)" -ForegroundColor White
Write-Host "  - VIP_SUBSET.md (High-profile individuals)" -ForegroundColor White
Write-Host "  - STATISTICS.md (Statistical breakdown)" -ForegroundColor White
Write-Host "  - top_300_data.json (Raw data)" -ForegroundColor White
Write-Host "`nLocation: $Top300Path" -ForegroundColor Cyan
