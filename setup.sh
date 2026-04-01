#!/bin/bash
# Claude Agents Setup Script
# Run this once after cloning/downloading the project.
# Usage: bash setup.sh
# Or with a custom install path: bash setup.sh /path/to/install

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${CYAN}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
echo "  Claude Agents — Setup"
echo "  ─────────────────────"
echo ""

# ── 1. Determine install path ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -n "$1" ]; then
  INSTALL_DIR="$1"
else
  INSTALL_DIR="$SCRIPT_DIR"
fi

info "Install path: $INSTALL_DIR"

# ── 2. Detect OS ──────────────────────────────────────────────────────────────
OS="unknown"
case "$OSTYPE" in
  darwin*) OS="macos" ;;
  linux*)  OS="linux" ;;
  msys*|cygwin*|mingw*) OS="windows" ;;
esac
info "Detected OS: $OS"

# ── 3. Cross-platform sed helper ──────────────────────────────────────────────
# macOS sed requires `sed -i ''`; GNU sed (Linux) requires `sed -i`
sed_inplace() {
  local file="$1"; shift
  if [ "$OS" = "macos" ]; then
    sed -i '' "$@" "$file"
  else
    sed -i "$@" "$file"
  fi
}

# ── 4. Check prerequisites ────────────────────────────────────────────────────
echo ""
info "Checking prerequisites..."

command -v node >/dev/null 2>&1 || fail "Node.js not found. Install from https://nodejs.org"
ok "Node.js $(node --version)"

command -v npx >/dev/null 2>&1 || fail "npx not found. Reinstall Node.js."
ok "npx available"

command -v claude >/dev/null 2>&1 || fail "Claude Code CLI not found. Install from https://claude.ai/code"
ok "Claude Code CLI found"

# Python check (used by lead-extractor and text-sanitizer)
PYTHON_BIN=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || true)
if [ -z "$PYTHON_BIN" ]; then
  warn "Python not found. lead-extractor and text-sanitizer agents require Python."
  warn "Install from https://python.org — then re-run setup.sh."
else
  PYTHON_VERSION=$("$PYTHON_BIN" --version 2>&1)
  ok "Python found: $PYTHON_VERSION ($PYTHON_BIN)"
fi

# ── 5. Replace hardcoded paths in all agent/shared files ──────────────────────
echo ""
info "Patching agent files with your install path..."

find "$INSTALL_DIR/agents" "$INSTALL_DIR/_shared" -name "*.md" -o -name "*.sh" 2>/dev/null | while read -r file; do
  sed_inplace "$file" \
    -e "s|/Users/[^/]*/Desktop/claude gens for claude|$INSTALL_DIR|g" \
    -e "s|/Users/[^/]*/claude-agents|$INSTALL_DIR|g" \
    -e "s|/home/[^/]*/claude-agents|$INSTALL_DIR|g" \
    2>/dev/null || true
done

ok "All agent paths updated to: $INSTALL_DIR"

# ── 6. Create _shared directories ─────────────────────────────────────────────
echo ""
info "Creating shared directories..."

mkdir -p "$INSTALL_DIR/_shared/state"
mkdir -p "$INSTALL_DIR/_shared/backups"
mkdir -p "$INSTALL_DIR/_shared/retired"
ok "Shared directories ready"

# Initialise problems.md if missing
if [ ! -f "$INSTALL_DIR/_shared/problems.md" ]; then
  cat > "$INSTALL_DIR/_shared/problems.md" << 'EOF'
# Shared Problem Log

All agents write errors here. Format:

```
## [YYYY-MM-DD HH:MM] [agent-name] — ERROR_TYPE
- **Severity:** low / medium / high / critical
- **Task:** what was being attempted
- **Error:** exact error or description
- **Tried:** what was attempted to fix it
- **Resolved:** no
- **Notes:** any extra context
```

Never delete entries — mark resolved with RESOLVED.

---

EOF
  ok "problems.md initialised"
fi

# Initialise knowledge.md if missing
if [ ! -f "$INSTALL_DIR/_shared/knowledge.md" ]; then
  cat > "$INSTALL_DIR/_shared/knowledge.md" << 'EOF'
# Shared Knowledge Base

Cross-agent facts. See _shared/AGENT_PROTOCOL.md section 3 for format.

---

<!-- entries go below this line -->
EOF
  ok "knowledge.md initialised"
fi

