# Enhanced Analytics - Person-Term Matrix and Interaction Graph
# Builds on the initial analysis to create detailed relationship maps

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$AnalyticsPath = Join-Path $BasePath "analytics"

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "ENHANCED ANALYTICS - RELATIONSHIP MAPPING" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Load the existing data
Write-Host "`nLoading existing analysis data..." -ForegroundColor Yellow
$allDocs = Get-Content (Join-Path $AnalyticsPath "all_documents.json") -Raw | ConvertFrom-Json
$personCounts = Get-Content (Join-Path $AnalyticsPath "person_counts.json") -Raw | ConvertFrom-Json
$vipMentions = Get-Content (Join-Path $AnalyticsPath "vip_mentions.json") -Raw | ConvertFrom-Json

Write-Host "Loaded $($allDocs.Count) documents" -ForegroundColor Green

# Initialize structures
$personTermMatrix = @{}
$interactions = @{}
$documentClusters = @{}

# Illegal activity keywords
$IllegalTerms = @(
    "sex", "sexual", "massage", "naked", "nude", "underage",
    "minor", "young girl", "teenage", "prostitute", "prostitution",
    "trafficking", "abuse", "molest", "rape", "assault",
    "drug", "cocaine", "heroin", "pills", "prescription",
    "illegal", "crime", "criminal", "victim", "exploit"
)

# Build Person-Term Matrix
Write-Host "`n=== Building Person-Term Association Matrix ===" -ForegroundColor Cyan

foreach ($doc in $allDocs) {
    $people = $doc.people_mentioned
    $terms = $doc.illegal_terms_found
    
    # For each person in this document
    foreach ($person in $people) {
        if (-not $personTermMatrix.ContainsKey($person)) {
            $personTermMatrix[$person] = @{}
        }
        
        # Associate them with each term found in the document
        foreach ($term in $terms) {
            if (-not $personTermMatrix[$person].ContainsKey($term)) {
                $personTermMatrix[$person][$term] = 0
            }
            $personTermMatrix[$person][$term]++
        }
    }
}

Write-Host "Built matrix for $($personTermMatrix.Count) people" -ForegroundColor Green

# Build Interaction Graph
Write-Host "`n=== Building Interaction Graph ===" -ForegroundColor Cyan

foreach ($doc in $allDocs) {
    $people = $doc.people_mentioned
    
    # Create connections between all people mentioned in the same document
    for ($i = 0; $i -lt $people.Count; $i++) {
        $person1 = $people[$i]
        
        if (-not $interactions.ContainsKey($person1)) {
            $interactions[$person1] = @{}
        }
        
        for ($j = $i + 1; $j -lt $people.Count; $j++) {
            $person2 = $people[$j]
            
            # Track connection strength (number of documents they appear together)
            if (-not $interactions[$person1].ContainsKey($person2)) {
                $interactions[$person1][$person2] = 0
            }
            $interactions[$person1][$person2]++
            
            # Bidirectional
            if (-not $interactions.ContainsKey($person2)) {
                $interactions[$person2] = @{}
            }
            if (-not $interactions[$person2].ContainsKey($person1)) {
                $interactions[$person2][$person1] = 0
            }
            $interactions[$person2][$person1]++
        }
    }
}

