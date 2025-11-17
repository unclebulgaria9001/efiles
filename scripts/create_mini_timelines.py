#!/usr/bin/env python3
"""
Create Mini-Timelines for VIPs
Individual timeline files with date ranges in filenames (YYYYMMDD-to-YYYYMMDD)
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
UNIFIED_TIMELINE = BASE_PATH / "unified_timeline"
MINI_TIMELINES = BASE_PATH / "mini_timelines"

# Create output directory
MINI_TIMELINES.mkdir(exist_ok=True)

# VIPs to track - actual people only
ACTUAL_VIPS = {
    # Core figures
    'Ghislaine Maxwell', 'Maxwell', 'Ghislaine',
    'Virginia Roberts', 'Virginia Giuffre', 'Giuffre', 'Virginia',
    'Jeffrey Epstein', 'Epstein', 'Jeffrey',
    
    # Royal/Political
    'Prince Andrew', 'Andrew', 'Duke of York',
    'Bill Clinton', 'Clinton', 'William Clinton', 'President Bill Clinton',
    'Donald Trump', 'Trump',
    'Bill Richardson', 'Richardson',
    'George Mitchell', 'Mitchell',
    'Ehud Barak', 'Barak',
    'Al Gore', 'Gore',
    'John Kerry', 'Kerry',
    'Henry Kissinger', 'Kissinger',
    'Ted Kennedy', 'Kennedy',
    'Andrew Cuomo', 'Cuomo',
    'Eliot Spitzer', 'Spitzer',
    'Michael Bloomberg', 'Bloomberg',
    
    # Epstein Associates/Staff
    'Sarah Kellen', 'Kellen',
    'Nadia Marcinkova', 'Marcinkova', 'Nadia',
    'Adriana Ross', 'Ross', 'Adriana',
    'Lesley Groff', 'Groff',
    'Jean-Luc Brunel', 'Brunel',
    'Leslie Wexner', 'Wexner',
    'Juan Alessi', 'Alessi',
    'Tony Figueroa', 'Figueroa',
    'Emmy Tayler', 'Tayler', 'Emmy Taylor',
    'Eva Andersson', 'Andersson', 'Eva Anderson',
    'Haley Robson', 'Robson',
    'Janusz Banasiak', 'Banasiak',
    'Alfredo Rodriguez', 'Rodriguez',
    'Philip Barden', 'Barden',
    'Christina Venero', 'Venero',
    
    # Victims/Witnesses
    'Johanna Sjoberg', 'Sjoberg',
    'Courtney Wild', 'Wild',
    'Michelle Licata', 'Licata',
    'Annie Farmer', 'Farmer',
    'Maria Farmer',
    'Sarah Ransome', 'Ransome',
    'Carolyn Andriamo', 'Andriamo',
    'Jane Doe', 'Doe',
    
    # Legal Team - Plaintiffs
    'Sigrid McCawley', 'McCawley', 'Mccawley',
    'David Boies', 'Boies',
    'Brad Edwards', 'Edwards',
    'Paul Cassell', 'Cassell',
    'Jack Scarola', 'Scarola',
    'Spencer Kuvin', 'Kuvin',
    
    # Legal Team - Defense
    'Laura Menninger', 'Menninger',
    'Alan Dershowitz', 'Dershowitz',
    'Kenneth Starr', 'Starr',
    'Roy Black', 'Black',
    'Jay Lefkowitz', 'Lefkowitz',
    'Gerald Lefcourt', 'Lefcourt',
    'Martin Weinberg', 'Weinberg',
    
    # Law Enforcement/Prosecutors
    'Alexander Acosta', 'Acosta',
    'Marie Villafana', 'Villafana',
    'Detective Recarey', 'Recarey',
    'Louis Freeh', 'Freeh',
    
    # Business Associates
    'Glenn Dubin', 'Dubin',
    'Eva Dubin',
    'Ron Burkle', 'Burkle',
    'Rupert Murdoch', 'Murdoch',
    'Mort Zuckerman', 'Zuckerman',
    'Edgar Bronfman', 'Bronfman',
    'Leon Black',
    'Tom Pritzker', 'Pritzker',
    
    # Academics/Scientists
    'Marvin Minsky', 'Minsky',
    'Stephen Hawking', 'Hawking',
    'Lawrence Krauss', 'Krauss',
    'Steven Pinker', 'Pinker',
    
    # Celebrities/Media
    'Kevin Spacey', 'Spacey',
    'Chris Tucker', 'Tucker',
    'Naomi Campbell', 'Campbell',
    'Heidi Klum', 'Klum',
    'Courtney Love', 'Love',
    'Katie Couric', 'Couric',
    'Woody Allen', 'Allen',
    'Michael Wolff', 'Wolff',
    'Charlie Rose', 'Rose',
    'Katie Ford', 'Ford',
    'Shelby Bryan', 'Bryan',
    'Chris Evans', 'Evans',
    'Ralph Fiennes', 'Fiennes',
    'Alec Baldwin', 'Baldwin',
    'David Blaine', 'Blaine',
    'David Copperfield', 'Copperfield',
    'Mick Jagger', 'Jagger',
    'Dustin Hoffman', 'Hoffman',
    
    # Court Personnel/Reporters (high event count)
    'Meredith Schultz', 'Schultz',
    'Kelli Ann Willis', 'Willis',
    'Steven Olson', 'Olson'
}

MIN_EVENTS = 10  # Only create timelines for VIPs with 10+ events

def load_timeline_data():
    """Load the unified timeline JSON data"""
    json_path = UNIFIED_TIMELINE / "timeline_data.json"
    
    if not json_path.exists():
        print(f"ERROR: Timeline data not found at {json_path}")
        return None
    
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        # Handle both array and object formats
        if isinstance(data, list):
            return data
        elif isinstance(data, dict):
            return data.get('events', [])
        return []

def extract_vip_events(timeline_data):
    """Extract events for each VIP"""
    print("\nExtracting VIP events...")
    
    vip_events = defaultdict(list)
    
    # timeline_data is already a list of events
    for event in timeline_data:
        people = event.get('people', [])
        
        for person in people:
            vip_events[person].append(event)
    
    # Filter to only actual VIPs with enough events
    filtered_vips = {
        vip: events for vip, events in vip_events.items()
        if vip in ACTUAL_VIPS and len(events) >= MIN_EVENTS
    }
    
    print(f"  Found {len(filtered_vips)} VIPs with {MIN_EVENTS}+ events")
    
    return filtered_vips

def get_date_range(events):
    """Get the earliest and latest dates from events"""
    dated_events = [e for e in events if e.get('date')]
    
    if not dated_events:
        return None, None
    
    dates = [datetime.fromisoformat(e['date']) for e in dated_events]
    
    earliest = min(dates)
    latest = max(dates)
    
    return earliest, latest

def create_mini_timeline(vip_name, events):
    """Create a mini-timeline for a specific VIP"""
    
    # Sort events by date
    dated_events = [e for e in events if e.get('date')]
    undated_events = [e for e in events if not e.get('date')]
    
    dated_events.sort(key=lambda x: x['date'])
    
    # Get date range
    earliest, latest = get_date_range(events)
    
    if not earliest:
        print(f"  Skipping {vip_name} - no dated events")
        return None
    
    # Format dates for filename
    start_date = earliest.strftime('%Y%m%d')
    end_date = latest.strftime('%Y%m%d')
    
    # Create safe filename - remove invalid characters
    safe_name = vip_name.replace(' ', '_').replace('.', '').replace('\n', '_').replace('\r', '').replace('/', '_').replace('\\', '_').lower()
    # Remove any other problematic characters
    safe_name = ''.join(c for c in safe_name if c.isalnum() or c == '_')
    filename = f"{safe_name}_{start_date}_to_{end_date}.md"
    
    # Create markdown content
    md = f"""# {vip_name} - Timeline

