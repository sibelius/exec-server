#!/usr/bin/env bash
set -euo pipefail

# Resolve project directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load .env file if present
if [ -f "$SCRIPT_DIR/.env" ]; then
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

# Auto-detect Node.js binary
find_node() {
  # 1. Explicit env var
  if [ -n "${EXEC_SERVER_NODE:-}" ] && [ -x "$EXEC_SERVER_NODE" ]; then
    echo "$EXEC_SERVER_NODE"
    return
  fi

  # 2. fnm
  if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash 2>/dev/null)" || true
    if command -v node &>/dev/null; then
      command -v node
      return
    fi
  fi

  # 3. nvm
  if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
    source "${NVM_DIR:-$HOME/.nvm}/nvm.sh" --no-use
    nvm use default &>/dev/null || true
    if command -v node &>/dev/null; then
      command -v node
      return
    fi
  fi

  # 4. System node
  if command -v node &>/dev/null; then
    command -v node
    return
  fi

  echo "Error: Node.js not found. Set EXEC_SERVER_NODE or install Node.js." >&2
  exit 1
}

NODE_BIN="$(find_node)"
echo "Using Node.js: $NODE_BIN ($(\"$NODE_BIN\" --version))"

exec "$NODE_BIN" --experimental-strip-types "$SCRIPT_DIR/src/index.ts"
