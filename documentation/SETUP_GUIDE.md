# Setup Guide - Epstein Email Extraction

## Step 1: Install Python

### Download Python
1. Go to https://www.python.org/downloads/
2. Download Python 3.11 or later (recommended: Python 3.11.x)
3. Run the installer

### IMPORTANT: During Installation
✅ **CHECK THE BOX**: "Add Python to PATH"
- This is critical! The checkbox is at the bottom of the installer
- Without this, the script won't be able to find Python

### Verify Installation
Open PowerShell or Command Prompt and run:
```powershell
python --version
```
You should see: `Python 3.11.x` (or similar)

If you see "Python was not found", you need to:
1. Reinstall Python with "Add to PATH" checked, OR
2. Manually add Python to your PATH environment variable

---

## Step 2: Install Tesseract OCR (Optional but Recommended)

### Why Tesseract?
- Required for extracting text from scanned/image-based PDFs
- If your PDFs are text-based (most are), you can skip this
- The script will warn you but continue without it

### Download Tesseract
1. Go to: https://github.com/UB-Mannheim/tesseract/wiki
2. Download the Windows installer (tesseract-ocr-w64-setup-v5.x.x.exe)
3. Run the installer
4. **Important**: During installation, note the installation path (usually `C:\Program Files\Tesseract-OCR`)

### Add Tesseract to PATH
1. Press Windows key, search for "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables" button
4. Under "System variables", find and select "Path"
5. Click "Edit"
6. Click "New"
7. Add: `C:\Program Files\Tesseract-OCR` (or your installation path)
8. Click OK on all windows
9. **Restart PowerShell/Command Prompt**

### Verify Installation
```powershell
tesseract --version
```
You should see version information

---

## Step 3: Run the Extraction

### Method 1: Easy Way (Recommended)
1. Double-click `START_EXTRACTION.bat`
2. Follow the prompts
3. Wait for completion (2-4 hours)

### Method 2: PowerShell
1. Right-click `RUN_EMAIL_EXTRACTION.ps1`
2. Select "Run with PowerShell"
3. If you get an execution policy error, run:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```
4. Then try again

### Method 3: Manual
```powershell
# Navigate to the directory
cd "G:\My Drive\04_Resources\Notes\Epstein Email Dump"

# Install dependencies
python -m pip install --upgrade pip
python -m pip install -r requirements_email_extraction.txt

# Run the script
python extract_emails_to_excel.py
```

---

## What to Expect

### During Processing
- You'll see progress messages for each PDF being processed
- Progress is saved every 10 files
- A log file (`email_extraction.log`) tracks everything
- You can stop and resume anytime

### Processing Time
- **388 PDF files total**
- **Text-based PDFs**: ~1-2 hours
- **With OCR**: ~3-4 hours
- Depends on your computer speed

### Output
- **Excel file**: `epstein_emails_YYYYMMDD_HHMMSS.xlsx`
- **Log file**: `email_extraction.log`
- **Progress file**: `extraction_progress.json`

---

## Troubleshooting

### "Python not found"
**Problem**: Python isn't installed or not in PATH
**Solution**: 
1. Reinstall Python with "Add to PATH" checked
2. Or manually add to PATH (see Step 1)

### "pip not found"
**Problem**: pip isn't installed
**Solution**:
```powershell
python -m ensurepip --upgrade
```

### "Tesseract not found" (Warning)
**Problem**: Tesseract isn't installed
**Solution**:
- If your PDFs are text-based: Ignore this warning, continue
- If you need OCR: Install Tesseract (see Step 2)

### Script is slow
**This is normal!**
- 388 PDFs take time to process
- OCR is particularly slow
- Progress is saved, you can stop/resume

### "No text extracted" warnings
**Problem**: Some PDFs might be empty or corrupted
**Solution**: This is OK, script will skip them and continue

### Excel file won't open
**Problem**: File might be too large
**Solution**: 
- Try opening in Google Sheets
- Or use LibreOffice Calc
- Or split the processing (contact for help)

### Process was interrupted
**Solution**: Just run the script again
- It will automatically resume from where it stopped
- Already-processed files are skipped

### Want to start fresh
**Solution**: Delete `extraction_progress.json` and run again

---

## Monitoring Progress

### Real-time Monitoring
Open `email_extraction.log` in a text editor while the script runs
- Notepad++, VS Code, or any text editor
- Refresh to see latest progress

### Check Progress File
Open `extraction_progress.json` to see:
- How many files processed
- Which files are done
- Last update time

---

## After Completion

### Find Your Excel File
Look for: `epstein_emails_YYYYMMDD_HHMMSS.xlsx`
- In the same directory as the script
- Named with timestamp of when it was created

### Excel Structure
- **Filename**: Source PDF name
- **Subject**: Email subject
- **Date**: Email date
- **Initial Content**: First email
- **Reply 1, 2, 3...**: Subsequent replies
- **Full Text**: Complete extracted text

### Next Steps
1. Open the Excel file
2. Review the extracted data
3. Use Excel filters/sorting to analyze
4. Check the log file for any warnings

---

## Need Help?

1. **Check the log file**: `email_extraction.log`
2. **Read error messages carefully**: They usually explain the problem
3. **Verify Python installation**: Run `python --version`
4. **Verify Tesseract** (if needed): Run `tesseract --version`
5. **Check this guide**: Most issues are covered above

---

## Quick Reference

### Files Created by This Tool
- `extract_emails_to_excel.py` - Main Python script
- `requirements_email_extraction.txt` - Python dependencies
- `RUN_EMAIL_EXTRACTION.ps1` - PowerShell launcher
- `START_EXTRACTION.bat` - Batch file launcher
- `EMAIL_EXTRACTION_README.md` - Detailed documentation
- `SETUP_GUIDE.md` - This file

### Files Created During Processing
- `epstein_emails_*.xlsx` - Output Excel file
- `email_extraction.log` - Processing log
- `extraction_progress.json` - Resume data

### Commands You Might Need
```powershell
# Check Python
python --version

# Check Tesseract
tesseract --version

# Install dependencies
python -m pip install -r requirements_email_extraction.txt

# Run extraction
python extract_emails_to_excel.py

# View log
notepad email_extraction.log
```

---

## Ready to Start?

1. ✅ Python installed with PATH
2. ✅ Tesseract installed (optional)
3. ✅ Double-click `START_EXTRACTION.bat`
4. ✅ Wait for completion
5. ✅ Open the Excel file

**Good luck with your extraction!**
