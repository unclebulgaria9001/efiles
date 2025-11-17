# 🚀 Background Mode - Email Extraction Guide

## Overview
Run the email extraction process in the background so you can continue using your computer while processing 388 PDFs (2-4 hours).

---

## 🎯 Quick Start

### Step 1: Start Background Process
```
Double-click: START_BACKGROUND.bat
```

The process will:
- ✅ Check Python and dependencies
- ✅ Install missing packages automatically
- ✅ Launch extraction in a minimized window
- ✅ Let you continue working immediately

### Step 2: Monitor Progress (Optional)
```
Double-click: MONITOR_PROGRESS.bat
```

This shows:
- 📊 Files processed (X / 388)
- 📧 Emails extracted
- ⏱️ Estimated time remaining
- 📝 Recent log entries
- 🔍 Live log viewer option

---

## 📁 Files for Background Mode

| File | Purpose |
|------|---------|
| **START_BACKGROUND.bat** | Start extraction in background |
| **MONITOR_PROGRESS.bat** | Check progress anytime |
| `RUN_BACKGROUND.ps1` | Background launcher script |
| `MONITOR_PROGRESS.ps1` | Progress monitoring script |

---

## 🎮 How It Works

### Starting the Process
1. Double-click `START_BACKGROUND.bat`
2. Confirm you want to start (press 'y')
3. A PowerShell window opens and minimizes
4. You can immediately close the launcher window
5. Continue using your computer normally

### Background Window
- Runs minimized in taskbar
- Shows progress messages
- Stays open until completion
- Can be closed anytime (progress is saved)

### Monitoring
- Open `MONITOR_PROGRESS.bat` anytime
- View current progress and stats
- Watch live log updates
- Check for output files

---

## 📊 Monitoring Options

### Option 1: Progress Monitor (Recommended)
```
Double-click: MONITOR_PROGRESS.bat
```

Shows:
- Current progress (X/388 files)
- Emails extracted count
- Estimated time remaining
- Recent log entries
- Interactive menu with options

### Option 2: Log File
Open `email_extraction.log` in any text editor:
- Notepad
- Notepad++
- VS Code
- Refresh to see updates

### Option 3: Progress File
Open `extraction_progress.json`:
```json
{
  "processed_files": ["file1.pdf", "file2.pdf", ...],
  "last_updated": "2024-01-15T14:30:00",
  "total_emails": 150
}
```

### Option 4: Background Window
- Find minimized PowerShell window in taskbar
- Click to restore and view live progress
- Shows real-time processing messages

---

## 🛑 Stopping the Process

### Method 1: Close Background Window
1. Find PowerShell window in taskbar
2. Right-click → Close
3. Progress is automatically saved
4. Resume later by running `START_BACKGROUND.bat` again

### Method 2: Task Manager
1. Open Task Manager (Ctrl+Shift+Esc)
2. Find "Windows PowerShell" process
3. End task
4. Progress is saved, can resume

### Resuming After Stop
- Just run `START_BACKGROUND.bat` again
- Already-processed files are skipped
- Continues from where it stopped
- No data is lost

---

## ⚡ Advantages of Background Mode

### ✅ Benefits
- **Keep working**: Use your computer normally
- **Minimized**: Doesn't clutter your screen
- **Resumable**: Stop and restart anytime
- **Monitored**: Check progress whenever you want
- **Safe**: Progress saved every 10 files
- **Automatic**: Installs dependencies if needed

### 🔄 vs. Foreground Mode
| Feature | Background | Foreground |
|---------|-----------|------------|
| Computer usage | ✅ Can use normally | ❌ Window stays open |
| Monitoring | Via separate tool | Direct in window |
| Resumable | ✅ Yes | ✅ Yes |
| Installation | ✅ Automatic | Manual prompts |
| Best for | Long sessions | Quick monitoring |

---

## 📈 Progress Tracking

### Real-Time Stats
The monitor shows:
```
Files Processed: 150 / 388
Emails Extracted: 145
Last Updated: 2024-01-15T14:30:00
Progress: 38.7%
Estimated Time Remaining: 2 hours 15 minutes
```

### Progress Indicators
- **0-25%**: Just getting started
- **25-50%**: Making good progress
- **50-75%**: Over halfway there
- **75-100%**: Almost done!

### Time Estimates
- Based on average 30 seconds per file
- Actual time varies by:
  - PDF complexity
  - Text vs. image-based
  - OCR requirements
  - Computer speed

---

