# Tweet Analyzer Workflow

## How It Works

When Joshua sends a tweet screenshot via iMessage:

### Step 1: Extract Tweet Content
1. Use `image` tool to analyze screenshot
2. Extract full tweet text
3. Identify tweet type (project idea, tool, app, concept)

### Step 2: Generate Project Plan
1. Classify project type (web app, CLI, API, etc.)
2. Recommend tech stack based on content
3. Define MVP scope
4. Estimate effort (hours/days)
5. List core features

### Step 3: Create Project Directory
```bash
mkdir -p ~/Documents/Code/tweet-projects/tweet-{id or slug}
```

### Step 4: Write IDEA.md
Generate structured markdown with:
- Original tweet text
- Project classification
- Tech stack
- Core features
- MVP scope
- Implementation phases
- Effort estimate

### Step 5: Optional - Bootstrap Project
If Joshua approves:
- Create GitHub repo
- Generate project scaffold
- Write initial code
- Deploy MVP

## Commands

**Manual trigger:**
```bash
tweet-to-project <screenshot-path>
```

**Automatic:**
Just send tweet screenshot via iMessage - I'll detect it and process automatically.

## Storage
- Project ideas: `~/Documents/Code/tweet-projects/`
- Each project gets its own directory with `IDEA.md`

## Status
- ✅ Workflow defined
- ✅ Scripts created
- ❌ bird CLI (download broken, using screenshots instead)
- ✅ Screenshot analysis working
