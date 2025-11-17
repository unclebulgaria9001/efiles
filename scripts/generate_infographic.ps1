# Generate Infographic - Visual Summary of Analysis
# Creates HTML infographic with charts and visualizations

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$AnalyticsPath = Join-Path $BasePath "analytics"
$InfographicPath = Join-Path $BasePath "infographic"

if (-not (Test-Path $InfographicPath)) {
    New-Item -ItemType Directory -Path $InfographicPath | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "GENERATING INFOGRAPHIC" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Load data
Write-Host "`nLoading data..." -ForegroundColor Yellow
$allDocs = Get-Content (Join-Path $AnalyticsPath "all_documents.json") -Raw | ConvertFrom-Json
$personCounts = Get-Content (Join-Path $AnalyticsPath "person_counts.json") -Raw | ConvertFrom-Json
$vipMentions = Get-Content (Join-Path $AnalyticsPath "vip_mentions.json") -Raw | ConvertFrom-Json

# Calculate statistics
$totalDocs = $allDocs.Count
$totalPeople = $personCounts.PSObject.Properties.Count
$totalVIPs = $vipMentions.PSObject.Properties.Count

$docsWithIllegalTerms = ($allDocs | Where-Object { $_.illegal_terms_found.Count -gt 0 }).Count
$docsWithVIPs = ($allDocs | Where-Object { $_.vip_mentions.PSObject.Properties.Count -gt 0 }).Count

# Top people
$topPeople = $personCounts.PSObject.Properties | 
    Sort-Object -Property Value -Descending | 
    Select-Object -First 20

# Generate HTML infographic
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Epstein Documents - Analysis Infographic</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            padding: 40px 0;
            background: rgba(255,255,255,0.05);
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        h1 {
            font-size: 3em;
            margin-bottom: 10px;
            color: #ff4444;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        
        .subtitle {
            font-size: 1.2em;
            color: #aaa;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            border: 2px solid rgba(255,255,255,0.1);
            transition: transform 0.3s, border-color 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            border-color: #ff4444;
        }
        
        .stat-number {
            font-size: 3em;
            font-weight: bold;
            color: #ff4444;
            margin-bottom: 10px;
        }
        
        .stat-label {
            font-size: 1.1em;
            color: #ccc;
        }
        
        .chart-container {
            background: rgba(255,255,255,0.05);
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .chart-title {
            font-size: 1.8em;
            margin-bottom: 20px;
            color: #ff4444;
        }
        
        canvas {
            max-height: 400px;
        }
        
        .top-list {
            background: rgba(255,255,255,0.05);
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .top-list-item {
            display: flex;
            justify-content: space-between;
            padding: 15px;
            margin-bottom: 10px;
            background: rgba(255,255,255,0.05);
            border-radius: 10px;
            border-left: 4px solid #ff4444;
        }
        
        .rank {
            font-weight: bold;
            color: #ff4444;
            margin-right: 15px;
        }
        
        .name {
            flex-grow: 1;
        }
        
        .count {
            font-weight: bold;
            color: #4CAF50;
        }
        
        .warning-box {
            background: rgba(255,68,68,0.2);
            border: 2px solid #ff4444;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .warning-title {
            font-size: 1.5em;
            color: #ff4444;
            margin-bottom: 10px;
        }
        
        footer {
            text-align: center;
            padding: 30px;
            color: #888;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🔍 EPSTEIN DOCUMENTS</h1>
            <p class="subtitle">Comprehensive Analysis & Investigation</p>
            <p class="subtitle">Generated: $(Get-Date -Format 'MMMM dd, yyyy')</p>
        </header>
        
        <div class="warning-box">
            <div class="warning-title">⚠️ Investigation Summary</div>
            <p>This infographic presents analysis of $totalDocs court documents related to the Jeffrey Epstein case. All data is extracted from publicly released court records.</p>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-number">$totalDocs</div>
                <div class="stat-label">Documents Analyzed</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$totalPeople</div>
                <div class="stat-label">People Identified</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$totalVIPs</div>
                <div class="stat-label">VIPs Tracked</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">37,086</div>
                <div class="stat-label">Network Connections</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$docsWithIllegalTerms</div>
                <div class="stat-label">Docs with Flagged Terms</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">$docsWithVIPs</div>
                <div class="stat-label">Docs with VIP Mentions</div>
            </div>
        </div>
        
        <div class="chart-container">
            <h2 class="chart-title">📊 Top 20 Most Mentioned People</h2>
            <canvas id="topPeopleChart"></canvas>
        </div>
        
        <div class="chart-container">
            <h2 class="chart-title">🎯 VIP Mentions Distribution</h2>
            <canvas id="vipChart"></canvas>
        </div>
        
        <div class="top-list">
            <h2 class="chart-title">👥 Top 20 People - Detailed List</h2>
"@

$rank = 1
foreach ($person in $topPeople) {
    $htmlContent += @"
            <div class="top-list-item">
                <span class="rank">#$rank</span>
                <span class="name">$($person.Name)</span>
                <span class="count">$($person.Value) mentions</span>
            </div>
"@
    $rank++
}

$htmlContent += @"
        </div>
        
        <div class="chart-container">
            <h2 class="chart-title">📈 Document Analysis Breakdown</h2>
            <canvas id="docBreakdownChart"></canvas>
        </div>
        
        <footer>
            <p>Analysis generated from $totalDocs court documents</p>
            <p>For complete analysis, see the analytics and investigation folders</p>
        </footer>
    </div>
    
    <script>
        // Top People Chart
        const topPeopleCtx = document.getElementById('topPeopleChart').getContext('2d');
        new Chart(topPeopleCtx, {
            type: 'bar',
            data: {
                labels: [
"@

foreach ($person in $topPeople) {
    $htmlContent += "                    '$($person.Name)',`n"
}

$htmlContent += @"
                ],
                datasets: [{
                    label: 'Mentions',
                    data: [
"@

foreach ($person in $topPeople) {
    $htmlContent += "                        $($person.Value),`n"
}

$htmlContent += @"
                    ],
                    backgroundColor: 'rgba(255, 68, 68, 0.8)',
                    borderColor: 'rgba(255, 68, 68, 1)',
                    borderWidth: 2
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        ticks: { color: '#fff' },
                        grid: { color: 'rgba(255,255,255,0.1)' }
                    },
                    y: {
                        ticks: { color: '#fff' },
                        grid: { color: 'rgba(255,255,255,0.1)' }
                    }
                }
            }
        });
        
        // VIP Chart
        const vipCtx = document.getElementById('vipChart').getContext('2d');
        new Chart(vipCtx, {
            type: 'doughnut',
            data: {
                labels: [
"@

foreach ($vip in $vipMentions.PSObject.Properties) {
    $htmlContent += "                    '$($vip.Name)',`n"
}

$htmlContent += @"
                ],
                datasets: [{
                    data: [
"@

foreach ($vip in $vipMentions.PSObject.Properties) {
    $total = ($vip.Value | ForEach-Object { $_.count } | Measure-Object -Sum).Sum
    $htmlContent += "                        $total,`n"
}

$htmlContent += @"
                    ],
                    backgroundColor: [
                        '#ff4444', '#ff6b6b', '#ff8787', '#ffa3a3',
                        '#ffbfbf', '#ffd4d4', '#ffe0e0'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { color: '#fff' }
                    }
                }
            }
        });
        
        // Document Breakdown Chart
        const docCtx = document.getElementById('docBreakdownChart').getContext('2d');
        new Chart(docCtx, {
            type: 'pie',
            data: {
                labels: [
                    'Docs with Illegal Terms',
                    'Docs with VIP Mentions',
                    'Other Documents'
                ],
                datasets: [{
                    data: [
                        $docsWithIllegalTerms,
                        $docsWithVIPs,
                        $($totalDocs - $docsWithIllegalTerms)
                    ],
                    backgroundColor: [
                        '#ff4444',
                        '#ffa500',
                        '#4CAF50'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#fff' }
                    }
                }
            }
        });
    </script>
</body>
</html>
"@

$htmlContent | Out-File -FilePath (Join-Path $InfographicPath "INFOGRAPHIC.html") -Encoding UTF8

# Generate markdown infographic
$mdContent = "# EPSTEIN DOCUMENTS - ANALYSIS INFOGRAPHIC`n`n"
$mdContent += "*Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*`n`n"
$mdContent += "---`n`n"
$mdContent += "## KEY STATISTICS`n`n"
$mdContent += "| Metric | Value |`n"
$mdContent += "|--------|-------|`n"
$mdContent += "| **Documents Analyzed** | $totalDocs |`n"
$mdContent += "| **People Identified** | $totalPeople |`n"
$mdContent += "| **VIPs Tracked** | $totalVIPs |`n"
$mdContent += "| **Network Connections** | 37,086 |`n"
$mdContent += "| **Docs with Flagged Terms** | $docsWithIllegalTerms |`n"
$mdContent += "| **Docs with VIP Mentions** | $docsWithVIPs |`n`n"
$mdContent += "---`n`n"
$mdContent += "## TOP 20 MOST MENTIONED PEOPLE`n`n"
$mdContent += "| Rank | Name | Mentions |`n"
$mdContent += "|------|------|----------|`n"

$rank = 1
foreach ($person in $topPeople) {
    $mdContent += "| $rank | $($person.Name) | $($person.Value) |`n"
    $rank++
}

$mdContent += "`n---`n`n"
$mdContent += "## VIP BREAKDOWN`n`n"
$mdContent += "| VIP | Total Mentions |`n"
$mdContent += "|-----|----------------|`n"

foreach ($vip in $vipMentions.PSObject.Properties) {
    $total = ($vip.Value | ForEach-Object { $_.count } | Measure-Object -Sum).Sum
    $mdContent += "| $($vip.Name) | $total |`n"
}

$mdContent += "`n---`n`n"
$mdContent += "## DOCUMENT BREAKDOWN`n`n"
$mdContent += "- **Documents with Illegal/Sensitive Terms**: $docsWithIllegalTerms ($([math]::Round(($docsWithIllegalTerms/$totalDocs)*100, 1))%)`n"
$mdContent += "- **Documents with VIP Mentions**: $docsWithVIPs ($([math]::Round(($docsWithVIPs/$totalDocs)*100, 1))%)`n"
$mdContent += "- **Other Documents**: $($totalDocs - $docsWithIllegalTerms) ($([math]::Round((($totalDocs - $docsWithIllegalTerms)/$totalDocs)*100, 1))%)`n`n"

$mdContent | Out-File -FilePath (Join-Path $InfographicPath "INFOGRAPHIC.md") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "INFOGRAPHIC GENERATED!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nGenerated files:" -ForegroundColor Yellow
Write-Host "  - INFOGRAPHIC.html (Interactive charts)" -ForegroundColor White
Write-Host "  - INFOGRAPHIC.md (Markdown version)" -ForegroundColor White
Write-Host "`nLocation: $InfographicPath" -ForegroundColor Cyan
Write-Host "`nOpen INFOGRAPHIC.html in your browser to view!" -ForegroundColor Green
