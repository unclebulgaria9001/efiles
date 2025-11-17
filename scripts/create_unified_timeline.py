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
    
    # Add all events in strict chronological order
    for event in dated_events:
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

def extract_title_from_content(event):
    """Extract a meaningful title from the event content"""
    filename = event.get('filename', '')
    
    # For emails, use subject
    if event['type'] == 'email':
        subject = event.get('subject', 'untitled')
        # Clean up subject
        subject = subject.replace('_', ' ').strip()
        if len(subject) > 100:
            subject = subject[:97] + '...'
        return subject
    
    # For court documents, extract title from filename
    if event['type'] == 'court_document':
        # Remove extension and clean up
        title = filename.replace('.pdf', '').replace('_', ' ')
        
        # Common court document patterns
        if 'complaint' in title.lower():
            return 'Civil Complaint Filed'
        elif 'deposition' in title.lower():
            return 'Deposition Transcript'
        elif 'motion' in title.lower():
            return 'Court Motion Filed'
        elif 'order' in title.lower():
            return 'Court Order'
        elif 'exhibit' in title.lower():
            return 'Court Exhibits'
        elif 'affidavit' in title.lower():
            return 'Affidavit Filed'
        else:
            # Use cleaned filename
            if len(title) > 100:
                title = title[:97] + '...'
            return title
    
    # For flight logs
    if event['type'] == 'flight':
        locations = event.get('locations', [])
        if len(locations) >= 2:
            return f"Flight: {locations[0]} → {locations[-1]}"
        elif locations:
            return f"Flight to {locations[0]}"
        else:
            return "Flight Log Entry"
    
    # For other documents, use doc types or filename
    doc_types = event.get('doc_types', [])
    if doc_types:
        return ' / '.join([dt.replace('_', ' ').title() for dt in doc_types[:2]])
    
    # Fallback to cleaned filename
    title = filename.replace('.pdf', '').replace('_', ' ')
    if len(title) > 100:
        title = title[:97] + '...'
    return title if title else 'Document'

def load_document_text(filename):
    """Load the full extracted text for a document"""
    docs_path = COMPLETE_EXTRACTION / "all_documents"
    
    # Try to find the text file
    doc_id = filename.replace('.pdf', '').replace('.txt', '')
    text_file = docs_path / f"{doc_id}.txt"
    
    if text_file.exists():
        try:
            with open(text_file, 'r', encoding='utf-8', errors='ignore') as f:
                return f.read()
        except:
            pass
    
    return None

def extract_content_snippet(full_text, date_string=None, people=None, max_length=500):
    """Extract a relevant snippet from the full text"""
    if not full_text:
        return None
    
    # Try to find context around the date or people mentioned
    snippet_start = 0
    
    # If we have a date, try to find it in the text
    if date_string:
        date_pos = full_text.lower().find(date_string.lower())
        if date_pos > 0:
            snippet_start = max(0, date_pos - 200)
    
    # If we have people, try to find first mention
    elif people:
        for person in people[:3]:
            person_pos = full_text.lower().find(person.lower())
            if person_pos > 0:
                snippet_start = max(0, person_pos - 200)
                break
    
    # Extract snippet
    snippet = full_text[snippet_start:snippet_start + max_length]
    
    # Clean up snippet
    snippet = snippet.strip()
    
    # Try to start at a sentence boundary
    first_period = snippet.find('. ')
    if first_period > 0 and first_period < 100:
        snippet = snippet[first_period + 2:]
    
    # Try to end at a sentence boundary
    last_period = snippet.rfind('. ')
    if last_period > 300:
        snippet = snippet[:last_period + 1]
    
    # Clean up whitespace
    snippet = ' '.join(snippet.split())
    
    return snippet

