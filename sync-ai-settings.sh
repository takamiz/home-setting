#!/bin/bash

# Repository directory
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="$HOME"

# Sync .claude (excluding heavy/sensitive data)
rsync -av --progress \
  --exclude="cache/" \
  --exclude="debug/" \
  --exclude="image-cache/" \
  --exclude="paste-cache/" \
  --exclude="plugins/" \
  --exclude="projects/" \
  --exclude="telemetry/" \
  --exclude="session-env" \
  --exclude="history.jsonl" \
  --exclude="file-history" \
  --exclude=".credentials.json" \
  --exclude="backups/" \
  --exclude="journal/" \
  --exclude="plans/" \
  --exclude="shell-snapshots/" \
  --exclude="tasks/" \
  --exclude="todos/" \
  "$HOME_DIR/.claude/" "$REPO_DIR/.claude/"

# Sync .gemini (excluding heavy/sensitive data and worker data)
rsync -av --progress \
  --exclude="tmp/" \
  --exclude="history/" \
  --exclude="antigravity/" \
  --exclude="google_accounts.json" \
  --exclude="oauth_creds.json" \
  --exclude="state.json" \
  "$HOME_DIR/.gemini/" "$REPO_DIR/.gemini/"

echo "Sync completed!"
