# Error Handling Framework
*Started: 2026-02-11 22:54 PST*

## Design Principles
1. **Fail gracefully** - Never crash, always have a fallback
2. **Learn from failures** - Log errors and adapt strategies
3. **User transparency** - Clear error messages, no hiding problems
4. **Self-healing** - Attempt recovery before giving up

## Implementation Plan

### 1. API Resilience Pattern
```javascript
async function resilientApiCall(primaryFn, fallbacks = []) {
  const errors = [];
  
  // Try primary
  try {
    return await withTimeout(primaryFn(), 5000);
  } catch (e) {
    errors.push({ source: 'primary', error: e });
  }
  
  // Try fallbacks in order
  for (const [name, fallbackFn] of fallbacks) {
    try {
      return await withTimeout(fallbackFn(), 5000);
    } catch (e) {
      errors.push({ source: name, error: e });
    }
  }
  
  // All failed - return cached or throw
  return getCachedOrThrow(errors);
}
```

### 2. Weather Service Example
```javascript
const weather = await resilientApiCall(
  () => wttr.getWeather(location),
  [
    ['openmeteo', () => openMeteo.getWeather(coords)],
    ['cache', () => weatherCache.getLastKnown(location)]
  ]
);
```

### 3. State Persistence
- Auto-save session state every 5 minutes
- Crash recovery via state files
- Rollback mechanism for corrupted data

### 4. Network Issues
- Exponential backoff with jitter
- Circuit breaker pattern for repeated failures
- Offline mode detection and graceful degradation

### 5. File System Safety
- Check disk space before writes
- Atomic file operations (write to temp, then rename)
- Backup critical files before modification

## Test Cases

### Weather Service Tests
- [ ] Primary service timeout
- [ ] All services down
- [ ] Invalid location format
- [ ] Network completely offline
- [ ] Partial response (incomplete data)

### Memory File Tests
- [ ] Corrupted MEMORY.md
- [ ] Disk full during write
- [ ] Concurrent access conflicts
- [ ] Missing memory directory

### Tool Execution Tests
- [ ] Command not found
- [ ] Command hangs/timeout
- [ ] Permission denied
- [ ] Resource exhaustion (CPU/memory)

## Next Steps
1. Implement base error handling utilities
2. Create test harness
3. Add monitoring/alerting
4. Build self-diagnostic tools