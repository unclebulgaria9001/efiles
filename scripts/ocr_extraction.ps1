# OCR-Based Text Extraction using Tesseract
# Extracts text from PDFs and images for comprehensive analysis

param(
    [string]$BasePath = "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
)

$ExtractedPath = Join-Path $BasePath "extracted"
$OCROutputPath = Join-Path $BasePath "ocr_extracted"
$TempPath = Join-Path $BasePath "temp_ocr"

# Create directories
@($OCROutputPath, $TempPath) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "OCR-BASED TEXT EXTRACTION" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

# Check for required tools
Write-Host "`nChecking for required tools..." -ForegroundColor Yellow

$tesseractPath = "tesseract"
$magickPath = "magick"
$gs = "gswin64c"  # Ghostscript for Windows

# Test if Tesseract is available
try {
    $null = & $tesseractPath --version 2>&1
    Write-Host "  Tesseract OCR: Found" -ForegroundColor Green
} catch {
    Write-Host "  Tesseract OCR: NOT FOUND" -ForegroundColor Red
    Write-Host "`n  Please install Tesseract OCR:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://github.com/UB-Mannheim/tesseract/wiki" -ForegroundColor White
    Write-Host "  2. Install with default settings" -ForegroundColor White
    Write-Host "  3. Add to PATH or use full path" -ForegroundColor White
    Write-Host "`n  Alternative: Use Chocolatey: choco install tesseract" -ForegroundColor White
    $tesseractPath = $null
}

# Test if ImageMagick is available
try {
    $null = & $magickPath --version 2>&1
    Write-Host "  ImageMagick: Found" -ForegroundColor Green
} catch {
    Write-Host "  ImageMagick: NOT FOUND" -ForegroundColor Red
    Write-Host "`n  Please install ImageMagick:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://imagemagick.org/script/download.php" -ForegroundColor White
    Write-Host "  2. Install with 'Install legacy utilities' option" -ForegroundColor White
    Write-Host "`n  Alternative: Use Chocolatey: choco install imagemagick" -ForegroundColor White
    $magickPath = $null
}

# Test if Ghostscript is available
try {
    $null = & $gs --version 2>&1
    Write-Host "  Ghostscript: Found" -ForegroundColor Green
} catch {
    Write-Host "  Ghostscript: NOT FOUND (optional)" -ForegroundColor Yellow
    Write-Host "  Install from: https://ghostscript.com/releases/gsdnld.html" -ForegroundColor White
    $gs = $null
}

if (-not $tesseractPath) {
    Write-Host "`n" + ("=" * 70) -ForegroundColor Red
    Write-Host "CANNOT PROCEED WITHOUT TESSERACT OCR" -ForegroundColor Red
    Write-Host ("=" * 70) -ForegroundColor Red
    Write-Host "`nInstall Tesseract and re-run this script." -ForegroundColor Yellow
    exit 1
}

# Function to convert PDF to images
function Convert-PDFToImages {
    param(
        [string]$PdfPath,
        [string]$OutputFolder
    )
    
    $pdfName = [System.IO.Path]::GetFileNameWithoutExtension($PdfPath)
    $outputPattern = Join-Path $OutputFolder "$pdfName-page"
    
    try {
        if ($magickPath) {
            # Use ImageMagick to convert PDF to images
            & $magickPath convert -density 300 "$PdfPath" -quality 100 "$outputPattern-%04d.png" 2>&1 | Out-Null
        } elseif ($gs) {
            # Use Ghostscript as fallback
            & $gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r300 -sOutputFile="$outputPattern-%04d.png" "$PdfPath" 2>&1 | Out-Null
        } else {
            Write-Host "  Warning: Cannot convert PDF to images (no converter available)" -ForegroundColor Yellow
            return @()
        }
        
        # Return list of generated images
        return Get-ChildItem -Path $OutputFolder -Filter "$pdfName-page-*.png"
    }
    catch {
        Write-Host "  Error converting PDF: $_" -ForegroundColor Red
        return @()
    }
}

# Function to OCR an image
function Get-OCRText {
    param(
        [string]$ImagePath
    )
    
    $outputBase = [System.IO.Path]::GetFileNameWithoutExtension($ImagePath)
    $outputPath = Join-Path $TempPath $outputBase
    
    try {
        # Run Tesseract OCR
        & $tesseractPath "$ImagePath" "$outputPath" -l eng 2>&1 | Out-Null
        
        # Read the output text file
        $textFile = "$outputPath.txt"
        if (Test-Path $textFile) {
            $text = Get-Content $textFile -Raw -Encoding UTF8
            Remove-Item $textFile -Force
            return $text
        }
        
        return ""
    }
    catch {
        Write-Host "  Error during OCR: $_" -ForegroundColor Red
        return ""
    }
}

