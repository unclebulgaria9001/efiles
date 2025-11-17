# 📧 Epstein Email PDF to Excel Extraction Tool

## 🎯 Overview
This tool processes **388 PDF files** containing Epstein emails and extracts them into a structured Excel spreadsheet with proper email threading (subject, date, initial content, replies).

---

## 🚀 Quick Start Guide

### 1️⃣ First Time Setup

**Step 1**: Verify your system is ready
```
Double-click: CHECK_SETUP.bat
```

**Step 2**: If Python is missing, install it
- Download: https://www.python.org/downloads/
- ⚠️ **CRITICAL**: Check "Add Python to PATH" during installation
- Restart your computer after installation

**Step 3**: Run setup check again
```
Double-click: CHECK_SETUP.bat
```
Should show all green checkmarks ✓

### 2️⃣ Run the Extraction

```
Double-click: START_EXTRACTION.bat
```

That's it! The process will:
- Extract text from all 388 PDFs
- Parse email threads
- Perform OCR on images (if Tesseract installed)
- Save progress every 10 files
- Create Excel spreadsheet with results

**Expected Time**: 2-4 hours

---

## 📁 File Guide

### 🟢 Files to Use

| File | Purpose | When to Use |
|------|---------|-------------|
| **CHECK_SETUP.bat** | Verify system ready | Run first, before extraction |
| **START_EXTRACTION.bat** | Run the extraction | After setup is verified |
| **START_HERE_EMAIL_EXTRACTION.md** | Quick reference guide | When you need quick help |
| **SETUP_GUIDE.md** | Detailed setup instructions | If you have installation issues |
| **EMAIL_EXTRACTION_README.md** | Technical documentation | For advanced configuration |

### 🔵 Script Files (Don't Edit)

| File | Purpose |
|------|---------|
| `extract_emails_to_excel.py` | Main Python extraction script |
| `RUN_EMAIL_EXTRACTION.ps1` | PowerShell automation script |
| `CHECK_SETUP.ps1` | System verification script |
| `requirements_email_extraction.txt` | Python package list |

### 🟡 Output Files (Created During Processing)

| File | Description |
|------|-------------|
| `epstein_emails_*.xlsx` | **Your final Excel output** |
| `email_extraction.log` | Detailed processing log |
| `extraction_progress.json` | Resume data (if interrupted) |

---

## 📊 Excel Output Structure

The generated Excel file will have these columns:

| Column | Description | Example |
|--------|-------------|---------|
| **Filename** | Source PDF name | `1325-1.pdf` |
| **Subject** | Email subject | `Re: Meeting tomorrow` |
| **Date** | Email timestamp | `Jan 15, 2015` |
| **Initial Content** | First email in thread | `Hi John, Can we meet...` |
| **Reply 1** | First reply | `Sure, what time works...` |
| **Reply 2** | Second reply | `How about 3pm...` |
| **Reply 3+** | Additional replies | (as many as needed) |
| **Full Text** | Complete extracted text | (entire PDF content) |

---

## ⚙️ System Requirements

### Required
- ✅ **Windows 10/11**
- ✅ **Python 3.8+** (with PATH)
- ✅ **4GB RAM minimum** (8GB recommended)
- ✅ **1GB free disk space**

### Optional
- ⚠️ **Tesseract OCR** (for scanned/image PDFs)
  - Most PDFs work fine without it
  - Only needed if PDFs are scanned images
  - Download: https://github.com/UB-Mannheim/tesseract/wiki

---

## 🔧 Troubleshooting

### ❌ "Python was not found"
**Problem**: Python not installed or not in PATH

**Solution**:
1. Install Python from https://www.python.org/downloads/
2. During installation, CHECK the box: "Add Python to PATH"
3. Restart computer
4. Run `CHECK_SETUP.bat` again

### ❌ "pip not found"
**Problem**: pip package manager missing

**Solution**:
```powershell
python -m ensurepip --upgrade
```

### ⚠️ "Tesseract not found" (Warning)
**Problem**: Tesseract OCR not installed

**Solution**:
- **If PDFs are text-based**: Ignore this warning, continue
- **If PDFs are scanned images**: Install Tesseract
  1. Download: https://github.com/UB-Mannheim/tesseract/wiki
  2. Install and add to PATH
  3. Restart PowerShell

### 🐌 "Script is very slow"
**This is normal!**
- 388 PDFs take time to process
- OCR is particularly slow (if used)
- Progress is saved every 10 files
- You can stop and resume anytime

### 🛑 "Process was interrupted"
**Solution**: Just run `START_EXTRACTION.bat` again
- Script automatically resumes from where it stopped
- Already-processed files are skipped
- No data is lost

### 🔄 "Want to start fresh"
**Solution**: 
1. Delete `extraction_progress.json`
2. Run `START_EXTRACTION.bat` again

### 📄 "No text extracted" warnings
**Problem**: Some PDFs might be empty or corrupted

**Solution**: This is OK
- Script will skip problematic files
- Continue processing remaining files
- Check log for specific file names

### 💾 "Excel file won't open"
**Problem**: File might be too large

**Solution**:
- Try Google Sheets (handles larger files)
- Try LibreOffice Calc (free alternative)
- File size depends on amount of extracted text

---

## 📈 Monitoring Progress

