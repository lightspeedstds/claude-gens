# Agent Problem Log

This file is the shared error memory for all agents in this system.
Every agent reads this on startup and writes here when errors occur.
The `agent-supervisor` reads this file to triage agent health.

**Format rules:**
- One entry per error, newest at the bottom
- Never delete entries — mark them resolved with ✅ instead
- Use consistent severity labels: `low` / `medium` / `high` / `critical`

---

<!-- ENTRIES BEGIN BELOW — do not remove this line -->
