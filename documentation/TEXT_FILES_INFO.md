# 📄 Individual Text Files - Information

## Overview
In addition to the Excel spreadsheet, each email is now saved as an individual text file with a descriptive filename for easy searching and browsing.

---

## 📁 Location
**Folder**: `extracted_text_files/`

All text files are saved in this dedicated folder within the main directory.

---

## 📝 Filename Format

Each text file is named using this pattern:
```
[Index]_[Date]_[Subject].txt
```

### Components:
- **Index**: 4-digit number (0001, 0002, etc.) - processing order
- **Date**: Extracted email date (sanitized for filenames)
- **Subject**: Email subject line (sanitized, max 60 characters)

### Examples:
```
0001_Tuesday, May 17, 201_RE_ Notice of Subpoena.txt
0002_Friday, June 24, 201_untitled.txt
0009_Thursday, June 16, 2_Proof of Service - Second Email.txt
0081_Monday,July18,20162__RE_Giuffre- Conferralregardingsearchterms.txt
```

---

## 📋 File Contents

Each text file contains:

### Header Section
```
================================================================================
EMAIL EXTRACTION FROM: [original_pdf_filename]
================================================================================

Subject: [Email subject]
Date: [Email date]
Source PDF: [PDF filename]
```

### Initial Email Content
```
================================================================================
INITIAL EMAIL CONTENT
================================================================================

[First email in the thread]
```

### Replies (if any)
```
================================================================================
REPLY 1
================================================================================

[First reply content]

================================================================================
REPLY 2
================================================================================

[Second reply content]

... (continues for all replies)
```

### Full Text
```
================================================================================
FULL EXTRACTED TEXT
================================================================================

[Complete extracted text from PDF]
```

---

## 🔍 Finding Emails

### By Subject
Files are named with the subject, so you can:
- Sort by name to group similar subjects
- Search for keywords in filenames
- Use Windows search to find specific subjects

### By Date
Files include the date in the filename:
- Sort chronologically
- Search for specific date ranges
- Filter by month/year

### By Index
The 4-digit index preserves processing order:
- Sequential numbering (0001-0388)
- Matches the row number in Excel
- Easy cross-reference between Excel and text files

---

## 💡 Usage Tips

### Windows Explorer
1. Navigate to `extracted_text_files/` folder
2. Use the search box to find keywords
3. Sort by name to group by date or subject
4. Preview files with Quick Look (spacebar)

### Search Examples
- Find all emails about "subpoena": Search filename for "subpoena"
- Find May 2016 emails: Search for "May" in filename
- Find specific person: Open files and Ctrl+F to search content

### Opening Files
- Double-click to open in Notepad
- Right-click → "Open with" for other editors
- Use Notepad++, VS Code, or any text editor for better viewing

---

## 📊 File Statistics

- **Total Files**: 388 (one per PDF)
- **Format**: Plain text (.txt)
- **Encoding**: UTF-8
- **Average Size**: ~10-20 KB per file
- **Total Size**: ~4-8 MB for all files

---

## 🎯 Benefits

### Easy Browsing
- Browse emails like regular files
- No need to open Excel for quick checks
- Drag and drop into other applications

### Full-Text Search
- Use Windows search across all files
- Find emails by any content keyword
- Search tools can index the folder

### Portable
- Share individual emails easily
- Copy specific files without the full dataset
- Email-friendly format

### Backup
- Simple to backup (just copy folder)
- Version control friendly
- Easy to archive

---

## 🔄 Relationship to Excel File

### Cross-Reference
- **Text file index** = **Excel row number**
- Example: `0025_...txt` = Row 25 in Excel
- Both contain the same email data

### When to Use Each

**Use Text Files When:**
- Quickly browsing individual emails
- Searching for specific content
- Sharing a single email
- Reading full email threads
- Need plain text format

**Use Excel When:**
- Analyzing multiple emails
- Sorting/filtering by criteria
- Creating reports
- Comparing emails side-by-side
- Need structured data

---

## 📁 Folder Structure

```
Epstein Email Dump/
├── extracted_text_files/          ← Individual text files here
│   ├── 0001_[date]_[subject].txt
│   ├── 0002_[date]_[subject].txt
│   ├── ...
│   └── 0388_[date]_[subject].txt
├── epstein_emails_[timestamp].xlsx ← Excel spreadsheet
├── email_extraction.log            ← Processing log
└── extraction_progress.json        ← Progress tracker
```

---

## 🛠️ Technical Details

### Filename Sanitization
Invalid characters are replaced with underscores:
- `< > : " / \ | ? *` → `_`
- Extra spaces removed
- Trailing dots/spaces removed
- Length limited to prevent path issues

### Content Format
- Section headers: 80 equals signs
- Clear section labels
- Preserved original text formatting
- UTF-8 encoding for international characters

### File Creation
- Created during PDF processing
- One file per successfully processed PDF
- Skipped if PDF has no extractable content
- Logged in `email_extraction.log`

---

## ✅ Quality Assurance

### Filename Safety
- All filenames are Windows-compatible
- No special characters that cause issues
- Length limits prevent path errors
- Unique index prevents duplicates

### Content Accuracy
- Exact same data as Excel file
- All replies preserved
- Full text included
- Source PDF referenced

### Organization
- Sequential numbering
- Descriptive names
- Single dedicated folder
- Easy to navigate

---

## 📝 Example File Content

```
================================================================================
EMAIL EXTRACTION FROM: 1325-4.pdf
================================================================================

Subject: RE: Notice of Subpoena
Date: Tuesday, May 17, 2016 at 1:08 PM
Source PDF: 1325-4.pdf

================================================================================
INITIAL EMAIL CONTENT
================================================================================

Hello Laura - We are working on the calendar and I have it almost complete...

================================================================================
REPLY 1
================================================================================

Sent: Tuesday, May 17, 2016 3:53 PM
To: Laura Menninger; Meredith Schultz; Jeff Pagliuca
Subject: RE: Notice of Subpoena

We were serving subpoenas on dates that we thought are grouped...

================================================================================
FULL EXTRACTED TEXT
================================================================================

[Complete PDF text content here...]
```

---

## 🎉 Summary

**What You Get:**
- 388 individual text files
- Descriptive, searchable filenames
- Well-formatted, readable content
- Easy to browse and search
- Complements the Excel spreadsheet

**Location:**
`G:\My Drive\04_Resources\Notes\Epstein Email Dump\extracted_text_files\`

**Ready to Use:**
- Files are being created as extraction progresses
- Check the folder to see files appearing
- Final count will be 388 files when complete

---

*Text files are created automatically during the extraction process*
*Each file corresponds to one row in the Excel spreadsheet*
