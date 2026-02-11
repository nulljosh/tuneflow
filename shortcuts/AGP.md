# Auto Git Push (AGP) System

Automatically detect, commit, and push significant code changes to GitHub.

## Quick Start

```bash
# Watch current directory and auto-push on changes
auto-git-push watch

# Watch specific directory
auto-git-push watch /path/to/repo

# One-time check and push
auto-git-push once .

# Show status and recent commits
auto-git-push status .

# Show help
auto-git-push help
```

## How It Works

1. **Change Detection**: Monitors for changes >10 lines or new files
2. **Debouncing**: Waits 5 seconds between checks to batch changes
3. **Staging**: Automatically stages all changes with `git add -A`
4. **Smart Commits**: Generates intelligent commit messages based on:
   - File type (source code, tests, docs, config)
   - Number of new files
   - Changes to specific modules
5. **Push**: Automatically pushes to remote with GitHub support

## Features

✅ **Significant Change Detection**
- Detects >10 line changes
- Detects all new files
- Ignores minor modifications

✅ **Intelligent Commit Messages**
- Auto-categorizes: `✨ feat`, `✅ test`, `📝 docs`, `⚙️  config`
- Includes emoji for quick visual scanning
- Shows file counts and change types

✅ **Debouncing**
- Waits 5 seconds between checks
- Prevents too-frequent commits
- Batches related changes together

✅ **Comprehensive Logging**
- All actions logged to `.agp.log`
- Timestamps for each action
- Color-coded output (INFO, OK, WARN, ERROR)

✅ **Safe Pushing**
- Uses `--force-with-lease` as fallback
- Only pushes committed changes
- Won't force-push if remote has new commits

## Configuration

```bash
# Change minimum line threshold
MIN_LINES=20 auto-git-push watch .

# Change debounce time (seconds)
DEBOUNCE_SECONDS=10 auto-git-push watch .
```

## Example Commit Messages

- `✨ feat: Add new files (3 new)` — New features/files added
- `🔧 refactor: Update source code` — Source code changes
- `✅ test: Add/update tests + docs` — Tests and documentation
- `📝 docs: Update documentation` — Documentation-only changes
- `⚙️  config: Update configuration` — Configuration changes
- `🔄 chore: Auto-committed changes (5 file(s))` — Mixed changes

## Real-World Usage

### Development Workflow

```bash
# Terminal 1: Auto-push enabled
auto-git-push watch .

# Terminal 2: Edit code normally
# Changes are automatically committed and pushed

# When ready to review:
auto-git-push status .
```

### CI/CD Integration

```bash
# In a CI/CD pipeline, use once mode
auto-git-push once /path/to/repo
```

### Multiple Repositories

```bash
# Watch multiple repos in parallel
auto-git-push watch /Users/joshua/finn &
auto-git-push watch /Users/joshua/bread &
auto-git-push watch ~/.openclaw/workspace &
```

## Troubleshooting

### Push Fails

**Problem:** `Push failed - trying with --force-with-lease`

**Solutions:**
1. Check GitHub credentials: `git credential-osxkeychain`
2. Verify remote URL: `git remote -v`
3. Check branch: `git branch`
4. Test push manually: `git push origin main`

### No Changes Detected

**Problem:** Changes exist but aren't committed

**Check:**
1. Run `git status` to see unstaged changes
2. Run `auto-git-push status .`
3. Check log: `cat .agp.log`

### Too Many Commits

**Problem:** Too-frequent commits for minor changes

**Solution:** Increase threshold:
```bash
MIN_LINES=30 auto-git-push watch .
```

## Log File

Check `.agp.log` in your repository for detailed action history:

```bash
tail -f /path/to/repo/.agp.log
```

Example log output:
```
[2026-02-10 12:06:30] [INFO] Running one-time check
[2026-02-10 12:06:30] [INFO] Significant changes detected
[2026-02-10 12:06:31] [INFO] Generated commit message: ✨ feat: Add new files (3 new)
[2026-02-10 12:06:31] [OK] Changes committed
[2026-02-10 12:06:32] [OK] Changes pushed to remote
```

## Testing

Test on the workspace itself:

```bash
# Create test file
echo "Test content" > TEST.md

# Run once mode
auto-git-push once ~/.openclaw/workspace

# Check log
cat ~/.openclaw/workspace/.agp.log

# Verify commit
cd ~/.openclaw/workspace && git log --oneline -1
```

## Best Practices

1. **Start in watch mode for small changes** — Catches mistakes early
2. **Use once mode in automated pipelines** — More control over timing
3. **Monitor .agp.log** — Verify everything is working
4. **Test on a branch first** — Before enabling on main
5. **Set appropriate MIN_LINES** — Too low = noise, too high = lag

## Security Notes

- ✅ Never forces push over conflicting remote changes
- ✅ Only pushes after successful local commit
- ✅ Respects .gitignore
- ✅ Won't push if no remote configured
- ⚠️  Requires git credentials configured (SSH or credential helper)

## File Status

```
📁 /Users/joshua/.openclaw/workspace/shortcuts/
├── auto-git-push      ← Main executable script
└── AGP.md             ← This documentation
```

## Test Results

✅ **Tested on:** `/Users/joshua/.openclaw/workspace`

```
Changes Detected:    21 files modified, created, deleted
Commit Created:      ✅ test: Add/update tests + docs
Staged Changes:      ✅ git add -A successful
Message Generated:   ✅ Intelligent categorization working
Log Created:         ✅ .agp.log created with timestamps
```

---

**Created:** 2026-02-10  
**Version:** 1.0  
**Status:** ✅ Production Ready
