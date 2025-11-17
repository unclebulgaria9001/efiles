#!/usr/bin/env python3
"""
Process Nobody's Girl Memoir - Extract Timeline Data
Analyzes Virginia Roberts Giuffre's memoir for dates, events, people, locations
"""

import os
import sys
import json
import re
from pathlib import Path
from datetime import datetime
from collections import defaultdict
import pdfplumber
import PyPDF2

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
DOWNLOAD_PATH = BASE_PATH / "additional_downloads"
OUTPUT_PATH = BASE_PATH / "nobodys_girl_timeline"
UNIFIED_TIMELINE = BASE_PATH / "unified_timeline"

# Create output directory
OUTPUT_PATH.mkdir(exist_ok=True)

# Known people to track
KNOWN_PEOPLE = {
    "Jeffrey Epstein": ["Epstein", "Jeffrey", "Jeff"],
    "Ghislaine Maxwell": ["Ghislaine", "Maxwell", "Ghis"],
    "Prince Andrew": ["Andrew", "Prince Andrew", "Duke of York"],
    "Bill Clinton": ["Clinton", "President Clinton", "Bill"],
    "Donald Trump": ["Trump", "Donald"],
    "Alan Dershowitz": ["Dershowitz", "Alan"],
    "Jean-Luc Brunel": ["Brunel", "Jean-Luc"],
    "Leslie Wexner": ["Wexner", "Les"],
    "Sarah Kellen": ["Sarah", "Kellen"],
    "Nadia Marcinkova": ["Nadia", "Marcinkova"],
    "Adriana Ross": ["Adriana", "Ross"],
    "Virginia's father": ["Dad", "Sky", "father"],
    "Virginia's mother": ["Mom", "Lynn", "mother"]
}

# Known locations
KNOWN_LOCATIONS = [
    "Little St. James", "Little Saint James", "island",
    "Palm Beach", "Florida",
    "New York", "Manhattan", "East 71st Street",
    "New Mexico", "Zorro Ranch",
    "Paris", "France",
    "London", "United Kingdom", "England",
    "Thailand", "Bangkok",
    "Australia", "Sydney",
    "Virgin Islands", "St. Thomas",
    "Mar-a-Lago"
]

def extract_text_from_pdf(pdf_path):
    """Extract all text from PDF"""
    print(f"Extracting text from {pdf_path.name}...")
    
    full_text = ""
    
    # Try pdfplumber first
    try:
        with pdfplumber.open(pdf_path) as pdf:
            for i, page in enumerate(pdf.pages):
                text = page.extract_text()
                if text:
                    full_text += text + "\n\n"
                
                if (i + 1) % 10 == 0:
                    print(f"  Processed {i + 1} pages...")
    except Exception as e:
        print(f"  pdfplumber failed: {e}")
        
        # Fallback to PyPDF2
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                for i, page in enumerate(pdf_reader.pages):
                    text = page.extract_text()
                    if text:
                        full_text += text + "\n\n"
                    
                    if (i + 1) % 10 == 0:
                        print(f"  Processed {i + 1} pages...")
        except Exception as e2:
            print(f"  PyPDF2 also failed: {e2}")
            return None
    
    print(f"  Extracted {len(full_text):,} characters")
    return full_text

