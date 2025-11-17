#!/usr/bin/env python3
"""
Update All Analysis - Person Counts, Dashboards, Reports
Uses complete extraction data to regenerate all analytics
"""

import os
import sys
import json
import re
from pathlib import Path
from datetime import datetime
from collections import Counter, defaultdict

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
COMPLETE_EXTRACTION = BASE_PATH / "complete_extraction"
ANALYTICS_PATH = BASE_PATH / "analytics"
TOP_300_PATH = BASE_PATH / "top_300_people"
INVESTIGATION_PATH = BASE_PATH / "investigation"

# Create output directories
ANALYTICS_PATH.mkdir(exist_ok=True)
TOP_300_PATH.mkdir(exist_ok=True)

# Known VIPs with aliases
KNOWN_VIPS = {
    "Jeffrey Epstein": ["Epstein", "Jeffrey", "Jeff Epstein", "JE"],
    "Ghislaine Maxwell": ["Maxwell", "Ghislaine", "GM", "G Maxwell"],
    "Virginia Giuffre": ["Virginia Roberts", "Giuffre", "Roberts", "Virginia", "V Giuffre"],
    "Prince Andrew": ["Andrew", "Duke of York", "Prince Andrew"],
    "Bill Clinton": ["Clinton", "William Clinton", "President Clinton", "Bill"],
    "Donald Trump": ["Trump", "Donald J Trump", "President Trump", "Donald"],
    "Alan Dershowitz": ["Dershowitz", "Alan"],
    "Leslie Wexner": ["Wexner", "Les Wexner"],
    "Jean-Luc Brunel": ["Brunel", "Jean Luc Brunel"],
    "Sarah Kellen": ["Kellen", "Sarah"],
    "Nadia Marcinkova": ["Marcinkova", "Nadia"],
    "Adriana Ross": ["Ross", "Adriana"],
    "Lesley Groff": ["Groff", "Lesley"],
    "Johanna Sjoberg": ["Sjoberg", "Johanna"],
    "Sarah Ransome": ["Ransome", "Sarah"]
}

# Sensitive terms
SENSITIVE_TERMS = [
    "sex", "sexual", "massage", "nude", "underage", "minor", "minors",
    "trafficking", "abuse", "assault", "victim", "victims", "rape",
    "drug", "drugs", "cocaine", "pills"
]

