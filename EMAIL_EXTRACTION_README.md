# Epstein Email PDF Extraction Tool

## Overview
This tool extracts email content from 388 PDF files and organizes them into a structured Excel spreadsheet with columns for:
- Filename
- Subject
- Date
- Initial Content
- Reply 1, Reply 2, Reply 3, etc. (as many as needed)
- Full Text

## Features
- **Multi-method PDF extraction**: Uses pdfplumber and PyPDF2 for text extraction
- **OCR support**: Automatically performs OCR on image-based PDFs using Tesseract
- **Email thread parsing**: Intelligently splits email threads into initial message and replies
- **Progress tracking**: Saves progress every 10 files, allowing you to resume if interrupted
- **Excel formatting**: Creates a well-formatted Excel file with proper column widths and styling
- **Comprehensive logging**: All activity logged to `email_extraction.log`

## Quick Start

### Option 1: Double-click to run
Simply double-click `START_EXTRACTION.bat`

### Option 2: PowerShell
```powershell
.\RUN_EMAIL_EXTRACTION.ps1
```

### Option 3: Manual Python
```bash
pip install -r requirements_email_extraction.txt
python extract_emails_to_excel.py
```

## Requirements

### Required
- **Python 3.8+**: [Download here](https://www.python.org/downloads/)
- **Python packages**: Automatically installed by the script
  - pdfplumber
  - PyPDF2
  - pandas
  - openpyxl
  - Pillow

### Optional (for OCR)
- **Tesseract OCR**: [Download here](https://github.com/UB-Mannheim/tesseract/wiki)
  - Required only for image-based PDFs
  - Most PDFs contain extractable text and won't need OCR

## Process Details

### What the script does:
1. Scans the `extracted` directory for all PDF files (388 total)
2. For each PDF:
   - Extracts text using pdfplumber (primary method)
   - Falls back to PyPDF2 if needed
   - Performs OCR if no text is found (requires Tesseract)
   - Parses email structure (subject, date, body, replies)
3. Saves progress every 10 files
4. Creates final Excel spreadsheet with all extracted data

### Estimated Time
- **With text-based PDFs**: 1-2 hours
- **With OCR needed**: 3-4 hours
- Progress is saved, so you can stop and resume anytime

## Output

### Excel File
- **Location**: Same directory as the script
- **Filename**: `epstein_emails_YYYYMMDD_HHMMSS.xlsx`
- **Sheet**: "Emails"
- **Columns**:
  - Filename: Source PDF filename
  - Subject: Email subject line
  - Date: Email date/timestamp
  - Initial Content: First email in the thread
  - Reply 1, Reply 2, etc.: Subsequent replies in the thread
  - Full Text: Complete extracted text (first 10,000 characters)

### Log File
- **Location**: `email_extraction.log`
- **Contains**: Detailed processing information, errors, and progress

### Progress File
- **Location**: `extraction_progress.json`
- **Contains**: List of processed files (for resuming)

## Resuming Interrupted Processing

If the process is interrupted:
1. Simply run the script again
2. It will automatically skip already-processed files
3. Continue from where it left off

To start fresh:
1. Delete `extraction_progress.json`
2. Run the script again

## Troubleshooting

### "Python not found"
- Install Python from https://www.python.org/downloads/
- Make sure to check "Add Python to PATH" during installation

### "Tesseract not found" warning
- This is OK if your PDFs contain extractable text
- Only needed for scanned/image PDFs
- Install from: https://github.com/UB-Mannheim/tesseract/wiki

### "No text extracted" warnings
- Some PDFs may be empty or corrupted
- Check the log file for specific files
- These will be skipped automatically

### Script runs slowly
- Normal for 388 files
- OCR is particularly slow (if needed)
- Progress is saved every 10 files
- You can stop and resume anytime

### Excel file is large
- Normal - contains all email content
- File size depends on amount of text extracted
- Can be opened in Excel, Google Sheets, or LibreOffice

## Advanced Usage

### Modify extraction parameters
Edit `extract_emails_to_excel.py`:
- Line 156: `text[:5000]` - Change character limit for initial content
- Line 157: `p[:5000]` - Change character limit for replies
- Line 163: `text[:10000]` - Change character limit for full text
- Line 275: `if idx % 10 == 0:` - Change progress save frequency

### Custom output location
Edit line 32 in `extract_emails_to_excel.py`:
```python
self.output_file = Path("your/custom/path/emails.xlsx")
```

## Technical Details

### Email Parsing Logic
The script looks for:
- **Subject patterns**: "Subject:", "Re:", "Fwd:"
- **Date patterns**: Various date formats (MM/DD/YYYY, Month DD YYYY, etc.)
- **Thread separators**: "Original Message", "From:", "On...wrote:", etc.

### Text Extraction Priority
1. pdfplumber (best for formatted documents)
2. PyPDF2 (fallback for compatibility)
3. OCR via Tesseract (for image-based PDFs)

### Data Limits
- Initial content: 5,000 characters
- Each reply: 5,000 characters
- Full text: 10,000 characters
- (Prevents Excel cell size issues while preserving content)

## Support

For issues or questions:
1. Check `email_extraction.log` for detailed error messages
2. Review this README for troubleshooting steps
3. Ensure all requirements are installed

## License
This tool is provided as-is for document processing purposes.
