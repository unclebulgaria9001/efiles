# OCR Setup & Execution Guide

## Overview

This guide will help you set up OCR (Optical Character Recognition) to properly extract text from all PDFs and images, then re-run the analysis with much better results.

---

## Why OCR?

**Current Problem**: Basic text extraction misses:
- Scanned documents (images of text)
- Complex PDF layouts
- Embedded images with text
- Poor quality PDFs

**OCR Solution**: Converts images to text
- Can read scanned documents
- Extracts text from images
- Much higher accuracy
- Finds more people and connections

---

## Step 1: Install Required Software

### A. Tesseract OCR (REQUIRED)

**Option 1: Direct Download** (Recommended)
1. Download from: https://github.com/UB-Mannheim/tesseract/wiki
2. Get the latest Windows installer (tesseract-ocr-w64-setup-*.exe)
3. Run installer with default settings
4. **Important**: Check "Add to PATH" during installation

**Option 2: Chocolatey** (If you have Chocolatey)
```powershell
choco install tesseract
```

**Verify Installation**:
```powershell
tesseract --version
```
Should show version info (e.g., "tesseract 5.x.x")

### B. ImageMagick (REQUIRED)

**Option 1: Direct Download**
1. Download from: https://imagemagick.org/script/download.php
2. Get Windows installer (ImageMagick-*-Q16-x64-dll.exe)
3. Run installer
4. **Important**: Check "Install legacy utilities (e.g., convert)" option
5. **Important**: Check "Add to PATH" option

**Option 2: Chocolatey**
```powershell
choco install imagemagick
```

**Verify Installation**:
```powershell
magick --version
```
Should show version info

### C. Ghostscript (OPTIONAL - Fallback)

**Download**: https://ghostscript.com/releases/gsdnld.html
- Get Windows 64-bit installer
- Install with defaults

---

## Step 2: Run OCR Extraction

Once software is installed:

```powershell
cd "G:\My Drive\04_Resources\Notes\Epstein Email Dump"
powershell -ExecutionPolicy Bypass -File ".\ocr_extraction.ps1"
```

**What it does**:
1. Converts each PDF page to high-resolution image (300 DPI)
2. Runs Tesseract OCR on each image
3. Combines all pages into markdown files
4. Saves to `ocr_extracted/` folder

**Time**: ~5-10 minutes per PDF (388 PDFs = several hours)
- Can run overnight
- Progress shown every 10 files
- Can interrupt and resume

**Output**:
- `ocr_extracted/` folder with 388 markdown files
- `ocr_extracted/INDEX.md` with links to all files

---

## Step 3: Run Comprehensive Reanalysis

After OCR extraction completes:

```powershell
powershell -ExecutionPolicy Bypass -File ".\comprehensive_reanalysis.ps1"
```

**What it does**:
1. Loads all OCR-extracted text
2. Searches for known people (18+ individuals)
3. Finds sensitive terms and co-occurrences
4. Generates comprehensive reports

**Time**: ~2-5 minutes

**Output**:
- `reanalysis/COMPLETE_ANALYSIS.md` - All people with full details
- `reanalysis/VIP_ANALYSIS.md` - High-profile individuals only
- `reanalysis/STATISTICS.md` - Summary statistics
- `reanalysis/analysis_data.json` - Raw data

---

## What You'll Get

### Better People Detection

**Before OCR** (Basic extraction):
- 10-12 people found
- Mostly metadata and staff
- Missing key figures

**After OCR** (Expected):
- 18+ known people tracked
- Virginia Giuffre mentions found
- Prince Andrew, Clinton, Trump (if in documents)
- Better context and quotes
- More connections mapped

### Known People Tracked