def load_all_documents():
    """Load all extracted documents"""
    print("Loading all extracted documents...")
    
    docs_path = COMPLETE_EXTRACTION / "all_documents"
    if not docs_path.exists():
        print("  ERROR: Complete extraction not found!")
        print("  Please run EXTRACT_AND_PROCESS_ALL.ps1 first")
        return []
    
    documents = []
    metadata_files = list(docs_path.glob("*_metadata.json"))
    
    print(f"  Found {len(metadata_files)} documents")
    
    for meta_file in metadata_files:
        try:
            with open(meta_file, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            
            # Load corresponding text file
            text_file = docs_path / f"{metadata['doc_id']}.txt"
            if text_file.exists():
                with open(text_file, 'r', encoding='utf-8') as f:
                    text = f.read()
                metadata['full_text'] = text
            else:
                metadata['full_text'] = ""
            
            documents.append(metadata)
        except Exception as e:
            print(f"  Error loading {meta_file.name}: {e}")
    
    print(f"  Loaded {len(documents)} documents successfully")
    return documents

def count_all_people(documents):
    """Count all people mentions across all documents"""
    print("\nCounting all people mentions...")
    
    people_data = defaultdict(lambda: {
        'total_mentions': 0,
        'documents': [],
        'contexts': [],
        'sensitive_terms': Counter(),
        'document_types': Counter(),
        'dates': []
    })
    
    for doc in documents:
        doc_people = doc.get('people', [])
        doc_id = doc['doc_id']
        doc_types = doc.get('document_types', [])
        doc_dates = doc.get('dates', [])
        text_lower = doc.get('full_text', '').lower()
        
        # Count people in this document
        for person in doc_people:
            if len(person) < 5:  # Skip very short names
                continue
            
            # Count occurrences
            pattern = re.escape(person.lower())
            matches = len(re.findall(pattern, text_lower))
            
            if matches > 0:
                people_data[person]['total_mentions'] += matches
                people_data[person]['documents'].append(doc_id)
                
                # Track document types
                for doc_type in doc_types:
                    people_data[person]['document_types'][doc_type] += 1
                
                # Track dates
                people_data[person]['dates'].extend([d['date_string'] for d in doc_dates[:3]])
                
                # Check for sensitive terms
                for term in SENSITIVE_TERMS:
                    if term in text_lower:
                        people_data[person]['sensitive_terms'][term] += 1
                
                # Extract context (first occurrence)
                if len(people_data[person]['contexts']) < 3:
                    lines = doc.get('full_text', '').split('\n')
                    for line in lines:
                        if person.lower() in line.lower():
                            context = line.strip()[:200]
                            if context and context not in people_data[person]['contexts']:
                                people_data[person]['contexts'].append(context)
                                break
    
    print(f"  Found {len(people_data)} unique people")
    return dict(people_data)

def identify_vips(people_data):
    """Identify VIP mentions"""
    print("\nIdentifying VIP mentions...")
    
    vip_data = {}
    
    for vip_name, aliases in KNOWN_VIPS.items():
        vip_data[vip_name] = {
            'total_mentions': 0,
            'documents': set(),
            'contexts': [],
            'sensitive_terms': Counter(),
            'document_types': Counter(),
            'dates': []
        }
        
        # Check all aliases
        for alias in [vip_name] + aliases:
            alias_lower = alias.lower()
            
            # Find matches in people_data
            for person, data in people_data.items():
                if alias_lower in person.lower() or person.lower() in alias_lower:
                    vip_data[vip_name]['total_mentions'] += data['total_mentions']
                    vip_data[vip_name]['documents'].update(data['documents'])
                    vip_data[vip_name]['contexts'].extend(data['contexts'])
                    vip_data[vip_name]['sensitive_terms'].update(data['sensitive_terms'])
                    vip_data[vip_name]['document_types'].update(data['document_types'])
                    vip_data[vip_name]['dates'].extend(data['dates'])
    
    # Convert sets to lists for JSON serialization
    for vip in vip_data:
        vip_data[vip]['documents'] = list(vip_data[vip]['documents'])
        vip_data[vip]['contexts'] = vip_data[vip]['contexts'][:5]  # Top 5
        vip_data[vip]['dates'] = list(set(vip_data[vip]['dates']))[:10]  # Top 10 unique
    
    vips_found = sum(1 for v in vip_data.values() if v['total_mentions'] > 0)
    print(f"  Found {vips_found} VIPs with mentions")
    
    return vip_data

def create_dashboard(documents, people_data, vip_data):
    """Create main dashboard"""
    print("\nCreating dashboard...")
    
    # Calculate statistics
    total_docs = len(documents)
    total_people = len(people_data)
    total_vips = sum(1 for v in vip_data.values() if v['total_mentions'] > 0)
    
    doc_types = Counter()
    for doc in documents:
        for dt in doc.get('document_types', []):
            doc_types[dt] += 1
    
    docs_with_sensitive = sum(1 for doc in documents 
                              if any(term in doc.get('full_text', '').lower() 
                                    for term in SENSITIVE_TERMS))
    
    # Top 20 people
    top_people = sorted(people_data.items(), 
                       key=lambda x: x[1]['total_mentions'], 
                       reverse=True)[:20]
    
    # Create dashboard markdown
    dashboard = f"""# Analytics Dashboard - Complete Analysis

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Data Source**: Complete extraction of all 388 PDFs

---

## 📊 Key Statistics

### Documents
- **Total Documents Analyzed**: {total_docs:,}
- **Total Text Extracted**: {sum(doc.get('text_length', 0) for doc in documents):,} characters
- **Documents with Sensitive Terms**: {docs_with_sensitive}
- **Images Extracted**: {sum(doc.get('images_extracted', 0) for doc in documents)}

### People
- **Unique People Identified**: {total_people:,}
- **Total Person Mentions**: {sum(p['total_mentions'] for p in people_data.values()):,}
- **VIPs Identified**: {total_vips}
- **Average Mentions per Person**: {sum(p['total_mentions'] for p in people_data.values()) / max(total_people, 1):.1f}

### Document Types
"""
    
    for doc_type, count in doc_types.most_common():
        dashboard += f"- **{doc_type.replace('_', ' ').title()}**: {count} documents\n"
    
    dashboard += f"""

---

## 👥 Top 20 Most Mentioned People

| Rank | Name | Total Mentions | Documents | Sensitive Terms | Document Types |
|------|------|----------------|-----------|-----------------|----------------|
"""
    
    for i, (person, data) in enumerate(top_people, 1):
        mentions = data['total_mentions']
        doc_count = len(set(data['documents']))
        sensitive_count = sum(data['sensitive_terms'].values())
        doc_types_str = ', '.join(data['document_types'].most_common(2)[0][0] 
                                  if data['document_types'] else ['unknown'])
        
        dashboard += f"| {i} | {person} | {mentions:,} | {doc_count} | {sensitive_count} | {doc_types_str} |\n"
    
    dashboard += """

---

## 🎯 VIP Tracking Summary

"""
    
    vip_sorted = sorted(vip_data.items(), 
                       key=lambda x: x[1]['total_mentions'], 
                       reverse=True)
    
    for vip_name, data in vip_sorted:
        if data['total_mentions'] > 0:
            dashboard += f"""### {vip_name}
- **Total Mentions**: {data['total_mentions']:,}
- **Documents**: {len(data['documents'])}
- **Sensitive Term Co-occurrences**: {sum(data['sensitive_terms'].values())}
- **Primary Document Types**: {', '.join(dt for dt, _ in data['document_types'].most_common(3))}

"""
    
    dashboard += """---

## 📈 Analysis Breakdown

### By Document Type
"""
    
    for doc_type, count in doc_types.most_common():
        pct = (count / total_docs) * 100
        dashboard += f"- **{doc_type.replace('_', ' ').title()}**: {count} documents ({pct:.1f}%)\n"
    
    dashboard += f"""

### Sensitive Content
- **Documents with Sensitive Terms**: {docs_with_sensitive} ({(docs_with_sensitive/total_docs)*100:.1f}%)
- **Most Common Sensitive Terms**:
"""
    
    all_sensitive = Counter()
    for person_data in people_data.values():
        all_sensitive.update(person_data['sensitive_terms'])
    
    for term, count in all_sensitive.most_common(10):
        dashboard += f"  - {term}: {count} co-occurrences\n"
    
    dashboard += """

---

## 🔍 Quick Links

- [VIP Tracking Details](vip_tracking.md)
- [Person Counts](person_counts.md)
- [Network Visualization](network_visualization.html)
- [Illegal Activity Tracking](illegal_activity.md)
- [Top 300 People Analysis](../top_300_people/TOP_300_PEOPLE.md)

---

*This dashboard is automatically generated from the complete extraction of all 388 PDFs.*
"""
    
    # Save dashboard
    dashboard_file = ANALYTICS_PATH / "DASHBOARD.md"
    with open(dashboard_file, 'w', encoding='utf-8') as f:
        f.write(dashboard)
    
    print(f"  Saved: {dashboard_file}")
    return dashboard

def create_person_counts(people_data):
    """Create detailed person counts report"""
    print("\nCreating person counts report...")
    
    report = f"""# Person Counts - Complete Analysis

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total People**: {len(people_data):,}  
**Total Mentions**: {sum(p['total_mentions'] for p in people_data.values()):,}

---

## All People (Sorted by Mentions)

"""
    
    sorted_people = sorted(people_data.items(), 
                          key=lambda x: x[1]['total_mentions'], 
                          reverse=True)
    
    for i, (person, data) in enumerate(sorted_people, 1):
        report += f"""### {i}. {person}

- **Total Mentions**: {data['total_mentions']:,}
- **Documents**: {len(set(data['documents']))}
- **Document Types**: {', '.join(dt for dt, _ in data['document_types'].most_common(3))}
"""
        
        if data['sensitive_terms']:
            report += f"- **Sensitive Terms**: {', '.join(f'{term}({count})' for term, count in data['sensitive_terms'].most_common(5))}\n"
        
        if data['dates']:
            report += f"- **Associated Dates**: {', '.join(data['dates'][:5])}\n"
        
        if data['contexts']:
            report += f"\n**Sample Context**:\n> {data['contexts'][0]}\n"
        
        report += "\n---\n\n"
    
    # Save report
    report_file = ANALYTICS_PATH / "person_counts.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"  Saved: {report_file}")

def create_vip_tracking(vip_data):
    """Create VIP tracking report"""
    print("\nCreating VIP tracking report...")
    
    report = f"""# VIP Tracking - Complete Analysis

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**VIPs Tracked**: {len(KNOWN_VIPS)}  
**VIPs with Mentions**: {sum(1 for v in vip_data.values() if v['total_mentions'] > 0)}

---

## VIP Summary

| VIP | Total Mentions | Documents | Sensitive Terms | Primary Doc Type |
|-----|----------------|-----------|-----------------|------------------|
"""
    
    vip_sorted = sorted(vip_data.items(), 
                       key=lambda x: x[1]['total_mentions'], 
                       reverse=True)
    
    for vip_name, data in vip_sorted:
        mentions = data['total_mentions']
        doc_count = len(data['documents'])
        sensitive_count = sum(data['sensitive_terms'].values())
        primary_type = data['document_types'].most_common(1)[0][0] if data['document_types'] else 'N/A'
        
        report += f"| {vip_name} | {mentions:,} | {doc_count} | {sensitive_count} | {primary_type} |\n"
    
    report += "\n---\n\n## Detailed VIP Profiles\n\n"
    
    for vip_name, data in vip_sorted:
        if data['total_mentions'] == 0:
            continue
        
        report += f"""### {vip_name}

**Statistics**:
- Total Mentions: {data['total_mentions']:,}
- Documents: {len(data['documents'])}
- Sensitive Term Co-occurrences: {sum(data['sensitive_terms'].values())}

**Document Types**:
"""
        for doc_type, count in data['document_types'].most_common(5):
            report += f"- {doc_type.replace('_', ' ').title()}: {count} documents\n"
        
        if data['sensitive_terms']:
            report += "\n**Associated Sensitive Terms**:\n"
            for term, count in data['sensitive_terms'].most_common(10):
                report += f"- {term}: {count} co-occurrences\n"
        
        if data['dates']:
            report += f"\n**Associated Dates**: {', '.join(data['dates'][:10])}\n"
        
        if data['contexts']:
            report += "\n**Sample Mentions**:\n"
            for context in data['contexts'][:3]:
                report += f"> {context}\n\n"
        
        report += "\n---\n\n"
    
    # Save report
    report_file = ANALYTICS_PATH / "vip_tracking.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"  Saved: {report_file}")

def create_top_300_analysis(people_data):
    """Create top 300 people analysis"""
    print("\nCreating top 300 people analysis...")
    
    top_300 = sorted(people_data.items(), 
                    key=lambda x: x[1]['total_mentions'], 
                    reverse=True)[:300]
    
    report = f"""# Top 300 People - Complete Analysis

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Total People Analyzed**: {len(people_data):,}  
**Top 300 Represent**: {sum(p[1]['total_mentions'] for p in top_300):,} mentions

---

## Summary Statistics

- **Total Mentions (Top 300)**: {sum(p[1]['total_mentions'] for p in top_300):,}
- **Average Mentions**: {sum(p[1]['total_mentions'] for p in top_300) / 300:.1f}
- **Documents Covered**: {len(set(doc for p in top_300 for doc in p[1]['documents']))}

---

## Top 300 People

"""
    
    for i, (person, data) in enumerate(top_300, 1):
        report += f"""### {i}. {person}

**Statistics**:
- Total Mentions: {data['total_mentions']:,}
- Documents: {len(set(data['documents']))}
- Document Types: {', '.join(dt for dt, _ in data['document_types'].most_common(3))}
"""
        
        if data['sensitive_terms']:
            report += f"- Sensitive Terms: {sum(data['sensitive_terms'].values())} co-occurrences\n"
            report += f"  - Top terms: {', '.join(f'{term}({count})' for term, count in data['sensitive_terms'].most_common(3))}\n"
        
        if data['dates']:
            report += f"- Associated Dates: {', '.join(data['dates'][:3])}\n"
        
        if data['contexts']:
            report += f"\n**Sample Context**:\n> {data['contexts'][0][:200]}...\n"
        
        report += "\n---\n\n"
    
    # Save report
    report_file = TOP_300_PATH / "TOP_300_PEOPLE.md"
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"  Saved: {report_file}")

