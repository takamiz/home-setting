#!/bin/bash
# update-ai-tools.sh - Update npm, claude, cursor-agent, and gemini CLIs

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------
# npm itself
# ---------------------------------------------------------------
update_npm() {
    info "Updating npm..."
    if ! command -v npm &>/dev/null; then
        warn "npm not found, skipping"
        return
    fi
    local before
    before=$(npm --version 2>/dev/null || echo "unknown")
    sudo npm install -g npm
    local after
    after=$(npm --version 2>/dev/null || echo "unknown")
    if [[ "$before" != "$after" ]]; then
        success "npm: $before → $after"
    else
        success "npm is up to date ($after)"
    fi
}

# ---------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------
update_claude() {
    info "Updating claude..."

    # If not installed, install via native installer
    if ! command -v claude &>/dev/null; then
        warn "claude not found, installing via native installer..."
        curl -fsSL https://claude.ai/install.sh | bash
        success "claude installed"
        return
    fi

    # If installed via npm (deprecated), migrate to native installer
    if npm list -g @anthropic-ai/claude-code &>/dev/null 2>&1; then
        warn "claude is installed via npm (deprecated). Migrating to native installer..."
        curl -fsSL https://claude.ai/install.sh | bash
        npm uninstall -g @anthropic-ai/claude-code
        success "claude migrated to native installer"
        return
    fi

    local before
    before=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    claude update
    local after
    after=$(claude --version 2>/dev/null | head -1 || echo "unknown")
    if [[ "$before" != "$after" ]]; then
        success "claude: $before → $after"
    else
        success "claude is up to date ($after)"
    fi
}

# ---------------------------------------------------------------
# Cursor Agent CLI
# ---------------------------------------------------------------
update_cursor() {
    info "Updating cursor-agent..."
    if ! command -v cursor-agent &>/dev/null; then
        warn "cursor-agent not found, skipping"
        return
    fi
    local before
    before=$(cursor-agent --version 2>/dev/null || echo "unknown")
    cursor-agent update
    local after
    after=$(cursor-agent --version 2>/dev/null || echo "unknown")
    if [[ "$before" != "$after" ]]; then
        success "cursor-agent: $before → $after"
    else
        success "cursor-agent is up to date ($after)"
    fi
}

# ---------------------------------------------------------------
# Gemini CLI (npm global)
# ---------------------------------------------------------------
update_gemini() {
    info "Updating gemini..."
    if ! command -v npm &>/dev/null; then
        warn "npm not found, skipping gemini"
        return
    fi
    local before
    before=$(gemini --version 2>/dev/null || echo "unknown")
    sudo npm update -g @google/gemini-cli
    local after
    after=$(gemini --version 2>/dev/null || echo "unknown")
    if [[ "$before" != "$after" ]]; then
        success "gemini: $before → $after"
    else
        success "gemini is up to date ($after)"
    fi
}

# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------
TARGETS=("npm" "claude" "cursor" "gemini")

if [[ $# -gt 0 ]]; then
    TARGETS=("$@")
fi

echo "================================================"
echo " AI Tools Updater"
echo "================================================"

for target in "${TARGETS[@]}"; do
    echo ""
    case "$target" in
        npm)    update_npm ;;
        claude) update_claude ;;
        cursor) update_cursor ;;
        gemini) update_gemini ;;
        *) warn "Unknown target: $target (available: npm, claude, cursor, gemini)" ;;
    esac
done

echo ""
echo "================================================"
success "Done."
