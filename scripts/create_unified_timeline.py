#!/usr/bin/env python3
"""
Create Unified Timeline - Links All Sources
Integrates emails, documents, flight logs, court filings into one chronological timeline
"""

import os
import sys
import json
import re
from pathlib import Path
from datetime import datetime
from collections import defaultdict
import dateutil.parser as date_parser

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
COMPLETE_EXTRACTION = BASE_PATH / "complete_extraction"
EMAILS_PATH = BASE_PATH / "extracted_emails_organized"
TIMELINE_OUTPUT = BASE_PATH / "unified_timeline"

# Create output directory
TIMELINE_OUTPUT.mkdir(exist_ok=True)

# Known VIPs for tracking
KNOWN_VIPS = [
    "Jeffrey Epstein", "Epstein",
    "Ghislaine Maxwell", "Maxwell",
    "Virginia Giuffre", "Virginia Roberts", "Giuffre",
    "Prince Andrew", "Andrew",
    "Bill Clinton", "Clinton",
    "Donald Trump", "Trump",
    "Alan Dershowitz", "Dershowitz",
    "Leslie Wexner", "Wexner",
    "Jean-Luc Brunel", "Brunel"
]

def parse_date(date_string):
    """Parse various date formats into a standard datetime"""
    if not date_string or date_string.strip() == "":
        return None
    
    try:
        # Try standard parser first
        return date_parser.parse(date_string, fuzzy=True)
    except:
        pass
    
    # Try common patterns
    patterns = [
        r'(\d{1,2})/(\d{1,2})/(\d{2,4})',  # MM/DD/YYYY or M/D/YY
        r'(\d{1,2})-(\d{1,2})-(\d{2,4})',  # MM-DD-YYYY
        r'(\d{4})-(\d{2})-(\d{2})',        # YYYY-MM-DD
    ]
    
    for pattern in patterns:
        match = re.search(pattern, date_string)
        if match:
            try:
                parts = match.groups()
                if len(parts[2]) == 2:  # 2-digit year
                    year = int(parts[2])
                    year = 2000 + year if year < 50 else 1900 + year
                else:
                    year = int(parts[2])
                
                if pattern == r'(\d{4})-(\d{2})-(\d{2})':
                    return datetime(year, int(parts[1]), int(parts[2]))
                else:
                    return datetime(year, int(parts[0]), int(parts[1]))
            except:
                pass
    
    return None