1. **Jeffrey Epstein** (Primary subject)
2. **Ghislaine Maxwell** (Associate/Recruiter)
3. **Virginia Giuffre** (Victim/Witness)
4. **Prince Andrew** (Royal/Political)
5. **Bill Clinton** (Political)
6. **Donald Trump** (Political)
7. **Alan Dershowitz** (Attorney)
8. **Leslie Wexner** (Financial backer)
9. **Jean-Luc Brunel** (Associate)
10. **Sarah Kellen** (Assistant)
11. **Nadia Marcinkova** (Associate)
12. **Adriana Ross** (Assistant)
13. **Lesley Groff** (Assistant)
14. **Johanna Sjoberg** (Victim/Witness)
15. **Sarah Ransome** (Victim/Witness)
16. **Nicole Simmons** (Staff)
17. **Brenda Rodriguez** (Staff)
18. **Tony Figueroa** (Court personnel)

Plus aliases and variations for each.

---

## Troubleshooting

### "Tesseract not found"
- Reinstall and ensure "Add to PATH" is checked
- Or edit script to use full path: `C:\Program Files\Tesseract-OCR\tesseract.exe`

### "ImageMagick not found"
- Reinstall with "Install legacy utilities" checked
- Verify `magick` command works

### "Out of memory" errors
- Close other applications
- Process in batches (edit script to process 50 at a time)
- Increase virtual memory in Windows

### OCR taking too long
- Normal - each PDF takes 5-10 minutes
- Can run overnight
- Progress saved - can resume if interrupted

### Poor OCR quality
- Some PDFs may be too low quality
- Scanned documents work best at 300 DPI
- Handwritten text won't be recognized

---

## Quick Start (If Software Already Installed)

```powershell
# Navigate to folder
cd "G:\My Drive\04_Resources\Notes\Epstein Email Dump"

# Step 1: Extract text with OCR (takes several hours)
powershell -ExecutionPolicy Bypass -File ".\ocr_extraction.ps1"

# Step 2: Run comprehensive analysis (takes 2-5 minutes)
powershell -ExecutionPolicy Bypass -File ".\comprehensive_reanalysis.ps1"

# Step 3: View results
# Open: reanalysis\COMPLETE_ANALYSIS.md
```

---

## Expected Results

### Documents
- All 388 PDFs processed with OCR
- Text extracted from scanned images
- Better quality extraction

### People
- 18+ known individuals tracked
- Aliases and variations matched
- Contexts and quotes extracted
- Sensitive term co-occurrences mapped

### Reports
- Complete analysis with all people
- VIP-only analysis
- Statistics and summaries
- JSON data for further analysis

---

## Alternative: Manual OCR (If Automated Fails)

If the automated script doesn't work:

1. **Use Adobe Acrobat Pro** (if available)
   - Open PDF
   - Tools → Recognize Text → In This File
   - Save as searchable PDF

2. **Use Online OCR**
   - https://www.onlineocr.net/
   - Upload PDF, download text
   - Manual but works

3. **Use Google Drive**
   - Upload PDF to Google Drive
   - Right-click → Open with Google Docs
   - Automatically OCRs the document

---

## Next Steps After OCR

1. **Review Results**
   - Open `reanalysis/COMPLETE_ANALYSIS.md`
   - Check `reanalysis/VIP_ANALYSIS.md`

2. **Search for Specific People**
   - Use Ctrl+F in markdown files
   - Check JSON data for programmatic access

3. **Cross-Reference**
   - Compare with external sources
   - Verify findings
   - Build comprehensive picture

4. **Generate Visualizations**
   - Use analysis data to create graphs
   - Map connections
   - Build timeline

---

## System Requirements

- **OS**: Windows 10/11
- **RAM**: 8GB minimum, 16GB recommended
- **Disk Space**: 5-10 GB for OCR output
- **Time**: Several hours for full extraction

---

## Support

If you encounter issues:
1. Check software is installed correctly
2. Verify PATH environment variables
3. Try running PowerShell as Administrator
4. Check error messages in console

---

**Ready to begin? Start with Step 1: Install Required Software**
