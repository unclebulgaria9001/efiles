#!/usr/bin/env python3
"""
Extract ALL Specific Message Book Calls with Times
Comprehensive extraction of every documented phone call from message books and phone records
"""

import json
from pathlib import Path

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
OUTPUT_FILE = BASE_PATH / "unified_timeline" / "message_book_calls.json"

# ALL documented message book calls with specific dates and times
ALL_MESSAGE_BOOK_CALLS = [
    # FEBRUARY 6, 2005 - DETAILED CALL SEQUENCE
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 12:49 PM",
        "title": "Haley Robson First Call - Victim Recruitment Day",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Victim"],
        "locations": ["Palm Beach"],
        "description": "First incoming call from Haley Robson's residence (561-333-0180) at 12:49 PM. Same day victim and victim's father stated incident occurred at Epstein's house. Start of documented call sequence leading to victim being brought to Epstein.",
        "source": "Detective Recarey Report, Cingular Wireless phone records",
        "evidence_type": "Phone records",
        "significance": "Documented start of recruitment sequence",
        "call_time": "12:49 PM EST",
        "phone_number": "561-333-0180",
        "call_type": "Incoming from Robson residence"
    },
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 12:50 PM",
        "title": "Haley Robson Calls Sarah Kellen",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Sarah Kellen"],
        "locations": ["Palm Beach", "New York"],
        "description": "Haley Robson calls Sarah Kellen (Epstein's assistant) at 917-855-3363 at 12:50 PM EST. First step in coordination sequence to bring victim to Epstein's house.",
        "source": "Detective Recarey Report, Phone records analysis",
        "evidence_type": "Phone records",
        "significance": "Shows Robson coordinating with Kellen before bringing victim",
        "call_time": "12:50 PM EST",
        "phone_number": "917-855-3363",
        "call_type": "Outgoing to Sarah Kellen"
    },
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 12:52 PM",
        "title": "Haley Robson Calls Epstein's Palm Beach House",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Jeffrey Epstein"],
        "locations": ["Palm Beach"],
        "description": "Haley Robson calls Epstein's Palm Beach house at 12:52 PM EST. Two minutes after calling Sarah Kellen, confirming coordination of victim delivery.",
        "source": "Detective Recarey Report, Phone records",
        "evidence_type": "Phone records",
        "significance": "Direct call to Epstein's house to arrange victim visit",
        "call_time": "12:52 PM EST",
        "call_type": "Outgoing to Epstein residence"
    },
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 1:01 PM",
        "title": "Haley Robson Calls Victim (First Call)",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Victim"],
        "locations": ["Palm Beach"],
        "description": "Haley Robson calls victim at 1:01 PM EST. After coordinating with Kellen and Epstein's house, Robson contacts victim to arrange pickup.",
        "source": "Detective Recarey Report, Phone records",
        "evidence_type": "Phone records",
        "significance": "Recruitment call to victim after coordination complete",
        "call_time": "1:01 PM EST",
        "call_duration": "One minute or less",
        "call_type": "Outgoing to victim"
    },
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 1:02 PM",
        "title": "Haley Robson Calls Victim (Second Call)",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Haley Robson", "Victim"],
        "locations": ["Palm Beach"],
        "description": "Second call from Haley Robson's cellular phone (561-308-0282) to victim at 1:02 PM EST. Call duration one minute or less. Time frame within thirteen minutes of first call. Robson's residence in close proximity to victim's.",
        "source": "Detective Recarey Report, Cingular Wireless records",
        "evidence_type": "Phone records",
        "significance": "Follow-up recruitment call, victim brought to Epstein same day",
        "call_time": "1:02 PM EST",
        "phone_number": "561-308-0282",
        "call_duration": "One minute or less",
        "call_type": "Outgoing from Robson cellular"
    },
    {
        "date": "20050206",
        "formatted_date": "February 6, 2005 - 5:50 PM",
        "title": "Victim Calls Haley Robson After Incident",
        "type": "PHONE_CALL",
        "category": "Message Book Evidence",
        "people": ["Victim", "Haley Robson"],
        "locations": ["Palm Beach"],
        "description": "Victim telephoned Robson's residence at 5:50 PM, after incident at Epstein's house. Several calls made after this, both incoming and outgoing to Robson.",
        "source": "Detective Recarey Report, Phone records",
        "evidence_type": "Phone records",
        "significance": "Post-incident contact between victim and recruiter",
        "call_time": "5:50 PM EST",
        "call_type": "Incoming to Robson residence"
    },
    
    # JULY 2004 - MAXWELL MESSAGE
    {
        "date": "20040700",
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
    
    # APRIL 5, 2005 - TRASH PULL
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
        "legal_note": "Detective Recarey testified about this evidence",
        "call_time": "11:00 AM"
    },
    
    # SEPTEMBER-OCTOBER 2005 - PHONE RECORDS
    {
        "date": "20050900",
        "formatted_date": "September 2005",
        "title": "Sarah Kellen Phone Records - Multiple Victim Calls",
        "type": "PHONE_RECORDS",
        "category": "Evidence Analysis",
        "people": ["Sarah Kellen", "Jeffrey Epstein"],
        "locations": ["Palm Beach", "New York"],
        "description": "Analysis of Sarah Kellen's cellular phone (917-855-3363) for September-October 2005. Phone financially responsible party: Jeffrey Epstein, 457 Madison Ave, New York. Eighty-seven pages of calls made to/from cell phone. Local (561) numbers analyzed. Kellen called victim/witnesses frequently when Epstein in Palm Beach to 'work'. Confirms girls' testimony that Kellen notified them when Epstein in town.",
        "source": "Detective Recarey Report, Cingular Wireless subpoena",
        "evidence_type": "Phone records",
        "significance": "Epstein paid for Sarah's phone used to coordinate victims",
        "phone_number": "917-855-3363",
        "record_pages": "87 pages of calls"
    },
    {
        "date": "20051000",
        "formatted_date": "October 2005",
        "title": "Haley Robson Phone Records - Victim Coordination",
        "type": "PHONE_RECORDS",
        "category": "Evidence Analysis",
        "people": ["Haley Robson"],
        "locations": ["Palm Beach"],
        "description": "Analysis of Haley Robson's phone records (561-308-0282) from Cingular Wireless. Records show calls during timeframe when victims were brought to Epstein house to 'work'. Incoming and outgoing calls analyzed. No calls to Robson's cellular or residence prior to February 6, 2005.",
        "source": "Detective Recarey Report, Phone records subpoena",
        "evidence_type": "Phone records",
        "significance": "Documented recruitment and coordination calls",
        "phone_number": "561-308-0282"
    },
    
    # INVESTIGATION EVENTS
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

