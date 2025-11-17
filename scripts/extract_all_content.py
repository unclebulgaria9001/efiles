#!/usr/bin/env python3
"""
Complete Content Extraction - All PDFs, Images, and Documents
Extracts everything from all PDFs and links to timeline
"""

import os
import sys
import json
import re
from pathlib import Path
from datetime import datetime
import pdfplumber
import PyPDF2
from PIL import Image
import io

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
EXTRACTED_PATH = BASE_PATH / "extracted"
OUTPUT_PATH = BASE_PATH / "complete_extraction"
IMAGES_PATH = OUTPUT_PATH / "extracted_images"
DOCUMENTS_PATH = OUTPUT_PATH / "all_documents"
TIMELINE_PATH = OUTPUT_PATH / "timeline_data"

# Create output directories
OUTPUT_PATH.mkdir(exist_ok=True)
IMAGES_PATH.mkdir(exist_ok=True)
DOCUMENTS_PATH.mkdir(exist_ok=True)
TIMELINE_PATH.mkdir(exist_ok=True)

# Document type detection patterns
EMAIL_PATTERNS = [
    r'From:',
    r'To:',
    r'Subject:',
    r'Date:',
    r'Sent:',
    r'Received:'
]

DEPOSITION_PATTERNS = [
    r'DEPOSITION',
    r'TESTIMONY',
    r'SWORN',
    r'COURT REPORTER',
    r'EXAMINATION BY',
    r'Q\.',
    r'A\.'
]

LEGAL_DOC_PATTERNS = [
    r'UNITED STATES DISTRICT COURT',
    r'CASE NO\.',
    r'PLAINTIFF',
    r'DEFENDANT',
    r'MOTION',
    r'ORDER',
    r'COMPLAINT'
]

FLIGHT_LOG_PATTERNS = [
    r'FLIGHT',
    r'PASSENGER',
    r'DEPARTURE',
    r'ARRIVAL',
    r'TAIL NUMBER'
]

