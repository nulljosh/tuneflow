# Code Sync Daemon

Background auto-sync daemon for all git repos in `~/Documents/Code/`.

## Features

✓ Watches all repos in ~/Documents/Code/ simultaneously
✓ Auto-commits with AI-generated messages (Claude Haiku)
✓ Auto-pushes to GitHub
✓ Pulls remote updates every hour
✓ 30-second debounce to prevent commit spam
✓ Runs 24/7 as macOS Launch Agent
✓ Controllable via OpenClaw shortcuts

## Quick Start

### 1. Set up Anthropic API Key

The daemon uses Claude Haiku to generate intelligent commit messages. You need to set your API key:

```bash
# Add to ~/.zshrc (or ~/.bashrc)
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
source ~/.zshrc
```

Or update the Launch Agent plist to include your key:

```bash
# Edit the plist file
nano ~/Library/LaunchAgents/com.joshua.code-sync.plist

# Add under <key>EnvironmentVariables</key>:
<key>ANTHROPIC_API_KEY</key>
<string>sk-ant-your-key-here</string>
```

### 2. Start the Daemon

**Option A: Via Launch Agent (auto-starts on login)**
```bash
launchctl load ~/Library/LaunchAgents/com.joshua.code-sync.plist
launchctl start com.joshua.code-sync
```

**Option B: Via OpenClaw**
```bash
openclaw run code-sync-start
```

**Option C: Manually (for testing)**
```bash
~/.openclaw/workspace/shortcuts/code-sync start
```

### 3. Check Status

```bash
openclaw run code-sync-status
# or
~/.openclaw/workspace/shortcuts/code-sync status
```

### 4. View Logs

```bash
tail -f ~/.openclaw/logs/code-sync.log
```

## Commands

Direct access:
- `~/.openclaw/workspace/shortcuts/code-sync start` - Start daemon
- `~/.openclaw/workspace/shortcuts/code-sync stop` - Stop daemon
- `~/.openclaw/workspace/shortcuts/code-sync status` - Check status
- `~/.openclaw/workspace/shortcuts/setup-remotes.sh` - Setup GitHub remotes

Optional aliases (add to ~/.zshrc):
```bash
alias code-sync="~/.openclaw/workspace/shortcuts/code-sync"
alias setup-remotes="~/.openclaw/workspace/shortcuts/setup-remotes.sh"
```

## How It Works

1. **File Watching**: Monitors all repos in ~/Documents/Code/ using Node.js fs.watch
2. **Debouncing**: Waits 30 seconds after last change before committing
3. **AI Commit Messages**: Uses Claude Haiku to analyze git diff and generate contextual messages
4. **Auto-Push**: Pushes to each repo's GitHub remote (origin)
5. **Periodic Pull**: Checks for remote updates every hour

## Configuration

### Adjust Timing

Edit `~/.openclaw/workspace/shortcuts/code-sync`:

```javascript
const DEBOUNCE_MS = 30000; // 30 seconds (default)
const CHECK_INTERVAL_MS = 3600000; // 1 hour (default)
```

### Exclude Repos

The daemon automatically skips:
- Non-git folders (no .git directory)
- Ignored files (respects each repo's .gitignore)
- System files (.DS_Store, node_modules, venv, __pycache__)

To exclude a specific repo, remove its .git folder or don't set a remote.

## Troubleshooting

### Daemon won't start
```bash
# Check logs for errors
cat ~/.openclaw/logs/code-sync-error.log

# Make sure API key is set
echo $ANTHROPIC_API_KEY

# Try running manually to see errors
~/.openclaw/workspace/shortcuts/code-sync start
```

### No commits being made
```bash
# Check if changes are significant enough (30s debounce)
# Check logs
tail -20 ~/.openclaw/logs/code-sync.log

# Verify repos have remotes
cd ~/Documents/Code/your-repo
git remote -v
```

### Push failures
```bash
# Ensure GitHub authentication is configured
gh auth status

# Check for merge conflicts
cd ~/Documents/Code/your-repo
git status
```

### Stop the daemon
```bash
openclaw run code-sync-stop
# or
launchctl stop com.joshua.code-sync
```

## Cost Estimate

- **API calls**: ~10-50/day (depends on coding activity)
- **Cost**: ~$0.01-0.05/day with Haiku (~$18/year)

## Safety Features

✓ **Respects .gitignore** - Won't commit secrets or ignored files
✓ **30-second debounce** - Prevents commit spam
✓ **No force push** - Fails if conflicts exist
✓ **Pull with rebase** - Avoids merge commits
✓ **Co-Authored-By tag** - All commits tagged with Claude attribution

## Files

- **Main script**: `~/.openclaw/workspace/shortcuts/code-sync`
- **Launch Agent**: `~/Library/LaunchAgents/com.joshua.code-sync.plist`
- **Logs**: `~/.openclaw/logs/code-sync.log`
- **Error logs**: `~/.openclaw/logs/code-sync-error.log`
- **OpenClaw config**: `~/.openclaw/openclaw.json`

## Alternatives

If you want simpler per-repo auto-push, use the existing `auto-git-push` script:

```bash
cd ~/Documents/Code/your-repo
~/.openclaw/workspace/shortcuts/auto-git-push watch .
```

This daemon is better for continuous background sync across all repos.
