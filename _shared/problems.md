# Agent Problem Log

One entry per error. Mark resolved with ✅. Newest at bottom. Never delete entries.
Severity: `low` / `medium` / `high` / `critical`

---

<!-- ENTRIES BEGIN BELOW -->

## [2026-03-31 ~14:00] [elevenlabs-tts] — API-KEY-INVALID
- **Severity:** high
- **Task:** TTS generation for hello button
- **Error:** 401 Unauthorized — old key had been revoked
- **Tried:** sourcing from .env, confirming variable set
- **Resolved:** ✅ yes — user provided new key, updated ~/.claude/scripts/.env

## [2026-03-31 ~14:10] [elevenlabs-tts] — MODEL-DEPRECATED
- **Severity:** medium
- **Task:** TTS generation
- **Error:** `eleven_monolingual_v1` removed from free tier, returns 422
- **Tried:** default model from docs
- **Resolved:** ✅ yes — switched to `eleven_turbo_v2_5`

## [2026-03-31 ~14:15] [elevenlabs-tts] — VOICE-BLOCKED
- **Severity:** medium
- **Task:** TTS with Rachel voice
- **Error:** Rachel (library voice) requires paid plan — returns 403
- **Tried:** Rachel voice ID `21m00Tcm4TlvDq8ikWAM`
- **Resolved:** ✅ yes — switched to Alice (premade voice, free tier safe, ID: `Xb7hH8MSUJpSbSDYk0k2`)

## [2026-03-31 ~14:30] [screenshot-reporter] — SCREENCAPTURE-PERMISSION-DENIED
- **Severity:** medium
- **Task:** Screenshot after task completion
- **Error:** `screencapture: could not create image from display` — Screen Recording permission not granted
- **Tried:** `screencapture -x output.png`
- **Resolved:** ✅ yes — used `mcp__chrome-devtools__take_screenshot` as fallback

## [2026-03-31 ~14:45] [multi-person-gmail-blaster] — ENCODING-NOT-SANITIZED
- **Severity:** high
- **Task:** Sending Finding Billy update emails
- **Error:** Email sent without running text-sanitizer — user saw `Ã¢Â€Â` encoding artifacts
- **Tried:** Sent directly from template
- **Resolved:** ✅ yes — re-ran sanitizer, showed output to user, resent with approval

## [2026-03-31 ~15:00] [finding-billy-labeler] — LABEL-APPLY-FORMAT-ERROR
- **Severity:** medium
- **Task:** Apply Label_1 to Finding Billy reply threads
- **Error:** `gmail_modify_labels` called with string instead of JSON array for `add_label_ids`
- **Tried:** Passing `"Label_1"` as string
- **Resolved:** ✅ yes — fetched tool schema via ToolSearch, passed `["Label_1"]` as array

## [2026-03-31 ~16:00] [elevenlabs-github-exporter] — AUDIO-BLOCKED-FILE-PROTOCOL
- **Severity:** medium
- **Task:** hello.html button page
- **Error:** Browser blocked audio playback — `file://` protocol blocks `<audio src>` in Chrome/Safari
- **Tried:** External src reference to local hello.mp3
- **Resolved:** ✅ yes — embedded MP3 as base64 data URI for local use; GitHub-hosted version uses external src and works over https

## [2026-03-31 ~17:00] [google-workspace-lightspeed] — LOGIN-REQUIRED
- **Severity:** high
- **Task:** Send email from studios.lightspeed20@gmail.com
- **Error:** Both MCP instances shared ~/.workspace-mcp/ credential store, causing auth collision
- **Tried:** Adding second MCP instance without separate GWORKSPACE_CREDS_DIR
- **Resolved:** partial — created ~/.workspace-mcp-lightspeed/ with separate creds dir; user still needs to complete OAuth in terminal: `GWORKSPACE_CREDS_DIR=~/.workspace-mcp-lightspeed npx -y @alanse/mcp-server-google-workspace`
