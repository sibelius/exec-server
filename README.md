# exec-server

A lightweight HTTP server that executes shell commands. Designed as a bridge between a remote SSH session (e.g., a Linux dev server) and your local macOS machine — letting you open URLs, copy to clipboard, and run commands locally from a remote terminal.

## Quick Start

```bash
# Install dependencies
pnpm install

# Start in development mode (with auto-reload)
pnpm dev

# Start in production mode
pnpm start
```

The server listens on `http://127.0.0.1:7771` by default.

## Prerequisites

- Node.js >= 22 (with `--experimental-strip-types` support)
- pnpm (or npm)
- `jq` (for `www-browser` URL encoding)

## Configuration

All settings are configured via environment variables. Create a `.env` file from the example:

```bash
cp .env.example .env
```

| Variable | Default | Description |
|---|---|---|
| `EXEC_SERVER_PORT` | `7771` | Port to listen on |
| `EXEC_SERVER_HOST` | `127.0.0.1` | Host/interface to bind to |
| `EXEC_SERVER_TIMEOUT` | `30000` | Command timeout in milliseconds |
| `EXEC_SERVER_NODE` | *(auto-detected)* | Path to Node.js binary |

## API

### `GET /`

Health check. Returns `working`.

```bash
curl http://localhost:7771/
```

### `GET /exec?command=<command>`

Execute a shell command and return the result as JSON.

```bash
# Simple command
curl "http://localhost:7771/exec?command=echo%20hello"

# Open a URL in the default browser
curl "http://localhost:7771/exec?command=open%20https://github.com"

# Copy text to clipboard
curl "http://localhost:7771/exec?command=echo%20Hello%20|%20pbcopy"
```

Response:

```json
{
  "success": true,
  "stdout": "hello\n",
  "stderr": ""
}
```

## Install as a Service

### macOS (LaunchAgent)

```bash
./install.sh
```

This will:
- Auto-detect Node.js (fnm, nvm, or system)
- Install dependencies if needed
- Create and load a LaunchAgent (`~/Library/LaunchAgents/com.exec-server.plist`)
- Install `www-browser` to `/usr/local/bin`

To uninstall:

```bash
./uninstall.sh
```

### Linux (systemd)

```bash
./install-linux.sh
```

This will:
- Install dependencies if needed
- Create and enable a systemd user service
- Enable lingering for persistence across logouts
- Install `www-browser` to `~/.local/bin`
- Optionally create an xdg-open desktop entry

To uninstall:

```bash
./uninstall-linux.sh
```

## Remote Usage with `www-browser`

The `www-browser` script forwards URL opens from a remote machine to your local exec-server. This is useful when working via SSH and you want `xdg-open` or similar commands to open in your local browser.

On the remote machine, install `www-browser` to your PATH:

```bash
# The install scripts do this automatically, or manually:
cp www-browser ~/.local/bin/www-browser
chmod +x ~/.local/bin/www-browser
```

Then set it as your default browser:

```bash
export BROWSER=www-browser
```

### SSH Tunnel

For security, use an SSH tunnel to forward the port rather than exposing exec-server to the network:

```bash
# From your local machine, create a reverse tunnel:
ssh -R 7771:localhost:7771 user@remote-server

# On the remote machine, www-browser will connect to localhost:7771
# which tunnels back to your local exec-server
```

## Security Warning

**exec-server executes arbitrary shell commands.** Only bind to `127.0.0.1` (the default) and use SSH tunnels for remote access. Never expose this server to the public internet or untrusted networks.
