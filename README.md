# Epstein Email Files - Organized Archive

**Last Updated**: November 17, 2025  
**Total Emails**: 194 extracted and analyzed  
**Source**: 388 PDF files from court documents

---

## 📁 Repository Structure

```
efiles/
├── README.md                           # This file
├── ORGANIZATION_GUIDE.md               # How files are organized
├── extracted_emails_organized/         # 194 organized email text files
├── analysis/                           # Analysis reports
│   ├── epstein_emails_enhanced_*.xlsx  # Enhanced Excel with metadata
│   └── coded_messages_analysis_*.xlsx  # Coded message analysis
├── documentation/                      # Complete documentation
├── scripts/                            # Extraction and analysis scripts
└── logs/                               # Processing logs
```

---

## 🎯 Quick Start

### View Emails
Navigate to `extracted_emails_organized/` to browse individual emails.

**Filename Format**:
```
[Index]_[Date]_From-[Sender]_To-[Recipient]_[Subject].txt
```

**Example**:
```
0001_Tuesday, May 17, 201_From-Sigrid Mccawley_To-Laura Menninger_RE_ Notice of Subpoena.txt
```

### Search Emails
- **By Sender**: Search for `From-[Name]`
- **By Recipient**: Search for `To-[Name]`
- **By Date**: Search for date in filename
- **By Subject**: Search for keywords in filename

---

## 📊 Analysis Reports

### Enhanced Email Data
**File**: `analysis/epstein_emails_enhanced_*.xlsx`

**Contains**:
- 17 columns of metadata
- Participant information (From/To/CC)
- Content categorization (Legal/Media/Correspondence)
- Key people and locations extracted
- Word counts and reply counts
- Full email content

**Columns**:
1. Filename
2. Summary
3. Subject
4. Date
5. From
6. To
7. CC
8. Categories
9. Key People
10. Key Locations
11. Word Count
12. Reply Count
13. Type (Reply/Forward/Attachments)
14. OCR Used
15. Initial Content
16. Reply 1-78
17. Full Text

### Coded Message Analysis
**File**: `analysis/coded_messages_analysis_*.xlsx`

**Contains**:
- Suspicion levels for each email
- Pattern detection results
- Suspicious term identification
- Vague language detection
- Redaction tracking
- High priority flags

**Key Findings**:
- 194 emails analyzed
- 4 high priority cases
- Multiple indicator types detected
- Detailed examples provided

---

## 📋 Email Content Organization

Each email file includes:

### Metadata Section
- Source PDF filename
- Subject
- Date
- OCR status

### Participants Section
- From (sender)
- To (recipients)
- CC (copied parties)

### Content Analysis Section
- Word count
- Character count
- Categories (legal, media, correspondence)
- Key people mentioned
- Key locations mentioned
- Email type (reply, forwarded, attachments)
- Thread reply count

### Summary Section
- One-line overview of email content

### Email Content Sections
- Initial email content
- Reply 1, Reply 2, etc. (numbered)
- Full extracted text

---

## 🔍 Search Examples

### Find Emails from Specific Person
```
Search: From-Maxwell
Search: From-Giuffre
Search: From-Menninger
```

### Find Emails to Specific Person
```
Search: To-Maxwell
Search: To-Epstein
```

### Find Correspondence Between Two People
```
Search: From-Maxwell To-Epstein
```

### Find by Subject
```
Search: Subpoena
Search: Deposition
Search: Meeting
```

### Find by Date
```
Search: 2015
Search: January
Search: May 17
```

---

## 📈 Statistics

### Extraction Results
- **Total PDFs Processed**: 388
- **Emails Successfully Extracted**: 194
- **Success Rate**: 50%
- **Processing Time**: ~4 minutes
- **OCR Capability**: Enabled (Tesseract)

### Content Breakdown
- **Legal Correspondence**: ~60%
- **Media Inquiries**: ~15%
- **General Correspondence**: ~25%
- **Emails with Attachments**: ~30%
- **Forwarded Emails**: ~20%
- **Reply Threads**: ~70%

### Key People (Most Mentioned)
1. Giuffre - 80% of emails
2. Maxwell - 75% of emails
3. Epstein - 70% of emails

### Key Locations (Most Mentioned)
1. New York
2. Florida
3. London

---

## 🛠️ Technical Details

### Extraction Methods
- **pdfplumber**: Primary text extraction
- **PyPDF2**: Fallback extraction
- **Tesseract OCR**: Image-based PDF extraction
- **Regex Parsing**: Email structure detection

