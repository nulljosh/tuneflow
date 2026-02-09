#!/bin/bash
# Etymology and word definition bot

command="$1"
shift
words="$*"

case "$command" in
  etymology|ety)
    echo "📖 **Etymology of '$words'**"
    echo ""
    # Try dictionary API first (has etymology)
    result=$(curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$words" | \
      python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  if isinstance(data, list) and len(data) > 0:
    entry = data[0]
    if 'origin' in entry:
      print(entry['origin'])
    else:
      print('Etymology not available in database')
except:
  print('Not found')
" 2>/dev/null)
    
    if [ -z "$result" ] || [ "$result" = "Not found" ]; then
      echo "Etymology: (lookup not available, try /define for meaning)"
    else
      echo "$result"
    fi
    ;;
    
  define|def)
    echo "📚 **Definition of '$words'**"
    echo ""
    # Use dictionary API
    curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$words" | \
      python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  if isinstance(data, list) and len(data) > 0:
    entry = data[0]
    for meaning in entry.get('meanings', [])[:2]:
      print(f\"**{meaning['partOfSpeech']}:**\")
      for defn in meaning.get('definitions', [])[:2]:
        print(f\"  • {defn['definition']}\")
        if 'example' in defn:
          print(f\"    _{defn['example']}_\")
      print()
except: pass
" 2>/dev/null || echo "Definition not found"
    ;;
    
  synonym|syn)
    echo "🔄 **Synonyms for '$words'**"
    echo ""
    curl -s "https://api.dictionaryapi.dev/api/v2/entries/en/$words" | \
      python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  if isinstance(data, list) and len(data) > 0:
    entry = data[0]
    synonyms = set()
    for meaning in entry.get('meanings', []):
      for defn in meaning.get('definitions', []):
        synonyms.update(defn.get('synonyms', []))
    if synonyms:
      print(', '.join(list(synonyms)[:10]))
    else:
      print('No synonyms found')
except: pass
" 2>/dev/null || echo "Not found"
    ;;
    
  rhyme)
    echo "🎵 **Rhymes with '$words'**"
    echo ""
    # Use datamuse API
    curl -s "https://api.datamuse.com/words?rel_rhy=$words&max=10" | \
      python3 -c "
import json, sys
try:
  data = json.load(sys.stdin)
  rhymes = [w['word'] for w in data]
  if rhymes:
    print(', '.join(rhymes))
  else:
    print('No rhymes found')
except: pass
"
    ;;
    
  *)
    echo "📖 Word Bot Commands:"
    echo ""
    echo "  /etymology [word]  - Word origin and history"
    echo "  /define [word]     - Definition and examples"
    echo "  /synonym [word]    - Similar words"
    echo "  /rhyme [word]      - Words that rhyme"
    echo ""
    echo "Example: /etymology Geist universe"
    ;;
esac