**Period**: {earliest.strftime('%B %d, %Y')} to {latest.strftime('%B %d, %Y')}  
**Total Events**: {len(events)}  
**Dated Events**: {len(dated_events)}  
**Undated Events**: {len(undated_events)}  
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

---

## Overview

This timeline tracks all documented interactions and mentions of **{vip_name}** in relation to Jeffrey Epstein and associates.

### Event Breakdown

- **Emails**: {len([e for e in events if e['type'] == 'email'])}
- **Court Documents**: {len([e for e in events if e['type'] == 'court_document'])}
- **Flight Logs**: {len([e for e in events if e['type'] == 'flight'])}
- **Other Documents**: {len([e for e in events if e['type'] == 'document'])}

---

## Chronological Events

"""
    
    # Add events
    for event in dated_events:
        md += format_mini_event(event, vip_name)
    
    # Add undated events if any
    if undated_events:
        md += "\n---\n\n## Undated Events\n\n"
        for event in undated_events:
            md += format_mini_event(event, vip_name)
    
    # Add footer
    md += f"""
---

## Summary

**{vip_name}** appears in **{len(events)} events** spanning from **{earliest.strftime('%Y')}** to **{latest.strftime('%Y')}**.

### Key Statistics

- **First mention**: {earliest.strftime('%B %d, %Y')}
- **Last mention**: {latest.strftime('%B %d, %Y')}
- **Time span**: {(latest - earliest).days} days (~{(latest - earliest).days / 365.25:.1f} years)
- **Total events**: {len(events)}