$totalConnections = ($interactions.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
Write-Host "Built graph with $($interactions.Count) nodes and $totalConnections connections" -ForegroundColor Green

# Generate Enhanced Person-Term Matrix Report
Write-Host "`n=== Generating Enhanced Reports ===" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 1. Person-Term Matrix (Top 100 people)
$content = @"
# Person-Term Association Matrix
*Generated: $timestamp*

This matrix shows which people are mentioned in documents containing specific illegal/sensitive terms.

## Top 100 People with Term Associations

"@

# Get top people by mention count
$topPeople = $personCounts.PSObject.Properties | 
    Sort-Object -Property Value -Descending | 
    Select-Object -First 100 -ExpandProperty Name

foreach ($person in $topPeople) {
    if ($personTermMatrix.ContainsKey($person)) {
        $terms = $personTermMatrix[$person]
        if ($terms.Count -gt 0) {
            $content += @"

### $person
**Total Mentions**: $($personCounts.$person)

| Term | Co-occurrences |
|------|----------------|
"@
            
            # Sort terms by count
            $sortedTerms = $terms.GetEnumerator() | Sort-Object -Property Value -Descending
            foreach ($term in $sortedTerms) {
                $content += "| $($term.Key) | $($term.Value) |`n"
            }
        }
    }
}

$content | Out-File -FilePath (Join-Path $AnalyticsPath "person_term_matrix.md") -Encoding UTF8
Write-Host "  Generated person_term_matrix.md" -ForegroundColor Gray

# 2. Interaction Graph Report
$content = @"
# Interaction Network Graph
*Generated: $timestamp*

This shows which people are mentioned together in documents, forming a network of associations.

## Network Statistics

- **Total Nodes (People)**: $($interactions.Count)
- **Total Edges (Connections)**: $($totalConnections / 2)
- **Average Connections per Person**: $([math]::Round($totalConnections / $interactions.Count, 2))

## Top 50 Most Connected People

| Rank | Person | Connections | Top Associates |
|------|--------|-------------|----------------|
"@

# Sort by connection count
$sortedPeople = $interactions.GetEnumerator() | 
    Sort-Object -Property { $_.Value.Count } -Descending | 
    Select-Object -First 50

$rank = 1
foreach ($person in $sortedPeople) {
    $name = $person.Key
    $connections = $person.Value
    $connectionCount = $connections.Count
    
    # Get top 3 associates
    $topAssociates = $connections.GetEnumerator() | 
        Sort-Object -Property Value -Descending | 
        Select-Object -First 3 -ExpandProperty Key
    
    $associatesList = $topAssociates -join ", "
    
    $content += "| $rank | $name | $connectionCount | $associatesList |`n"
    $rank++
}

$content += @"

## Detailed Connection List

"@

# Detailed connections for top 20
$topPeople = $sortedPeople | Select-Object -First 20

foreach ($person in $topPeople) {
    $name = $person.Key
    $connections = $person.Value
    
    $content += @"

### $name
**Total Connections**: $($connections.Count)

| Connected Person | Shared Documents |
|------------------|------------------|
"@
    
    $sortedConnections = $connections.GetEnumerator() | Sort-Object -Property Value -Descending
    foreach ($conn in $sortedConnections) {
        $content += "| $($conn.Key) | $($conn.Value) |`n"
    }
}

$content | Out-File -FilePath (Join-Path $AnalyticsPath "interaction_graph.md") -Encoding UTF8
Write-Host "  Generated interaction_graph.md" -ForegroundColor Gray

# 3. Generate Graph Data for Visualization
Write-Host "`n=== Generating Graph Visualization Data ===" -ForegroundColor Cyan

# Create nodes array
$nodes = @()
foreach ($person in $interactions.Keys) {
    $nodes += @{
        id = $person
        label = $person
        connections = $interactions[$person].Count
        mentions = if ($personCounts.PSObject.Properties.Name -contains $person) { $personCounts.$person } else { 0 }
    }
}

# Create edges array (only include edges once)
$edges = @()
$processed = @{}

foreach ($person1 in $interactions.Keys) {
    foreach ($person2 in $interactions[$person1].Keys) {
        $key1 = "$person1|$person2"
        $key2 = "$person2|$person1"
        
        if (-not $processed.ContainsKey($key1) -and -not $processed.ContainsKey($key2)) {
            $edges += @{
                source = $person1
                target = $person2
                weight = $interactions[$person1][$person2]
            }
            $processed[$key1] = $true
        }
    }
}

$graphData = @{
    nodes = $nodes
    edges = $edges
    metadata = @{
        generated = $timestamp
        total_nodes = $nodes.Count
        total_edges = $edges.Count
    }
}

$graphData | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $AnalyticsPath "interaction_graph.json") -Encoding UTF8
Write-Host "  Generated interaction_graph.json" -ForegroundColor Gray

