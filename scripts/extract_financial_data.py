#!/usr/bin/env python3
"""
Extract Financial Data from Epstein Documents
Track money flow, payments, transfers, and financial relationships
"""

import re
import json
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# Base paths
BASE_PATH = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump")
COMPLETE_EXTRACTION = BASE_PATH / "complete_extraction" / "all_documents"
OUTPUT_PATH = BASE_PATH / "financial_analysis"

# Create output directory
OUTPUT_PATH.mkdir(exist_ok=True)

# Financial patterns
PATTERNS = {
    'dollar_amount': r'\$([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})?)',
    'million': r'(\d+(?:\.\d+)?)\s*million',
    'billion': r'(\d+(?:\.\d+)?)\s*billion',
    'payment': r'(?:paid|payment|pay|paying)\s+(?:of\s+)?\$?([0-9,]+)',
    'transfer': r'(?:transfer|transferred|wire)\s+(?:of\s+)?\$?([0-9,]+)',
    'loan': r'(?:loan|lent|lending)\s+(?:of\s+)?\$?([0-9,]+)',
    'salary': r'(?:salary|wage|compensation)\s+(?:of\s+)?\$?([0-9,]+)',
    'account': r'account\s+(?:number\s+)?([0-9\-]+)',
    'bank': r'((?:Chase|Bank of America|Wells Fargo|Citibank|HSBC|Deutsche Bank|JPMorgan)[^.]*)',
}

class FinancialTransaction:
    def __init__(self, amount, transaction_type, source, destination, date, context, document):
        self.amount = amount
        self.transaction_type = transaction_type
        self.source = source
        self.destination = destination
        self.date = date
        self.context = context
        self.document = document
    
    def to_dict(self):
        return {
            'amount': self.amount,
            'type': self.transaction_type,
            'from': self.source,
            'to': self.destination,
            'date': self.date,
            'context': self.context,
            'document': self.document
        }

def extract_dollar_amounts(text):
    """Extract all dollar amounts from text"""
    amounts = []
    
    # Direct dollar amounts
    for match in re.finditer(PATTERNS['dollar_amount'], text, re.IGNORECASE):
        amount_str = match.group(1).replace(',', '')
        try:
            amount = float(amount_str)
            context = text[max(0, match.start()-100):min(len(text), match.end()+100)]
            amounts.append({
                'amount': amount,
                'formatted': f"${match.group(1)}",
                'context': context.strip()
            })
        except:
            pass
    
    # Million amounts
    for match in re.finditer(PATTERNS['million'], text, re.IGNORECASE):
        try:
            amount = float(match.group(1)) * 1_000_000
            context = text[max(0, match.start()-100):min(len(text), match.end()+100)]
            amounts.append({
                'amount': amount,
                'formatted': f"${match.group(1)} million",
                'context': context.strip()
            })
        except:
            pass
    
    # Billion amounts
    for match in re.finditer(PATTERNS['billion'], text, re.IGNORECASE):
        try:
            amount = float(match.group(1)) * 1_000_000_000
            context = text[max(0, match.start()-100):min(len(text), match.end()+100)]
            amounts.append({
                'amount': amount,
                'formatted': f"${match.group(1)} billion",
                'context': context.strip()
            })
        except:
            pass
    
    return amounts

def extract_payments(text):
    """Extract payment information"""
    payments = []
    
    for match in re.finditer(PATTERNS['payment'], text, re.IGNORECASE):
        amount_str = match.group(1).replace(',', '')
        try:
            amount = float(amount_str)
            context = text[max(0, match.start()-150):min(len(text), match.end()+150)]
            payments.append({
                'amount': amount,
                'type': 'payment',
                'context': context.strip()
            })
        except:
            pass
    
    return payments

def extract_entities_from_context(context):
    """Extract people and organizations from context"""
    # Common entities in Epstein case
    entities = {
        'people': [],
        'organizations': []
    }
    
    people = [
        'Epstein', 'Maxwell', 'Giuffre', 'Virginia Roberts', 'Prince Andrew',
        'Bill Clinton', 'Donald Trump', 'Wexner', 'Brunel', 'Dershowitz',
        'Sarah Kellen', 'Nadia Marcinkova', 'Adriana Ross'
    ]
    
    organizations = [
        'Southern Trust Company', 'Financial Trust Company', 'Maple Inc',
        'NES LLC', 'J. Epstein & Co', 'Victoria\'s Secret', 'Limited Brands',
        'Clinton Foundation', 'Trump Organization'
    ]
    
    for person in people:
        if person.lower() in context.lower():
            entities['people'].append(person)
    
    for org in organizations:
        if org.lower() in context.lower():
            entities['organizations'].append(org)
    
    return entities