def create_statistics_summary(documents, people_data, vip_data):
    """Create statistics summary"""
    print("\nCreating statistics summary...")
    
    stats = f"""# Statistics Summary - Complete Analysis

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

---

## Document Statistics

- **Total Documents**: {len(documents):,}
- **Total Text**: {sum(doc.get('text_length', 0) for doc in documents):,} characters
- **Total Images**: {sum(doc.get('images_extracted', 0) for doc in documents)}
- **Total Dates Found**: {sum(doc.get('dates_found', 0) for doc in documents)}

### By Document Type
"""
    
    doc_types = Counter()
    for doc in documents:
        for dt in doc.get('document_types', []):
            doc_types[dt] += 1
    
    for doc_type, count in doc_types.most_common():
        pct = (count / len(documents)) * 100
        stats += f"- **{doc_type.replace('_', ' ').title()}**: {count} ({pct:.1f}%)\n"
    
    stats += f"""

---

## People Statistics

- **Total Unique People**: {len(people_data):,}
- **Total Mentions**: {sum(p['total_mentions'] for p in people_data.values()):,}
- **Average Mentions per Person**: {sum(p['total_mentions'] for p in people_data.values()) / len(people_data):.1f}
- **VIPs Identified**: {sum(1 for v in vip_data.values() if v['total_mentions'] > 0)}

### Top 10 Most Mentioned
"""
    
    top_10 = sorted(people_data.items(), key=lambda x: x[1]['total_mentions'], reverse=True)[:10]
    for i, (person, data) in enumerate(top_10, 1):
        stats += f"{i}. **{person}**: {data['total_mentions']:,} mentions\n"
    
    stats += f"""

---

## Sensitive Content Statistics

- **Documents with Sensitive Terms**: {sum(1 for doc in documents if any(term in doc.get('full_text', '').lower() for term in SENSITIVE_TERMS))}
- **Total Sensitive Term Co-occurrences**: {sum(sum(p['sensitive_terms'].values()) for p in people_data.values())}

### Most Common Sensitive Terms
"""
    
    all_sensitive = Counter()
    for person_data in people_data.values():
        all_sensitive.update(person_data['sensitive_terms'])
    
    for term, count in all_sensitive.most_common(10):
        stats += f"- **{term}**: {count} co-occurrences\n"
    
    stats += """

---

*Statistics generated from complete extraction of all 388 PDFs*
"""
    
    # Save to multiple locations
    stats_file1 = ANALYTICS_PATH / "STATISTICS.md"
    stats_file2 = TOP_300_PATH / "STATISTICS.md"
    
    with open(stats_file1, 'w', encoding='utf-8') as f:
        f.write(stats)
    with open(stats_file2, 'w', encoding='utf-8') as f:
        f.write(stats)
    
    print(f"  Saved: {stats_file1}")
    print(f"  Saved: {stats_file2}")