# 4. VIP-Specific Analysis
Write-Host "`n=== Generating VIP-Specific Analysis ===" -ForegroundColor Cyan

$vipList = @("epstein", "maxwell", "giuffre", "virginia giuffre", "ghislaine maxwell", "marcinkova", "ross")

$content = @"
# VIP Deep Dive Analysis
*Generated: $timestamp*

Detailed analysis of high-profile individuals and their associations.

"@

foreach ($vip in $vipList) {
    if ($personTermMatrix.ContainsKey($vip) -or $interactions.ContainsKey($vip)) {
        $content += @"

## $($vip.ToUpper())

### Mention Statistics
- **Total Mentions**: $($personCounts.$vip)
"@
        
        # Term associations
        if ($personTermMatrix.ContainsKey($vip)) {
            $terms = $personTermMatrix[$vip]
            $content += @"

- **Documents with Illegal Terms**: $($terms.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum)

### Associated Terms

| Term | Co-occurrences |
|------|----------------|
"@
            
            $sortedTerms = $terms.GetEnumerator() | Sort-Object -Property Value -Descending
            foreach ($term in $sortedTerms) {
                $content += "| $($term.Key) | $($term.Value) |`n"
            }
        }
        
        # Network connections
        if ($interactions.ContainsKey($vip)) {
            $connections = $interactions[$vip]
            $content += @"

### Network Connections
**Total People Connected**: $($connections.Count)

| Person | Shared Documents |
|--------|------------------|
"@
            
            $sortedConnections = $connections.GetEnumerator() | 
                Sort-Object -Property Value -Descending | 
                Select-Object -First 20
            
            foreach ($conn in $sortedConnections) {
                $content += "| $($conn.Key) | $($conn.Value) |`n"
            }
        }
        
        $content += "`n---`n"
    }
}

$content | Out-File -FilePath (Join-Path $AnalyticsPath "vip_deep_dive.md") -Encoding UTF8
Write-Host "  Generated vip_deep_dive.md" -ForegroundColor Gray

