#!/usr/bin/env python3
"""
Person Aliases and Nickname Mapping
Links people with their various names, aliases, and nicknames
"""

# Person alias mapping
# Format: canonical_name -> [list of aliases, nicknames, variations]
PERSON_ALIASES = {
    # Core Figures
    "Jeffrey Epstein": [
        "Epstein",
        "Jeffrey",
        "Jeff Epstein",
        "J. Epstein",
        "JE",
        "Mr. Epstein"
    ],
    
    "Ghislaine Maxwell": [
        "Maxwell",
        "Ghislaine",
        "G. Maxwell",
        "GM",
        "Ms. Maxwell",
        "Defendant Maxwell",
        "Defendant"
    ],
    
    "Virginia Roberts Giuffre": [
        "Virginia Roberts",
        "Virginia Giuffre",
        "Virginia",
        "Giuffre",
        "Roberts",
        "V. Giuffre",
        "V. Roberts",
        "VG",
        "VR",
        "Plaintiff Virginia Giuffre",
        "Plaintiff Giuffre",
        "Plaintiff",
        "Jane Doe 3"
    ],
    
    # Royal/Political
    "Prince Andrew": [
        "Andrew",
        "Duke of York",
        "Prince Andrew, Duke of York",
        "HRH Prince Andrew",
        "The Duke of York"
    ],
    
    "Bill Clinton": [
        "Clinton",
        "William Clinton",
        "President Clinton",
        "President Bill Clinton",
        "William Jefferson Clinton",
        "Bill"
    ],
    
    "Donald Trump": [
        "Trump",
        "Donald J. Trump",
        "President Trump",
        "Donald"
    ],
    
    # Epstein Associates
    "Sarah Kellen": [
        "Kellen",
        "Sarah",
        "Sarah Kensington",
        "S. Kellen"
    ],
    
    "Nadia Marcinkova": [
        "Marcinkova",
        "Nadia",
        "Nada Marcinkova",
        "N. Marcinkova"
    ],
    
    "Adriana Ross": [
        "Ross",
        "Adriana",
        "Adriana Mucinska",
        "A. Ross"
    ],
    
    "Lesley Groff": [
        "Groff",
        "Lesley",
        "L. Groff"
    ],
    
    "Jean-Luc Brunel": [
        "Brunel",
        "Jean-Luc",
        "J.L. Brunel",
        "JL Brunel"
    ],
    
    "Emmy Tayler": [
        "Tayler",
        "Emmy",
        "Emmy Taylor",
        "E. Tayler"
    ],
    
    "Eva Andersson": [
        "Andersson",
        "Eva",
        "Eva Anderson",
        "E. Andersson"
    ],
    
    # Legal Team - Plaintiffs
    "Sigrid McCawley": [
        "McCawley",
        "Sigrid",
        "S. McCawley",
        "Mccawley"
    ],
    
    "David Boies": [
        "Boies",
        "David",
        "D. Boies"
    ],
    
    "Brad Edwards": [
        "Edwards",
        "Brad",
        "Bradley Edwards",
        "B. Edwards"
    ],
    
    "Paul Cassell": [
        "Cassell",
        "Paul",
        "P. Cassell"
    ],
    
    # Legal Team - Defense
    "Laura Menninger": [
        "Menninger",
        "Laura",
        "L. Menninger"
    ],
    
    "Alan Dershowitz": [
        "Dershowitz",
        "Alan",
        "A. Dershowitz",
        "Prof. Dershowitz",
        "Professor Dershowitz"
    ],
    
    # Victims/Witnesses
    "Johanna Sjoberg": [
        "Sjoberg",
        "Johanna",
        "J. Sjoberg"
    ],
    
    "Sarah Ransome": [
        "Ransome",
        "Sarah",
        "S. Ransome"
    ],
    
    "Carolyn Andriamo": [
        "Andriamo",
        "Carolyn",
        "C. Andriamo"
    ],
    
    "Annie Farmer": [
        "Farmer",
        "Annie",
        "A. Farmer"
    ],
    
    "Maria Farmer": [
        "Maria Farmer",
        "M. Farmer"
    ],
    
    # Staff/Associates
    "Juan Alessi": [
        "Alessi",
        "Juan",
        "J. Alessi"
    ],
    
    "Tony Figueroa": [
        "Figueroa",
        "Tony",
        "Anthony Figueroa",
        "T. Figueroa"
    ],
    
    "Alfredo Rodriguez": [
        "Rodriguez",
        "Alfredo",
        "A. Rodriguez"
    ],
    
    "Philip Barden": [
        "Barden",
        "Philip",
        "P. Barden"
    ],
    
    "Christina Venero": [
        "Venero",
        "Christina",
        "C. Venero"
    ],
    
    "Janusz Banasiak": [
        "Banasiak",
        "Janusz",
        "J. Banasiak"
    ],
    
    # Law Enforcement
    "Detective Recarey": [
        "Recarey",
        "Det. Recarey",
        "Detective Joseph Recarey",
        "Joseph Recarey"
    ],
    
    "Louis Freeh": [
        "Freeh",
        "Louis",
        "L. Freeh",
        "Director Freeh"
    ],
    
    # Court Personnel
    "Meredith Schultz": [
        "Schultz",
        "Meredith",
        "M. Schultz"
    ],
    
    "Kelli Ann Willis": [
        "Willis",
        "Kelli Ann",
        "K. Willis"
    ],
    
    "Steven Olson": [
        "Olson",
        "Steven",
        "S. Olson"
    ],
    
    # Business Associates
    "Leslie Wexner": [
        "Wexner",
        "Leslie",
        "Les Wexner",
        "L. Wexner"
    ],
    
    "Glenn Dubin": [
        "Dubin",
        "Glenn",
        "G. Dubin"
    ],
    
    "Eva Dubin": [
        "Eva Dubin",
        "E. Dubin"
    ],
    
    # Celebrities
    "Chris Tucker": [
        "Tucker",
        "Chris",
        "Christopher Tucker"
    ],
    
    "Kevin Spacey": [
        "Spacey",
        "Kevin",
        "K. Spacey"
    ],
    
    "Naomi Campbell": [
        "Campbell",
        "Naomi",
        "N. Campbell"
    ],
}