def format_event(event):
    """Format a single event for the timeline with enhanced details and content snippets"""
    event_type = event['type']
    date_obj = event.get('date')
    
    # Format date as YYYYMMDD
    if date_obj:
        date_str = date_obj.strftime('%Y%m%d')
    else:
        date_str = 'UNDATED'
    
    # Get category
    category_map = {
        'email': 'EMAIL',
        'flight': 'FLIGHT',
        'court_document': 'COURT',
        'document': 'DOCUMENT'
    }
    category = category_map.get(event_type, 'OTHER')
    
    # Get title
    title = extract_title_from_content(event)
    
    # Format main entry line
    md = f"**{date_str} - {category} - {title}**\n\n"
    
    # Add detailed description based on type
    if event_type == 'email':
        from_person = event.get('from', 'Unknown')
        to_person = event.get('to', 'Unknown')
        
        md += f"**From**: {from_person}  \n"
        md += f"**To**: {to_person}  \n"
        
        if event.get('content_preview'):
            preview = event['content_preview'].strip()
            if len(preview) > 200:
                preview = preview[:197] + '...'
            md += f"**Preview**: {preview}  \n"
        
        if event.get('people'):
            people_list = ', '.join(event['people'][:8])
            md += f"**People Mentioned**: {people_list}  \n"
        
        if event.get('key_terms'):
            terms = ', '.join(event['key_terms'])
            md += f"**Key Terms**: {terms}  \n"
        
        # Add content snippet
        md += f"\n**Content Snippet**:\n"
        md += f"> {event.get('content_preview', 'No preview available')[:400]}...\n\n"
        
        md += f"**File**: `{event['filename']}`  \n"
        
        # Link to extracted text
        email_path = f"extracted_emails_organized/{event['filename']}"
        md += f"**Full Text**: [`{event['filename']}`](../{email_path})  \n"
    
    elif event_type == 'flight':
        if event.get('people'):
            passengers = ', '.join(event['people'][:15])
            md += f"**Passengers**: {passengers}  \n"
        
        if event.get('locations'):
            locations = ' → '.join(event['locations'])
            md += f"**Route**: {locations}  \n"
        
        # Try to load and extract snippet
        full_text = load_document_text(event['filename'])
        if full_text:
            snippet = extract_content_snippet(full_text, event.get('date_string'), event.get('people'))
            if snippet:
                md += f"\n**Flight Log Entry**:\n"
                md += f"> {snippet}\n\n"
        
        md += f"**Source**: `{event['filename']}`  \n"
        
        # Link to extracted text
        doc_id = event['filename'].replace('.pdf', '')
        text_path = f"complete_extraction/all_documents/{doc_id}.txt"
        md += f"**Full Text**: [`{doc_id}.txt`](../{text_path})  \n"
    
    elif event_type == 'court_document':
        doc_types = event.get('doc_types', [])
        if doc_types:
            types_str = ', '.join([dt.replace('_', ' ').title() for dt in doc_types])
            md += f"**Document Type**: {types_str}  \n"
        
        if event.get('people'):
            people_list = ', '.join(event['people'][:12])
            md += f"**People Mentioned**: {people_list}  \n"
        
        if event.get('locations'):
            locations = ', '.join(event['locations'][:5])
            md += f"**Locations**: {locations}  \n"
        
        # Try to load and extract snippet
        full_text = load_document_text(event['filename'])
        if full_text:
            snippet = extract_content_snippet(full_text, event.get('date_string'), event.get('people'), max_length=600)
            if snippet:
                md += f"\n**Document Excerpt**:\n"
                md += f"> {snippet}\n\n"
        
        md += f"**File**: `{event['filename']}`  \n"
        
        # Link to extracted text
        doc_id = event['filename'].replace('.pdf', '')
        text_path = f"complete_extraction/all_documents/{doc_id}.txt"
        md += f"**Full Text**: [`{doc_id}.txt`](../{text_path})  \n"
    
    elif event_type == 'document':
        doc_types = event.get('doc_types', [])
        if doc_types:
            types_str = ', '.join([dt.replace('_', ' ').title() for dt in doc_types])
            md += f"**Document Type**: {types_str}  \n"
        
        if event.get('people'):
            people_list = ', '.join(event['people'][:8])
            md += f"**People Mentioned**: {people_list}  \n"
        
        if event.get('locations'):
            locations = ', '.join(event['locations'][:5])
            md += f"**Locations**: {locations}  \n"
        
        text_len = event.get('text_length', 0)
        if text_len > 0:
            md += f"**Length**: {text_len:,} characters  \n"
        
        # Try to load and extract snippet
        full_text = load_document_text(event['filename'])
        if full_text:
            snippet = extract_content_snippet(full_text, event.get('date_string'), event.get('people'), max_length=500)
            if snippet:
                md += f"\n**Document Excerpt**:\n"
                md += f"> {snippet}\n\n"
        
        md += f"**File**: `{event['filename']}`  \n"
        
        # Link to extracted text
        doc_id = event['filename'].replace('.pdf', '')
        text_path = f"complete_extraction/all_documents/{doc_id}.txt"
        md += f"**Full Text**: [`{doc_id}.txt`](../{text_path})  \n"
    
    md += "\n---\n\n"
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

All events listed in strict chronological order (YYYYMMDD - CATEGORY - TITLE format):

"""
        
        for event in dated:
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
