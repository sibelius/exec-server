#!/usr/bin/env bash
set -euo pipefail

# exec-server macOS installer
# Installs as a LaunchAgent (runs as current user on login)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.exec-server"
PLIST_PATH="$HOME/Library/LaunchAgents/${LABEL}.plist"
WWW_BROWSER_DEST="/usr/local/bin/www-browser"

echo "=== exec-server macOS installer ==="
echo ""

# Ensure we're on macOS
if [ "$(uname)" != "Darwin" ]; then
  echo "Error: This installer is for macOS. Use install-linux.sh for Linux."
  exit 1
fi

# Auto-detect Node.js (same logic as start-exec-server.sh)
find_node() {
  if [ -n "${EXEC_SERVER_NODE:-}" ] && [ -x "$EXEC_SERVER_NODE" ]; then
    echo "$EXEC_SERVER_NODE"
    return
  fi
  if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash 2>/dev/null)" || true
    if command -v node &>/dev/null; then
      command -v node
      return
    fi
  fi
  if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh" --no-use
    nvm use default &>/dev/null || true
    if command -v node &>/dev/null; then
      command -v node
      return
    fi
  fi
  if command -v node &>/dev/null; then
    command -v node
    return
  fi
  echo "Error: Node.js not found. Set EXEC_SERVER_NODE or install Node.js." >&2
  exit 1
}

NODE_BIN="$(find_node)"
echo "Node.js: $NODE_BIN ($("$NODE_BIN" --version))"
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

# Unload existing service if present
if launchctl list "$LABEL" &>/dev/null; then
  echo ""
  echo "Stopping existing service..."
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
fi

# Generate LaunchAgent plist
echo ""
echo "Creating LaunchAgent: $PLIST_PATH"
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_DIR}/start-exec-server.sh</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/tmp/${LABEL}.stdout</string>
    <key>StandardErrorPath</key>
    <string>/tmp/${LABEL}.stderr</string>

    <key>WorkingDirectory</key>
    <string>${SCRIPT_DIR}</string>
</dict>
</plist>
EOF

# Load service
echo "Starting service..."
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

# Install www-browser
echo ""
echo "Installing www-browser to $WWW_BROWSER_DEST"
sudo cp "$SCRIPT_DIR/www-browser" "$WWW_BROWSER_DEST"
sudo chmod +x "$WWW_BROWSER_DEST"

# Summary
echo ""
echo "=== Installation complete ==="
echo ""
echo "  Service: $LABEL (LaunchAgent)"
echo "  Plist:   $PLIST_PATH"
echo "  Logs:    /tmp/${LABEL}.stdout, /tmp/${LABEL}.stderr"
echo "  Browser: $WWW_BROWSER_DEST"
echo ""
echo "Test with:"
echo "  curl http://localhost:${EXEC_SERVER_PORT:-7771}/"
echo ""
echo "Uninstall with:"
echo "  ./uninstall.sh"
