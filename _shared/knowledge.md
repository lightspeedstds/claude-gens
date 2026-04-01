# Shared Knowledge Base

Cross-agent facts. Read this on startup if your work might overlap with prior discoveries. Write here when you find something durable that other agents could use.

Format: `## [TIMESTAMP] [agent-name] — [category]` with an `_Expires:_` line.

See `_shared/AGENT_PROTOCOL.md` § 3 for full guidelines.

---

<!-- entries go below this line -->

## 2026-03-29 mcp-wrapper-factory — google-workspace verified
Google Workspace MCP fully working: Sheets create + write confirmed. Gmail send confirmed. Calendar read confirmed.
Auth token at ~/.workspace-mcp/.gworkspace-credentials.json — valid, auto-refreshes every 45min.
_Expires: never (refresh token persists)_

## stale-file-hunter — iCloud Drive full scan (2026-03-31)
- Scanned: ~/Library/Mobile Documents/ (243 files) + ~/Library/CloudStorage/OneDrive-Personal/ (84MB local, large files evicted)
- **CRITICAL: iCloud Drive .Trash has never been emptied** — 22.75 GB in ~/Library/Mobile Documents/.Trash/
  - 6 screen recordings from 2026-03-05 alone = 21.4 GB (9.2G, 4.4G, 4.1G, 3.9G, 782M, 216M)
  - Emptying iCloud Drive trash would immediately free ~22.75 GB — resolves storage crisis
- OneDrive (CloudStorage): 85 stale files (mtime >90 days), ~2.26 GB reclaimable
  - Largest: Teams Chat recordings (1.0GB, 875MB, 183MB, 87MB .mp4s — all cloud-only/evicted)
  - Archive folder: 71.5MB locally present stale files (old .pptx, .docx, .xlsx)
- iCloud Drive proper: only 2 files mtime >90 days (both tiny, 72KB + 2KB — not worth deleting)
- No .icloud placeholder files found (all files are locally present or legitimately small)
- iCloud containers with 0B usage: GarageBand, Music Memos, Pages, Numbers, Automator, Preview, etc.
_Expires: 2026-06-30_
