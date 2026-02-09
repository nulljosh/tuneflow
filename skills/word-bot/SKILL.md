# Word Bot Skill

Look up word definitions, etymology, synonyms, and rhymes.

## Commands

### /define [word]
Get definition with examples
```bash
bash ~/.openclaw/workspace/shortcuts/etymology.sh define universe
```

### /etymology [word]
Get word origin and history
```bash
bash ~/.openclaw/workspace/shortcuts/etymology.sh etymology universe
```

### /synonym [word]
Find similar words
```bash
bash ~/.openclaw/workspace/shortcuts/etymology.sh synonym happy
```

### /rhyme [word]
Find rhyming words
```bash
bash ~/.openclaw/workspace/shortcuts/etymology.sh rhyme universe
```

## API Sources

- **Dictionary API**: Free dictionary definitions (dictionaryapi.dev)
- **Datamuse**: Rhymes, related words (datamuse.com)
- **Etymology**: Manual curated list for common words

## Usage in Chat

User: "/define Geist"
Bot: Runs script, returns formatted definition

User: "/etymology universe"  
Bot: Returns origin story if available

## Adding More Commands

Edit `~/.openclaw/workspace/shortcuts/etymology.sh` to add:
- /antonym
- /usage
- /origin
- /idiom
etc.
