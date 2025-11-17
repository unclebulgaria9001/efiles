#!/usr/bin/env python3
"""
Update Timelines with Telephone Message Book Analysis
Adds message book evidence to unified timeline, mini-timelines, and cohort analysis
"""

import json
from pathlib import Path
from datetime import datetime

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
TIMELINE_JSON = BASE_PATH / "unified_timeline" / "timeline_data.json"
COHORT_FILE = BASE_PATH / "COHORT_ANALYSIS.md"
CONNECTIONS_FILE = BASE_PATH / "RELATIONSHIP_NETWORK_ANALYSIS.md"

# Message book events to add
MESSAGE_BOOK_EVENTS = [
    {
        "date": "20051020",
        "formatted_date": "October 20, 2005",
        "title": "Telephone Message Books Seized",
        "type": "COURT",
        "category": "Evidence",
        "people": ["Jeffrey Epstein", "Sarah Kellen", "Detective Joseph Recarey"],
        "locations": ["Palm Beach"],
        "description": "Palm Beach Police execute search warrant at Epstein's mansion. Telephone message books with carbon copies seized from kitchen, office, and staff quarters. Books cover 2003-2005.",
        "source": "Case 1-05-000368, Detective Recarey",
        "significance": "Critical evidence of systematic operation"
    },
    {
        "date": "20051215",
        "formatted_date": "December 15, 2005",
        "title": "Message Books Reviewed - Victims Identified",
        "type": "INVESTIGATION",
        "category": "Evidence Analysis",
        "people": ["Detective Joseph Recarey", "Sarah Kellen", "Jeffrey Epstein"],
        "locations": ["Palm Beach"],
        "description": "Detective Recarey reviews telephone message books. Finds first names of girls, phone numbers, and messages confirming 'work'. Also finds recruitment messages: 'I have girls for him' and 'I have 2 girls for him' taken by Sarah Kellen for Epstein.",
        "source": "Detective Recarey Report, December 15, 2005",
        "significance": "Led to identification of dozens of victims through subpoenas"
    },
    {
        "date": "20051215",
        "formatted_date": "December 15, 2005",
        "title": "Subpoenas Issued Based on Message Books",
        "type": "INVESTIGATION",
        "category": "Legal Action",
        "people": ["Detective Joseph Recarey"],
        "locations": ["Palm Beach"],
        "description": "Based on telephone message book evidence, Detective Recarey requests subpoenas for subscriber information on phone numbers and time frame data. Copies of messages made for evidentiary purposes.",
        "source": "Detective Recarey Report",
        "significance": "Investigative roadmap for victim identification"
    },
    {
        "date": "20051208",
        "formatted_date": "December 8, 2005",
        "title": "Victim Located Through Message Book",
        "type": "INVESTIGATION",
        "category": "Victim Identification",
        "people": ["Detective Joseph Recarey", "Detective Caristo"],
        "locations": ["Palm Beach"],
        "description": "Detective Recarey reviews 2005 yearbook and locates victim from message book. Cross-references name spelling with phone records. Victim identified as minor attending school, participating in early release program.",
        "source": "Detective Recarey Report",
        "significance": "Message books led to victim identification"
    },
    {
        "date": "20051213",
        "formatted_date": "December 13, 2005",
        "title": "Minor Victim Interview - Message Book Case",
        "type": "INVESTIGATION",
        "category": "Victim Testimony",
        "people": ["Detective Dawson", "Detective Joseph Recarey"],
        "locations": ["Palm Beach"],
        "description": "Interview of 16-year-old victim identified through message book. Testified she was recruited before Christmas 2004, needed money for Christmas. Taken to Epstein's house by friend, encountered Sarah Kellen (white female with long blond hair), provided massage that became sexual.",
        "source": "Sworn taped statement, December 13, 2005",
        "significance": "Corroborated message book evidence"
    }
]

# Sarah Kellen message book activities
SARAH_KELLEN_ACTIVITIES = [
    {
        "date": "20030101",
        "formatted_date": "2003-2005 (ongoing)",
        "title": "Sarah Kellen Takes Telephone Messages",
        "type": "OPERATIONAL",
        "category": "Coordination",
        "people": ["Sarah Kellen", "Jeffrey Epstein"],
        "locations": ["Palm Beach"],
        "description": "Sarah Kellen systematically takes telephone messages in carbon copy books. Records victim confirmations of 'work', recruitment offers ('I have girls for him'), schedules appointments. Professional message-taking system maintained over years.",
        "source": "Telephone message books 2003-2005",
        "significance": "Evidence of Sarah Kellen's central coordinating role"
    }
]

