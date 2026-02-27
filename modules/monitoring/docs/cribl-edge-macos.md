# Cribl Edge on macOS (Native Installation)

Native Cribl Edge installation for collecting logs from macOS hosts.

## Installation

Cribl Edge is installed via the Cribl Cloud enrollment script:

```bash
sudo curl 'https://YOUR_ORG.cribl.cloud/init/install-edge.sh?group=default_fleet&token=YOUR_TOKEN&user=cribl&user_group=cribl' | sudo bash -
```

This installs to `/opt/cribl/` and creates a `cribl` user.

## Full Disk Access (FDA) Workaround

macOS requires Full Disk Access for reading files in protected directories
(like user home folders). However, macOS FDA only accepts application bundles (.app),
not raw binaries.

### Problem

- Cribl Edge is installed as `/opt/cribl/bin/cribl` (raw binary)
- macOS System Settings silently rejects raw binaries from FDA
- The launchd service runs the binary directly

### Solution: App Bundle Wrapper

Create a minimal .app bundle that wraps the Cribl binary:

```bash
# 1. Create app bundle structure
sudo mkdir -p /Applications/CriblEdge.app/Contents/MacOS

# 2. Create wrapper script
sudo tee /Applications/CriblEdge.app/Contents/MacOS/cribl > /dev/null << 'EOF'
#!/bin/bash
exec /opt/cribl/bin/cribl "$@"
EOF
sudo chmod 755 /Applications/CriblEdge.app/Contents/MacOS/cribl

# 3. Create Info.plist
sudo tee /Applications/CriblEdge.app/Contents/Info.plist > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>cribl</string>
    <key>CFBundleIdentifier</key>
    <string>io.cribl.edge</string>
    <key>CFBundleName</key>
    <string>Cribl Edge</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF
```

### Grant FDA

1. Open **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Click **+** button
3. Navigate to `/Applications/`
4. Select **CriblEdge.app** and click **Open**
5. Ensure the toggle is ON

### Update launchd to Use Wrapper

The launchd service must launch through the FDA-enabled wrapper:

```bash
# 1. Stop the service
sudo launchctl unload /Library/LaunchDaemons/io.cribl.plist

# 2. Backup original plist
sudo cp /Library/LaunchDaemons/io.cribl.plist /Library/LaunchDaemons/io.cribl.plist.backup

# 3. Update plist to use wrapper
sudo sed -i '' 's|/opt/cribl/bin/cribl|/Applications/CriblEdge.app/Contents/MacOS/cribl|' /Library/LaunchDaemons/io.cribl.plist

# 4. Restart the service
sudo launchctl load /Library/LaunchDaemons/io.cribl.plist
```

### Verify FDA is Working

```bash
# Check if Cribl can read protected files (replace $USER with your username)
sudo -u cribl cat /Users/$USER/.claude/logs/mcp.jsonl | head -1
```

If FDA is working, this will output JSON. If not, you'll get "Operation not permitted".

## Known Limitations

Per [Cribl Edge macOS documentation](https://docs.cribl.io/edge/edge-macos/):

> "Edge on macOS does not include support for system metrics or system state at this time."

macOS Cribl Edge is in **Preview** and only supports:

- File monitoring (with FDA)
- Log collection (with FDA)

For system metrics (CPU, memory, disk, network), use **Telegraf** instead.

## Ports

| Port | Purpose |
|------|---------|
| 9420 | API / OTEL input |
| 9000 | Web UI |

## Service Management

```bash
# Start
sudo launchctl load /Library/LaunchDaemons/io.cribl.plist

# Stop
sudo launchctl unload /Library/LaunchDaemons/io.cribl.plist

# Check status
sudo launchctl list | grep cribl

# View logs
tail -f /opt/cribl/log/cribl.log
```

## Updating After Cribl Upgrades

If Cribl Edge auto-updates, the wrapper still points to the updated binary (via exec).
No changes needed unless the installation path changes.

If the launchd plist is overwritten during an upgrade, re-run the sed command above.
