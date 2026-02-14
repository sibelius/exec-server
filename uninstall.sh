#!/usr/bin/env bash
set -euo pipefail

# exec-server macOS uninstaller

LABEL="com.exec-server"
PLIST_PATH="$HOME/Library/LaunchAgents/${LABEL}.plist"
WWW_BROWSER_DEST="/usr/local/bin/www-browser"

echo "=== exec-server macOS uninstaller ==="
echo ""

# Stop and remove LaunchAgent
if launchctl list "$LABEL" &>/dev/null; then
  echo "Stopping service..."
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
fi

if [ -f "$PLIST_PATH" ]; then
  echo "Removing plist: $PLIST_PATH"
  rm "$PLIST_PATH"
fi

# Remove www-browser
if [ -f "$WWW_BROWSER_DEST" ]; then
  echo "Removing www-browser: $WWW_BROWSER_DEST"
  sudo rm "$WWW_BROWSER_DEST"
fi

echo ""
echo "=== Uninstall complete ==="
