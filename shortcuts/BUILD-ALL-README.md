# build-all Command

Automatically build all projects in `~/Documents/Code/`.

## What It Does

1. **Discovers projects** - Finds all directories with both `README.md` and `.git`
2. **Detects build system** - Identifies the appropriate build tool:
   - npm/yarn/pnpm (Node.js)
   - Cargo (Rust)
   - Python (pip, setup.py, pyproject.toml)
   - Go (go.mod)
   - Gradle (Java/Kotlin)
   - Maven (Java)
   - Make (Makefile)
   - CMake (C/C++)
3. **Runs builds** - Executes appropriate build commands for each project
4. **Continues on error** - Doesn't stop if one project fails
5. **Reports summary** - Shows: X passed, Y failed, Z skipped

## Usage

```bash
# Run from anywhere:
~/.openclaw/workspace/shortcuts/build-all

# Or if shortcuts is in PATH:
build-all
```

## Output

- **Console**: Real-time colored output with progress
- **Log file**: `.build-all.log` in current directory with full details
- **Exit code**: `0` if all builds passed, `1` if any failed

## Build Commands by Type

| System | Command |
|--------|---------|
| npm | `npm install && npm run build` |
| yarn | `yarn install && yarn build` |
| pnpm | `pnpm install && pnpm run build` |
| cargo | `cargo build --release` |
| python | `pip install -e .` |
| go | `go build ./...` |
| gradle | `./gradlew build` |
| maven | `mvn clean package` |
| make | `make` |
| cmake | `mkdir build && cd build && cmake .. && make` |

## Example Output

```
==========================================
[2026-02-10 12:07:15] Building all projects in ~/Documents/Code/
==========================================
Found 21 project(s) to build

[2026-02-10 12:07:15] [START] bread: Building...
[2026-02-10 12:07:16] [BUILD] bread: Detected npm project
[2026-02-10 12:07:45] [✓ PASS] bread: Build successful

[2026-02-10 12:07:45] [START] NullOS: Building...
[2026-02-10 12:07:46] [BUILD] NullOS: Detected Makefile project
[2026-02-10 12:07:50] [✓ PASS] NullOS: Build successful

...

==========================================
[2026-02-10 12:08:30] Build Summary
==========================================
[2026-02-10 12:08:30] Passed:  14
[2026-02-10 12:08:30] Failed:  0
[2026-02-10 12:08:30] Skipped: 7
[2026-02-10 12:08:30] Total:   21
```

## Log File

Full build output saved to `.build-all.log` for debugging failures.

## Notes

- Projects are discovered only if they have both `README.md` and `.git`
- Projects without a recognized build system are skipped (not failures)
- Each project builds in isolation (in its own directory)
- Build continues even if one project fails (tracks all results)
