#!/usr/bin/env bash
set -euo pipefail

# exec-server Linux installer
# Installs as a systemd user service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="exec-server"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_PATH="$SERVICE_DIR/${SERVICE_NAME}.service"
WWW_BROWSER_DEST="$HOME/.local/bin/www-browser"

echo "=== exec-server Linux installer ==="
echo ""

# Ensure we're on Linux
if [ "$(uname)" != "Linux" ]; then
  echo "Error: This installer is for Linux. Use install.sh for macOS."
  exit 1
fi

# Check for systemd
if ! command -v systemctl &>/dev/null; then
  echo "Error: systemd is required."
  exit 1
fi

echo "Project: $SCRIPT_DIR"

# Install dependencies if needed
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
  echo ""
  echo "Installing dependencies..."
  if command -v pnpm &>/dev/null; then
    (cd "$SCRIPT_DIR" && pnpm install)
  elif command -v npm &>/dev/null; then
    (cd "$SCRIPT_DIR" && npm install)
  else
    echo "Error: pnpm or npm is required to install dependencies."
    exit 1
  fi
fi

# Stop existing service if running
if systemctl --user is-active "$SERVICE_NAME" &>/dev/null; then
  echo ""
  echo "Stopping existing service..."
  systemctl --user stop "$SERVICE_NAME"
fi

# Generate systemd user service
echo ""
echo "Creating systemd user service: $SERVICE_PATH"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_PATH" <<EOF
[Unit]
Description=exec-server - HTTP command execution server
After=network.target

[Service]
Type=simple
WorkingDirectory=${SCRIPT_DIR}
ExecStart=${SCRIPT_DIR}/start-exec-server.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Reload and start
echo "Starting service..."
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user start "$SERVICE_NAME"

# Enable lingering so service runs without active login session
echo "Enabling user lingering..."
loginctl enable-linger "$(whoami)" 2>/dev/null || true

# Install www-browser
echo ""
echo "Installing www-browser to $WWW_BROWSER_DEST"
mkdir -p "$(dirname "$WWW_BROWSER_DEST")"
cp "$SCRIPT_DIR/www-browser" "$WWW_BROWSER_DEST"
chmod +x "$WWW_BROWSER_DEST"

# Optionally generate xdg-open desktop entry
read -rp "Create xdg-open desktop entry for www-browser? [y/N] " CREATE_DESKTOP
if [[ "${CREATE_DESKTOP,,}" == "y" ]]; then
  DESKTOP_DIR="$HOME/.local/share/applications"
  mkdir -p "$DESKTOP_DIR"
  cat > "$DESKTOP_DIR/exec-server-browser.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=exec-server Browser
Exec=${WWW_BROWSER_DEST} %u
Terminal=false
Type=Application
MimeType=x-scheme-handler/http;x-scheme-handler/https;
EOF
  xdg-mime default exec-server-browser.desktop x-scheme-handler/http 2>/dev/null || true
  xdg-mime default exec-server-browser.desktop x-scheme-handler/https 2>/dev/null || true
  echo "Desktop entry created at $DESKTOP_DIR/exec-server-browser.desktop"
fi

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo ""
  echo "NOTE: Add ~/.local/bin to your PATH:"
  echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
fi

# Summary
echo ""
echo "=== Installation complete ==="
echo ""
echo "  Service: $SERVICE_NAME (systemd user)"
echo "  Unit:    $SERVICE_PATH"
echo "  Logs:    journalctl --user -u $SERVICE_NAME"
echo "  Browser: $WWW_BROWSER_DEST"
echo ""
echo "Test with:"
echo "  curl http://localhost:${EXEC_SERVER_PORT:-7771}/"
echo ""
echo "Uninstall with:"
echo "  ./uninstall-linux.sh"