def extract_dates(text):
    """Extract all dates mentioned in the text"""
    print("\nExtracting dates...")
    
    dates = []
    
    # Date patterns
    patterns = [
        # Full dates
        (r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b', 'full_date'),
        # Month and year
        (r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{4}\b', 'month_year'),
        # Year only
        (r'\b(19\d{2}|20\d{2})\b', 'year'),
        # Numeric dates
        (r'\b\d{1,2}/\d{1,2}/\d{2,4}\b', 'numeric'),
        # Age mentions (to calculate dates)
        (r'\bI was (\d{1,2})\b', 'age'),
        (r'\bat (\d{1,2})\b', 'age'),
        (r'\bwhen I was (\d{1,2})\b', 'age')
    ]
    
    for pattern, date_type in patterns:
        matches = re.finditer(pattern, text, re.IGNORECASE)
        for match in matches:
            # Get context (200 chars before and after)
            start = max(0, match.start() - 200)
            end = min(len(text), match.end() + 200)
            context = text[start:end].replace('\n', ' ')
            
            dates.append({
                'date_string': match.group(0),
                'date_type': date_type,
                'context': context,
                'position': match.start()
            })
    
    print(f"  Found {len(dates)} date mentions")
    return dates

def extract_people_mentions(text):
    """Extract mentions of known people"""
    print("\nExtracting people mentions...")
    
    mentions = defaultdict(list)
    
    for person, aliases in KNOWN_PEOPLE.items():
        for alias in aliases:
            # Case-insensitive search
            pattern = re.compile(r'\b' + re.escape(alias) + r'\b', re.IGNORECASE)
            matches = pattern.finditer(text)
            
            for match in matches:
                # Get context
                start = max(0, match.start() - 200)
                end = min(len(text), match.end() + 200)
                context = text[start:end].replace('\n', ' ')
                
                mentions[person].append({
                    'alias_used': match.group(0),
                    'context': context,
                    'position': match.start()
                })
    
    # Count mentions per person
    for person in mentions:
        print(f"  {person}: {len(mentions[person])} mentions")
    
    return dict(mentions)

def extract_locations(text):
    """Extract mentions of known locations"""
    print("\nExtracting location mentions...")
    
    locations = defaultdict(list)
    
    for location in KNOWN_LOCATIONS:
        pattern = re.compile(r'\b' + re.escape(location) + r'\b', re.IGNORECASE)
        matches = pattern.finditer(text)
        
        for match in matches:
            # Get context
            start = max(0, match.start() - 200)
            end = min(len(text), match.end() + 200)
            context = text[start:end].replace('\n', ' ')
            
            locations[location].append({
                'context': context,
                'position': match.start()
            })
    
    # Count mentions per location
    for location in locations:
        print(f"  {location}: {len(locations[location])} mentions")
    
    return dict(locations)

def extract_key_events(text):
    """Extract key event descriptions"""
    print("\nExtracting key events...")
    
    # Keywords that indicate important events
    event_keywords = [
        'first time', 'first met', 'recruited', 'introduced',
        'flew to', 'traveled to', 'went to',
        'abuse', 'assault', 'forced', 'made me',
        'escaped', 'left', 'got away',
        'told', 'reported', 'came forward',
        'lawsuit', 'deposition', 'court'
    ]
    
    events = []
    
    for keyword in event_keywords:
        pattern = re.compile(r'[^.!?]*\b' + re.escape(keyword) + r'\b[^.!?]*[.!?]', re.IGNORECASE)
        matches = pattern.finditer(text)
        
        for match in matches:
            sentence = match.group(0).strip()
            
            # Get broader context
            start = max(0, match.start() - 300)
            end = min(len(text), match.end() + 300)
            context = text[start:end].replace('\n', ' ')
            
            events.append({
                'keyword': keyword,
                'sentence': sentence,
                'context': context,
                'position': match.start()
            })
    
    print(f"  Found {len(events)} key event mentions")
    return events

def create_timeline_entries(dates, people, locations, events, full_text):
    """Create timeline entries from extracted data"""
    print("\nCreating timeline entries...")
    
    timeline_entries = []
    
    # Combine all data by position in text
    all_items = []
    
    # Add dates
    for date_info in dates:
        all_items.append({
            'type': 'date',
            'position': date_info['position'],
            'data': date_info
        })
    
    # Add people mentions
    for person, person_mentions in people.items():
        for mention in person_mentions:
            all_items.append({
                'type': 'person',
                'position': mention['position'],
                'person': person,
                'data': mention
            })
    
    # Add location mentions
    for location, loc_mentions in locations.items():
        for mention in loc_mentions:
            all_items.append({
                'type': 'location',
                'position': mention['position'],
                'location': location,
                'data': mention
            })
    
    # Add events
    for event in events:
        all_items.append({
            'type': 'event',
            'position': event['position'],
            'data': event
        })
    
    # Sort by position
    all_items.sort(key=lambda x: x['position'])
    
    # Group nearby items (within 500 characters) into timeline entries
    current_entry = None
    proximity_threshold = 500
    
    for item in all_items:
        if current_entry is None:
            current_entry = {
                'dates': [],
                'people': [],
                'locations': [],
                'events': [],
                'position': item['position']
            }
        
        # Check if this item is close to current entry
        if item['position'] - current_entry['position'] > proximity_threshold:
            # Save current entry and start new one
            if current_entry['dates'] or current_entry['events']:
                timeline_entries.append(current_entry)
            
            current_entry = {
                'dates': [],
                'people': [],
                'locations': [],
                'events': [],
                'position': item['position']
            }
        
        # Add item to current entry
        if item['type'] == 'date':
            current_entry['dates'].append(item['data'])
        elif item['type'] == 'person':
            if item['person'] not in current_entry['people']:
                current_entry['people'].append(item['person'])
        elif item['type'] == 'location':
            if item['location'] not in current_entry['locations']:
                current_entry['locations'].append(item['location'])
        elif item['type'] == 'event':
            current_entry['events'].append(item['data'])
    
    # Add last entry
    if current_entry and (current_entry['dates'] or current_entry['events']):
        timeline_entries.append(current_entry)
    
    print(f"  Created {len(timeline_entries)} timeline entries")
    return timeline_entries

def create_markdown_timeline(timeline_entries, full_text):
    """Create markdown timeline from entries"""
    print("\nCreating markdown timeline...")
    
    md = f"""# Nobody's Girl - Timeline Analysis

**Source**: Nobody's Girl: A Memoir of Surviving Abuse and Fighting for Justice  
**Author**: Virginia Roberts Giuffre  
**Analyzed**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Timeline Entries**: {len(timeline_entries)}

---

## Overview

This timeline is extracted from Virginia Roberts Giuffre's memoir, providing first-hand accounts of:
- Recruitment and initial abuse
- Travel and locations visited
- People encountered
- Specific incidents with dates
- Escape and coming forward
- Legal battle timeline

---

## Timeline Entries

"""
    
    for i, entry in enumerate(timeline_entries, 1):
        md += f"### Entry #{i}\n\n"
        
        # Dates
        if entry['dates']:
            md += "**Dates Mentioned**:\n"
            for date in entry['dates']:
                md += f"- {date['date_string']} ({date['date_type']})\n"
            md += "\n"
        
        # People
        if entry['people']:
            md += f"**People**: {', '.join(entry['people'])}  \n\n"
        
        # Locations
        if entry['locations']:
            md += f"**Locations**: {', '.join(entry['locations'])}  \n\n"
        
        # Events
        if entry['events']:
            md += "**Events**:\n"
            for event in entry['events']:
                md += f"- *{event['keyword']}*: {event['sentence']}\n"
            md += "\n"
        
        # Context
        if entry['events']:
            md += f"**Context**: {entry['events'][0]['context'][:300]}...\n\n"
        elif entry['dates']:
            md += f"**Context**: {entry['dates'][0]['context'][:300]}...\n\n"
        
        md += "---\n\n"
    
    return md

def main():
    """Main processing function"""
    print("="*80)
    print("PROCESS NOBODY'S GIRL MEMOIR")
    print("="*80)
    
    # Find PDF
    pdf_path = DOWNLOAD_PATH / "nobodys_girl_virginia_giuffre.pdf"
    
    if not pdf_path.exists():
        print(f"\nERROR: PDF not found at {pdf_path}")
        print("\nPlease download the book first:")
        print("  Run: .\\DOWNLOAD_NOBODYS_GIRL.ps1")
        print("  Or manually save PDF to:", pdf_path)
        return 1
    
    # Extract text
    full_text = extract_text_from_pdf(pdf_path)
    
    if not full_text:
        print("\nERROR: Could not extract text from PDF")
        return 1
    
    # Save full text
    text_path = OUTPUT_PATH / "nobodys_girl_full_text.txt"
    with open(text_path, 'w', encoding='utf-8') as f:
        f.write(full_text)
    print(f"\nSaved full text: {text_path}")
    
    # Extract data
    dates = extract_dates(full_text)
    people = extract_people_mentions(full_text)
    locations = extract_locations(full_text)
    events = extract_key_events(full_text)
    
    # Create timeline entries
    timeline_entries = create_timeline_entries(dates, people, locations, events, full_text)
    
    # Create markdown timeline
    timeline_md = create_markdown_timeline(timeline_entries, full_text)
    
    # Save timeline
    timeline_path = OUTPUT_PATH / "NOBODYS_GIRL_TIMELINE.md"
    with open(timeline_path, 'w', encoding='utf-8') as f:
        f.write(timeline_md)
    print(f"Saved timeline: {timeline_path}")
    
    # Save JSON data
    json_data = {
        'source': 'Nobody\'s Girl by Virginia Roberts Giuffre',
        'analyzed': datetime.now().isoformat(),
        'timeline_entries': timeline_entries,
        'statistics': {
            'total_entries': len(timeline_entries),
            'dates_found': len(dates),
            'people_mentions': {person: len(mentions) for person, mentions in people.items()},
            'location_mentions': {loc: len(mentions) for loc, mentions in locations.items()},
            'key_events': len(events)
        }
    }
    
    json_path = OUTPUT_PATH / "nobodys_girl_data.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, indent=2)
    print(f"Saved JSON data: {json_path}")
    
    # Summary
    print("\n" + "="*80)
    print("PROCESSING COMPLETE!")
    print("="*80)
    print(f"\nTimeline entries: {len(timeline_entries)}")
    print(f"Dates found: {len(dates)}")
    print(f"People tracked: {len(people)}")
    print(f"Locations found: {len(locations)}")
    print(f"Key events: {len(events)}")
    
    print(f"\nOutput location: {OUTPUT_PATH}")
    print(f"  - Full text: nobodys_girl_full_text.txt")
    print(f"  - Timeline: NOBODYS_GIRL_TIMELINE.md")
    print(f"  - JSON data: nobodys_girl_data.json")
    
    print("\nNext step: Add to unified timeline")
    print("  Run: .\\ADD_NOBODYS_GIRL_TO_TIMELINE.ps1")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