def load_emails():
    """Load all email files and extract timeline data"""
    print("Loading emails...")
    
    email_events = []
    
    if not EMAILS_PATH.exists():
        print("  No emails folder found")
        return email_events
    
    email_files = list(EMAILS_PATH.glob("*.txt"))
    print(f"  Found {len(email_files)} email files")
    
    for email_file in email_files:
        try:
            with open(email_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Extract metadata from filename
            filename = email_file.stem
            parts = filename.split('_')
            
            # Try to parse date from filename
            date_str = parts[1] if len(parts) > 1 else ""
            from_str = parts[2].replace('From-', '') if len(parts) > 2 else "Unknown"
            to_str = parts[3].replace('To-', '') if len(parts) > 3 else "Unknown"
            subject = '_'.join(parts[4:]) if len(parts) > 4 else "untitled"
            
            # Parse date
            parsed_date = parse_date(date_str)
            
            # Extract people mentioned
            people = []
            for vip in KNOWN_VIPS:
                if vip.lower() in content.lower():
                    people.append(vip)
            
            # Extract key terms
            key_terms = []
            sensitive_terms = ['flight', 'massage', 'girl', 'minor', 'island', 'party']
            for term in sensitive_terms:
                if term in content.lower():
                    key_terms.append(term)
            
            email_events.append({
                'date': parsed_date,
                'date_string': date_str,
                'type': 'email',
                'source': 'Email',
                'filename': email_file.name,
                'from': from_str,
                'to': to_str,
                'subject': subject,
                'people': list(set(people)),
                'key_terms': list(set(key_terms)),
                'content_preview': content[:200].replace('\n', ' ')
            })
        except Exception as e:
            print(f"  Error loading {email_file.name}: {e}")
    
    print(f"  Loaded {len(email_events)} email events")
    return email_events

def load_documents():
    """Load all document metadata and extract timeline data"""
    print("\nLoading documents...")
    
    doc_events = []
    
    docs_path = COMPLETE_EXTRACTION / "all_documents"
    if not docs_path.exists():
        print("  No documents folder found")
        return doc_events
    
    metadata_files = list(docs_path.glob("*_metadata.json"))
    print(f"  Found {len(metadata_files)} document metadata files")
    
    for meta_file in metadata_files:
        try:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            
            # Extract dates from document
            dates = metadata.get('dates', [])
            
            for date_info in dates:
                parsed_date = parse_date(date_info['date_string'])
                
                doc_events.append({
                    'date': parsed_date,
                    'date_string': date_info['date_string'],
                    'type': 'document',
                    'source': 'Document',
                    'filename': metadata['filename'],
                    'doc_id': metadata['doc_id'],
                    'doc_types': metadata.get('document_types', []),
                    'people': metadata.get('people', [])[:10],
                    'locations': metadata.get('locations', []),
                    'text_length': metadata.get('text_length', 0)
                })
        except Exception as e:
            print(f"  Error loading {meta_file.name}: {e}")
    
    print(f"  Loaded {len(doc_events)} document events")
    return doc_events

def identify_flight_logs(doc_events):
    """Identify and extract flight log specific events"""
    print("\nIdentifying flight log events...")
    
    flight_events = []
    
    for event in doc_events:
        if event['type'] == 'document':
            filename = event.get('filename', '').lower()
            doc_types = event.get('doc_types', [])
            
            # Check if this is a flight log
            if 'flight' in filename or 'flight_log' in doc_types:
                flight_events.append({
                    **event,
                    'type': 'flight',
                    'source': 'Flight Log'
                })
    
    print(f"  Identified {len(flight_events)} flight log events")
    return flight_events

def identify_court_documents(doc_events):
    """Identify and extract court document specific events"""
    print("\nIdentifying court document events...")
    
    court_events = []
    
    for event in doc_events:
        if event['type'] == 'document':
            filename = event.get('filename', '').lower()
            doc_types = event.get('doc_types', [])
            
            # Check if this is a court document
            if ('complaint' in filename or 'deposition' in filename or 
                'legal_document' in doc_types or 'court' in filename):
                court_events.append({
                    **event,
                    'type': 'court_document',
                    'source': 'Court Filing'
                })
    
    print(f"  Identified {len(court_events)} court document events")
    return court_events

def create_unified_timeline(all_events):
    """Create a unified chronological timeline"""
    print("\nCreating unified timeline...")
    
    # Filter events with valid dates
    dated_events = [e for e in all_events if e['date'] is not None]
    undated_events = [e for e in all_events if e['date'] is None]
    
    # Sort by date
    dated_events.sort(key=lambda x: x['date'])
    
    print(f"  Events with dates: {len(dated_events)}")
    print(f"  Events without dates: {len(undated_events)}")
    
    # Group by year and month
    by_year_month = defaultdict(list)
    for event in dated_events:
        year_month = event['date'].strftime('%Y-%m')
        by_year_month[year_month].append(event)
    
    # Create markdown timeline
    timeline_md = f"""# Unified Timeline - All Sources

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total Events**: {len(all_events):,}  
**Dated Events**: {len(dated_events):,}  
**Undated Events**: {len(undated_events):,}

---

## Overview

This timeline integrates all sources:
- **Emails**: {len([e for e in all_events if e['type'] == 'email'])} events
- **Documents**: {len([e for e in all_events if e['type'] == 'document'])} events
- **Flight Logs**: {len([e for e in all_events if e['type'] == 'flight'])} events
- **Court Documents**: {len([e for e in all_events if e['type'] == 'court_document'])} events

---

## Chronological Timeline

"""
    
    # Add events by year/month
    for year_month in sorted(by_year_month.keys()):
        events = by_year_month[year_month]
        
        # Parse year/month for header
        year, month = year_month.split('-')
        month_name = datetime(int(year), int(month), 1).strftime('%B %Y')
        
        timeline_md += f"\n### {month_name}\n\n"
        timeline_md += f"**Events this month**: {len(events)}\n\n"
        
        # Group by day
        by_day = defaultdict(list)
        for event in events:
            day = event['date'].strftime('%Y-%m-%d')
            by_day[day].append(event)
        
        for day in sorted(by_day.keys()):
            day_events = by_day[day]
            day_formatted = datetime.strptime(day, '%Y-%m-%d').strftime('%A, %B %d, %Y')
            
            timeline_md += f"\n#### {day_formatted}\n\n"
            
            for event in day_events:
                timeline_md += format_event(event)
    
    # Add undated events section
    if undated_events:
        timeline_md += "\n---\n\n## Undated Events\n\n"
        timeline_md += f"**Total**: {len(undated_events)}\n\n"
        
        # Group by type
        by_type = defaultdict(list)
        for event in undated_events:
            by_type[event['type']].append(event)
        
        for event_type in sorted(by_type.keys()):
            type_events = by_type[event_type]
            timeline_md += f"\n### {event_type.replace('_', ' ').title()} ({len(type_events)})\n\n"
            
            for event in type_events[:50]:  # Limit to first 50
                timeline_md += format_event(event)
    
    return timeline_md

def format_event(event):
    """Format a single event for the timeline"""
    event_type = event['type']
    source = event.get('source', 'Unknown')
    
    md = f"**[{source}]** "
    
    if event_type == 'email':
        md += f"Email from **{event['from']}** to **{event['to']}**\n"
        md += f"  - Subject: {event['subject']}\n"
        md += f"  - File: `{event['filename']}`\n"
        if event['people']:
            md += f"  - People mentioned: {', '.join(event['people'][:5])}\n"
        if event['key_terms']:
            md += f"  - Key terms: {', '.join(event['key_terms'])}\n"
    
    elif event_type == 'flight':
        md += f"Flight Log Entry\n"
        md += f"  - File: `{event['filename']}`\n"
        if event['people']:
            md += f"  - Passengers/People: {', '.join(event['people'][:10])}\n"
        if event['locations']:
            md += f"  - Locations: {', '.join(event['locations'])}\n"
    
    elif event_type == 'court_document':
        md += f"Court Document\n"
        md += f"  - File: `{event['filename']}`\n"
        md += f"  - Types: {', '.join(event.get('doc_types', []))}\n"
        if event['people']:
            md += f"  - People mentioned: {', '.join(event['people'][:10])}\n"
    
    elif event_type == 'document':
        md += f"Document\n"
        md += f"  - File: `{event['filename']}`\n"
        md += f"  - Types: {', '.join(event.get('doc_types', []))}\n"
        if event['people']:
            md += f"  - People mentioned: {', '.join(event['people'][:5])}\n"
    
    md += "\n"
    return md

def create_vip_timelines(all_events):
    """Create individual timelines for each VIP"""
    print("\nCreating VIP-specific timelines...")
    
    vip_events = defaultdict(list)
    
    for event in all_events:
        people = event.get('people', [])
        
        # Check for VIPs
        for person in people:
            for vip in KNOWN_VIPS:
                if vip.lower() in person.lower():
                    vip_events[vip].append(event)
                    break
    
    # Create timeline for each VIP
    for vip, events in vip_events.items():
        if len(events) < 5:  # Skip VIPs with very few events
            continue
        
        # Sort by date
        dated = [e for e in events if e['date'] is not None]
        dated.sort(key=lambda x: x['date'])
        
        vip_md = f"""# Timeline: {vip}

**Total Events**: {len(events)}  
**Dated Events**: {len(dated)}  
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

---

## Event Summary

- **Emails**: {len([e for e in events if e['type'] == 'email'])}
- **Documents**: {len([e for e in events if e['type'] == 'document'])}
- **Flight Logs**: {len([e for e in events if e['type'] == 'flight'])}
- **Court Documents**: {len([e for e in events if e['type'] == 'court_document'])}

---

## Chronological Events

"""
        
        for event in dated:
            date_str = event['date'].strftime('%Y-%m-%d')
            vip_md += f"\n### {date_str}\n\n"
            vip_md += format_event(event)
        
        # Save VIP timeline
        vip_filename = vip.replace(' ', '_').lower() + '_timeline.md'
        vip_path = TIMELINE_OUTPUT / vip_filename
        
        with open(vip_path, 'w', encoding='utf-8') as f:
            f.write(vip_md)
        
        print(f"  Created timeline for {vip}: {len(events)} events")

def create_timeline_index(all_events):
    """Create an index of all timelines"""
    print("\nCreating timeline index...")
    
    index_md = f"""# Timeline Index

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total Events**: {len(all_events):,}

---

## Available Timelines

### Main Timeline
- **[Unified Timeline](UNIFIED_TIMELINE.md)** - All sources chronologically organized
  - {len(all_events):,} total events
  - Emails, documents, flight logs, court filings

### VIP Timelines

"""
    
    # List VIP timelines
    vip_files = sorted(TIMELINE_OUTPUT.glob("*_timeline.md"))
    for vip_file in vip_files:
        vip_name = vip_file.stem.replace('_timeline', '').replace('_', ' ').title()
        index_md += f"- **[{vip_name}]({vip_file.name})** - All events mentioning this person\n"
    
    index_md += f"""

---

## Timeline Statistics

### By Source Type
- **Emails**: {len([e for e in all_events if e['type'] == 'email']):,}
- **Documents**: {len([e for e in all_events if e['type'] == 'document']):,}
- **Flight Logs**: {len([e for e in all_events if e['type'] == 'flight']):,}
- **Court Documents**: {len([e for e in all_events if e['type'] == 'court_document']):,}

### By Date Status
- **Dated Events**: {len([e for e in all_events if e['date'] is not None]):,}
- **Undated Events**: {len([e for e in all_events if e['date'] is None]):,}

---

## How to Use

### Search by Date
1. Open `UNIFIED_TIMELINE.md`
2. Use Ctrl+F to search for specific dates
3. Navigate by year/month headers

### Search by Person
1. Open the VIP's timeline file
2. See all events mentioning that person
3. Chronologically organized

### Search by Type
1. Open `UNIFIED_TIMELINE.md`
2. Search for `[Email]`, `[Flight Log]`, `[Court Filing]`, etc.
3. Filter by source type

### Cross-Reference
1. Find an event in one timeline
2. Note the date and people involved
3. Search other timelines for same date/people
4. Build connections across sources

---

*All timelines link emails, documents, flight logs, and court filings chronologically*
"""
    
    index_path = TIMELINE_OUTPUT / "INDEX.md"
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(index_md)
    
    print(f"  Created timeline index")

def main():
    """Main timeline creation process"""
    print("="*80)
    print("CREATE UNIFIED TIMELINE - ALL SOURCES")
    print("="*80)
    
    # Load all sources
    email_events = load_emails()
    doc_events = load_documents()
    flight_events = identify_flight_logs(doc_events)
    court_events = identify_court_documents(doc_events)
    
    # Combine all events
    all_events = email_events + doc_events + flight_events + court_events
    
    print(f"\nTotal events collected: {len(all_events):,}")
    
    # Create unified timeline
    timeline_md = create_unified_timeline(all_events)
    
    # Save unified timeline
    timeline_path = TIMELINE_OUTPUT / "UNIFIED_TIMELINE.md"
    with open(timeline_path, 'w', encoding='utf-8') as f:
        f.write(timeline_md)
    
    print(f"\nSaved unified timeline: {timeline_path}")
    
    # Create VIP timelines
    create_vip_timelines(all_events)
    
    # Create index
    create_timeline_index(all_events)
    
    # Save JSON data
    json_path = TIMELINE_OUTPUT / "timeline_data.json"
    
    # Convert dates to strings for JSON
    json_events = []
    for event in all_events:
        event_copy = event.copy()
        if event_copy['date']:
            event_copy['date'] = event_copy['date'].isoformat()
        json_events.append(event_copy)
    
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(json_events, f, indent=2)
    
    print(f"Saved JSON data: {json_path}")
    
    # Summary
    print("\n" + "="*80)
    print("UNIFIED TIMELINE COMPLETE!")
    print("="*80)
    print(f"\nTotal events: {len(all_events):,}")
    print(f"  - Emails: {len(email_events):,}")
    print(f"  - Documents: {len(doc_events):,}")
    print(f"  - Flight Logs: {len(flight_events):,}")
    print(f"  - Court Documents: {len(court_events):,}")
    
    print(f"\nOutput location: {TIMELINE_OUTPUT}")
    print(f"  - Unified timeline: UNIFIED_TIMELINE.md")
    print(f"  - VIP timelines: *_timeline.md")
    print(f"  - Index: INDEX.md")
    print(f"  - JSON data: timeline_data.json")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