def get_canonical_name(name):
    """
    Get the canonical name for a person given any alias
    
    Args:
        name: Any name or alias
        
    Returns:
        Canonical name if found, otherwise original name
    """
    name_lower = name.lower().strip()
    
    # Check if it's already a canonical name
    for canonical, aliases in PERSON_ALIASES.items():
        if canonical.lower() == name_lower:
            return canonical
    
    # Check if it's an alias
    for canonical, aliases in PERSON_ALIASES.items():
        for alias in aliases:
            if alias.lower() == name_lower:
                return canonical
    
    # Not found, return original
    return name

def get_all_aliases(canonical_name):
    """
    Get all aliases for a canonical name
    
    Args:
        canonical_name: The canonical name
        
    Returns:
        List of all aliases, or empty list if not found
    """
    return PERSON_ALIASES.get(canonical_name, [])

def merge_person_names(names):
    """
    Merge a list of names to their canonical forms
    
    Args:
        names: List of names (may include aliases)
        
    Returns:
        List of unique canonical names
    """
    canonical_names = set()
    
    for name in names:
        canonical = get_canonical_name(name)
        canonical_names.add(canonical)
    
    return sorted(list(canonical_names))

def get_all_known_people():
    """
    Get list of all canonical names
    
    Returns:
        Sorted list of all canonical person names
    """
    return sorted(PERSON_ALIASES.keys())

def export_alias_mapping():
    """
    Export alias mapping for documentation
    
    Returns:
        Formatted string with all mappings
    """
    output = []
    output.append("# Person Alias Mapping\n")
    output.append(f"Total People: {len(PERSON_ALIASES)}\n")
    output.append("\n---\n\n")
    
    for canonical, aliases in sorted(PERSON_ALIASES.items()):
        output.append(f"## {canonical}\n")
        output.append(f"**Aliases**: {len(aliases)}\n\n")
        for alias in sorted(aliases):
            output.append(f"- {alias}\n")
        output.append("\n")
    
    return "".join(output)

if __name__ == "__main__":
    # Test the mapping
    print("Person Alias System")
    print("=" * 80)
    print(f"\nTotal canonical names: {len(PERSON_ALIASES)}")
    
    # Count total aliases
    total_aliases = sum(len(aliases) for aliases in PERSON_ALIASES.values())
    print(f"Total aliases: {total_aliases}")
    
    # Test some examples
    print("\nExample mappings:")
    test_names = [
        "Epstein",
        "Maxwell", 
        "Virginia Roberts",
        "Giuffre",
        "Andrew",
        "Clinton",
        "Dershowitz"
    ]
    
    for name in test_names:
        canonical = get_canonical_name(name)
        print(f"  '{name}' → '{canonical}'")
    
    # Test merging
    print("\nMerge test:")
    test_list = ["Epstein", "Jeffrey", "Jeffrey Epstein", "Maxwell", "Ghislaine"]
    merged = merge_person_names(test_list)
    print(f"  Input: {test_list}")
    print(f"  Merged: {merged}")
