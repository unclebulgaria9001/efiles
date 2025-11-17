#!/usr/bin/env python3
"""
Consolidate Timeline Using Person Aliases
Updates timeline_data.json to use canonical names for all people
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from person_aliases import get_canonical_name, merge_person_names, PERSON_ALIASES

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
UNIFIED_TIMELINE = BASE_PATH / "unified_timeline"
TIMELINE_JSON = UNIFIED_TIMELINE / "timeline_data.json"
TIMELINE_JSON_BACKUP = UNIFIED_TIMELINE / "timeline_data_before_alias_consolidation.json"

def load_timeline():
    """Load the timeline JSON"""
    if not TIMELINE_JSON.exists():
        print(f"ERROR: Timeline not found at {TIMELINE_JSON}")
        return None
    
    with open(TIMELINE_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_timeline(data):
    """Save the timeline JSON"""
    with open(TIMELINE_JSON, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def backup_timeline():
    """Create backup of original timeline"""
    if TIMELINE_JSON.exists():
        with open(TIMELINE_JSON, 'r', encoding='utf-8') as f:
            data = json.load(f)
        with open(TIMELINE_JSON_BACKUP, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"  Backup created: {TIMELINE_JSON_BACKUP.name}")

def consolidate_people_in_event(event):
    """Consolidate people names in a single event"""
    if 'people' not in event:
        return event, []
    
    original_people = event['people']
    canonical_people = merge_person_names(original_people)
    
    changes = []
    if set(original_people) != set(canonical_people):
        changes.append({
            'original': original_people,
            'canonical': canonical_people
        })
    
    event['people'] = canonical_people
    return event, changes

def analyze_consolidation(timeline_data):
    """Analyze what would change with consolidation"""
    print("\nAnalyzing potential consolidations...")
    
    # Count unique names before
    all_people_before = set()
    for event in timeline_data:
        if 'people' in event:
            all_people_before.update(event['people'])
    
    # Count what they would become
    all_people_after = set()
    for person in all_people_before:
        canonical = get_canonical_name(person)
        all_people_after.add(canonical)
    
    print(f"\n  Unique people before: {len(all_people_before)}")
    print(f"  Unique people after: {len(all_people_after)}")
    print(f"  Reduction: {len(all_people_before) - len(all_people_after)} duplicates")
    
    # Show examples of consolidations
    print("\n  Example consolidations:")
    consolidation_examples = defaultdict(list)
    for person in all_people_before:
        canonical = get_canonical_name(person)
        if canonical != person:
            consolidation_examples[canonical].append(person)
    
    # Show top 10
    sorted_examples = sorted(
        consolidation_examples.items(),
        key=lambda x: len(x[1]),
        reverse=True
    )[:10]
    
    for canonical, aliases in sorted_examples:
        print(f"    '{canonical}' ← {aliases}")
    
    return len(all_people_before) - len(all_people_after)

def consolidate_timeline(timeline_data):
    """Consolidate all people names in timeline"""
    print("\nConsolidating timeline...")
    
    total_events = len(timeline_data)
    events_changed = 0
    all_changes = []
    
    for i, event in enumerate(timeline_data):
        event, changes = consolidate_people_in_event(event)
        if changes:
            events_changed += 1
            all_changes.extend(changes)
        
        if (i + 1) % 500 == 0:
            print(f"  Processed {i + 1}/{total_events} events...")
    
    print(f"\n  Total events: {total_events}")
    print(f"  Events changed: {events_changed}")
    print(f"  Total consolidations: {len(all_changes)}")
    
    return timeline_data, events_changed

def generate_consolidation_report(timeline_data):
    """Generate a report of all consolidations"""
    print("\nGenerating consolidation report...")
    
    # Count occurrences of each canonical name
    name_counts = defaultdict(int)
    for event in timeline_data:
        if 'people' in event:
            for person in event['people']:
                name_counts[person] += 1
    
    # Create report
    report_path = UNIFIED_TIMELINE / "ALIAS_CONSOLIDATION_REPORT.md"
    
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write("# Timeline Alias Consolidation Report\n\n")
        f.write(f"**Generated**: {Path(__file__).name}\n\n")
        f.write("---\n\n")
        
        f.write("## Summary\n\n")
        f.write(f"- **Total unique people**: {len(name_counts)}\n")
        f.write(f"- **Total canonical names**: {len(PERSON_ALIASES)}\n")
        f.write(f"- **Events processed**: {len(timeline_data)}\n\n")
        
        f.write("---\n\n")
        f.write("## Top People by Event Count\n\n")
        
        sorted_counts = sorted(name_counts.items(), key=lambda x: x[1], reverse=True)
        
        f.write("| Rank | Person | Events | Aliases |\n")
        f.write("|------|--------|--------|----------|\n")
        
        for i, (person, count) in enumerate(sorted_counts[:50], 1):
            aliases = PERSON_ALIASES.get(person, [])
            alias_count = len(aliases)
            f.write(f"| {i} | **{person}** | {count} | {alias_count} |\n")
        
        f.write("\n---\n\n")
        f.write("## All Canonical Names with Aliases\n\n")
        
        for canonical in sorted(PERSON_ALIASES.keys()):
            aliases = PERSON_ALIASES[canonical]
            count = name_counts.get(canonical, 0)
            
            f.write(f"### {canonical}\n\n")
            f.write(f"**Events**: {count}  \n")
            f.write(f"**Aliases**: {len(aliases)}\n\n")
            
            for alias in sorted(aliases):
                f.write(f"- `{alias}`\n")
            
            f.write("\n")
    
    print(f"  Report saved: {report_path.name}")

def main():
    print("=" * 80)
    print("CONSOLIDATE TIMELINE USING PERSON ALIASES")
    print("=" * 80)
    
    # Load timeline
    print("\nLoading timeline...")
    timeline_data = load_timeline()
    
    if not timeline_data:
        return 1
    
    print(f"  Loaded {len(timeline_data)} events")
    
    # Analyze
    duplicates = analyze_consolidation(timeline_data)
    
    if duplicates == 0:
        print("\n  No consolidations needed!")
        return 0
    
    # Confirm
    print(f"\nThis will consolidate {duplicates} duplicate person names.")
    print("Continue? (Y/N)")
    response = input().strip().upper()
    
    if response != 'Y':
        print("  Cancelled.")
        return 0
    
    # Backup
    print("\nCreating backup...")
    backup_timeline()
    
    # Consolidate
    timeline_data, events_changed = consolidate_timeline(timeline_data)
    
    # Save
    print("\nSaving consolidated timeline...")
    save_timeline(timeline_data)
    print(f"  Saved: {TIMELINE_JSON.name}")
    
    # Generate report
    generate_consolidation_report(timeline_data)
    
    print("\n" + ("=" * 80))
    print("CONSOLIDATION COMPLETE!")
    print("=" * 80)
    print(f"\nEvents changed: {events_changed}")
    print(f"Duplicates removed: {duplicates}")
    print(f"\nBackup: {TIMELINE_JSON_BACKUP.name}")
    print(f"Report: ALIAS_CONSOLIDATION_REPORT.md")
    
    print("\nNext steps:")
    print("  1. Review the consolidation report")
    print("  2. Run: python scripts\\create_unified_timeline.py")
    print("  3. Run: python scripts\\create_mini_timelines.py")
    print("  4. Regenerate all timelines with consolidated names")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
