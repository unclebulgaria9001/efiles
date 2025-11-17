#!/usr/bin/env python3
"""
Extract Specific Message Book Calls and Add to Timeline
Maps individual phone calls from message books to timeline events
"""

import json
from pathlib import Path
from datetime import datetime

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
TIMELINE_JSON = BASE_PATH / "unified_timeline" / "timeline_data.json"

# Specific message book calls documented in court filings
MESSAGE_BOOK_CALLS = [
    {
        "date": "20040700",  # July 2004 (specific day not mentioned)
        "formatted_date": "July 2004",
        "title": "Message Book Call - 14-Year-Old Victim",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Ghislaine Maxwell", "Jeffrey Epstein", "[14-year-old victim]"],
        "locations": ["Palm Beach"],
        "description": "Message from 14-year-old girl (name redacted) taken by Ghislaine Maxwell for Jeffrey Epstein. Message states: '[Name] is available on Tuesday no one for tomorrow.' Victim was 14 years old on the date of the message.",
        "source": "GIUFFRE001465, Court Document 1327-5",
        "evidence_type": "Carbon copy message pad",
        "significance": "Documented evidence of Maxwell scheduling underage victim",
        "legal_note": "Used by law enforcement to confirm identity of underage victim"
    },
    {
        "date": "20050405",
        "formatted_date": "April 5, 2005",
        "title": "Message Book Call - HR (Haley Robson) 11:00 Appointment",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Jeffrey Epstein", "Sarah Kellen"],
        "locations": ["Palm Beach"],
        "description": "Message from HR (Haley Robson) indicating 11:00 appointment. Multiple females' names and telephone numbers recorded. Message recovered from Epstein's trash by Palm Beach Police.",
        "source": "Detective Recarey Deposition, Trash Pull April 5, 2005",
        "evidence_type": "Message pad from trash",
        "significance": "Shows recruitment network and scheduling system",
        "legal_note": "Detective Recarey testified about this evidence"
    },
    {
        "date": "20050900",  # September 2005 (general timeframe)
        "formatted_date": "September 2005",
        "title": "Sarah Kellen Phone Records - Multiple Victim Calls",
        "type": "PHONE_RECORDS",
        "category": "Evidence Analysis",
        "people": ["Sarah Kellen", "Jeffrey Epstein"],
        "locations": ["Palm Beach", "New York"],
        "description": "Analysis of Sarah Kellen's cellular phone (917-855-3363) for September-October 2005. Phone financially responsible party: Jeffrey Epstein, 457 Madison Ave, New York. Multiple calls to/from victims documented.",
        "source": "Detective Recarey Report, Cingular Wireless subpoena",
        "evidence_type": "Phone records",
        "significance": "Epstein paid for Sarah's phone used to coordinate victims"
    },
    {
        "date": "20051000",  # October 2005 (general timeframe)
        "formatted_date": "October 2005",
        "title": "Haley Robson Phone Records - Victim Coordination",
        "type": "PHONE_RECORDS",
        "category": "Evidence Analysis",
        "people": ["Haley Robson"],
        "locations": ["Palm Beach"],
        "description": "Analysis of Haley Robson's phone records (561-308-0282) from Cingular Wireless. Records show calls during timeframe when victims were brought to Epstein house to 'work'. Incoming and outgoing calls analyzed.",
        "source": "Detective Recarey Report, Phone records subpoena",
        "evidence_type": "Phone records",
        "significance": "Documented recruitment and coordination calls"
    }
]

# Additional message pad references (specific dates not provided in documents)
ADDITIONAL_MESSAGE_PADS = [
    "GIUFFRE001523", "GIUFFRE001427", "GIUFFRE001451", "GIUFFRE001454",
    "GIUFFRE001460", "GIUFFRE001461", "GIUFFRE001464", "GIUFFRE001465",
    "GIUFFRE001436", "GIUFFRE001435", "GIUFFRE001472", "GIUFFRE001474",
    "GIUFFRE001492", "GIUFFRE001553", "GIUFFRE001388", "GIUFFRE001555",
    "GIUFFRE001556", "GIUFFRE001557", "GIUFFRE001392", "GIUFFRE001526",
    "GIUFFRE001530", "GIUFFRE001568", "GIUFFRE001536", "GIUFFRE001538",
    "GIUFFRE001541", "GIUFFRE001546", "GIUFFRE001399", "GIUFFRE001402",
    "GIUFFRE001405", "GIUFFRE001406", "GIUFFRE001449", "GIUFFRE001409",
    "GIUFFRE001410", "GIUFFRE001411"
]

