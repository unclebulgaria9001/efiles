# Person Alias and Nickname System

**Purpose**: Link people with their various names, aliases, and nicknames  
**Created**: November 17, 2025

---

## Overview

The timeline currently has duplicate entries for the same person under different names. For example:

- "Epstein", "Jeffrey", "Jeffrey Epstein", "J. Epstein", "JE" → All the same person
- "Maxwell", "Ghislaine", "Ghislaine Maxwell", "GM" → All the same person
- "Virginia Roberts", "Virginia Giuffre", "Giuffre", "VG" → All the same person

This system consolidates these duplicates into canonical names.

---

## Problem

### **Current State**
```json
{
  "people": ["Epstein", "Maxwell", "Jeffrey", "Ghislaine"]
}
```

**Issues**:
- "Epstein" and "Jeffrey" are the same person (Jeffrey Epstein)
- "Maxwell" and "Ghislaine" are the same person (Ghislaine Maxwell)
- VIP timelines are split across multiple names
- Event counts are inaccurate

### **After Consolidation**
```json
{
  "people": ["Jeffrey Epstein", "Ghislaine Maxwell"]
}
```

**Benefits**:
- ✅ Accurate person identification
- ✅ Correct event counts
- ✅ Better VIP timelines
- ✅ Cleaner data

---

## Alias Mapping

### **Core Figures**

#### **Jeffrey Epstein**
**Canonical Name**: `Jeffrey Epstein`  
**Aliases**:
- Epstein
- Jeffrey
- Jeff Epstein
- J. Epstein
- JE
- Mr. Epstein

#### **Ghislaine Maxwell**
**Canonical Name**: `Ghislaine Maxwell`  
**Aliases**:
- Maxwell
- Ghislaine
- G. Maxwell
- GM
- Ms. Maxwell
- Defendant Maxwell
- Defendant

#### **Virginia Roberts Giuffre**
**Canonical Name**: `Virginia Roberts Giuffre`  
**Aliases**:
- Virginia Roberts
- Virginia Giuffre
- Virginia
- Giuffre
- Roberts
- V. Giuffre
- V. Roberts
- VG
- VR
- Plaintiff Virginia Giuffre
- Plaintiff Giuffre
- Plaintiff
- Jane Doe 3

---

### **Royal/Political**

#### **Prince Andrew**
**Canonical Name**: `Prince Andrew`  
**Aliases**:
- Andrew
- Duke of York
- Prince Andrew, Duke of York
- HRH Prince Andrew
- The Duke of York

#### **Bill Clinton**
**Canonical Name**: `Bill Clinton`  
**Aliases**:
- Clinton
- William Clinton
- President Clinton
- President Bill Clinton
- William Jefferson Clinton
- Bill

#### **Donald Trump**
**Canonical Name**: `Donald Trump`  
**Aliases**:
- Trump
- Donald J. Trump
- President Trump
- Donald

---

### **Epstein Associates**

#### **Sarah Kellen**
**Canonical Name**: `Sarah Kellen`  
**Aliases**:
- Kellen
- Sarah
- Sarah Kensington
- S. Kellen

#### **Nadia Marcinkova**
**Canonical Name**: `Nadia Marcinkova`  
**Aliases**:
- Marcinkova
- Nadia
- Nada Marcinkova
- N. Marcinkova

#### **Adriana Ross**
**Canonical Name**: `Adriana Ross`  
**Aliases**:
- Ross
- Adriana
- Adriana Mucinska
- A. Ross

---

### **Legal Team**

#### **Alan Dershowitz**
**Canonical Name**: `Alan Dershowitz`  
**Aliases**:
- Dershowitz
- Alan
- A. Dershowitz
- Prof. Dershowitz
- Professor Dershowitz

#### **Laura Menninger**
**Canonical Name**: `Laura Menninger`  
**Aliases**:
- Menninger
- Laura
- L. Menninger

#### **David Boies**
**Canonical Name**: `David Boies`  
**Aliases**:
- Boies
- David
- D. Boies

