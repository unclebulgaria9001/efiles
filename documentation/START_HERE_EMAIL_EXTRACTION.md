# 📧 Epstein Email Extraction - START HERE

## 🎯 What This Does
Extracts email content from **388 PDF files** and creates an organized Excel spreadsheet with:
- Subject
- Date  
- Initial email content
- All replies (Reply 1, Reply 2, Reply 3, etc.)
- Full text
- Images (OCR extracted)

---

## ⚡ Quick Start (3 Steps)

### Step 1: Check Setup
Double-click: **`CHECK_SETUP.bat`**

This will verify:
- ✅ Python is installed
- ✅ Required packages are available
- ✅ PDF files are found
- ⚠️ Tesseract OCR (optional)

### Step 2: Install (if needed)
If Step 1 shows missing items:
1. **Install Python**: https://www.python.org/downloads/
   - ⚠️ **IMPORTANT**: Check "Add Python to PATH" during installation
2. **Install Tesseract** (optional): https://github.com/UB-Mannheim/tesseract/wiki
3. Run `CHECK_SETUP.bat` again

### Step 3: Run Extraction

**🚀 RECOMMENDED - Background Mode:**
Double-click: **`START_BACKGROUND.bat`**
- Runs in background (minimized window)
- Continue using your computer
- Monitor with `MONITOR_PROGRESS.bat`

**OR - Foreground Mode:**
Double-click: **`START_EXTRACTION.bat`**
- Runs in active window
- See live progress directly
- Window stays open

Then wait 2-4 hours for completion.

---

## 📁 Files You Need

### To Run
- **`START_BACKGROUND.bat`** ← **RECOMMENDED** - Run in background
- **`MONITOR_PROGRESS.bat`** ← Check progress anytime
- **`CHECK_SETUP.bat`** ← Verify setup first
- `START_EXTRACTION.bat` ← Alternative: foreground mode

### Documentation
- **`BACKGROUND_MODE_GUIDE.md`** ← How to use background mode
- **`SETUP_GUIDE.md`** ← Detailed setup instructions
- **`EMAIL_EXTRACTION_README.md`** ← Technical documentation

### Created by Script
- **`extract_emails_to_excel.py`** ← Main Python script
- **`requirements_email_extraction.txt`** ← Python dependencies
- **`RUN_EMAIL_EXTRACTION.ps1`** ← PowerShell runner

---

## ⏱️ What to Expect

### Processing Time
- **388 PDF files** to process
- **1-2 hours** for text-based PDFs
- **3-4 hours** if OCR is needed
- Progress saved every 10 files (resumable)

### Output Files
- **Excel**: `epstein_emails_YYYYMMDD_HHMMSS.xlsx`
- **Log**: `email_extraction.log`
- **Progress**: `extraction_progress.json`

---

## 🔧 Troubleshooting

### Python Not Found
**Error**: "Python was not found"
**Fix**: Install Python with "Add to PATH" checked
**Link**: https://www.python.org/downloads/

### Tesseract Warning
**Warning**: "Tesseract not found"
**Fix**: Only needed for scanned PDFs - most PDFs work without it
**Link**: https://github.com/UB-Mannheim/tesseract/wiki

### Process Interrupted
**Problem**: Script stopped before finishing
**Fix**: Just run `START_EXTRACTION.bat` again - it will resume automatically

### Want to Start Over
**Fix**: Delete `extraction_progress.json` and run again

---

## 📊 Excel Output Structure

| Column | Description |
|--------|-------------|
| Filename | Source PDF filename |
| Subject | Email subject line |
| Date | Email date/timestamp |
| Initial Content | First email in thread |
| Reply 1 | First reply |
| Reply 2 | Second reply |
| Reply 3+ | Additional replies (as many as needed) |
| Full Text | Complete extracted text |

---

## 🎓 Advanced Options

### Monitor Progress
Open `email_extraction.log` in a text editor while running

### Resume Interrupted Process
Just run the script again - already processed files are skipped

### Modify Extraction
Edit `extract_emails_to_excel.py`:
- Line 156: Character limit for initial content
- Line 157: Character limit for replies  
- Line 275: Progress save frequency

---

## 📞 Need Help?

1. **Check**: `email_extraction.log` for error details
2. **Read**: `SETUP_GUIDE.md` for detailed instructions
3. **Verify**: Run `CHECK_SETUP.ps1` to diagnose issues

---

## ✅ Checklist

Before running extraction:
- [ ] Python 3.8+ installed with PATH
- [ ] Ran `CHECK_SETUP.ps1` successfully
- [ ] Have 2-4 hours available (or can resume later)
- [ ] Tesseract installed (optional, for scanned PDFs)

Ready? **Double-click `START_EXTRACTION.bat`**

---

## 📝 Notes

- **Resumable**: Stop and restart anytime
- **Safe**: Original PDFs are never modified
- **Logged**: Everything tracked in `email_extraction.log`
- **Progress**: Saved every 10 files automatically

---

**Good luck with your extraction! 🚀**
