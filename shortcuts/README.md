# Code Runner - iMessage Code Execution Agent

Execute code directly from iMessage messages. Write code once, get results instantly.

## Quick Start

```bash
# Test the runner
echo "print('hello')" | ./code-runner --type python

# View documentation
cat CODE-RUNNER-DOCS.md

# Run tests
./test-code-runner

# Install cron job (auto-monitoring)
./install-code-runner
```

## Supported Languages

| Language | Command | Example |
|----------|---------|---------|
| **Python** | `code: [code]` | `code: print(2+2)` |
| **Node.js** | `node: [code]` | `node: console.log([1,2,3])` |
| **SQL** | `sql: [query]` | `sql: SELECT 1+1;` |
| **C** | `c: [code]` | `c: #include <stdio.h>...` |
| **Bash** | `bash: [script]` | `bash: echo "hello"` |

## Files

```
shortcuts/
├── code-runner              # Main CLI (executes code)
├── code-monitor             # iMessage monitor (detects + routes commands)
├── install-code-runner      # Setup cron job
├── test-code-runner         # Test suite
├── README.md                # This file
└── CODE-RUNNER-DOCS.md      # Full documentation
```

## How It Works

1. **You send an iMessage** with code: `code: print([1,2,3])`
2. **Monitor detects it** (runs every 5 min via cron)
3. **Executor processes it** (routes to appropriate interpreter)
4. **Results sent back** via iMessage with output + metadata

## Examples

### Python Quick Math
```
You: code: sum([1, 2, 3, 4, 5])
Bot: 15
      python | 145ms
```

### Node.js Array Operations
```
You: node: [1,2,3].map(x => x*x)
Bot: [ 1, 4, 9 ]
      node | 89ms
```

### SQL Database Query
```
You: sql: CREATE TABLE users(id INT, name TEXT);
       INSERT INTO users VALUES(1, 'Alice'), (2, 'Bob');
       SELECT * FROM users;
Bot: 1|Alice
     2|Bob
      sql | 234ms
```

### C Compilation
```
You: c: #include <stdio.h>
       int main() { printf("Hello from C"); }
Bot: Hello from C
      c | 567ms
```

## Installation

### Standalone Usage

```bash
# Make it executable
chmod +x code-runner

# Run directly
echo "print('test')" | ./code-runner --type python
```

### With Cron Job (Auto-Monitoring)

```bash
# Install automated monitoring
./install-code-runner

# Verify it's running
crontab -l | grep code-monitor

# Watch logs
tail -f ~/.openclaw/workspace/logs/code-runner.log
```

## CLI Options

```
code-runner [options] [code]

Options:
  --type TYPE       Code type: python, node, c, sql, bash
  --format FORMAT   Output format: text (default), json
  --file FILE       Read code from file instead of stdin

Examples:
  echo 'print(42)' | code-runner --type python
  code-runner --type sql < query.sql
  echo '5**2' | code-runner --type python --format json
```

## Safety Features

- **Timeout:** 30-second maximum execution time
- **Output limit:** 8KB max (prevents huge iMessages)
- **Deduplication:** Won't re-execute the same command
- **Error handling:** Full error capture with line numbers
- **Rate limiting:** Processes in small batches

## Configuration

Edit these constants in the scripts:

**code-runner:**
- `MAX_OUTPUT = 8000` bytes
- `MAX_RUNTIME = 30000` ms

**code-monitor:**
- Check frequency: 5 minutes (configurable)
- Batch size: 50 messages at a time
- State file: `~/.openclaw/workspace/.code-monitor-state.json`

## Troubleshooting

### Command not found
```bash
# Make sure scripts are executable
chmod +x code-runner code-monitor

# Add to PATH (optional)
export PATH="$HOME/.openclaw/workspace/shortcuts:$PATH"
```

### Cron job not running
```bash
# Check if installed
crontab -l

# Manually test
~/.openclaw/workspace/shortcuts/code-monitor --once

# Check logs
tail ~/.openclaw/workspace/logs/code-runner.log
```

### iMessage not responding
1. Verify `code-monitor` is running: `pgrep -f code-monitor`
2. Check recent messages are being detected
3. Ensure message format matches patterns (see CODE-RUNNER-DOCS.md)

## Performance

Typical execution times:

- Python: 150-300ms
- Node.js: 80-200ms
- SQL: 100-500ms
- C: 200-800ms (includes compilation)
- Bash: 50-400ms

*Times include startup overhead and output formatting*

## Examples by Language

### Python - Data Science
```
code: import json
      data = {"users": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}
      print(json.dumps(data, indent=2))
```

### Node.js - Functional Programming
```
node: const users = ["alice", "bob", "charlie"];
      const greeting = users
        .filter(u => u.length > 3)
        .map(u => `Hello, ${u.toUpperCase()}`)
        .join("\n");
      console.log(greeting);
```

### SQL - Data Analysis
```
sql: CREATE TABLE sales(product TEXT, amount INT);
     INSERT INTO sales VALUES('Widget', 100), ('Gadget', 150), ('Doohickey', 75);
     SELECT product, amount FROM sales WHERE amount > 80 ORDER BY amount DESC;
```

### C - System Programming
```
c: #include <stdio.h>
   #include <string.h>
   int main() {
     char str[] = "Programming";
     printf("Length: %zu\n", strlen(str));
     return 0;
   }
```

### Bash - System Operations
```
bash: echo "System Info:"
      uname -a
      echo "Disk Usage:"
      df -h | head -2
```

## Advanced Usage

### Chained Execution
```
code: result = 42
      print(f"Answer: {result}")
      print(f"Double: {result * 2}")
```

### Error Handling
```
python code automatically captures:
  - Syntax errors
  - Runtime exceptions
  - Stack traces
  - stderr output
```

### Large Output Handling
```
Outputs larger than 8KB are automatically truncated
with a notice: [Output truncated - original size: 12,543 bytes]
```

## Limits & Constraints

| Limit | Value | Reason |
|-------|-------|--------|
| Execution timeout | 30s | Prevent hangs |
| Output size | 8KB | iMessage limit |
| Memory | System default | Safety margin |
| CPU | No limit | Monitor if needed |
| File operations | Full access | Run as your user |

## What's Logged

Activity logged to: `~/.openclaw/workspace/logs/code-runner.log`

```
[code-monitor] Checking 25 messages...
[code-monitor] Found python command in message msg_12345
[code-monitor] Executed python: SUCCESS
[code-monitor] Processed 1 commands
```

## Development

### Run tests
```bash
./test-code-runner

# Expected output:
#  All tests passed!
```

### Add a new language

1. Add pattern to `code-monitor`:
   ```javascript
   rust: /^rust:\s*([\s\S]+?)(?:\n|$)/m,
   ```

2. Add executor to `code-runner`:
   ```javascript
   case "rust":
     return this.executeRust(code);
   ```

3. Implement the function:
   ```javascript
   async executeRust(code) {
     return this.execCmd("rustc", ["-o", "/tmp/rust_out", "-"]);
   }
   ```

### Customize behavior

Edit the scripts directly - no complex build process. Small, readable, modifiable.

## License

Part of the OpenClaw agent system.

## Support

For issues or questions:
1. Check logs: `tail ~/.openclaw/workspace/logs/code-runner.log`
2. Run test suite: `./test-code-runner`
3. Review CODE-RUNNER-DOCS.md for detailed documentation

---

**Last updated:** 2026-02-10
**Status:**  Ready for production
