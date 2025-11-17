import json
from pathlib import Path

timeline_file = Path(r"G:\My Drive\04_Resources\Notes\Epstein Email Dump\unified_timeline\timeline_data.json")
data = json.load(open(timeline_file, encoding='utf-8'))

print(f"Total events: {len(data)}")

phone_calls = [e for e in data if e.get('type') == 'PHONE_CALL']
print(f"\nPhone call events: {len(phone_calls)}")

for call in phone_calls:
    print(f"\n  Date: {call.get('formatted_date')}")
    print(f"  Title: {call.get('title')}")
    print(f"  People: {', '.join(call.get('people', []))}")

message_book = [e for e in data if 'Message Book' in e.get('title', '')]
print(f"\n\nMessage Book events: {len(message_book)}")

for event in message_book[:10]:
    print(f"\n  Date: {event.get('formatted_date')}")
    print(f"  Title: {event.get('title')}")
