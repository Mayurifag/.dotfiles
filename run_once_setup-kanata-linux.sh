#!/usr/bin/env bash
# run_once_setup-kanata-linux.sh
# Configures kanata keyboard remapper on Linux:
#   - Adds user to 'input' and 'uinput' groups (required by kanata)
#   - Ensures uinput kernel module loads on boot
#   - Enables and starts the kanata systemd user service
#
# NOTE: Group changes (input/uinput) only take effect AFTER you log out and
# log back in. If kanata fails to start with "Permission denied", re-login
# and run: systemctl --user start kanata

set -euo pipefail

[ "$(uname -s)" = "Linux" ] || exit 0

echo "[kanata] Adding user to 'input' group..."
sudo usermod -aG input "$USER"

echo "[kanata] Adding user to 'uinput' group..."
sudo usermod -aG uinput "$USER"

echo "[kanata] Ensuring uinput module loads on boot..."
echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf > /dev/null

echo "[kanata] Loading uinput module now (if not already loaded)..."
sudo modprobe uinput 2>/dev/null || true

echo "[kanata] Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "[kanata] Enabling kanata service..."
systemctl --user enable kanata.service

echo "[kanata] Starting kanata service (may fail if not yet in uinput/input groups)..."
systemctl --user start kanata.service || true

echo ""
echo "======================================================================"
echo "  kanata setup complete."
echo "  If kanata failed to start, LOG OUT and LOG BACK IN, then run:"
echo "    systemctl --user start kanata"
echo "======================================================================"
