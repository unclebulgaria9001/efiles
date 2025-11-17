# Full Text Extraction - Create Markdown Files for All PDFs
# Extracts complete text from every PDF and saves as markdown

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$ErrorActionPreference = "Continue"

$ExtractedPath = Join-Path $BasePath "extracted"
$TextOutputPath = Join-Path $BasePath "full_text_markdown"

# Create output directory
if (-not (Test-Path $TextOutputPath)) {
    New-Item -ItemType Directory -Path $TextOutputPath | Out-Null
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "FULL TEXT EXTRACTION TO MARKDOWN" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Function to extract text from PDF
function Get-PDFText {
    param([string]$PdfPath)
    
    try {
        # Read PDF as bytes and extract ASCII text
        $bytes = [System.IO.File]::ReadAllBytes($PdfPath)
        $text = [System.Text.Encoding]::ASCII.GetString($bytes)
        
        # Clean up binary junk, keep readable text
        $text = $text -replace '[^\x20-\x7E\r\n]', ' '
        $text = $text -replace '\s+', ' '
        $text = $text -replace '  +', ' '
        
        # Try to extract text between stream markers
        $textContent = ""
        if ($text -match 'stream(.+?)endstream') {
            $streams = [regex]::Matches($text, 'stream(.+?)endstream', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            foreach ($stream in $streams) {
                $streamText = $stream.Groups[1].Value
                # Remove common PDF operators
                $streamText = $streamText -replace 'BT|ET|Tf|Td|Tj|TJ|\'|\"', ' '
                $streamText = $streamText -replace '\d+\.\d+', ''
                $streamText = $streamText -replace '[<>\[\]\(\)]', ''
                $textContent += $streamText + " "
            }
        }
        
        # If stream extraction didn't work well, use the whole cleaned text
        if ($textContent.Length -lt 100) {
            $textContent = $text
        }
        
        # Final cleanup
        $textContent = $textContent -replace '\s+', ' '
        $textContent = $textContent.Trim()
        
        return $textContent
    }
    catch {
        Write-Host "  Error extracting from $($PdfPath): $_" -ForegroundColor Red
        return ""
    }
}

# Function to create markdown file
function Create-MarkdownFile {
    param(
        [string]$PdfPath,
        [string]$Text,
        [string]$OutputPath
    )
    
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($PdfPath)
    $pdfInfo = Get-Item $PdfPath
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $fileSize = [math]::Round($pdfInfo.Length / 1KB, 2)
    
    $markdown = "# Document: $filename`n`n"
    $markdown += "**Source PDF**: ````$($pdfInfo.Name)````  `n"
    $markdown += "**File Size**: $fileSize KB  `n"
    $markdown += "**Created**: $($pdfInfo.CreationTime)  `n"
    $markdown += "**Modified**: $($pdfInfo.LastWriteTime)  `n`n"
    $markdown += "---`n`n"
    $markdown += "## Extracted Text`n`n"
    $markdown += "$Text`n`n"
    $markdown += "---`n`n"
    $markdown += "*Text extracted: $timestamp*  `n"
    $markdown += "*Extraction method: Basic ASCII extraction (may be incomplete for scanned documents)*`n"
    
    $outputFile = Join-Path $OutputPath "$filename.md"
    $markdown | Out-File -FilePath $outputFile -Encoding UTF8
    
    return $outputFile
}

# Find all PDFs
Write-Host "`nFinding PDF files..." -ForegroundColor Yellow
$pdfFiles = Get-ChildItem -Path $ExtractedPath -Recurse -Filter "*.pdf" | Where-Object { $_.Name -notlike "._*" }
Write-Host "Found $($pdfFiles.Count) PDF files`n" -ForegroundColor Green

# Process each PDF
$processed = 0
$successful = 0
$failed = 0

foreach ($pdf in $pdfFiles) {
    $processed++
    
    if ($processed % 10 -eq 0) {
        Write-Host "  Processed $processed / $($pdfFiles.Count) files..." -ForegroundColor Gray
    }
    
    try {
        # Extract text
        $text = Get-PDFText -PdfPath $pdf.FullName
        
        if ($text.Length -gt 50) {
            # Create markdown file
            $mdFile = Create-MarkdownFile -PdfPath $pdf.FullName -Text $text -OutputPath $TextOutputPath
            $successful++
        }
        else {
            Write-Host "  Warning: Minimal text extracted from $($pdf.Name)" -ForegroundColor Yellow
            # Still create file but note the issue
            $text = "[WARNING: Minimal text could be extracted from this PDF. It may be a scanned image or encrypted.]`n`n$text"
            $mdFile = Create-MarkdownFile -PdfPath $pdf.FullName -Text $text -OutputPath $TextOutputPath
            $failed++
        }
    }
    catch {
        Write-Host "  Failed to process $($pdf.Name): $_" -ForegroundColor Red
        $failed++
    }
}

# Create index file
Write-Host "`nCreating index file..." -ForegroundColor Yellow

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$successRate = [math]::Round(($successful / $pdfFiles.Count) * 100, 1)

$indexContent = "# Full Text Extraction Index`n"
$indexContent += "*Generated: $timestamp*`n`n"
$indexContent += "## Extraction Summary`n`n"
$indexContent += "- **Total PDFs**: $($pdfFiles.Count)`n"
$indexContent += "- **Successfully Extracted**: $successful`n"
$indexContent += "- **Limited Extraction**: $failed`n"
$indexContent += "- **Success Rate**: $successRate%`n`n"
$indexContent += "## Limitations`n`n"
$indexContent += "This extraction uses basic ASCII text extraction from PDFs. For best results:`n"
$indexContent += "- **Scanned documents** may have minimal or no text (require OCR)`n"
$indexContent += "- **Encrypted PDFs** may not extract properly`n"
$indexContent += "- **Complex layouts** may have text order issues`n"
$indexContent += "- **Images** are not extracted`n`n"
$indexContent += "## All Extracted Documents`n`n"

# Add links to all markdown files
$mdFiles = Get-ChildItem -Path $TextOutputPath -Filter "*.md" | Sort-Object Name

foreach ($mdFile in $mdFiles) {
    $size = [math]::Round($mdFile.Length / 1KB, 2)
    $indexContent += "- [````$($mdFile.BaseName)````]($($mdFile.Name)) - $size KB`n"
}

$indexContent | Out-File -FilePath (Join-Path $TextOutputPath "INDEX.md") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "TEXT EXTRACTION COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nResults:" -ForegroundColor Yellow
Write-Host "  Total PDFs: $($pdfFiles.Count)" -ForegroundColor White
Write-Host "  Successfully extracted: $successful" -ForegroundColor Green
Write-Host "  Limited extraction: $failed" -ForegroundColor Yellow
Write-Host "`nOutput location: $TextOutputPath" -ForegroundColor Cyan
Write-Host "  - INDEX.md (Start here)" -ForegroundColor White
Write-Host "  - $($mdFiles.Count) markdown files" -ForegroundColor White