---

## Total Coverage

### **Statistics**
- **Canonical Names**: 50+ people
- **Total Aliases**: 200+ variations
- **Coverage**: All major VIPs

### **Categories**
1. **Core Figures** (3): Epstein, Maxwell, Giuffre
2. **Royal/Political** (6): Andrew, Clinton, Trump, etc.
3. **Epstein Associates** (10): Kellen, Marcinkova, Ross, etc.
4. **Victims/Witnesses** (7): Sjoberg, Ransome, Farmer, etc.
5. **Legal Team** (10): Dershowitz, Menninger, Boies, etc.
6. **Law Enforcement** (2): Recarey, Freeh
7. **Court Personnel** (3): Schultz, Willis, Olson
8. **Business Associates** (5): Wexner, Dubin, etc.
9. **Celebrities** (4): Tucker, Spacey, Campbell, etc.

---

## How It Works

### **1. Alias Mapping File**
`scripts/person_aliases.py`

Contains dictionary mapping canonical names to aliases:

```python
PERSON_ALIASES = {
    "Jeffrey Epstein": [
        "Epstein",
        "Jeffrey",
        "Jeff Epstein",
        "J. Epstein",
        "JE"
    ],
    "Ghislaine Maxwell": [
        "Maxwell",
        "Ghislaine",
        "G. Maxwell",
        "GM"
    ],
    # ... etc
}
```

### **2. Consolidation Script**
`scripts/consolidate_timeline_aliases.py`

- Loads `timeline_data.json`
- For each event, converts all people names to canonical forms
- Removes duplicates
- Saves updated timeline
- Creates backup of original

### **3. PowerShell Wrapper**
`CONSOLIDATE_ALIASES.ps1`

- Runs consolidation script
- Optionally regenerates timelines
- Commits changes to Git

---

## Usage

### **Run Consolidation**
```powershell
.\CONSOLIDATE_ALIASES.ps1
```

### **What It Does**
1. **Analyze**: Shows how many duplicates will be consolidated
2. **Backup**: Creates backup of original timeline
3. **Consolidate**: Updates all person names to canonical forms
4. **Report**: Generates consolidation report
5. **Regenerate**: Optionally regenerates timelines
6. **Commit**: Optionally commits changes

### **Output**
- `timeline_data.json` (updated with canonical names)
- `timeline_data_before_alias_consolidation.json` (backup)
- `ALIAS_CONSOLIDATION_REPORT.md` (detailed report)

---

## Example Consolidations

### **Before**
```json
{
  "date": "2016-05-17",
  "people": ["Epstein", "Maxwell", "Jeffrey", "Ghislaine", "Virginia Roberts", "Giuffre"]
}
```

### **After**
```json
{
  "date": "2016-05-17",
  "people": ["Jeffrey Epstein", "Ghislaine Maxwell", "Virginia Roberts Giuffre"]
}
```

**Result**: 6 names → 3 canonical names

---

## Impact on Timelines

### **VIP Timeline Consolidation**

#### **Before**
- `epstein_*.md` (129 events)
- `jeffrey_*.md` (119 events)
- `jeffrey_epstein_*.md` (119 events)
- **Total**: 3 separate timelines

#### **After**
- `jeffrey_epstein_*.md` (367 events)
- **Total**: 1 consolidated timeline

### **Event Count Accuracy**

#### **Before**
- Ghislaine Maxwell: 780 events
- Maxwell: 174 events
- Ghislaine: 0 events
- **Total**: 954 events split across 2 timelines

#### **After**
- Ghislaine Maxwell: 954 events
- **Total**: 1 accurate timeline

---

## Benefits

### **1. Accurate VIP Timelines**
- No more split timelines for the same person
- Correct event counts
- Complete interaction history

### **2. Better Analysis**
- True frequency of mentions
- Accurate relationship mapping
- Cleaner data for visualization

### **3. Easier Search**
- Find all mentions of a person regardless of name variation
- Consistent naming across documents
- Better cross-referencing

