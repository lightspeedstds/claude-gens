# Agent Protocol

Every agent in this ecosystem follows this protocol. It exists in one place so all agents benefit when it improves — no need to re-edit individual agent files.

---

## 1. State — load at startup

Every agent reads its state file before doing any work:

```bash
STATE="/Users/kasra/Desktop/claude gens for claude/_shared/state/[agent-name].json"
cat "$STATE" 2>/dev/null || echo '{"last_run":null}'
```

Use the state to skip work already done. The specific fields depend on agent type (see section 4).

**If state is missing or malformed:** proceed as if running for the first time. Do not error out.

---

## 2. State — write at finish

Every agent writes updated state after completing its work:

```bash
STATE="/Users/kasra/Desktop/claude gens for claude/_shared/state/[agent-name].json"
cat > "$STATE" << 'STATEEOF'
{
  "last_run": "[$(date -u +%Y-%m-%dT%H:%M:%SZ)]",
  "last_run_summary": "[one-line summary of what was done]",
  ...agent-specific fields...
}
STATEEOF
```

Write state even if the run produced no results — the timestamp itself prevents redundant re-runs.

---

## 3. Knowledge base — cross-agent facts

Significant discoveries that other agents could benefit from go into the shared knowledge base:

```bash
KNOWLEDGE="/Users/kasra/Desktop/claude gens for claude/_shared/knowledge.md"
```

**Read it on startup** if your work could overlap with what another agent has already found.
**Write to it** when you discover something durable and broadly useful (not run-specific output).

Format for writing:
```markdown
## [TIMESTAMP] [agent-name] — [fact category]
[The fact, stated as a reusable truth]
_Expires: [date or "never" or "on next [agent-name] run"]_
```

Examples of what belongs here:
- "User's Downloads folder is 47GB and hasn't been cleaned since 2024"
- "YouTube channel X has 2.3M subs and uploads 3x/week (scout run 2026-03-27)"
- "Chrome DevTools MCP tools: [list]" (so mcp-wrapper-factory doesn't re-fetch)
- "Gmail MCP auth token is valid as of [date]"

Examples of what does NOT belong here:
- Run-specific output (goes in the agent's own state file)
- Error logs (go in problems.md)
- Temporary findings

---

## 4. State patterns by agent type

### Pattern A — File scanners
_(stale-file-hunter, storage-cleaner, corrupted-file-scanner)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "scanned_files": {
    "/absolute/path/to/file": {
      "mtime": 1234567890,
      "size": 102400,
      "result": "clean | stale | corrupt | suspect",
      "scanned_at": "ISO timestamp"
    }
  }
}
```

**Skip logic:** for each candidate file, run:
```bash
stat -f "%m" "/path/to/file"
```
If the returned mtime matches `scanned_files[path].mtime`, skip — the file hasn't changed. Only scan new or modified files.

**Staleness TTL:** re-scan everything unconditionally after 30 days regardless of mtime, since "stale" classification depends on elapsed time, not file content.

---

### Pattern B — Web researchers
_(researcher, verifier, youtube-channel-scout)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "url_cache": {
    "https://example.com/page": {
      "fetched_at": "ISO timestamp",
      "content_hash": "first 64 chars of content as fingerprint",
      "ttl_hours": 24
    }
  },
  "query_cache": {
    "search query string": {
      "fetched_at": "ISO timestamp",
      "result_summary": "...",
      "ttl_hours": 6
    }
  }
}
```

**Skip logic:** before fetching a URL or running a search query, check if it's in the cache and within TTL:
```
if cache[url].fetched_at + ttl_hours > now → use cached result, skip fetch
```

**TTL guidelines:**
- Breaking news / live data: 1h
- Channel/repo stats: 24h
- Package READMEs / documentation: 7 days
- Static reference material: 30 days

---

### Pattern C — Gmail agents
_(gmail-inbox-triage, gmail-search-assistant)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "last_fetch_time": "ISO timestamp",
  "seen_message_ids": ["id1", "id2"]
}
```

**Skip logic:** append `after:[last_fetch_time as YYYY/MM/DD]` to Gmail search queries so only new messages are fetched. Compare returned IDs against `seen_message_ids` to filter anything already processed.

Update `last_fetch_time` and `seen_message_ids` after every run.

---

### Pattern D — MCP tools
_(mcp-installer, mcp-wrapper-factory)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "packages": {
    "package-name": {
      "readme_fetched_at": "ISO timestamp",
      "readme_hash": "first 64 chars",
      "tools_extracted": ["tool1", "tool2"],
      "agents_generated": ["agent-name-1", "agent-name-2"],
      "install_verified_at": "ISO timestamp"
    }
  }
}
```

**Skip logic:**
- mcp-wrapper-factory: if `packages[name].agents_generated` is non-empty and README hash is unchanged → skip regenerating
- mcp-installer: if `packages[name].install_verified_at` exists and is < 7 days old → skip re-verifying install

---

### Pattern E — Real-time tools
_(ram-optimizer, page-debugger, performance-auditor, ui-inspector)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "history": [
    { "run_at": "ISO timestamp", "finding": "one-line summary" }
  ]
}
```

These agents analyze live system/browser state — caching doesn't make sense. State is kept only to maintain a run history (last 10 runs) so the user can see trends ("RAM was high 3 runs in a row").

Keep `history` to the last 10 entries. Drop oldest when adding new.

---

### Pattern F — Meta agents
_(agent-supervisor, parallel-orchestrator)_

```json
{
  "last_run": "ISO timestamp",
  "last_run_summary": "...",
  "last_scores": {
    "agent-name": {
      "tier": "thriving | stable | struggling | critical | untested",
      "error_count": 0,
      "resolution_rate": 1.0,
      "scored_at": "ISO timestamp"
    }
  }
}
```

**Skip logic:** agent-supervisor only re-scores agents whose `problems.md` entry count has changed since `last_scores[name].scored_at`.

---

## 5. Freshness check — skip entire run if recent

If a run is triggered but state shows the agent ran recently with no new inputs, tell the user and exit early:

```
[agent-name] last ran [X minutes/hours/days] ago.
Last result: [last_run_summary]
Nothing new to process. Run again with "force" to override.
```

**Default freshness thresholds:**

| Agent type | Skip if last run was within |
|------------|----------------------------|
| File scanners | 24 hours |
| Web researchers | 6 hours |
| Gmail agents | 30 minutes |
| MCP tools | 7 days |
| Real-time tools | Never skip (always run) |
| Meta agents | 1 hour |

---

## 6. Problems — unchanged from existing protocol

Write errors to `_shared/problems.md` using the format already defined there. State and problems are separate concerns — state tracks normal operation, problems tracks failures.

---

## 7. Rules

- Never write secrets, API keys, or credentials into state files
- Never grow `scanned_files` unboundedly — prune entries for paths that no longer exist
- State files are machine-readable JSON only — no comments, no markdown
- If writing state would fail (disk full, permissions), log to problems.md and continue — never let state write failure crash the agent's primary output