def save_all_calls():
    """Save all message book calls to JSON"""
    print(f"\nTotal message book call events: {len(ALL_MESSAGE_BOOK_CALLS)}")
    
    # Save to JSON
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(ALL_MESSAGE_BOOK_CALLS, f, indent=2)
    
    print(f"Saved to: {OUTPUT_FILE}")
    
    # Print summary
    print("\n" + "="*80)
    print("MESSAGE BOOK CALLS SUMMARY")
    print("="*80)
    
    # Group by date
    by_date = {}
    for call in ALL_MESSAGE_BOOK_CALLS:
        date = call['date']
        if date not in by_date:
            by_date[date] = []
        by_date[date].append(call)
    
    for date in sorted(by_date.keys()):
        calls = by_date[date]
        print(f"\n{date}:")
        for call in calls:
            print(f"  - {call['formatted_date']}: {call['title']}")
            if 'call_time' in call:
                print(f"    Time: {call['call_time']}")
            if 'phone_number' in call:
                print(f"    Phone: {call['phone_number']}")

if __name__ == "__main__":
    print("="*80)
    print("EXTRACTING ALL MESSAGE BOOK CALLS")
    print("="*80)
    save_all_calls()
    print("\n" + "="*80)
    print("COMPLETE!")
    print("="*80)
    print("\nNext: Run python scripts/create_unified_timeline.py")