# 5. Generate HTML Visualization
Write-Host "`n=== Generating HTML Visualization ===" -ForegroundColor Cyan

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Epstein Documents - Network Graph</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: Arial, sans-serif;
            background: #1a1a1a;
            color: #fff;
        }
        #graph {
            width: 100%;
            height: 800px;
            border: 1px solid #333;
            background: #0a0a0a;
        }
        .node {
            stroke: #fff;
            stroke-width: 1.5px;
        }
        .link {
            stroke: #999;
            stroke-opacity: 0.6;
        }
        .node-label {
            font-size: 10px;
            fill: #fff;
            pointer-events: none;
        }
        #info {
            margin-top: 20px;
            padding: 15px;
            background: #2a2a2a;
            border-radius: 5px;
        }
        h1 {
            color: #4CAF50;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        .stat-box {
            background: #333;
            padding: 15px;
            border-radius: 5px;
            border-left: 3px solid #4CAF50;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
        }
        .stat-label {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <h1>Epstein Documents - Interaction Network</h1>
    
    <div class="stats">
        <div class="stat-box">
            <div class="stat-value" id="nodeCount">0</div>
            <div class="stat-label">People Identified</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" id="edgeCount">0</div>
            <div class="stat-label">Connections</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" id="docCount">388</div>
            <div class="stat-label">Documents Analyzed</div>
        </div>
    </div>
    
    <div id="graph"></div>
    
    <div id="info">
        <h3>Instructions</h3>
        <p>• Hover over nodes to see person names</p>
        <p>• Node size represents number of mentions</p>
        <p>• Line thickness represents connection strength</p>
        <p>• Drag nodes to rearrange the graph</p>
    </div>
    
    <script>
        // Load the graph data
        fetch('interaction_graph.json')
            .then(response => response.json())
            .then(data => {
                document.getElementById('nodeCount').textContent = data.nodes.length;
                document.getElementById('edgeCount').textContent = data.edges.length;
                
                // Filter to top 100 most connected nodes for performance
                const topNodes = data.nodes
                    .sort((a, b) => b.connections - a.connections)
                    .slice(0, 100);
                
                const nodeIds = new Set(topNodes.map(n => n.id));
                const filteredEdges = data.edges.filter(e => 
                    nodeIds.has(e.source) && nodeIds.has(e.target)
                );
                
                createGraph(topNodes, filteredEdges);
            });
        
        function createGraph(nodes, edges) {
            const width = document.getElementById('graph').clientWidth;
            const height = 800;
            
            const svg = d3.select('#graph')
                .append('svg')
                .attr('width', width)
                .attr('height', height);
            
            const simulation = d3.forceSimulation(nodes)
                .force('link', d3.forceLink(edges).id(d => d.id).distance(100))
                .force('charge', d3.forceManyBody().strength(-300))
                .force('center', d3.forceCenter(width / 2, height / 2))
                .force('collision', d3.forceCollide().radius(d => Math.sqrt(d.mentions) * 2 + 5));
            
            const link = svg.append('g')
                .selectAll('line')
                .data(edges)
                .enter().append('line')
                .attr('class', 'link')
                .attr('stroke-width', d => Math.sqrt(d.weight));
            
            const node = svg.append('g')
                .selectAll('circle')
                .data(nodes)
                .enter().append('circle')
                .attr('class', 'node')
                .attr('r', d => Math.sqrt(d.mentions) * 2 + 3)
                .attr('fill', d => {
                    const vips = ['epstein', 'maxwell', 'giuffre', 'virginia giuffre', 'ghislaine maxwell'];
                    return vips.includes(d.id.toLowerCase()) ? '#ff4444' : '#4CAF50';
                })
                .call(d3.drag()
                    .on('start', dragstarted)
                    .on('drag', dragged)
                    .on('end', dragended));
            
            node.append('title')
                .text(d => `\${d.label}\nMentions: \${d.mentions}\nConnections: \${d.connections}`);
            
            simulation.on('tick', () => {
                link
                    .attr('x1', d => d.source.x)
                    .attr('y1', d => d.source.y)
                    .attr('x2', d => d.target.x)
                    .attr('y2', d => d.target.y);
                
                node
                    .attr('cx', d => d.x)
                    .attr('cy', d => d.y);
            });
            
            function dragstarted(event, d) {
                if (!event.active) simulation.alphaTarget(0.3).restart();
                d.fx = d.x;
                d.fy = d.y;
            }
            
            function dragged(event, d) {
                d.fx = event.x;
                d.fy = event.y;
            }
            
            function dragended(event, d) {
                if (!event.active) simulation.alphaTarget(0);
                d.fx = null;
                d.fy = null;
            }
        }
    </script>
</body>
</html>
"@

$htmlContent | Out-File -FilePath (Join-Path $AnalyticsPath "network_visualization.html") -Encoding UTF8
Write-Host "  Generated network_visualization.html" -ForegroundColor Gray

# Save enhanced data
$personTermMatrix | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $AnalyticsPath "person_term_matrix.json") -Encoding UTF8
$interactions | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $AnalyticsPath "interactions.json") -Encoding UTF8

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "ENHANCED ANALYSIS COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "`nNew files generated:" -ForegroundColor Yellow
Write-Host "  - person_term_matrix.md (Detailed associations)" -ForegroundColor White
Write-Host "  - interaction_graph.md (Network analysis)" -ForegroundColor White
Write-Host "  - vip_deep_dive.md (VIP-specific analysis)" -ForegroundColor White
Write-Host "  - network_visualization.html (Interactive graph)" -ForegroundColor White
Write-Host "  - *.json (Raw data files)" -ForegroundColor White
Write-Host "`nOpen network_visualization.html in a browser to see the interactive graph!" -ForegroundColor Cyan