def save_json_data(people_data, vip_data):
    """Save JSON data for programmatic access"""
    print("\nSaving JSON data...")
    
    # Convert Counter objects to dicts for JSON serialization
    people_json = {}
    for person, data in people_data.items():
        people_json[person] = {
            'total_mentions': data['total_mentions'],
            'documents': list(set(data['documents'])),
            'document_types': dict(data['document_types']),
            'sensitive_terms': dict(data['sensitive_terms']),
            'dates': data['dates'][:10],
            'contexts': data['contexts'][:3]
        }
    
    vip_json = {}
    for vip, data in vip_data.items():
        vip_json[vip] = {
            'total_mentions': data['total_mentions'],
            'documents': data['documents'],
            'document_types': dict(data['document_types']),
            'sensitive_terms': dict(data['sensitive_terms']),
            'dates': data['dates'],
            'contexts': data['contexts']
        }
    
    # Save files
    people_file = ANALYTICS_PATH / "people_data.json"
    vip_file = ANALYTICS_PATH / "vip_data.json"
    top_300_file = TOP_300_PATH / "top_300_data.json"
    
    with open(people_file, 'w', encoding='utf-8') as f:
        json.dump(people_json, f, indent=2)
    
    with open(vip_file, 'w', encoding='utf-8') as f:
        json.dump(vip_json, f, indent=2)
    
    # Top 300 JSON
    top_300 = dict(sorted(people_json.items(), 
                         key=lambda x: x[1]['total_mentions'], 
                         reverse=True)[:300])
    with open(top_300_file, 'w', encoding='utf-8') as f:
        json.dump(top_300, f, indent=2)
    
    print(f"  Saved: {people_file}")
    print(f"  Saved: {vip_file}")
    print(f"  Saved: {top_300_file}")