### Real-Time Monitoring
Open `email_extraction.log` in any text editor:
- Notepad
- Notepad++
- VS Code
- Refresh to see latest updates

### Check Progress
Open `extraction_progress.json` to see:
```json
{
  "processed_files": ["file1.pdf", "file2.pdf", ...],
  "last_updated": "2024-01-15T14:30:00",
  "total_emails": 150
}
```

### Console Output
The script shows:
```
Processing 1/388: 1325-1.pdf
Processing 2/388: 1325-2.pdf
...
Progress saved: 10/388 files processed
```

---

## 🎓 Advanced Usage

### Modify Extraction Parameters

Edit `extract_emails_to_excel.py`:

**Change character limits**:
```python
# Line 156 - Initial content limit
email_data['initial_content'] = parts[0][:5000]  # Change 5000

# Line 157 - Reply content limit  
email_data['replies'] = [p[:5000] for p in parts[1:]]  # Change 5000

# Line 163 - Full text limit
email_data['full_text'] = text[:10000]  # Change 10000
```

**Change progress save frequency**:
```python
# Line 275 - Save every N files
if idx % 10 == 0:  # Change 10 to desired number
```

### Custom Output Location
```python
# Line 32 - Change output path
self.output_file = Path("C:/Your/Custom/Path/emails.xlsx")
```

### Run Manually (Advanced)
```powershell
# Navigate to directory
cd "G:\My Drive\04_Resources\Notes\Epstein Email Dump"

# Install dependencies
python -m pip install -r requirements_email_extraction.txt

# Run extraction
python extract_emails_to_excel.py

# Monitor log
Get-Content email_extraction.log -Wait
```

---

## 📚 Technical Details

### PDF Processing Pipeline
1. **Text Extraction**: pdfplumber (primary) → PyPDF2 (fallback)
2. **OCR**: Tesseract (if text extraction fails)
3. **Email Parsing**: Regex patterns for subject, date, threading
4. **Excel Export**: pandas + openpyxl with formatting

### Email Parsing Patterns
**Subject Detection**:
- `Subject:`, `Re:`, `Fwd:`, `SUBJECT:`

**Date Detection**:
- `Date:`, `Sent:`, `DATE:`
- `MM/DD/YYYY`, `Month DD, YYYY`, `YYYY-MM-DD`

**Thread Separation**:
- `--- Original Message ---`
- `--- Forwarded message ---`
- `From: ... wrote:`
- Multiple underscores/equals signs

### Data Limits (Prevent Excel Issues)
- Initial content: 5,000 characters
- Each reply: 5,000 characters
- Full text: 10,000 characters

---

## 🔒 Privacy & Safety

- ✅ **No internet connection required**
- ✅ **All processing is local**
- ✅ **Original PDFs never modified**
- ✅ **No data sent anywhere**
- ✅ **Open source Python script (you can review it)**

---

## 📝 Workflow Summary

```
1. CHECK_SETUP.bat
   ↓
2. Install Python (if needed)
   ↓
3. CHECK_SETUP.bat (verify)
   ↓
4. START_EXTRACTION.bat
   ↓
5. Wait 2-4 hours
   ↓
6. Open epstein_emails_*.xlsx
```

---

## 🆘 Getting Help

### Check These First
1. ✅ Run `CHECK_SETUP.bat` - shows what's wrong
2. ✅ Read `email_extraction.log` - detailed error info
3. ✅ Check `SETUP_GUIDE.md` - step-by-step instructions

### Common Issues Covered
- Python installation
- PATH configuration
- Package installation
- Tesseract setup
- Resume interrupted processing
- Excel file issues

---

## 📦 What's Included

### Core Files
- ✅ Python extraction script
- ✅ PowerShell automation
- ✅ Batch file launchers
- ✅ Requirements file
- ✅ Setup verification

### Documentation
- ✅ Quick start guide
- ✅ Detailed setup guide
- ✅ Technical README
- ✅ This comprehensive guide

### Features
- ✅ Multi-method PDF extraction
- ✅ OCR support
- ✅ Email thread parsing
- ✅ Progress tracking
- ✅ Resume capability
- ✅ Excel formatting
- ✅ Comprehensive logging

---

## ✅ Pre-Flight Checklist

Before running extraction:
- [ ] Python 3.8+ installed
- [ ] "Add to PATH" was checked during Python install
- [ ] Ran `CHECK_SETUP.bat` successfully
- [ ] All checkmarks are green ✓
- [ ] Have 2-4 hours available (or can resume later)
- [ ] At least 1GB free disk space

Optional:
- [ ] Tesseract installed (for scanned PDFs)

---

## 🎉 Ready to Start?

1. **Verify**: Run `CHECK_SETUP.bat`
2. **Extract**: Run `START_EXTRACTION.bat`
3. **Wait**: 2-4 hours (resumable)
4. **Open**: `epstein_emails_*.xlsx`

**Good luck! 🚀**

---

## 📞 Support Resources

- **Quick Help**: `START_HERE_EMAIL_EXTRACTION.md`
- **Setup Issues**: `SETUP_GUIDE.md`
- **Technical Details**: `EMAIL_EXTRACTION_README.md`
- **Processing Log**: `email_extraction.log`
- **This Guide**: `README_EMAIL_EXTRACTION.md`

---

*Last Updated: 2024*
*Processing 388 Epstein Email PDFs → Structured Excel Output*
