# Shared Knowledge Base

Durable facts for all agents. Read before starting research or API work to avoid re-discovering known constraints.
Format: `## [DATE] [agent] — [topic]` with `_Expires:_` line.

---

## 2026-03-31 [elevenlabs-tts] — FREE TIER CONSTRAINTS
- Model: use `eleven_turbo_v2_5` — `eleven_monolingual_v1` is removed from free tier (422 error)
- Voices: only **premade** voices work on free tier — library/cloned voices return 403
- Alice (premade, free): ID `Xb7hH8MSUJpSbSDYk0k2` — confirmed working
- Rachel ID `21m00Tcm4TlvDq8ikWAM` — blocked on free tier
- API key stored in `~/.claude/scripts/.env` as `$ELEVENLABS_API_KEY`
_Expires: never (until plan changes)_

## 2026-03-31 [removebg] — API CONFIRMED WORKING
- Endpoint: `POST https://api.remove.bg/v1.0/removebg`
- Key in `~/.claude/scripts/.env` as `$REMOVEBG_API_KEY`
- Always returns PNG with transparency — output must be `.png`
- Free tier: up to 0.25 megapixels. `size=full` costs credits — never use unless asked
- Test confirmed: removed background from bidmas screenshot successfully
_Expires: never (unless plan changes)_

## 2026-03-31 [finding-billy-labeler] — GMAIL LABEL FORMAT
- `gmail_modify_labels` requires `add_label_ids` as a **JSON array**, not a string
- Correct: `["Label_1"]` — Wrong: `"Label_1"`
- Label_1 is the Finding Billy replies label (default Gmail label name)
- Labeler runs via launchd every 30 min: `~/Library/LaunchAgents/com.kasra.finding-billy-labeler.plist`
- Script: `~/.claude/scripts/finding-billy-labeler.sh`
_Expires: never_

## 2026-03-31 [multi-person-gmail-blaster] — TEXT SANITIZER REQUIRED
- Always run text-sanitizer before sending emails — learned the hard way (encoding artifacts sent to 8 contacts)
- Show sanitized output to Kasra and wait for explicit approval before calling any send tool
- Rule is now enforced in CLAUDE.md
_Expires: never_

## 2026-03-31 [screenshot-reporter] — SCREENCAPTURE BLOCKED
- `screencapture` fails with "could not create image from display" — Screen Recording permission not granted in macOS Privacy settings
- Fallback: use `mcp__chrome-devtools__take_screenshot` for browser content
- Do not retry screencapture until permission is granted in System Settings > Privacy > Screen Recording
_Expires: until permission granted_

## 2026-04-01 [github-committer] — REPO SETUP
- Claude-gens library repo: `https://github.com/lightspeedstds/claude-gens`
- GitHub Pages site: `https://lightspeedstds.github.io` (repo: `lightspeedstds/lightspeedstds.github.io`)
- GitHub CLI (`gh`) installed and authed as `lightspeedstds` (keyring)
- Git identity for this machine: name `lightspeedstds`, email `lightspeedstds@users.noreply.github.com`
- hello.html + hello.mp3 live at lightspeedstds.github.io — pushed 2026-04-01
_Expires: never_

## 2026-03-29 [mcp-wrapper-factory] — GOOGLE WORKSPACE MCP
- Personal account MCP: `mcp__google-workspace__*` — creds at `~/.workspace-mcp/`
- Lightspeed Studios (`studios.lightspeed20@gmail.com`) MCP: `mcp__google-workspace-lightspeed__*` — creds at `~/.workspace-mcp-lightspeed/`
- Lightspeed auth may still need completing: `GWORKSPACE_CREDS_DIR=~/.workspace-mcp-lightspeed npx -y @alanse/mcp-server-google-workspace`
- Auth token auto-refreshes every 45 min via refresh token
_Expires: never (refresh token persists)_

## 2026-03-31 [stale-file-hunter] — ICLOUD STORAGE
- iCloud Drive Trash emptied 2026-03-31 — freed ~22.75 GB (6 screen recordings)
- iCloud storage was 4.56/5GB before; should now be well under limit
- OneDrive (CloudStorage): ~2.26 GB of stale files remain (Teams recordings, old Office docs) — not yet cleaned
_Expires: 2026-06-30_