### Event Types

| Type | Count |
|------|-------|
| Emails | {len([e for e in events if e['type'] == 'email'])} |
| Court Documents | {len([e for e in events if e['type'] == 'court_document'])} |
| Flight Logs | {len([e for e in events if e['type'] == 'flight'])} |
| Other Documents | {len([e for e in events if e['type'] == 'document'])} |

---

**Timeline File**: `{filename}`  
**Full Timeline**: See `unified_timeline/UNIFIED_TIMELINE.md`  
**VIP Timeline**: See `unified_timeline/{safe_name}_timeline.md`
"""
    
    return filename, md

def format_mini_event(event, vip_name):
    """Format a single event for mini-timeline"""
    event_type = event['type']
    
    # Get date
    if event.get('date'):
        date_obj = datetime.fromisoformat(event['date'])
        date_str = date_obj.strftime('%Y%m%d')
        date_display = date_obj.strftime('%B %d, %Y')
    else:
        date_str = 'UNDATED'
        date_display = 'Date Unknown'
    
    # Category
    category_map = {
        'email': 'EMAIL',
        'flight': 'FLIGHT',
        'court_document': 'COURT',
        'document': 'DOCUMENT'
    }
    category = category_map.get(event_type, 'OTHER')
    
    # Title
    title = event.get('title', 'Untitled')
    
    md = f"### {date_display}\n\n"
    md += f"**{date_str} - {category} - {title}**\n\n"
    
    # Add details based on type
    if event_type == 'email':
        md += f"**From**: {event.get('from', 'Unknown')}  \n"
        md += f"**To**: {event.get('to', 'Unknown')}  \n"
        
        if event.get('people'):
            others = [p for p in event['people'] if p != vip_name]
            if others:
                md += f"**Also mentioned**: {', '.join(others[:5])}  \n"
        
        if event.get('content_preview'):
            preview = event['content_preview'][:300]
            md += f"\n> {preview}...\n\n"
    
    elif event_type == 'flight':
        if event.get('people'):
            passengers = [p for p in event['people'] if p != vip_name]
            md += f"**Traveling with**: {', '.join(passengers[:10])}  \n"
        
        if event.get('locations'):
            md += f"**Route**: {' → '.join(event['locations'])}  \n"
    
    elif event_type in ['court_document', 'document']:
        if event.get('doc_types'):
            types = ', '.join([dt.replace('_', ' ').title() for dt in event['doc_types'][:2]])
            md += f"**Type**: {types}  \n"
        
        if event.get('people'):
            others = [p for p in event['people'] if p != vip_name][:5]
            if others:
                md += f"**Also mentioned**: {', '.join(others)}  \n"
        
        if event.get('locations'):
            md += f"**Locations**: {', '.join(event['locations'][:3])}  \n"
    
    md += f"\n**Source**: `{event.get('filename', 'Unknown')}`  \n"
    md += "\n---\n\n"
    
    return md

def create_index(vip_timelines):
    """Create an index of all mini-timelines"""
    
    md = f"""# Mini-Timelines Index

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total VIP Timelines**: {len(vip_timelines)}

---

## Overview

Individual timelines for each person with significant interactions with Jeffrey Epstein and associates. Each timeline shows the complete date range of documented interactions.

---

## VIP Timelines

