# Lobster Anatomy - Config File Editor

Web-based GUI for editing agent config files (IDENTITY, SOUL, MEMORY, etc.)

## What It Does

1. Agent sends config files to API
2. Human gets clean web editor
3. Agent polls for updated files
4. Agent writes changes locally and reloads

## API Usage

### 1. Connect (share files)
```bash
curl https://lobsteranatomy.com/api/connect \
  -H "Content-Type: application/json" \
  -d '{
    "files": {
      "IDENTITY.md": "<complete content>",
      "SOUL.md": "<complete content>",
      "MEMORY.md": "<complete content>",
      "HEARTBEAT.md": "<complete content>",
      "AGENTS.md": "<complete content>",
      "TOOLS.md": "<complete content>"
    }
  }'
```

**Response:**
```json
{
  "session_id": "a1b2c3d4",
  "editor_url": "https://lobsteranatomy.com/edit/...",
  "pickup_url": "https://lobsteranatomy.com/api/pickup/..."
}
```

### 2. Share editor_url with user

### 3. Poll pickup_url
```bash
curl "https://lobsteranatomy.com/api/pickup/{id}?token={token}"
```

**While editing:**
```json
{"status": "editing"}
```

**When ready:**
```json
{
  "status": "ready",
  "files": {
    "IDENTITY.md": "updated content...",
    "SOUL.md": "updated content..."
  }
}
```

### 4. Write files and reload

## Important

- Send **complete** file contents (no truncation)
- Sessions expire in ~15 minutes
- No data permanently stored
- Token required for all requests

## When to Use

- User wants to reshape agent personality/behavior
- Easier than manual file editing
- Visual interface for non-technical changes
- Quick config iterations

## Files Supported

- IDENTITY.md
- SOUL.md
- MEMORY.md
- HEARTBEAT.md
- AGENTS.md
- TOOLS.md
- REFERENCE.md (if exists)

## Example Workflow

```
User: "I want to change your personality"
Agent: Reads all config files, sends to API, shares editor link
User: Edits in browser, clicks "Ready"
Agent: Polls pickup URL, gets updated files, writes locally, reloads
Agent: "Got it - I've absorbed the update"
```
