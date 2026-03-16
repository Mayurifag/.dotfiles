#!/usr/bin/env bash
# run_once_setup-kanata-macos.sh
# Configures kanata keyboard remapper on macOS:
#   - Creates launchd plists for kanata, Karabiner-VirtualHIDDevice-Daemon,
#     and Karabiner-VirtualHIDDevice-Manager
#   - Bootstraps and enables all three daemons via launchctl
#   - Creates log directory for kanata
#
# PREREQUISITES:
#   - kanata installed via Homebrew: brew install kanata
#   - Karabiner-DriverKit-VirtualHIDDevice installed:
#     https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/tree/main/dist
#   - Driver approved in System Settings > Privacy & Security
#
# NOTE: The Karabiner-DriverKit driver requires manual approval in System
# Settings after installation. This script cannot automate that step.

set -euo pipefail

[ "$(uname -s)" = "Darwin" ] || exit 0

KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CFG="/Users/$USER/.config/kanata/kanata.kbd"
PLIST_DIR="/Library/LaunchDaemons"
LOG_DIR="/Library/Logs/Kanata"

VHID_DAEMON_APP="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
VHID_MANAGER_APP="/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"

# ── 1. Create log directory ──────────────────────────────────────────────────
echo "[kanata] Creating log directory: $LOG_DIR"
sudo mkdir -p "$LOG_DIR"

# ── 2. Write kanata launchd plist ────────────────────────────────────────────
echo "[kanata] Writing kanata launchd plist..."
sudo tee "$PLIST_DIR/com.jtroo.kanata.plist" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jtroo.kanata</string>

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

# ── 3. Write Karabiner VirtualHIDDevice Daemon plist ─────────────────────────
echo "[kanata] Writing Karabiner VirtualHIDDevice Daemon plist..."
sudo tee "$PLIST_DIR/org.pqrs.karabiner.vhid-daemon.plist" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.pqrs.karabiner.vhid-daemon</string>

    <key>ProgramArguments</key>
    <array>
        <string>$VHID_DAEMON_APP</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# ── 4. Write Karabiner VirtualHIDDevice Manager plist ────────────────────────
echo "[kanata] Writing Karabiner VirtualHIDDevice Manager plist..."
sudo tee "$PLIST_DIR/org.pqrs.karabiner.vhid-manager.plist" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.pqrs.karabiner.vhid-manager</string>

    <key>ProgramArguments</key>
    <array>
        <string>$VHID_MANAGER_APP</string>
        <string>activate</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# ── 5. Bootstrap and enable daemons ──────────────────────────────────────────
echo "[kanata] Bootstrapping launchd daemons..."

for plist in com.jtroo.kanata org.pqrs.karabiner.vhid-daemon org.pqrs.karabiner.vhid-manager; do
    # bootout first in case already loaded (idempotent)
    sudo launchctl bootout system/"$plist" 2>/dev/null || true
    sudo launchctl bootstrap system "$PLIST_DIR/$plist.plist"
    sudo launchctl enable system/"$plist"
done

echo "[kanata] Starting daemons..."
sudo launchctl start org.pqrs.karabiner.vhid-daemon
sudo launchctl start org.pqrs.karabiner.vhid-manager
sleep 2
sudo launchctl start com.jtroo.kanata

echo ""
echo "======================================================================"
echo "  kanata macOS setup complete."
echo ""
echo "  If this is a fresh install, you MUST:"
echo "    1. Install Karabiner-DriverKit-VirtualHIDDevice from:"
echo "       https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/tree/main/dist"
echo "    2. Approve the driver in System Settings > Privacy & Security"
echo "    3. Reboot"
echo ""
echo "  Logs: $LOG_DIR/"
echo "  Config: $KANATA_CFG"
echo "======================================================================"
