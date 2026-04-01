# Claude Gens — Project Rules

This directory contains a library of Claude agents. When working inside this project, follow the routing rules below — use agents automatically based on task type without waiting for Kasra to name them.

---

## Auto-routing: use these agents without being told

| When the task involves... | Use this agent |
|--------------------------|---------------|
| Files not accessed in a long time, iCloud cleanup, stale files | `agents/file-management/stale-file-hunter` |
| Duplicate files, junk files, storage full, disk cleanup | `agents/file-management/storage-cleaner` |
| Broken, corrupt, or suspect files | `agents/file-management/corrupted-file-scanner` |
| A bash command failing or erroring | `agents/utility/bash-debugger` |
| A script looping, tokens draining, repeated calls | `agents/utility/bash-repeat-checker` |
| Sending emails, drafting emails, email blasts | `agents/mcp-powered/gmail/multi-person-gmail-blaster` |
| Searching or triaging inbox | `agents/mcp-powered/gmail/gmail-inbox-triage` |
| Labelling Finding Billy reply emails | `agents/mcp-powered/gmail/finding-billy-labeler` |
| Searching for information, research, web lookups | `agents/research/` (pick the most relevant) |
| Text going into emails or documents (check for encoding issues) | `agents/utility/text-sanitizer` — always run before sending |
| Any task that produces visible output (emails sent, files changed, etc.) | `agents/utility/screenshot-reporter` — run at the end |
| User message is vague, uses "it/that/the thing" with no clear referent | `agents/utility/context-manager` — ask one clarifying question |
| Generating HTML button pages with ElevenLabs audio for GitHub/static hosting | `agents/mcp-powered/elevenlabs/elevenlabs-github-exporter` |
| Removing background from an image | `agents/mcp-powered/removebg/removebg` |
| Converting text to speech, generating voiceover | `agents/mcp-powered/elevenlabs/elevenlabs-tts` |

---

## Gmail accounts

- **Personal account** → use `mcp__google-workspace__*` tools
- **Lightspeed Studios** (`studios.lightspeed20@gmail.com`) → use `mcp__google-workspace-lightspeed__*` tools
- Default to personal unless Kasra says "from Lightspeed" or the context is clearly studio-related

---

## Text sanitizer rule

Always run `agents/utility/text-sanitizer` on email body + subject before sending. Show Kasra the sanitized output and wait for approval before calling any send tool.

---

## Screenshot rule

After completing any task with visible results, run `agents/utility/screenshot-reporter` with a label describing what was done. Do this automatically — do not ask.

---

## API keys

Never paste, log, or echo API keys. Store them in `~/.claude/scripts/.env` and reference by variable name only. If Kasra pastes a key in chat, warn immediately and advise revocation.

---

## Agent output

Agents write state to `_shared/state/<agent-name>.json` and log errors to `_shared/problems.md`. Check `problems.md` at the start of any agent run.

---

## Shared knowledge

Durable discoveries go in `_shared/knowledge.md`. Read it before starting research or file scans to avoid re-doing known work.