def analyze_document(doc_path):
    """Analyze a single document for financial data"""
    try:
        with open(doc_path, 'r', encoding='utf-8', errors='ignore') as f:
            text = f.read()
    except:
        return None
    
    doc_name = doc_path.name
    
    # Extract all financial data
    amounts = extract_dollar_amounts(text)
    payments = extract_payments(text)
    
    if not amounts and not payments:
        return None
    
    return {
        'document': doc_name,
        'amounts': amounts,
        'payments': payments,
        'total_amounts': len(amounts),
        'total_payments': len(payments)
    }

def process_all_documents():
    """Process all documents and extract financial data"""
    print("=" * 80)
    print("EXTRACTING FINANCIAL DATA FROM DOCUMENTS")
    print("=" * 80)
    
    if not COMPLETE_EXTRACTION.exists():
        print(f"\nERROR: Documents not found at {COMPLETE_EXTRACTION}")
        return
    
    doc_files = list(COMPLETE_EXTRACTION.glob("*.txt"))
    print(f"\nFound {len(doc_files)} documents to analyze")
    
    all_financial_data = []
    documents_with_money = 0
    
    for i, doc_path in enumerate(doc_files):
        if (i + 1) % 50 == 0:
            print(f"  Processed {i + 1}/{len(doc_files)} documents...")
        
        result = analyze_document(doc_path)
        if result:
            all_financial_data.append(result)
            documents_with_money += 1
    
    print(f"\n  Total documents: {len(doc_files)}")
    print(f"  Documents with financial data: {documents_with_money}")
    
    # Save raw data
    output_file = OUTPUT_PATH / "financial_data_raw.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_financial_data, f, indent=2)
    
    print(f"\n  Saved raw data: {output_file.name}")
    
    return all_financial_data

def aggregate_financial_data(financial_data):
    """Aggregate and analyze financial data"""
    print("\n" + ("=" * 80))
    print("AGGREGATING FINANCIAL DATA")
    print("=" * 80)
    
    # Track all amounts
    all_amounts = []
    payment_contexts = []
    entity_mentions = defaultdict(int)
    
    for doc_data in financial_data:
        for amount_data in doc_data['amounts']:
            all_amounts.append(amount_data['amount'])
            
            # Extract entities from context
            entities = extract_entities_from_context(amount_data['context'])
            for person in entities['people']:
                entity_mentions[person] += 1
        
        for payment_data in doc_data['payments']:
            payment_contexts.append({
                'amount': payment_data['amount'],
                'context': payment_data['context'],
                'document': doc_data['document']
            })
    
    # Calculate statistics
    if all_amounts:
        total_value = sum(all_amounts)
        avg_amount = total_value / len(all_amounts)
        max_amount = max(all_amounts)
        min_amount = min(all_amounts)
        
        print(f"\n  Total amounts found: {len(all_amounts)}")
        print(f"  Total value: ${total_value:,.2f}")
        print(f"  Average amount: ${avg_amount:,.2f}")
        print(f"  Largest amount: ${max_amount:,.2f}")
        print(f"  Smallest amount: ${min_amount:,.2f}")
    
    # Top entities mentioned with money
    print(f"\n  Top entities mentioned with financial data:")
    sorted_entities = sorted(entity_mentions.items(), key=lambda x: x[1], reverse=True)
    for entity, count in sorted_entities[:10]:
        print(f"    {entity}: {count} mentions")
    
    # Save aggregated data
    aggregated = {
        'statistics': {
            'total_amounts': len(all_amounts),
            'total_value': sum(all_amounts) if all_amounts else 0,
            'average_amount': sum(all_amounts) / len(all_amounts) if all_amounts else 0,
            'max_amount': max(all_amounts) if all_amounts else 0,
            'min_amount': min(all_amounts) if all_amounts else 0
        },
        'entity_mentions': dict(sorted_entities),
        'payment_contexts': payment_contexts[:100]  # Top 100
    }
    
    output_file = OUTPUT_PATH / "financial_data_aggregated.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(aggregated, f, indent=2)
    
    print(f"\n  Saved aggregated data: {output_file.name}")
    
    return aggregated