def main():
    """Main update process"""
    print("="*80)
    print("UPDATE ALL ANALYSIS - Person Counts, Dashboards, Reports")
    print("="*80)
    
    # Load all documents
    documents = load_all_documents()
    if not documents:
        print("\nERROR: No documents loaded!")
        return 1
    
    # Count all people
    people_data = count_all_people(documents)
    
    # Identify VIPs
    vip_data = identify_vips(people_data)
    
    # Create all reports
    create_dashboard(documents, people_data, vip_data)
    create_person_counts(people_data)
    create_vip_tracking(vip_data)
    create_top_300_analysis(people_data)
    create_statistics_summary(documents, people_data, vip_data)
    save_json_data(people_data, vip_data)
    
    # Summary
    print("\n" + "="*80)
    print("ALL ANALYSIS UPDATED!")
    print("="*80)
    print(f"\nDocuments analyzed: {len(documents)}")
    print(f"People identified: {len(people_data):,}")
    print(f"VIPs found: {sum(1 for v in vip_data.values() if v['total_mentions'] > 0)}")
    print(f"\nReports generated:")
    print(f"  - {ANALYTICS_PATH / 'DASHBOARD.md'}")
    print(f"  - {ANALYTICS_PATH / 'person_counts.md'}")
    print(f"  - {ANALYTICS_PATH / 'vip_tracking.md'}")
    print(f"  - {TOP_300_PATH / 'TOP_300_PEOPLE.md'}")
    print(f"  - {ANALYTICS_PATH / 'STATISTICS.md'}")
    print(f"  - JSON data files")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
