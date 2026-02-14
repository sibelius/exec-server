#!/usr/bin/env bash
set -euo pipefail

# exec-server Linux uninstaller

SERVICE_NAME="exec-server"
SERVICE_PATH="$HOME/.config/systemd/user/${SERVICE_NAME}.service"
WWW_BROWSER_DEST="$HOME/.local/bin/www-browser"
DESKTOP_PATH="$HOME/.local/share/applications/exec-server-browser.desktop"

echo "=== exec-server Linux uninstaller ==="
echo ""

# Stop and disable systemd service
if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
  echo "Stopping service..."
  systemctl --user stop "$SERVICE_NAME"
fi

if systemctl --user is-enabled "$SERVICE_NAME" &>/dev/null; then
  echo "Disabling service..."
  systemctl --user disable "$SERVICE_NAME"
fi

if [ -f "$SERVICE_PATH" ]; then
  echo "Removing unit file: $SERVICE_PATH"
  rm "$SERVICE_PATH"
  systemctl --user daemon-reload
fi

# Remove www-browser
if [ -f "$WWW_BROWSER_DEST" ]; then
  echo "Removing www-browser: $WWW_BROWSER_DEST"
  rm "$WWW_BROWSER_DEST"
fi

# Remove desktop entry
if [ -f "$DESKTOP_PATH" ]; then
  echo "Removing desktop entry: $DESKTOP_PATH"
  rm "$DESKTOP_PATH"
fi

echo ""
echo "=== Uninstall complete ==="
