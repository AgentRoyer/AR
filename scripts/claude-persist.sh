#!/usr/bin/env bash
# Keep Claude Code state (conversations, memory, credentials, settings) in
# /workspaces, which survives Codespace stops AND rebuilds, and symlink it
# into every home directory the IDE might run Claude from.
set -euo pipefail

STORE=/workspaces/.claude-home   # outside the git repo, never committed
mkdir -p "$STORE/.claude"
chmod 700 "$STORE"

for H in /home/codespace /root; do
  [ -d "$H" ] || continue

  # ~/.claude : merge any local content into the store, then symlink.
  if [ -d "$H/.claude" ] && [ ! -L "$H/.claude" ]; then
    cp -a --update "$H/.claude/." "$STORE/.claude/"
    rm -rf "$H/.claude"
  fi
  ln -sfn "$STORE/.claude" "$H/.claude"

  # ~/.claude.json : keep whichever copy is newer, back up the other.
  if [ -f "$H/.claude.json" ] && [ ! -L "$H/.claude.json" ]; then
    if [ -f "$STORE/.claude.json" ] && [ "$STORE/.claude.json" -nt "$H/.claude.json" ]; then
      mv "$H/.claude.json" "$H/.claude.json.bak.$(date +%s)"
    else
      [ -f "$STORE/.claude.json" ] && mv "$STORE/.claude.json" "$STORE/.claude.json.bak.$(date +%s)"
      mv "$H/.claude.json" "$STORE/.claude.json"
    fi
  fi
  [ -f "$STORE/.claude.json" ] && ln -sfn "$STORE/.claude.json" "$H/.claude.json"
done

echo "Claude state persisted in $STORE"