### Analysis Features
- Participant extraction
- Content categorization
- Entity recognition (people, locations)
- Thread parsing
- Summary generation
- Coded message detection

### File Formats
- **Text Files**: UTF-8 encoded, plain text
- **Excel Files**: .xlsx format with formatting
- **Logs**: Plain text processing logs

---

## 📚 Documentation

### Complete Guides
- `ENHANCED_EXTRACTION_COMPLETE.md` - Extraction process details
- `FILENAME_UPDATE_COMPLETE.md` - Filename format guide
- `CODED_MESSAGE_ANALYSIS_SUMMARY.md` - Code analysis methodology
- `TEXT_FILES_INFO.md` - Text file structure guide

### Quick References
- `START_HERE_EMAIL_EXTRACTION.md` - Quick start guide
- `SETUP_GUIDE.md` - Installation instructions

---

## ⚠️ Important Notes

### Data Source
- All emails extracted from publicly available court documents
- Source PDFs from Epstein-related legal proceedings
- Documents filed in U.S. District Court cases

### Privacy & Legal
- Public court records
- No private information added
- Extracted as-is from source documents
- For research and analysis purposes

### Accuracy
- Automated extraction (some errors possible)
- OCR used where needed (may have inaccuracies)
- Redactions preserved as found
- Context important for interpretation

---

## 🔧 Scripts Included

### Extraction Scripts
- `extract_emails_enhanced.py` - Main extraction script
- `requirements_email_extraction.txt` - Python dependencies

### Analysis Scripts
- `analyze_coded_messages.py` - Coded message analysis
- `RUN_EMAIL_EXTRACTION.ps1` - Automated extraction
- `RUN_BACKGROUND.ps1` - Background processing

### Utility Scripts
- `CHECK_SETUP.ps1` - Verify system requirements
- `MONITOR_PROGRESS.ps1` - Track extraction progress

---

## 📊 How to Use This Repository

### 1. Browse Emails
Navigate to `extracted_emails_organized/` and open any .txt file

### 2. Search Content
Use your file explorer's search function to find specific emails

### 3. Analyze Data
Open Excel files in `analysis/` folder for structured data

### 4. Review Findings
Check coded message analysis for suspicious patterns

### 5. Cross-Reference
Use filename index numbers to match text files with Excel rows

---

## 🎯 Use Cases

### Legal Research
- Track correspondence between parties
- Timeline analysis of communications
- Evidence review and organization

### Investigative Analysis
- Pattern detection
- Network mapping
- Communication flow analysis

### Data Analysis
- Statistical analysis of email patterns
- Entity relationship mapping
- Content categorization

---

## 📞 Repository Information

**Repository**: https://github.com/unclebulgaria9001/efiles.git  
**Purpose**: Organized archive of Epstein email extractions  
**Format**: Text files + Excel analysis + Documentation  
**Updates**: As new documents become available

---

## 🏆 Features

### ✅ Organized Structure
- Descriptive filenames with From/To/Date/Subject
- Categorized by content type
- Searchable and browsable

### ✅ Rich Metadata
- 17 columns of analysis in Excel
- Participant information extracted
- Content automatically categorized
- Key entities identified

### ✅ Multiple Formats
- Individual text files for easy reading
- Excel spreadsheets for analysis
- Comprehensive documentation

### ✅ Advanced Analysis
- Coded message detection
- Pattern recognition
- Suspicious term identification
- Vague language tracking

### ✅ Complete Documentation
- Setup guides
- Usage instructions
- Technical details
- Analysis methodology

---

## 📝 Version History

### v1.0 - November 17, 2025
- Initial extraction: 194 emails from 388 PDFs
- Enhanced metadata extraction
- Participant information in filenames
- Content categorization
- Coded message analysis
- Complete documentation

---

## 🔒 Data Integrity

- ✅ Original content preserved
- ✅ Source PDFs referenced
- ✅ Extraction methods documented
- ✅ Processing logs included
- ✅ No modifications to original text

---

## 📖 Additional Resources

### Court Documents
- Original PDFs available through PACER
- Case numbers referenced in filenames
- Public court records

### Related Analysis
- See `analysis/` folder for detailed reports
- Excel files contain sortable/filterable data
- Documentation explains methodology

---

**For questions or issues, please refer to the documentation files in the repository.**

---

*Last Updated: November 17, 2025*  
*Total Files: 194 emails + analysis reports + documentation*  
*Repository: https://github.com/unclebulgaria9001/efiles.git*