def load_timeline_data():
    """Load existing timeline data"""
    if TIMELINE_JSON.exists():
        with open(TIMELINE_JSON, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def add_message_book_calls(timeline_data):
    """Add specific message book calls to timeline"""
    print("Adding specific message book calls to timeline...")
    
    added_count = 0
    for call in MESSAGE_BOOK_CALLS:
        # Check if event already exists
        exists = any(
            e.get('date') == call['date'] and 
            e.get('title') == call['title']
            for e in timeline_data
        )
        
        if not exists:
            timeline_data.append(call)
            print(f"  Added: {call['formatted_date']} - {call['title']}")
            added_count += 1
    
    # Sort by date (handle None values)
    timeline_data.sort(key=lambda x: x.get('date', '') or '')
    
    print(f"\nAdded {added_count} specific message book call events")
    return timeline_data

def save_timeline_data(timeline_data):
    """Save updated timeline data"""
    with open(TIMELINE_JSON, 'w', encoding='utf-8') as f:
        json.dump(timeline_data, f, indent=2)
    print(f"Saved updated timeline: {TIMELINE_JSON}")

def create_message_pad_index():
    """Create index of all message pad references"""
    index_file = BASE_PATH / "MESSAGE_PAD_INDEX.md"
    
    content = f"""# Message Pad Index

**Total Message Pads Referenced**: {len(ADDITIONAL_MESSAGE_PADS)}

## Overview

These are message pad document references (Bates numbers) cited in court filings as evidence of Ghislaine Maxwell's involvement in scheduling underage girls for Jeffrey Epstein.

## Source

Court Document: 1327-5 and 1328-23  
Context: "Messages Involving Defendant"

## Message Pad References

"""
    
    for i, pad_num in enumerate(ADDITIONAL_MESSAGE_PADS, 1):
        content += f"{i}. **{pad_num}**\n"
    
    content += f"""

## Known Details

### July 2004 Message (GIUFFRE001465)
- **From**: 14-year-old girl (name redacted)
- **Taken by**: Ghislaine Maxwell ("Ms. Maxwell")
- **For**: Jeffrey Epstein
- **Message**: "[Name] is available on Tuesday no one for tomorrow"
- **Significance**: Victim was 14 years old on date of message
- **Use**: Law enforcement confirmed identity of underage victim

### April 5, 2005 Trash Pull
- **From**: HR (Haley Robson)
- **Message**: 11:00 appointment
- **Also found**: Multiple females' names and telephone numbers
- **Recovery**: Epstein's trash
- **Testimony**: Detective Recarey deposition

## Legal Significance

**Evidence Type**: Business records (carbon copy message pads)

**Admissibility**: 
- Contemporaneous records
- Regular business practice
- Recovered from Epstein's home/trash
- Corroborated by victim testimony

**Use in Investigation**:
- Identified underage victims by name
- Confirmed ages at time of abuse
- Documented Maxwell's coordinating role
- Proved systematic operation

## Pattern Analysis

**Message Types**:
1. Availability confirmations ("available on Tuesday")
2. Appointment times ("11:00 appointment")
3. Recruitment offers ("I have girls for him")
4. Names and phone numbers of victims

**Taken By**:
- Primarily Ghislaine Maxwell
- Also Sarah Kellen
- Household staff

**For**:
- Jeffrey Epstein (recipient of messages)

## Cross-References

**See Also**:
- `TELEPHONE_MESSAGE_BOOK_ANALYSIS.md` - Full analysis
- `MESSAGE_BOOK_SUMMARY.md` - Quick reference
- `unified_timeline/UNIFIED_TIMELINE.md` - Timeline integration

---

**Note**: Specific dates for most message pads not provided in publicly available court documents. Only July 2004 and April 5, 2005 messages have documented dates.
"""
    
    with open(index_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\nCreated message pad index: {index_file.name}")

def main():
    print("\n" + "="*80)
    print("EXTRACTING SPECIFIC MESSAGE BOOK CALLS")
    print("="*80)
    
    # Load timeline
    timeline_data = load_timeline_data()
    print(f"\nLoaded {len(timeline_data)} existing events")
    
    # Add specific calls
    timeline_data = add_message_book_calls(timeline_data)
    
    # Save updated timeline
    save_timeline_data(timeline_data)
    
    # Create message pad index
    create_message_pad_index()
    
    print("\n" + "="*80)
    print("EXTRACTION COMPLETE!")
    print("="*80)
    print("\nNext steps:")
    print("1. Run: python scripts/create_unified_timeline.py")
    print("2. Run: python scripts/create_mini_timelines.py")
    print("3. Review specific message book calls in timelines")

if __name__ == "__main__":
    main()