# Function to process a PDF with OCR
function Process-PDFWithOCR {
    param(
        [string]$PdfPath,
        [string]$OutputPath
    )
    
    $pdfName = [System.IO.Path]::GetFileNameWithoutExtension($PdfPath)
    Write-Host "  Processing: $pdfName" -ForegroundColor Gray
    
    # Create temp folder for this PDF
    $pdfTempFolder = Join-Path $TempPath $pdfName
    if (-not (Test-Path $pdfTempFolder)) {
        New-Item -ItemType Directory -Path $pdfTempFolder | Out-Null
    }
    
    # Convert PDF to images
    Write-Host "    Converting to images..." -ForegroundColor DarkGray
    $images = Convert-PDFToImages -PdfPath $PdfPath -OutputFolder $pdfTempFolder
    
    if ($images.Count -eq 0) {
        Write-Host "    No images generated, skipping OCR" -ForegroundColor Yellow
        return ""
    }
    
    Write-Host "    OCR on $($images.Count) pages..." -ForegroundColor DarkGray
    
    # OCR each image
    $allText = ""
    $pageNum = 1
    foreach ($image in $images) {
        $text = Get-OCRText -ImagePath $image.FullName
        if ($text) {
            $allText += "`n`n--- PAGE $pageNum ---`n`n$text"
        }
        $pageNum++
    }
    
    # Clean up temp images
    Remove-Item -Path $pdfTempFolder -Recurse -Force -ErrorAction SilentlyContinue
    
    return $allText
}

# Main processing
Write-Host "`nFinding PDF files..." -ForegroundColor Yellow
$pdfFiles = Get-ChildItem -Path $ExtractedPath -Recurse -Filter "*.pdf" | Where-Object { $_.Name -notlike "._*" }
Write-Host "Found $($pdfFiles.Count) PDF files`n" -ForegroundColor Green

$processed = 0
$successful = 0
$failed = 0

foreach ($pdf in $pdfFiles) {
    $processed++
    
    Write-Host "[$processed / $($pdfFiles.Count)]" -ForegroundColor Cyan
    
    try {
        # Process with OCR
        $ocrText = Process-PDFWithOCR -PdfPath $pdf.FullName -OutputPath $OCROutputPath
        
        if ($ocrText.Length -gt 100) {
            # Save to markdown file
            $outputFile = Join-Path $OCROutputPath "$($pdf.BaseName).md"
            
            $pdfInfo = Get-Item $pdf.FullName
            
            $markdown = @"
# Document: $($pdf.BaseName)

**Source PDF**: ``$($pdfInfo.Name)``  
**File Size**: $([math]::Round($pdfInfo.Length / 1KB, 2)) KB  
**Created**: $($pdfInfo.CreationTime)  
**Modified**: $($pdfInfo.LastWriteTime)  
**Extraction Method**: Tesseract OCR

---

## Extracted Text (OCR)

$ocrText

---

*Text extracted: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*  
*OCR Engine: Tesseract*
"@
            
            $markdown | Out-File -FilePath $outputFile -Encoding UTF8
            $successful++
            Write-Host "  SUCCESS: Extracted $($ocrText.Length) characters" -ForegroundColor Green
        }
        else {
            Write-Host "  WARNING: Minimal text extracted" -ForegroundColor Yellow
            $failed++
        }
    }
    catch {
        Write-Host "  FAILED: $_" -ForegroundColor Red
        $failed++
    }
    
    # Progress update every 10 files
    if ($processed % 10 -eq 0) {
        Write-Host "`n  Progress: $processed / $($pdfFiles.Count) | Success: $successful | Failed: $failed`n" -ForegroundColor Cyan
    }
}

# Clean up temp directory
Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue

# Create index
Write-Host "`nCreating index..." -ForegroundColor Yellow

$indexContent = @"
# OCR Extraction Index
*Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*

## Extraction Summary

- **Total PDFs**: $($pdfFiles.Count)
- **Successfully Extracted**: $successful
- **Failed/Minimal**: $failed
- **Success Rate**: $([math]::Round(($successful / $pdfFiles.Count) * 100, 1))%

## Method

This extraction uses **Tesseract OCR** to extract text from PDF pages:
1. Convert each PDF page to high-resolution image (300 DPI)
2. Run OCR on each image
3. Combine all pages into single markdown file

## Advantages Over Basic Extraction

- **Scanned documents**: Can extract text from images
- **Complex layouts**: Better handling of multi-column text
- **Images**: Can extract text from embedded images
- **Quality**: Higher accuracy for difficult documents

## All Extracted Documents

"@

$mdFiles = Get-ChildItem -Path $OCROutputPath -Filter "*.md" | Sort-Object Name

foreach ($mdFile in $mdFiles) {
    $size = [math]::Round($mdFile.Length / 1KB, 2)
    $indexContent += "- [````$($mdFile.BaseName)````]($($mdFile.Name)) - $size KB`n"
}

$indexContent | Out-File -FilePath (Join-Path $OCROutputPath "INDEX.md") -Encoding UTF8

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "OCR EXTRACTION COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host "`nResults:" -ForegroundColor Yellow
Write-Host "  Total PDFs: $($pdfFiles.Count)" -ForegroundColor White
Write-Host "  Successfully extracted: $successful" -ForegroundColor Green
Write-Host "  Failed/Minimal: $failed" -ForegroundColor Yellow
Write-Host "`nOutput location: $OCROutputPath" -ForegroundColor Cyan
Write-Host "  - INDEX.md (Start here)" -ForegroundColor White
Write-Host "  - $($mdFiles.Count) markdown files with OCR text" -ForegroundColor White
Write-Host "`nNext step: Run comprehensive_reanalysis.ps1" -ForegroundColor Yellow