### **4. Data Quality**
- Removes duplicates
- Standardizes naming
- Improves consistency

---

## Adding New Aliases

### **Edit `scripts/person_aliases.py`**

```python
PERSON_ALIASES = {
    # Add new person
    "New Person Name": [
        "Alias 1",
        "Alias 2",
        "Nickname",
        "Initials"
    ],
    
    # Or add alias to existing person
    "Jeffrey Epstein": [
        "Epstein",
        "Jeffrey",
        # Add new alias here
        "New Alias"
    ]
}
```

### **Re-run Consolidation**
```powershell
.\CONSOLIDATE_ALIASES.ps1
```

---

## Functions Available

### **Python API**

```python
from person_aliases import (
    get_canonical_name,
    get_all_aliases,
    merge_person_names
)

# Get canonical name
canonical = get_canonical_name("Epstein")
# Returns: "Jeffrey Epstein"

# Get all aliases
aliases = get_all_aliases("Jeffrey Epstein")
# Returns: ["Epstein", "Jeffrey", "J. Epstein", ...]

# Merge list of names
names = ["Epstein", "Maxwell", "Jeffrey", "Ghislaine"]
canonical_names = merge_person_names(names)
# Returns: ["Jeffrey Epstein", "Ghislaine Maxwell"]
```

---

## Validation

### **Before Running**
The script shows:
- Number of unique people before consolidation
- Number of unique people after consolidation
- Number of duplicates to be removed
- Example consolidations

### **After Running**
The report shows:
- Total events processed
- Events changed
- Top people by event count
- All canonical names with their aliases

---

## Backup and Recovery

### **Automatic Backup**
Before consolidation, creates:
`timeline_data_before_alias_consolidation.json`

### **Manual Restore**
If needed, restore from backup:
```powershell
Copy-Item "unified_timeline\timeline_data_before_alias_consolidation.json" `
          "unified_timeline\timeline_data.json" -Force
```

---

## Integration with Epstein-Docs

When integrating the epstein-docs.github.io archive:

1. Their data will have different name variations
2. Run consolidation after integration
3. Merge their 12,243 people with our canonical names
4. Automatic deduplication across both datasets

---

## Future Enhancements

### **Planned**
1. **Fuzzy Matching**: Catch typos and misspellings
2. **Machine Learning**: Auto-detect new aliases
3. **Relationship Graph**: Visualize connections between canonical names
4. **API Integration**: Link to external databases (Wikipedia, etc.)

### **Possible**
1. **Organization Aliases**: Same system for companies
2. **Location Aliases**: Consolidate place names
3. **Cross-Reference**: Link to other Epstein databases

---

## Files

### **Created**
- `scripts/person_aliases.py` - Alias mapping
- `scripts/consolidate_timeline_aliases.py` - Consolidation script
- `CONSOLIDATE_ALIASES.ps1` - PowerShell wrapper
- `PERSON_ALIAS_SYSTEM.md` - This documentation

### **Modified**
- `unified_timeline/timeline_data.json` - Updated with canonical names
- `unified_timeline/UNIFIED_TIMELINE.md` - Regenerated
- `mini_timelines/*.md` - Regenerated with consolidated names

### **Generated**
- `unified_timeline/timeline_data_before_alias_consolidation.json` - Backup
- `unified_timeline/ALIAS_CONSOLIDATION_REPORT.md` - Consolidation report

---

## Summary

The Person Alias System:

✅ **Links** people with their nicknames and aliases  
✅ **Consolidates** duplicate timeline entries  
✅ **Improves** VIP timeline accuracy  
✅ **Standardizes** naming across all documents  
✅ **Enables** better analysis and search  

**Run**: `.\CONSOLIDATE_ALIASES.ps1` to consolidate your timeline!

---

*This system ensures that "Epstein", "Jeffrey", and "Jeffrey Epstein" are all recognized as the same person, creating more accurate and comprehensive timelines.*