# Initialise state files for agents that need them
init_state() {
  local name="$1"
  local initial="$2"
  local path="$INSTALL_DIR/_shared/state/${name}.json"
  if [ ! -f "$path" ]; then
    echo "$initial" > "$path"
    ok "State initialised: ${name}.json"
  fi
}

init_state "parallel-orchestrator"        '{"last_run":null,"patterns":{}}'
init_state "gmail-drafter"                '{"last_run":null,"seen_message_ids":[]}'
init_state "multi-person-gmail-blaster"   '{"last_run":null,"last_recipient_count":0,"last_subject":null}'

# ── 7. Register MCPs with Claude Code ─────────────────────────────────────────
echo ""
info "Registering MCP servers..."

register_mcp() {
  local name="$1"; shift
  if claude mcp list 2>/dev/null | grep -q "^$name:"; then
    warn "$name already registered — skipping"
  else
    claude mcp add -s user "$name" "$@" 2>/dev/null && ok "$name registered" || warn "$name failed to register (install manually)"
  fi
}

register_mcp "chrome-devtools" -- npx -y chrome-devtools-mcp@latest

# Only register Gmail/Calendar local MCPs if not using claude.ai integrations
echo ""
warn "Gmail, Calendar, and Google Workspace require OAuth setup."
warn "See index.html for step-by-step instructions."
echo ""
read -p "  Have you completed Google OAuth setup? (y/n): " OAUTH_DONE

if [[ "$OAUTH_DONE" == "y" || "$OAUTH_DONE" == "Y" ]]; then
  # Gmail
  GMAIL_DIR="$HOME/.gmail-mcp"
  if [ -f "$GMAIL_DIR/gcp-oauth.keys.json" ]; then
    register_mcp "gmail-local" -- npx @gongrzhe/server-gmail-autoauth-mcp
  else
    warn "Gmail: $GMAIL_DIR/gcp-oauth.keys.json not found — skipping"
  fi

  # Google Calendar
  CALENDAR_DIR="$HOME/.calendar-mcp"
  if [ -f "$CALENDAR_DIR/gcp-oauth.keys.json" ]; then
    register_mcp "google-calendar-local" -- npx -y @gongrzhe/server-calendar-autoauth-mcp
  else
    warn "Calendar: $CALENDAR_DIR/gcp-oauth.keys.json not found — skipping"
  fi

  # Google Drive
  GDRIVE_DIR="$HOME/.gdrive-mcp"
  if [ -f "$GDRIVE_DIR/gcp-oauth.keys.json" ]; then
    register_mcp "google-drive" \
      -e "GDRIVE_OAUTH_PATH=$GDRIVE_DIR/gcp-oauth.keys.json" \
      -e "GDRIVE_CREDENTIALS_PATH=$GDRIVE_DIR/credentials.json" \
      -- npx -y @modelcontextprotocol/server-gdrive
  else
    warn "Drive: $GDRIVE_DIR/gcp-oauth.keys.json not found — skipping"
  fi

  # Google Workspace
  WORKSPACE_DIR="$HOME/.workspace-mcp"
  if [ -f "$WORKSPACE_DIR/gcp-oauth.keys.json" ]; then
    read -p "  Enter your Google Cloud CLIENT_ID: " GW_CLIENT_ID
    read -s -p "  Enter your Google Cloud CLIENT_SECRET: " GW_CLIENT_SECRET
    echo ""
    register_mcp "google-workspace" \
      -e "CLIENT_ID=$GW_CLIENT_ID" \
      -e "CLIENT_SECRET=$GW_CLIENT_SECRET" \
      -e "GWORKSPACE_CREDS_DIR=$WORKSPACE_DIR" \
      -- npx -y @alanse/mcp-server-google-workspace
    unset GW_CLIENT_ID GW_CLIENT_SECRET
  else
    warn "Workspace: $WORKSPACE_DIR/gcp-oauth.keys.json not found — skipping"
  fi
else
  warn "Skipping Google MCP registration. Run setup.sh again after OAuth setup."
fi

# ── 8. Verify Claude Code can see the agents ──────────────────────────────────
echo ""
info "Verifying MCP registration..."
claude mcp list 2>/dev/null | grep -E "Connected|connected" | while read -r line; do
  ok "$line"
done

# ── 9. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────"
echo -e "  ${GREEN}Setup complete!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open Claude Code in this folder"
echo "  2. Restart Claude Code to load the new MCPs"
echo "  3. Try: '@parallel-orchestrator research 3 topics in parallel'"
echo ""
echo "  Need help? Open index.html in your browser."
echo ""