def create_money_flow_data(financial_data):
    """Create data structure for money flow visualization"""
    print("\n" + ("=" * 80))
    print("CREATING MONEY FLOW DATA")
    print("=" * 80)
    
    # Known financial transactions from documents
    transactions = [
        {
            'from': 'Jeffrey Epstein',
            'to': 'Ghislaine Maxwell',
            'amount': 15000000,
            'type': 'Property Transfer',
            'description': 'NYC townhouse at 116 E. 65th St.',
            'date': '2016-04-28',
            'source': 'Court documents'
        },
        {
            'from': 'Jeffrey Epstein',
            'to': 'Virginia Roberts',
            'amount': 15000,
            'type': 'Payment',
            'description': 'Payment after first encounter with Prince Andrew',
            'date': '2001',
            'source': 'Victim testimony'
        },
        {
            'from': 'Jeffrey Epstein',
            'to': 'Virginia Roberts',
            'amount': 200,
            'type': 'Payment',
            'description': 'First payment for "massage"',
            'date': '2000',
            'source': 'Victim testimony'
        },
        {
            'from': 'Johanna Sjoberg',
            'to': 'Jeffrey Epstein',
            'amount': 100,
            'type': 'Hourly Rate',
            'description': 'Offered $100/hour for "rubbing feet"',
            'date': 'Unknown',
            'source': 'Deposition testimony'
        },
        {
            'from': 'Virginia Giuffre',
            'to': 'Ghislaine Maxwell',
            'amount': 50000000,
            'type': 'Lawsuit Damages',
            'description': 'Seeking at least $50 million in compensatory and punitive damages',
            'date': '2015-09-21',
            'source': 'Court filing'
        },
        {
            'from': 'Virginia Giuffre',
            'to': 'Ghislaine Maxwell',
            'amount': 5000000,
            'type': 'Lost Wages Claim',
            'description': 'Past and future lost wages claim',
            'date': '2015',
            'source': 'Court interrogatory'
        }
    ]
    
    # Save money flow data
    output_file = OUTPUT_PATH / "money_flow_transactions.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(transactions, f, indent=2)
    
    print(f"\n  Created {len(transactions)} known transactions")
    print(f"  Saved: {output_file.name}")
    
    return transactions

def generate_mermaid_diagram(transactions):
    """Generate Mermaid diagram code for money flow"""
    print("\n" + ("=" * 80))
    print("GENERATING MONEY FLOW DIAGRAM")
    print("=" * 80)
    
    mermaid_code = []
    mermaid_code.append("```mermaid")
    mermaid_code.append("graph LR")
    mermaid_code.append("    %% Money Flow in Epstein Case")
    mermaid_code.append("")
    
    # Define nodes
    entities = set()
    for t in transactions:
        entities.add(t['from'])
        entities.add(t['to'])
    
    # Create sanitized node IDs
    node_ids = {}
    for i, entity in enumerate(sorted(entities)):
        node_id = f"N{i}"
        node_ids[entity] = node_id
        mermaid_code.append(f"    {node_id}[\"{entity}\"]")
    
    mermaid_code.append("")
    
    # Create edges
    for t in transactions:
        from_id = node_ids[t['from']]
        to_id = node_ids[t['to']]
        amount_str = f"${t['amount']:,.0f}"
        label = f"{amount_str}<br/>{t['type']}"
        mermaid_code.append(f"    {from_id} -->|{label}| {to_id}")
    
    mermaid_code.append("```")
    
    # Save diagram
    output_file = OUTPUT_PATH / "MONEY_FLOW_DIAGRAM.md"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Money Flow Diagram - Epstein Case\n\n")
        f.write("## Visualization\n\n")
        f.write("\n".join(mermaid_code))
        f.write("\n\n## Transaction Details\n\n")
        
        for t in sorted(transactions, key=lambda x: x['amount'], reverse=True):
            f.write(f"### ${t['amount']:,.0f} - {t['type']}\n\n")
            f.write(f"- **From**: {t['from']}\n")
            f.write(f"- **To**: {t['to']}\n")
            f.write(f"- **Date**: {t['date']}\n")
            f.write(f"- **Description**: {t['description']}\n")
            f.write(f"- **Source**: {t['source']}\n\n")
    
    print(f"\n  Generated Mermaid diagram")
    print(f"  Saved: {output_file.name}")

def main():
    print("\n")
    
    # Extract financial data
    financial_data = process_all_documents()
    
    if not financial_data:
        print("\nNo financial data found!")
        return
    
    # Aggregate data
    aggregated = aggregate_financial_data(financial_data)
    
    # Create money flow data
    transactions = create_money_flow_data(financial_data)
    
    # Generate diagram
    generate_mermaid_diagram(transactions)
    
    print("\n" + ("=" * 80))
    print("FINANCIAL ANALYSIS COMPLETE!")
    print("=" * 80)
    print(f"\nOutput location: {OUTPUT_PATH}")
    print(f"\nFiles created:")
    print(f"  - financial_data_raw.json")
    print(f"  - financial_data_aggregated.json")
    print(f"  - money_flow_transactions.json")
    print(f"  - MONEY_FLOW_DIAGRAM.md")

if __name__ == "__main__":
    main()