## 🎯 Typical Workflow

### Morning Start
```
8:00 AM  - Double-click START_BACKGROUND.bat
8:01 AM  - Confirm start, window minimizes
8:02 AM  - Continue with your work
10:00 AM - Check MONITOR_PROGRESS.bat (25% done)
12:00 PM - Check again (50% done)
2:00 PM  - Check again (75% done)
4:00 PM  - Process complete! Open Excel file
```

### Lunch Break Start
```
12:00 PM - Start background process
12:01 PM - Go to lunch
1:00 PM  - Return, check progress (25% done)
4:00 PM  - Process complete
```

### Overnight Processing
```
6:00 PM  - Start background process
6:01 PM  - Go home for the day
9:00 AM  - Return, process complete!
```

---

## 🔧 Troubleshooting

### Background window closes immediately
**Problem**: Python or dependencies missing

**Solution**:
1. Run `CHECK_SETUP.bat` first
2. Install Python if needed
3. Try `START_BACKGROUND.bat` again

### Can't find background window
**Problem**: Window is minimized

**Solution**:
- Look in taskbar for PowerShell icon
- Or use `MONITOR_PROGRESS.bat` instead

### Process seems stuck
**Problem**: Might be processing a large/complex PDF

**Solution**:
1. Open `MONITOR_PROGRESS.bat`
2. Check recent log entries
3. Look for "Processing: filename.pdf"
4. Wait a few minutes, some PDFs take longer

### Want to see what's happening
**Solution**:
1. Open `MONITOR_PROGRESS.bat`
2. Select option [1] for live log viewer
3. Watch real-time processing

### Computer going to sleep
**Problem**: Long process might be interrupted

**Solution**:
- Adjust power settings to prevent sleep
- Or check "Prevent sleep when plugged in"
- Process will resume if interrupted

---

## 💡 Tips & Best Practices

### Before Starting
- ✅ Close unnecessary programs (free up resources)
- ✅ Ensure computer won't sleep
- ✅ Have at least 1GB free disk space
- ✅ Run `CHECK_SETUP.bat` first

### During Processing
- ✅ Can use computer normally
- ✅ Check progress occasionally
- ✅ Don't delete log or progress files
- ✅ Don't move/delete PDF files being processed

### Monitoring
- ✅ Check every hour or so
- ✅ Look for errors in log
- ✅ Verify progress is advancing
- ✅ Note estimated completion time

### If Interrupted
- ✅ Just restart with `START_BACKGROUND.bat`
- ✅ Already-processed files are skipped
- ✅ No need to start over

---

## 📝 Output Files

### During Processing
- `email_extraction.log` - Processing log (updates in real-time)
- `extraction_progress.json` - Resume data
- `background_runner.ps1` - Temporary background script

### After Completion
- `epstein_emails_YYYYMMDD_HHMMSS.xlsx` - **Your final Excel file!**
- `email_extraction.log` - Complete processing log
- `extraction_progress.json` - Final statistics

---

## 🎉 Completion

### When Process Finishes
The background window will show:
```
========================================
EXTRACTION COMPLETE!
========================================

Completed at: 2024-01-15 16:30:00

Check the directory for your Excel file:
  epstein_emails_20240115_163000.xlsx

Log file: email_extraction.log
```

### Next Steps
1. Find the Excel file (starts with `epstein_emails_`)
2. Open it in Excel, Google Sheets, or LibreOffice
3. Review the extracted email data
4. Check the log for any warnings

---

## 🆘 Quick Reference

### Start Background Process
```
START_BACKGROUND.bat
```

### Monitor Progress
```
MONITOR_PROGRESS.bat
```

### View Log
```
notepad email_extraction.log
```

### Check Progress File
```
notepad extraction_progress.json
```

### Find Output
```
Look for: epstein_emails_*.xlsx
```

---

## ✅ Checklist

Before starting background mode:
- [ ] Python installed with PATH
- [ ] Ran `CHECK_SETUP.bat` successfully
- [ ] Computer won't sleep during processing
- [ ] At least 1GB free disk space
- [ ] Know how to monitor progress

During processing:
- [ ] Background window is minimized (in taskbar)
- [ ] Can check `MONITOR_PROGRESS.bat` anytime
- [ ] Log file is updating
- [ ] Progress is advancing

After completion:
- [ ] Excel file created
- [ ] Log file shows success
- [ ] Can open and view Excel file

---

**Ready to start? Double-click `START_BACKGROUND.bat`! 🚀**