# Date extraction patterns
DATE_PATTERNS = [
    r'\b\d{1,2}/\d{1,2}/\d{2,4}\b',
    r'\b\d{1,2}-\d{1,2}-\d{2,4}\b',
    r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}\b',
    r'\b\d{4}-\d{2}-\d{2}\b',
    r'\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},?\s+\d{4}\b'
]

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF using multiple methods"""
    text = ""
    method_used = "none"
    
    # Try pdfplumber first
    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
            if text.strip():
                method_used = "pdfplumber"
    except Exception as e:
        print(f"  pdfplumber failed: {e}")
    
    # Try PyPDF2 as fallback
    if not text.strip():
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                for page in pdf_reader.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text += page_text + "\n"
                if text.strip():
                    method_used = "PyPDF2"
        except Exception as e:
            print(f"  PyPDF2 failed: {e}")
    
    return text, method_used

def extract_images_from_pdf(pdf_path, doc_id):
    """Extract all images from PDF"""
    images = []
    
    try:
        with pdfplumber.open(pdf_path) as pdf:
            for page_num, page in enumerate(pdf.pages, 1):
                if hasattr(page, 'images'):
                    for img_num, img in enumerate(page.images, 1):
                        try:
                            # Save image
                            image_filename = f"{doc_id}_page{page_num}_img{img_num}.png"
                            image_path = IMAGES_PATH / image_filename
                            
                            # Extract image data
                            if 'stream' in img:
                                img_obj = page.within_bbox(img['bbox']).to_image()
                                img_obj.save(str(image_path))
                                
                                images.append({
                                    'filename': image_filename,
                                    'page': page_num,
                                    'bbox': img['bbox'],
                                    'path': str(image_path)
                                })
                        except Exception as e:
                            print(f"    Error extracting image: {e}")
    except Exception as e:
        print(f"  Image extraction failed: {e}")
    
    return images

def detect_document_type(text):
    """Detect what type of document this is"""
    text_lower = text.lower()
    types = []
    
    # Check for email
    email_score = sum(1 for pattern in EMAIL_PATTERNS if re.search(pattern, text, re.IGNORECASE))
    if email_score >= 3:
        types.append("email")
    
    # Check for deposition
    depo_score = sum(1 for pattern in DEPOSITION_PATTERNS if re.search(pattern, text, re.IGNORECASE))
    if depo_score >= 3:
        types.append("deposition")
    
    # Check for legal document
    legal_score = sum(1 for pattern in LEGAL_DOC_PATTERNS if re.search(pattern, text, re.IGNORECASE))
    if legal_score >= 2:
        types.append("legal_document")
    
    # Check for flight log
    flight_score = sum(1 for pattern in FLIGHT_LOG_PATTERNS if re.search(pattern, text, re.IGNORECASE))
    if flight_score >= 2:
        types.append("flight_log")
    
    # Check for financial document
    if any(term in text_lower for term in ['invoice', 'payment', 'wire transfer', 'account', 'balance']):
        types.append("financial")
    
    # Check for correspondence
    if any(term in text_lower for term in ['dear', 'sincerely', 'regards', 'thank you']):
        types.append("correspondence")
    
    if not types:
        types.append("unknown")
    
    return types

def extract_dates(text):
    """Extract all dates from text"""
    dates = []
    
    for pattern in DATE_PATTERNS:
        matches = re.finditer(pattern, text, re.IGNORECASE)
        for match in matches:
            dates.append({
                'date_string': match.group(),
                'position': match.start()
            })
    
    return dates

def extract_people(text):
    """Extract potential people names"""
    # Pattern for capitalized names
    name_pattern = r'\b[A-Z][a-z]+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)?\b'
    matches = re.finditer(name_pattern, text)
    
    names = []
    exclude = {'United States', 'New York', 'Palm Beach', 'District Court', 'Southern District'}
    
    for match in matches:
        name = match.group()
        if name not in exclude and len(name) > 5:
            names.append(name)
    
    return list(set(names))

def extract_locations(text):
    """Extract location mentions"""
    locations = []
    
    location_keywords = [
        'New York', 'Manhattan', 'Palm Beach', 'Florida', 'London', 'Paris',
        'Little St. James', 'Little Saint James', 'Virgin Islands', 'New Mexico',
        'Zorro Ranch', 'France', 'United Kingdom'
    ]
    
    for location in location_keywords:
        if re.search(r'\b' + re.escape(location) + r'\b', text, re.IGNORECASE):
            locations.append(location)
    
    return list(set(locations))

def link_to_emails(doc_id, text):
    """Try to link this document to extracted emails"""
    linked_emails = []
    
    # Check if this document references any email files
    email_files = list((BASE_PATH / "extracted_emails_organized").glob("*.txt"))
    
    for email_file in email_files:
        email_id = email_file.stem.split('_')[0]
        
        # Check for references
        if email_id in text or email_file.stem in text:
            linked_emails.append({
                'email_file': email_file.name,
                'email_id': email_id
            })
    
    return linked_emails

def process_pdf(pdf_path):
    """Process a single PDF completely"""
    filename = pdf_path.name
    doc_id = filename.replace('.pdf', '')
    
    print(f"\nProcessing: {filename}")
    
    # Extract text
    print("  Extracting text...")
    text, method = extract_text_from_pdf(pdf_path)
    
    if not text.strip():
        print("  WARNING: No text extracted!")
        text = "[NO TEXT EXTRACTED - POSSIBLY SCANNED IMAGE]"
    
    # Extract images
    print("  Extracting images...")
    images = extract_images_from_pdf(pdf_path, doc_id)
    print(f"    Found {len(images)} images")
    
    # Analyze content
    print("  Analyzing content...")
    doc_types = detect_document_type(text)
    dates = extract_dates(text)
    people = extract_people(text)
    locations = extract_locations(text)
    linked_emails = link_to_emails(doc_id, text)
    
    # Create document metadata
    metadata = {
        'doc_id': doc_id,
        'filename': filename,
        'extraction_date': datetime.now().isoformat(),
        'extraction_method': method,
        'document_types': doc_types,
        'text_length': len(text),
        'images_extracted': len(images),
        'dates_found': len(dates),
        'people_found': len(people),
        'locations_found': len(locations),
        'linked_emails': len(linked_emails),
        'dates': dates[:10],  # First 10 dates
        'people': people[:20],  # First 20 people
        'locations': locations,
        'linked_emails': linked_emails,
        'images': images
    }
    
    # Save full text
    text_file = DOCUMENTS_PATH / f"{doc_id}.txt"
    with open(text_file, 'w', encoding='utf-8') as f:
        f.write(f"# Document: {filename}\n")
        f.write(f"# Extraction Method: {method}\n")
        f.write(f"# Document Types: {', '.join(doc_types)}\n")
        f.write(f"# Images Extracted: {len(images)}\n")
        f.write(f"# Dates Found: {len(dates)}\n")
        f.write(f"# People Found: {len(people)}\n")
        f.write(f"# Locations Found: {len(locations)}\n")
        f.write(f"# Linked Emails: {len(linked_emails)}\n")
        f.write("\n" + "="*80 + "\n\n")
        f.write(text)
    
    # Save metadata
    meta_file = DOCUMENTS_PATH / f"{doc_id}_metadata.json"
    with open(meta_file, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2)
    
    return metadata

def create_master_index(all_metadata):
    """Create master index of all documents"""
    print("\nCreating master index...")
    
    # Group by document type
    by_type = {}
    for meta in all_metadata:
        for doc_type in meta['document_types']:
            if doc_type not in by_type:
                by_type[doc_type] = []
            by_type[doc_type].append(meta)
    
    # Create index markdown
    index_md = "# Complete Document Extraction Index\n\n"
    index_md += f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
    index_md += f"**Total Documents**: {len(all_metadata)}\n"
    index_md += f"**Total Images**: {sum(m['images_extracted'] for m in all_metadata)}\n"
    index_md += f"**Total Dates Found**: {sum(m['dates_found'] for m in all_metadata)}\n\n"
    
    index_md += "---\n\n## Documents by Type\n\n"
    
    for doc_type, docs in sorted(by_type.items()):
        index_md += f"### {doc_type.replace('_', ' ').title()} ({len(docs)} documents)\n\n"
        for doc in sorted(docs, key=lambda x: x['filename']):
            index_md += f"- **{doc['filename']}**\n"
            index_md += f"  - Text: {doc['text_length']:,} chars\n"
            index_md += f"  - Images: {doc['images_extracted']}\n"
            index_md += f"  - Dates: {doc['dates_found']}\n"
            index_md += f"  - People: {doc['people_found']}\n"
            if doc['linked_emails']:
                index_md += f"  - Linked Emails: {doc['linked_emails']}\n"
            index_md += "\n"
    
    # Save index
    index_file = OUTPUT_PATH / "MASTER_INDEX.md"
    with open(index_file, 'w', encoding='utf-8') as f:
        f.write(index_md)
    
    # Save JSON index
    index_json = OUTPUT_PATH / "master_index.json"
    with open(index_json, 'w', encoding='utf-8') as f:
        json.dump({
            'generated': datetime.now().isoformat(),
            'total_documents': len(all_metadata),
            'by_type': {k: len(v) for k, v in by_type.items()},
            'documents': all_metadata
        }, f, indent=2)
    
    print(f"  Saved to: {index_file}")

def create_timeline(all_metadata):
    """Create comprehensive timeline from all documents"""
    print("\nCreating timeline...")
    
    timeline_events = []
    
    for meta in all_metadata:
        for date_info in meta['dates']:
            timeline_events.append({
                'date_string': date_info['date_string'],
                'document': meta['filename'],
                'doc_id': meta['doc_id'],
                'document_types': meta['document_types'],
                'people': meta['people'][:5],
                'locations': meta['locations']
            })
    
    # Sort by date string (rough sort)
    timeline_events.sort(key=lambda x: x['date_string'])
    
    # Create timeline markdown
    timeline_md = "# Complete Timeline - All Documents\n\n"
    timeline_md += f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
    timeline_md += f"**Total Events**: {len(timeline_events)}\n\n"
    timeline_md += "---\n\n"
    
    for event in timeline_events:
        timeline_md += f"## {event['date_string']}\n\n"
        timeline_md += f"**Document**: {event['document']}\n"
        timeline_md += f"**Type**: {', '.join(event['document_types'])}\n"
        if event['people']:
            timeline_md += f"**People**: {', '.join(event['people'])}\n"
        if event['locations']:
            timeline_md += f"**Locations**: {', '.join(event['locations'])}\n"
        timeline_md += "\n---\n\n"
    
    # Save timeline
    timeline_file = TIMELINE_PATH / "COMPLETE_TIMELINE.md"
    with open(timeline_file, 'w', encoding='utf-8') as f:
        f.write(timeline_md)
    
    # Save JSON
    timeline_json = TIMELINE_PATH / "timeline_data.json"
    with open(timeline_json, 'w', encoding='utf-8') as f:
        json.dump(timeline_events, f, indent=2)
    
    print(f"  Saved to: {timeline_file}")

def main():
    """Main extraction process"""
    print("="*80)
    print("COMPLETE CONTENT EXTRACTION - ALL PDFs")
    print("="*80)
    
    # Get all PDFs
    pdf_files = list(EXTRACTED_PATH.glob("*.pdf"))
    print(f"\nFound {len(pdf_files)} PDF files")
    
    if not pdf_files:
        print("ERROR: No PDF files found!")
        return
    
    # Process all PDFs
    all_metadata = []
    
    for i, pdf_path in enumerate(pdf_files, 1):
        print(f"\n[{i}/{len(pdf_files)}]", end=" ")
        try:
            metadata = process_pdf(pdf_path)
            all_metadata.append(metadata)
        except Exception as e:
            print(f"  ERROR: {e}")
            continue
    
    # Create master index
    create_master_index(all_metadata)
    
    # Create timeline
    create_timeline(all_metadata)
    
    # Summary
    print("\n" + "="*80)
    print("EXTRACTION COMPLETE!")
    print("="*80)
    print(f"\nDocuments processed: {len(all_metadata)}")
    print(f"Images extracted: {sum(m['images_extracted'] for m in all_metadata)}")
    print(f"Timeline events: {sum(m['dates_found'] for m in all_metadata)}")
    print(f"\nOutput location: {OUTPUT_PATH}")
    print(f"  - All documents: {DOCUMENTS_PATH}")
    print(f"  - Extracted images: {IMAGES_PATH}")
    print(f"  - Timeline data: {TIMELINE_PATH}")
    print(f"  - Master index: {OUTPUT_PATH / 'MASTER_INDEX.md'}")

if __name__ == "__main__":
    main()
