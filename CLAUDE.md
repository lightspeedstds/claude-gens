# Claude Gens — Project Rules

This directory contains a library of Claude agents. Follow the routing rules below — use agents automatically based on task type WITHOUT waiting for Kasra to name them.

---

## Auto-routing: use these agents without being told

| When the task involves... | Use this agent | Notes |
|--------------------------|---------------|-------|
| Files not accessed in a long time, iCloud cleanup, stale files | `agents/file-management/stale-file-hunter` | Run immediately, no setup questions |
| Duplicate files, junk files, storage full, disk cleanup | `agents/file-management/storage-cleaner` | Run immediately, no setup questions |
| Broken, corrupt, or suspect files | `agents/file-management/corrupted-file-scanner` | |
| A bash command failing or erroring | `agents/utility/bash-debugger` | Auto-triggered on any shell error |
| A script looping, tokens draining, repeated calls | `agents/utility/bash-repeat-checker` | |
| Same fix tried 2+ times still not working | `agents/utility/repeat-debugger` | **Always use before trying another fix** |
| Sending emails, drafting emails, email blasts | `agents/mcp-powered/gmail/multi-person-gmail-blaster` | Always run text-sanitizer first |
| Checking inbox, unread emails, what needs replies | `agents/mcp-powered/gmail/gmail-inbox-triage` | Auto-drafts replies for urgent threads |
| Labelling Finding Billy reply emails | `agents/mcp-powered/gmail/finding-billy-labeler` | Runs on 30min launchd schedule |
| Searching for information, research, web lookups | `agents/research/researcher` | Actually fetches and reads pages |
| Text going into emails or documents | `agents/utility/text-sanitizer` | **Always run before any send** |
| Any task that produces visible output | `agents/utility/screenshot-reporter` | **Always run at the end automatically** |
| User message is vague or uses "it/that/the thing" | `agents/utility/context-manager` | Ask one clarifying question |
| Committing and pushing changes to GitHub | `agents/utility/github-committer` | Auto-detects account and SSH alias |
| HTML + audio pages for GitHub Pages | `agents/mcp-powered/elevenlabs/elevenlabs-github-exporter` | |
| Removing background from an image | `agents/mcp-powered/removebg/removebg` | |
| Converting text to speech, generating voiceover | `agents/mcp-powered/elevenlabs/elevenlabs-tts` | |
| User pastes a credential, API key, token, or secret | `agents/utility/sensitive-info-handler` | **Run immediately, do not echo the value** |

---

## Gmail accounts

- **Personal** (`kasramathlover@gmail.com`) → `mcp__google-workspace__*` tools
- **Lightspeed Studios** (`studios.lightspeed20@gmail.com`) → `mcp__google-workspace-lightspeed__*` tools
- Default to personal unless Kasra says "from Lightspeed" or context is clearly studio work

---

## GitHub accounts + SSH aliases

| Account | SSH alias | Repos |
|---------|-----------|-------|
| lightspeedstds | `git@github-lightspeedstds` | claude-gens, lightspeedstds.github.io |
| kkasra10 | `git@github-kkasra10` | personal projects |
| pyprinter | `git@github-pyprinter` | pyprinter.github.io |

Always use SSH remotes, never HTTPS. Keys in `~/.ssh/github_<account>`.

---

## Hard rules (always enforced)

1. **text-sanitizer** — run on every email body + subject before sending. Show sanitized output, wait for approval.
2. **screenshot-reporter** — run at end of every task with visible results. Automatically, without asking.
3. **sensitive-info-handler** — if a credential appears in chat, handle it immediately. Do not echo or repeat the value anywhere.
4. **repeat-debugger** — if the same fix has failed twice, stop guessing and use this agent before trying again.
5. **Never commit `.env` or secrets** — github-committer will unstage them automatically.

---

## Agent output

- State files → `_shared/state/<agent-name>.json`
- Error log → `_shared/problems.md` (check at start of any agent run)
- Durable discoveries → `_shared/knowledge.md` (read before research or file scans)

---

## API keys

Stored in `~/.claude/scripts/.env`. Never paste, log, or echo. Reference by variable name only.

Known keys:
- `ELEVENLABS_API_KEY` — ElevenLabs TTS
- `REMOVEBG_API_KEY` — Remove.bg
- `GOOGLE_CLIENT_ID` — pyprinter request site OAuth