| Person | Period | Events | Timeline File |
|--------|--------|--------|---------------|
"""
    
    # Sort by event count (descending)
    sorted_vips = sorted(vip_timelines.items(), key=lambda x: x[1]['event_count'], reverse=True)
    
    for vip_name, info in sorted_vips:
        period = f"{info['start_date']} to {info['end_date']}"
        events = info['event_count']
        filename = info['filename']
        
        md += f"| **{vip_name}** | {period} | {events} | [`{filename}`]({filename}) |\n"
    
    md += f"""

---

## How to Use

### View Individual Timeline
1. Click on any timeline file link above
2. See all events for that person chronologically
3. Read content snippets and details
4. Follow links to full documents

### Date Range Format
- Filenames use format: `name_YYYYMMDD_to_YYYYMMDD.md`
- Example: `prince_andrew_20010106_to_20190712.md`
- Shows complete interaction period at a glance

### Event Types
- **EMAIL**: Email correspondence
- **FLIGHT**: Flight log entries
- **COURT**: Court documents and filings
- **DOCUMENT**: Other documents

---

## Statistics

**Total VIPs Tracked**: {len(vip_timelines)}  
**Total Events**: {sum(info['event_count'] for info in vip_timelines.values())}  
**Minimum Events per VIP**: {MIN_EVENTS}

### Top 10 by Event Count

"""
    
    for i, (vip_name, info) in enumerate(sorted_vips[:10], 1):
        md += f"{i}. **{vip_name}**: {info['event_count']} events\n"
    
    md += """

---

**See also**:
- [Unified Timeline](../unified_timeline/UNIFIED_TIMELINE.md) - All events chronologically
- [VIP Timelines](../unified_timeline/INDEX.md) - Detailed VIP timelines
- [Timeline Format Guide](../TIMELINE_FORMAT_GUIDE.md) - Format documentation
"""
    
    return md

def main():
    """Main function"""
    print("="*80)
    print("CREATE MINI-TIMELINES FOR VIPS")
    print("="*80)
    
    # Load timeline data
    print("\nLoading timeline data...")
    timeline_data = load_timeline_data()
    
    if not timeline_data:
        return 1
    
    print(f"  Loaded {len(timeline_data)} events")
    
    # Extract VIP events
    vip_events = extract_vip_events(timeline_data)
    
    # Create mini-timelines
    print(f"\nCreating mini-timelines (minimum {MIN_EVENTS} events)...")
    
    vip_timelines = {}
    
    for vip_name, events in sorted(vip_events.items()):
        print(f"\n  Processing {vip_name}...")
        print(f"    Events: {len(events)}")
        
        result = create_mini_timeline(vip_name, events)
        
        if result:
            filename, md_content = result
            
            # Get date range for index
            earliest, latest = get_date_range(events)
            
            # Save timeline
            timeline_path = MINI_TIMELINES / filename
            with open(timeline_path, 'w', encoding='utf-8') as f:
                f.write(md_content)
            
            print(f"    Created: {filename}")
            print(f"    Period: {earliest.strftime('%Y-%m-%d')} to {latest.strftime('%Y-%m-%d')}")
            
            # Track for index
            vip_timelines[vip_name] = {
                'filename': filename,
                'start_date': earliest.strftime('%Y-%m-%d'),
                'end_date': latest.strftime('%Y-%m-%d'),
                'event_count': len(events)
            }
    
    # Create index
    print("\nCreating index...")
    index_md = create_index(vip_timelines)
    
    index_path = MINI_TIMELINES / "INDEX.md"
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(index_md)
    
    print(f"  Created: INDEX.md")
    
    # Summary
    print("\n" + "="*80)
    print("MINI-TIMELINES COMPLETE!")
    print("="*80)
    
    print(f"\nCreated {len(vip_timelines)} mini-timelines")
    print(f"Output location: {MINI_TIMELINES}")
    
    print("\nTop 5 VIPs by event count:")
    sorted_vips = sorted(vip_timelines.items(), key=lambda x: x[1]['event_count'], reverse=True)
    for i, (vip_name, info) in enumerate(sorted_vips[:5], 1):
        print(f"  {i}. {vip_name}: {info['event_count']} events ({info['start_date']} to {info['end_date']})")
    
    print(f"\nIndex: {index_path}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
