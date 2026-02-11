# Code Runner - Deployment Guide

**Status:** ✅ Ready to Deploy  
**Test Results:** 21/21 passing  
**Lines of Code:** ~450 LOC  

## 🚀 Deploy in 3 Steps

### Step 1: Verify Installation
```bash
ls -la ~/.openclaw/workspace/shortcuts/code-runner
# Should show: -rwxr-xr-x ... code-runner
```

### Step 2: Test Execution
```bash
echo "print('Hello Code Runner')" | ~/.openclaw/workspace/shortcuts/code-runner --type python
# Expected: Hello Code Runner
```

### Step 3: Enable Monitoring (Optional)
```bash
cd ~/.openclaw/workspace/shortcuts
./install-code-runner        # Every 5 minutes (default)
# or
./install-code-runner 30     # Every 30 minutes
```

## 📋 Files Included

### Core
| File | Purpose | Status |
|------|---------|--------|
| `code-runner` | Main executor | ✅ Tested |
| `code-monitor` | Message monitor | ✅ Ready |
| `install-code-runner` | Cron setup | ✅ Ready |

### Documentation
| File | Content |
|------|---------|
| `README.md` | Quick start |
| `CODE-RUNNER-DOCS.md` | Full reference |
| `BUILD-SUMMARY.md` | Technical details |
| `DEPLOYMENT-GUIDE.md` | This file |

### Testing
| File | Tests |
|------|-------|
| `test-code-runner` | 21 tests, all passing |

## 🧪 Quick Test

```bash
# Python
echo "print(2 + 2)" | code-runner --type python
# Output: 4

# Node.js
echo "console.log([1,2,3])" | code-runner --type node
# Output: [ 1, 2, 3 ]

# All tests
./test-code-runner
# Output: ✓ All tests passed!
```

## 📱 Using with iMessage

### Send Code Commands

Format: `[type]: [code]`

**Examples:**

```
code: print("Hello from Python")
node: console.log("Hello from Node")
sql: SELECT 1 + 1 as result;
c: #include <stdio.h>
   int main() { printf("Hello C"); return 0; }
bash: echo "Hello Bash"
```

### Automatic Response

Monitor runs every 5 minutes:
1. Detects your code command
2. Executes it
3. Sends results back via iMessage

## ⚙️ Configuration

### Cron Job Management

```bash
# Install
~/.openclaw/workspace/shortcuts/install-code-runner [interval]

# Check if running
crontab -l | grep code-monitor

# View logs
tail -f ~/.openclaw/workspace/logs/code-runner.log

# Remove
crontab -e  # Delete code-monitor line
```

### Custom Settings

Edit in the script files:

**code-runner:**
```javascript
const MAX_OUTPUT_BYTES = 8000;  // Output limit
const MAX_RUNTIME = 30000;      // Timeout (ms)
```

**code-monitor:**
```javascript
const poll_interval = 300000;   // 5 minutes
const batch_size = 50;          // Messages per check
```

## 🔍 Monitoring

### Check Status

```bash
# Is monitor running?
pgrep -f code-monitor

# View recent activity
tail -20 ~/.openclaw/workspace/logs/code-runner.log

# Check state
cat ~/.openclaw/workspace/.code-monitor-state.json
```

### View Logs

```bash
# All activity
tail -f ~/.openclaw/workspace/logs/code-runner.log

# Errors only
grep "Error" ~/.openclaw/workspace/logs/code-runner.log

# Specific type
grep "python" ~/.openclaw/workspace/logs/code-runner.log
```

## 🛠️ Troubleshooting

### "command not found"
```bash
# Make executable
chmod +x ~/.openclaw/workspace/shortcuts/code-runner

# Or use full path
~/.openclaw/workspace/shortcuts/code-runner --type python < code.py
```

### "No such file or directory"
```bash
# Check paths
which python3
which node
which sqlite3
which gcc

# Verify installation
python3 --version
node --version
```

### Monitor not running
```bash
# Check cron
crontab -l

# Manual test
~/.openclaw/workspace/shortcuts/code-monitor --once

# Check logs
tail ~/.openclaw/workspace/logs/code-runner.log
```

### iMessage not responding
1. Verify monitor is running: `pgrep -f code-monitor`
2. Check message format (should be `type: code`)
3. Verify code-runner works: test manually
4. Check logs for errors

## 📊 Performance

Typical execution times:

```
Python:  100-300ms  (startup + execution)
Node.js: 80-200ms   (compiled + cached)
C:       200-800ms  (compile + run)
SQL:     100-500ms  (database overhead)
Bash:    50-400ms   (varies by command)
```

Maximum output: 8 KB (iMessage compatible)
Maximum runtime: 30 seconds
Processing interval: 5 minutes (configurable)

## 🔐 Security Notes

### Run as Your User
Code executes with your permissions. Everything you can access, code can access.

### Recommended Safeguards
- Review code before execution (if using with untrusted sources)
- Monitor logs regularly
- Don't expose to public/untrusted users
- Consider sandboxing if needed (Docker/VM)

### Limits Applied
✅ Timeout: 30 seconds max  
✅ Output: 8 KB max  
✅ CPU: System defaults  
✅ Memory: System defaults  

## 📈 Scaling

### For More Frequent Checks
```bash
./install-code-runner 1  # Every minute
```

### For Less Frequent Checks
```bash
./install-code-runner 60  # Every hour
```

### For Real-Time (Webhook)
Implement webhook handler that calls code-runner directly.

## 🚨 Emergency Operations

### Stop Monitor
```bash
# Remove from crontab
crontab -e  # Delete code-monitor line

# Kill running processes
pkill -f code-monitor
```

### Clear State
```bash
# This allows re-executing same commands
rm ~/.openclaw/workspace/.code-monitor-state.json
```

### View Full Logs
```bash
# Last 50 lines
tail -50 ~/.openclaw/workspace/logs/code-runner.log

# Search for errors
grep -i error ~/.openclaw/workspace/logs/code-runner.log

# Real-time monitoring
tail -f ~/.openclaw/workspace/logs/code-runner.log
```

## 📚 Documentation Map

- **Quick Start:** → README.md
- **Full Reference:** → CODE-RUNNER-DOCS.md
- **Technical Details:** → BUILD-SUMMARY.md
- **Installation:** → This file (DEPLOYMENT-GUIDE.md)

## ✅ Pre-Flight Checklist

Before going live:

- [ ] Test code-runner directly: `echo "print(1)" | code-runner --type python`
- [ ] Run test suite: `./test-code-runner`
- [ ] Check dependencies installed: `python3 -v`, `node -v`, `sqlite3 -v`
- [ ] Create log directory: `mkdir -p ~/.openclaw/workspace/logs`
- [ ] Install cron: `./install-code-runner`
- [ ] Verify cron: `crontab -l | grep code-monitor`
- [ ] Wait 5 minutes and check logs: `tail ~/.openclaw/workspace/logs/code-runner.log`

## 📞 Support

For issues:

1. Check logs: `tail ~/.openclaw/workspace/logs/code-runner.log`
2. Run tests: `./test-code-runner`
3. Test directly: `echo "code" | code-runner --type python`
4. Review docs: See documentation map above

## 🎯 Next Steps

1. **Deploy:** Run `install-code-runner` to enable monitoring
2. **Test:** Send a test message: `code: print("test")`
3. **Verify:** Check logs after 5 minutes
4. **Use:** Start sending code commands via iMessage

---

**Installation Time:** ~2 minutes  
**Setup Difficulty:** Easy  
**Status:** ✅ Ready  

**Go ahead and deploy!**
