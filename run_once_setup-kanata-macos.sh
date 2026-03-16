#!/usr/bin/env bash
# run_once_setup-kanata-macos.sh
# Configures kanata keyboard remapper on macOS as a user LaunchAgent.
# Cleans up legacy system LaunchDaemon and redundant VirtualHID plists if present.
#
# PREREQUISITES:
#   - kanata installed via Homebrew: brew install kanata
#   - Karabiner-DriverKit-VirtualHIDDevice installed (manages its own daemons):
#     https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/tree/main/dist
#   - Driver approved in System Settings > Privacy & Security
#
# After running: grant Input Monitoring in
#   System Settings > Privacy & Security > Input Monitoring → add kanata

set -euo pipefail

[ "$(uname -s)" = "Darwin" ] || exit 0

KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CFG="$HOME/.config/kanata/kanata.kbd"
AGENT_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs/Kanata"
PLIST_LABEL="com.jtroo.kanata"

# ── 1. Remove legacy system daemon and redundant VirtualHID plists ─────────────
echo "[kanata] Cleaning up legacy system daemons..."
for svc in com.jtroo.kanata org.pqrs.karabiner.vhid-daemon org.pqrs.karabiner.vhid-manager; do
    sudo launchctl bootout system/"$svc" 2>/dev/null || true
    sudo rm -f "/Library/LaunchDaemons/$svc.plist"
done

# ── 2. Create directories ──────────────────────────────────────────────────────
mkdir -p "$LOG_DIR" "$AGENT_DIR"

# ── 3. Write LaunchAgent plist ─────────────────────────────────────────────────
echo "[kanata] Writing LaunchAgent plist..."
tee "$AGENT_DIR/$PLIST_LABEL.plist" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$KANATA_BIN</string>
        <string>-c</string>
        <string>$KANATA_CFG</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>$LOG_DIR/kanata.out.log</string>

    <key>StandardErrorPath</key>
    <string>$LOG_DIR/kanata.err.log</string>
</dict>
</plist>
EOF

# ── 4. Bootstrap and start user agent ─────────────────────────────────────────
echo "[kanata] Bootstrapping user LaunchAgent..."
GUI_DOMAIN="gui/$(id -u)"
launchctl bootout "$GUI_DOMAIN/$PLIST_LABEL" 2>/dev/null || true
launchctl bootstrap "$GUI_DOMAIN" "$AGENT_DIR/$PLIST_LABEL.plist"
launchctl enable "$GUI_DOMAIN/$PLIST_LABEL"
launchctl kickstart "$GUI_DOMAIN/$PLIST_LABEL"

echo ""
echo "======================================================================"
echo "  kanata macOS setup complete (user LaunchAgent)."
echo ""
echo "  ACTION REQUIRED: Grant Input Monitoring permission to kanata:"
echo "    System Settings > Privacy & Security > Input Monitoring"
echo "    Add: $KANATA_BIN"
echo ""
echo "  Logs: $LOG_DIR/"
echo "  Config: $KANATA_CFG"
echo "======================================================================"
