# OpenClaw Model Fallback Crash Bug

**Date:** 2026-02-10  
**Reporter:** Joshua  
**Severity:** Critical - Gateway crash

## Problem

When both primary and first fallback models hit quota limits, OpenClaw crashes instead of gracefully falling through to remaining fallback models (specifically the free local Ollama model).

## Current Behavior

1. Primary model (Sonnet) hits quota → tries fallback
2. First fallback (Gemini) hits quota → tries second fallback
3. Second fallback (Haiku) hits quota → **crashes gateway instead of trying Ollama**

## Expected Behavior

Should continue through all fallbacks:
1. Sonnet (quota exceeded) → skip
2. Gemini (quota exceeded) → skip
3. Haiku (quota exceeded) → skip
4. **Ollama (local, always available)** → use successfully

## Configuration

```json
"model": {
  "primary": "anthropic/claude-sonnet-4-5",
  "fallbacks": [
    "google/gemini-2.5-flash",
    "anthropic/claude-haiku-4-5",
    "ollama/qwen2.5:0.5b"
  ]
}
```

## Root Cause (Hypothesis)

The error handling in the model selection/API calling code likely:
- Catches quota/rate limit errors
- Attempts to fall back to next model
- **BUT:** Throws an unhandled exception when a fallback also fails, instead of continuing to the next fallback in the chain

## Proposed Fix

Error handling should be:

```javascript
async function callModelWithFallbacks(models, input) {
  let lastError;
  
  for (const model of models) {
    try {
      return await callModel(model, input);
    } catch (error) {
      // Log the error
      console.warn(`Model ${model} failed:`, error.message);
      
      // Check if it's a quota/rate limit error
      if (isQuotaError(error) || isRateLimitError(error)) {
        lastError = error;
        // Try next fallback
        continue;
      }
      
      // For other errors, maybe still try fallback?
      lastError = error;
      continue;
    }
  }
  
  // All models failed
  throw new Error(`All models exhausted. Last error: ${lastError?.message}`);
}
```

## Reproduction

1. Exhaust Anthropic Claude quota
2. Exhaust Google Gemini quota
3. Make a request
4. Gateway crashes when Haiku also fails/is exhausted

## Impact

- Complete service outage when primary + first fallback are exhausted
- Gateway crash requires manual restart
- Local free model (Ollama) is available but never reached

## Files to Investigate

Based on dist structure:
- `/opt/homebrew/lib/node_modules/openclaw/dist/agent-CiNnCBoO.js` (line 582: fallbacksOverride)
- `/opt/homebrew/lib/node_modules/openclaw/dist/pi-embedded-helpers-*.js` (model API calls)
- `/opt/homebrew/lib/node_modules/openclaw/dist/reply-B_4pVbIX.js` (error handling)

## Temporary Workaround

1. Move Ollama higher in fallback chain
2. Or: Set a lower-cost model as primary during high-usage periods
3. Monitor quotas manually and restart gateway when needed

## Related

This might also affect:
- Subagent model selection
- Image model fallbacks
- Any other multi-model failover scenarios