def load_timeline_data():
    """Load existing timeline data"""
    if TIMELINE_JSON.exists():
        with open(TIMELINE_JSON, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

def add_message_book_events(timeline_data):
    """Add message book events to timeline"""
    print("Adding message book events to timeline...")
    
    # Add new events
    for event in MESSAGE_BOOK_EVENTS + SARAH_KELLEN_ACTIVITIES:
        # Check if event already exists
        exists = any(
            e.get('date') == event['date'] and 
            e.get('title') == event['title']
            for e in timeline_data
        )
        
        if not exists:
            timeline_data.append(event)
            print(f"  Added: {event['formatted_date']} - {event['title']}")
    
    # Sort by date (handle None values)
    timeline_data.sort(key=lambda x: x.get('date', '') or '')
    
    return timeline_data

def save_timeline_data(timeline_data):
    """Save updated timeline data"""
    with open(TIMELINE_JSON, 'w', encoding='utf-8') as f:
        json.dump(timeline_data, f, indent=2)
    print(f"\nSaved updated timeline: {TIMELINE_JSON}")

def update_cohort_analysis():
    """Update cohort analysis with message book information"""
    print("\n" + "="*80)
    print("UPDATING COHORT ANALYSIS")
    print("="*80)
    
    if not COHORT_FILE.exists():
        print("Cohort analysis file not found")
        return
    
    with open(COHORT_FILE, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add message book section to Sarah Kellen's profile
    sarah_section = """
#### **Message Book Coordinator** (2003-2005)

**Evidence from Telephone Message Books**:

**Role**: Primary message taker and scheduler

> "These messages were taken by Sarah for Jeffrey Epstein" - Detective Recarey

**Responsibilities**:
1. **Answer phone calls** from victims and recruiters
2. **Record messages** in carbon copy books
3. **Schedule appointments** ("work" times)
4. **Coordinate arrivals** with household staff
5. **Maintain permanent records** of all communications

**Message Types Taken**:
- **Victim confirmations**: "Confirming work" calls
- **Recruitment offers**: "I have girls for him", "I have 2 girls for him"
- **Scheduling**: Times and dates for appointments

**Evidence Value**:
- Carbon copy records (2003-2005)
- First names and phone numbers documented
- Led to victim identification through subpoenas
- Corroborated by victim testimony

**Phone Records**:
- **Number**: 917-855-3363
- **Subscriber**: Sarah Kellen
- **Paid by**: Jeffrey Epstein
- **Address**: Epstein's residence
"""
    
    # Find Sarah Kellen section and add message book info
    if "#### **Sarah Kellen** (Scheduler/Coordinator)" in content:
        # Add after her main description
        content = content.replace(
            "**Connections**: Epstein, Maxwell, victims",
            "**Connections**: Epstein, Maxwell, victims\n" + sarah_section
        )
        
        with open(COHORT_FILE, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("  Updated Sarah Kellen's cohort profile with message book evidence")
    
    return content

def create_message_book_summary():
    """Create summary document for quick reference"""
    summary_file = BASE_PATH / "MESSAGE_BOOK_SUMMARY.md"
    
    content = """# Telephone Message Book Summary

**Quick Reference Guide**

## Key Evidence

### **What Was Seized**
- **Telephone message books** with carbon copies
- **Years**: 2003, 2004, 2005
- **Locations**: Kitchen, office, staff quarters
- **Format**: Top copy torn off, carbon copy remained

### **What Was Found**

#### **Type 1: Victim Confirmations**
- First names of girls
- Phone numbers
- Messages: "Confirming work"
- Time of day called

#### **Type 2: Recruitment Messages**
- "I have girls for him"
- "I have 2 girls for him"
- Taken by Sarah Kellen
- For Jeffrey Epstein

### **Investigation Results**

**Process**:
1. Message books seized (October 20, 2005)
2. Reviewed by Detective Recarey (December 15, 2005)
3. Subpoenas issued for phone numbers
4. Victims identified through yearbooks
5. Interviews conducted
6. Testimony collected

**Outcome**:
- Dozens of victims identified
- "Most of the girls" found in 2005 yearbook
- Corroborated victim testimony
- Evidence of systematic operation

### **Sarah Kellen's Role**

**Primary Message Taker**:
- Took all messages for Epstein
- Maintained carbon copy records
- Scheduled "work" appointments
- Coordinated recruitment

**Phone**: 917-855-3363 (paid by Epstein)

### **Code Language**

- **"Work"** = Massage/sexual services
- **"Girls"** = Victims/targets

### **Legal Significance**

**Evidence of**:
1. Sex trafficking of minors
2. Systematic operation (3+ years)
3. Staff involvement (Sarah Kellen)
4. Recruitment network
5. Pattern and practice

**Admissibility**: Business records exception

---

**See**: `TELEPHONE_MESSAGE_BOOK_ANALYSIS.md` for complete analysis
"""
    
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\n  Created summary: {summary_file.name}")

def main():
    print("\n" + "="*80)
    print("UPDATING TIMELINES WITH MESSAGE BOOK ANALYSIS")
    print("="*80)
    
    # Load timeline
    timeline_data = load_timeline_data()
    print(f"\nLoaded {len(timeline_data)} existing events")
    
    # Add message book events
    timeline_data = add_message_book_events(timeline_data)
    
    # Save updated timeline
    save_timeline_data(timeline_data)
    
    # Update cohort analysis
    update_cohort_analysis()
    
    # Create summary
    create_message_book_summary()
    
    print("\n" + "="*80)
    print("UPDATE COMPLETE!")
    print("="*80)
    print("\nNext steps:")
    print("1. Run: python scripts/create_unified_timeline.py")
    print("2. Run: python scripts/create_mini_timelines.py")
    print("3. Review updated timelines")

if __name__ == "__main__":
    main()
