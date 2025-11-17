"""
Epstein Document Analysis Tool
Extracts metadata, identifies people, tracks terms, and builds analytics
"""

import os
import re
import json
import PyPDF2
from pathlib import Path
from collections import defaultdict, Counter
from datetime import datetime
import hashlib

class EpsteinDocAnalyzer:
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.extracted_path = self.base_path / "extracted"
        self.analytics_path = self.base_path / "analytics"
        self.analytics_path.mkdir(exist_ok=True)
        
        # Data structures
        self.documents = []
        self.person_counts = Counter()
        self.term_counts = Counter()
        self.person_term_matrix = defaultdict(Counter)
        self.interactions = defaultdict(set)
        self.vip_mentions = defaultdict(list)
        self.illegal_quotes = []
        
        # VIP list (case-insensitive matching)
        self.vips = [
            "donald trump", "trump",
            "prince andrew", "andrew",
            "bill clinton", "clinton",
            "bill gates", "gates",
            "stephen hawking", "hawking",
            "alan dershowitz", "dershowitz",
            "ghislaine maxwell", "maxwell",
            "virginia giuffre", "giuffre", "virginia roberts",
            "jean luc brunel", "brunel",
            "leslie wexner", "wexner",
            "naomi campbell", "campbell",
            "kevin spacey", "spacey",
            "chris tucker", "tucker",
            "larry summers", "summers",
            "marvin minsky", "minsky",
            "glenn dubin", "dubin",
            "eva dubin",
            "sarah kellen", "kellen",
            "nadia marcinkova", "marcinkova",
            "adriana ross", "ross",
            "lesley groff", "groff"
        ]
        
        # Illegal activity keywords
        self.illegal_terms = [
            "sex", "sexual", "massage", "naked", "nude", "underage",
            "minor", "young girl", "teenage", "prostitute", "prostitution",
            "trafficking", "abuse", "molest", "rape", "assault",
            "drug", "cocaine", "heroin", "pills", "prescription",
            "illegal", "crime", "criminal", "victim", "exploit"
        ]
        
        # Common person name patterns
        self.name_pattern = re.compile(r'\b[A-Z][a-z]+ [A-Z][a-z]+(?:\s[A-Z][a-z]+)?\b')
        
    def extract_text_from_pdf(self, pdf_path):
        """Extract text from PDF file"""
        try:
            with open(pdf_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                text = ""
                metadata = {}
                
                # Extract metadata
                if reader.metadata:
                    metadata = {
                        'title': reader.metadata.get('/Title', ''),
                        'author': reader.metadata.get('/Author', ''),
                        'subject': reader.metadata.get('/Subject', ''),
                        'creator': reader.metadata.get('/Creator', ''),
                        'producer': reader.metadata.get('/Producer', ''),
                        'creation_date': reader.metadata.get('/CreationDate', ''),
                        'mod_date': reader.metadata.get('/ModDate', '')
                    }
                
                # Extract text from all pages
                for page in reader.pages:
                    text += page.extract_text() + "\n"
                
                return text, metadata, len(reader.pages)
        except Exception as e:
            print(f"Error reading {pdf_path}: {e}")
            return "", {}, 0
    
    def extract_emails(self, text):
        """Extract email addresses from text"""
        email_pattern = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        return list(set(email_pattern.findall(text)))
    
    def extract_phone_numbers(self, text):
        """Extract phone numbers from text"""
        phone_pattern = re.compile(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\b\(\d{3}\)\s*\d{3}[-.]?\d{4}\b')
        return list(set(phone_pattern.findall(text)))
    
    def extract_dates(self, text):
        """Extract dates from text"""
        date_patterns = [
            r'\b\d{1,2}/\d{1,2}/\d{2,4}\b',
            r'\b\d{1,2}-\d{1,2}-\d{2,4}\b',
            r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}\b'
        ]
        dates = []
        for pattern in date_patterns:
            dates.extend(re.findall(pattern, text, re.IGNORECASE))
        return list(set(dates))
    
    def find_people(self, text):
        """Find person names in text"""
        # Find capitalized names
        potential_names = self.name_pattern.findall(text)
        
        # Filter out common false positives
        exclude_words = {'United States', 'New York', 'Palm Beach', 'Virgin Islands', 
                        'District Court', 'Southern District', 'Federal Bureau'}
        
        names = [name for name in potential_names if name not in exclude_words]
        return names
    
    def find_vips(self, text):
        """Find VIP mentions in text"""
        text_lower = text.lower()
        found_vips = []
        
        for vip in self.vips:
            if vip.lower() in text_lower:
                # Count occurrences
                count = text_lower.count(vip.lower())
                found_vips.append((vip, count))
        
        return found_vips
    
    def find_illegal_activity_quotes(self, text, filename):
        """Find quotes suggesting illegal activity"""
        quotes = []
        lines = text.split('\n')
        
        for i, line in enumerate(lines):
            line_lower = line.lower()
            for term in self.illegal_terms:
                if term in line_lower and len(line.strip()) > 20:
                    # Get context (line before and after)
                    context_start = max(0, i-1)
                    context_end = min(len(lines), i+2)
                    context = ' '.join(lines[context_start:context_end])
                    
                    quotes.append({
                        'file': filename,
                        'term': term,
                        'quote': line.strip(),
                        'context': context.strip()
                    })
                    break  # Only add once per line
        
        return quotes
    
    def generate_content_summary(self, text, max_length=100):
        """Generate a brief summary of content"""
        # Remove extra whitespace
        text = ' '.join(text.split())
        
        # Try to find key sentences
        sentences = re.split(r'[.!?]+', text)
        if sentences:
            summary = sentences[0][:max_length]
            return summary.strip()
        
        return text[:max_length].strip()
    
    def process_document(self, pdf_path):
        """Process a single document"""
        print(f"Processing: {pdf_path.name}")
        
        text, metadata, page_count = self.extract_text_from_pdf(pdf_path)
        
        if not text:
            return None
        
        # Extract various elements
        emails = self.extract_emails(text)
        phones = self.extract_phone_numbers(text)
        dates = self.extract_dates(text)
        people = self.find_people(text)
        vips = self.find_vips(text)
        illegal_quotes = self.find_illegal_activity_quotes(text, pdf_path.name)
        
        # Generate content summary
        summary = self.generate_content_summary(text)
        
        # Create document hash for deduplication
        doc_hash = hashlib.md5(text.encode()).hexdigest()[:8]
        
        # Update counters
        for person in people:
            self.person_counts[person] += 1
        
        for vip, count in vips:
            self.person_counts[vip] += count
            self.vip_mentions[vip].append({
                'file': pdf_path.name,
                'count': count
            })
        
        # Track illegal quotes
        self.illegal_quotes.extend(illegal_quotes)
        
        # Build person-term matrix
        for person in people:
            for term in self.illegal_terms:
                if term in text.lower():
                    self.person_term_matrix[person][term] += 1
        
        # Track interactions (people mentioned together)
        for i, person1 in enumerate(people):
            for person2 in people[i+1:]:
                self.interactions[person1].add(person2)
                self.interactions[person2].add(person1)
        
        # Document record
        doc_record = {
            'original_filename': pdf_path.name,
            'path': str(pdf_path),
            'hash': doc_hash,
            'page_count': page_count,
            'metadata': metadata,
            'summary': summary,
            'emails': emails,
            'phones': phones,
            'dates': dates,
            'people_mentioned': people,
            'vip_mentions': dict(vips),
            'word_count': len(text.split()),
            'illegal_terms_found': [term for term in self.illegal_terms if term in text.lower()]
        }
        
        self.documents.append(doc_record)
        
        return doc_record
    
    def rename_files(self):
        """Rename files with descriptive names based on content"""
        print("\n=== Renaming files ===")
        rename_log = []
        
        for doc in self.documents:
            try:
                old_path = Path(doc['path'])
                
                # Build new filename
                parts = []
                
                # Add hash for uniqueness
                parts.append(doc['hash'])
                
                # Add VIPs if mentioned
                vips_in_doc = [vip for vip, count in doc['vip_mentions'].items() if count > 0]
                if vips_in_doc:
                    vip_str = '_'.join(vips_in_doc[:2]).replace(' ', '-')
                    parts.append(vip_str[:30])
                
                # Add summary snippet
                summary_slug = re.sub(r'[^\w\s-]', '', doc['summary'])
                summary_slug = re.sub(r'[\s]+', '_', summary_slug)[:40]
                if summary_slug:
                    parts.append(summary_slug)
                
                # Build new filename
                new_name = '_'.join(parts) + '.pdf'
                new_name = new_name.replace('__', '_')
                
                new_path = old_path.parent / new_name
                
                # Rename if different
                if old_path != new_path and not new_path.exists():
                    old_path.rename(new_path)
                    rename_log.append({
                        'old': old_path.name,
                        'new': new_name
                    })
                    doc['renamed_to'] = new_name
                    print(f"  Renamed: {old_path.name} -> {new_name}")
                
            except Exception as e:
                print(f"  Error renaming {doc['original_filename']}: {e}")
        
        # Save rename log
        with open(self.analytics_path / 'rename_log.json', 'w') as f:
            json.dump(rename_log, f, indent=2)
        
        return rename_log
    
    def generate_reports(self):
        """Generate all markdown reports"""
        print("\n=== Generating reports ===")
        
        # 1. Master Analytics Dashboard
        self.generate_master_dashboard()
        
        # 2. Person Counts Report
        self.generate_person_counts_report()
        
        # 3. VIP Tracking Report
        self.generate_vip_report()
        
        # 4. Illegal Activity Report
        self.generate_illegal_activity_report()
        
        # 5. Person-Term Matrix
        self.generate_person_term_matrix_report()
        
        # 6. Interaction Graph
        self.generate_interaction_graph()
        
        # 7. Document Index
        self.generate_document_index()
        
        # 8. Term Frequency Report
        self.generate_term_frequency_report()
        
        print("All reports generated!")
    
    def generate_master_dashboard(self):
        """Generate master analytics dashboard"""
        content = f"""# Epstein Documents Analysis Dashboard
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

## Overview Statistics

- **Total Documents Processed**: {len(self.documents)}
- **Total Pages**: {sum(doc['page_count'] for doc in self.documents)}
- **Unique People Identified**: {len(self.person_counts)}
- **VIP Mentions**: {len(self.vip_mentions)}
- **Illegal Activity Quotes**: {len(self.illegal_quotes)}
- **Total Interactions Mapped**: {sum(len(v) for v in self.interactions.values()) // 2}

## Top 20 Most Mentioned People

| Rank | Name | Mentions |
|------|------|----------|
"""
        for i, (person, count) in enumerate(self.person_counts.most_common(20), 1):
            content += f"| {i} | {person} | {count} |\n"
        
        content += f"""
## VIP Summary

| VIP | Total Mentions | Documents |
|-----|----------------|-----------|
"""
        for vip in sorted(self.vip_mentions.keys()):
            mentions = self.vip_mentions[vip]
            total = sum(m['count'] for m in mentions)
            doc_count = len(mentions)
            content += f"| {vip} | {total} | {doc_count} |\n"
        
        content += f"""
## Document Categories

- Documents with illegal terms: {sum(1 for doc in self.documents if doc['illegal_terms_found'])}
- Documents with VIP mentions: {sum(1 for doc in self.documents if doc['vip_mentions'])}
- Documents with email addresses: {sum(1 for doc in self.documents if doc['emails'])}
- Documents with phone numbers: {sum(1 for doc in self.documents if doc['phones'])}

## Quick Links

- [Person Counts Report](person_counts.md)
- [VIP Tracking Report](vip_tracking.md)
- [Illegal Activity Report](illegal_activity.md)
- [Person-Term Matrix](person_term_matrix.md)
- [Interaction Graph](interaction_graph.md)
- [Document Index](document_index.md)
- [Term Frequency Report](term_frequency.md)
"""
        
        with open(self.analytics_path / 'DASHBOARD.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_person_counts_report(self):
        """Generate person counts report"""
        content = f"""# Person Mention Counts
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

Total unique people identified: **{len(self.person_counts)}**

## All People (Sorted by Mention Count)

| Rank | Name | Mentions |
|------|------|----------|
"""
        for i, (person, count) in enumerate(self.person_counts.most_common(), 1):
            content += f"| {i} | {person} | {count} |\n"
        
        with open(self.analytics_path / 'person_counts.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_vip_report(self):
        """Generate VIP tracking report"""
        content = f"""# VIP Tracking Report
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

## High-Profile Individuals Mentioned

"""
        for vip in sorted(self.vip_mentions.keys()):
            mentions = self.vip_mentions[vip]
            total = sum(m['count'] for m in mentions)
            
            content += f"""
### {vip.title()}
- **Total Mentions**: {total}
- **Documents**: {len(mentions)}

#### Document List:
"""
            for mention in sorted(mentions, key=lambda x: x['count'], reverse=True):
                content += f"- `{mention['file']}` - {mention['count']} mentions\n"
        
        with open(self.analytics_path / 'vip_tracking.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_illegal_activity_report(self):
        """Generate illegal activity quotes report"""
        content = f"""# Illegal Activity References
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

**Total Quotes Found**: {len(self.illegal_quotes)}

## Quotes by Term

"""
        # Group by term
        by_term = defaultdict(list)
        for quote in self.illegal_quotes:
            by_term[quote['term']].append(quote)
        
        for term in sorted(by_term.keys()):
            quotes = by_term[term]
            content += f"""
### {term.upper()} ({len(quotes)} references)

"""
            for quote in quotes[:50]:  # Limit to 50 per term
                content += f"""
**File**: `{quote['file']}`

> {quote['quote']}

Context:
```
{quote['context'][:500]}
```

---

"""
        
        with open(self.analytics_path / 'illegal_activity.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_person_term_matrix_report(self):
        """Generate person-term association matrix"""
        content = f"""# Person-Term Association Matrix
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

This matrix shows which people are mentioned in documents containing specific terms.

## Top 50 People with Term Associations

"""
        # Get top people
        top_people = [person for person, _ in self.person_counts.most_common(50)]
        
        for person in top_people:
            if person in self.person_term_matrix:
                terms = self.person_term_matrix[person]
                if terms:
                    content += f"""
### {person}

| Term | Co-occurrences |
|------|----------------|
"""
                    for term, count in terms.most_common():
                        content += f"| {term} | {count} |\n"
        
        with open(self.analytics_path / 'person_term_matrix.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_interaction_graph(self):
        """Generate interaction graph data"""
        content = f"""# Interaction Graph
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

This shows which people are mentioned together in documents.

## Network Statistics

- **Total Nodes (People)**: {len(self.interactions)}
- **Total Edges (Connections)**: {sum(len(v) for v in self.interactions.values()) // 2}

## Top Connected People

"""
        # Sort by connection count
        sorted_people = sorted(self.interactions.items(), key=lambda x: len(x[1]), reverse=True)
        
        for person, connections in sorted_people[:50]:
            content += f"""
### {person}
**Connections**: {len(connections)}

Connected to: {', '.join(sorted(list(connections)[:20]))}
{"..." if len(connections) > 20 else ""}

"""
        
        # Generate graph data in JSON format
        graph_data = {
            'nodes': [{'id': person, 'connections': len(connections)} 
                     for person, connections in self.interactions.items()],
            'edges': [{'source': person, 'target': target} 
                     for person, targets in self.interactions.items() 
                     for target in targets]
        }
        
        with open(self.analytics_path / 'interaction_graph.json', 'w') as f:
            json.dump(graph_data, f, indent=2)
        
        content += f"""
## Graph Data

The full graph data is available in JSON format: `interaction_graph.json`

This can be visualized using tools like:
- Gephi
- Cytoscape
- D3.js
- NetworkX (Python)
"""
        
        with open(self.analytics_path / 'interaction_graph.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_document_index(self):
        """Generate document index"""
        content = f"""# Document Index
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

Total documents: **{len(self.documents)}**

## All Documents

"""
        for i, doc in enumerate(self.documents, 1):
            content += f"""
### {i}. {doc['original_filename']}

- **Hash**: `{doc['hash']}`
- **Pages**: {doc['page_count']}
- **Words**: {doc['word_count']}
- **Summary**: {doc['summary']}
- **People Mentioned**: {len(doc['people_mentioned'])}
- **VIPs**: {', '.join(doc['vip_mentions'].keys()) if doc['vip_mentions'] else 'None'}
- **Emails Found**: {len(doc['emails'])}
- **Phones Found**: {len(doc['phones'])}
- **Dates Found**: {len(doc['dates'])}
- **Illegal Terms**: {', '.join(doc['illegal_terms_found'][:5])}{"..." if len(doc['illegal_terms_found']) > 5 else ""}

"""
            if doc.get('renamed_to'):
                content += f"- **Renamed To**: `{doc['renamed_to']}`\n"
            
            content += "\n---\n"
        
        with open(self.analytics_path / 'document_index.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def generate_term_frequency_report(self):
        """Generate term frequency report"""
        # Count all terms
        all_terms = Counter()
        for doc in self.documents:
            for term in doc['illegal_terms_found']:
                all_terms[term] += 1
        
        content = f"""# Term Frequency Report
*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

## Illegal/Sensitive Terms Frequency

| Rank | Term | Documents | Total Mentions |
|------|------|-----------|----------------|
"""
        for i, (term, count) in enumerate(all_terms.most_common(), 1):
            content += f"| {i} | {term} | {count} | - |\n"
        
        with open(self.analytics_path / 'term_frequency.md', 'w', encoding='utf-8') as f:
            f.write(content)
    
    def run_full_analysis(self):
        """Run complete analysis pipeline"""
        print("=" * 60)
        print("EPSTEIN DOCUMENT ANALYSIS")
        print("=" * 60)
        
        # Find all PDF files
        pdf_files = list(self.extracted_path.rglob("*.pdf"))
        print(f"\nFound {len(pdf_files)} PDF files")
        
        # Process each document
        print("\n=== Processing Documents ===")
        for pdf_file in pdf_files:
            self.process_document(pdf_file)
        
        print(f"\nProcessed {len(self.documents)} documents successfully")
        
        # Rename files
        # self.rename_files()  # Commented out for safety - uncomment to rename
        
        # Generate reports
        self.generate_reports()
        
        # Save raw data
        print("\n=== Saving raw data ===")
        with open(self.analytics_path / 'all_documents.json', 'w', encoding='utf-8') as f:
            json.dump(self.documents, f, indent=2)
        
        with open(self.analytics_path / 'person_counts.json', 'w') as f:
            json.dump(dict(self.person_counts), f, indent=2)
        
        with open(self.analytics_path / 'vip_mentions.json', 'w') as f:
            json.dump(self.vip_mentions, f, indent=2)
        
        print("\n" + "=" * 60)
        print("ANALYSIS COMPLETE!")
        print("=" * 60)
        print(f"\nResults saved to: {self.analytics_path}")
        print("\nGenerated files:")
        print("  - DASHBOARD.md (Main overview)")
        print("  - person_counts.md")
        print("  - vip_tracking.md")
        print("  - illegal_activity.md")
        print("  - person_term_matrix.md")
        print("  - interaction_graph.md")
        print("  - document_index.md")
        print("  - term_frequency.md")
        print("  - *.json (Raw data files)")


if __name__ == "__main__":
    base_path = r"G:\My Drive\04_Resources\Notes\Epstein Email Dump"
    analyzer = EpsteinDocAnalyzer(base_path)
    analyzer.run_full_analysis()
