# macOS maintenance

## SD card sleep protection

On macOS 27.0.1, the built-in SD reader dropped `/Volumes/sdcard` during hibernation resume before APFS could finish
pending transactions. The [sleep guard](sdcard-sleep-guard.c) prevents idle sleep while the volume is mounted writable
and requests a full flush before forced sleep. It cannot block lid-close sleep or guarantee that the flush completes.

Keep the guard for this storage setup. Reassess it if the storage changes or repeated sleep and hibernation tests show
that the volume stays mounted and retains completed writes without the guard.

## LaunchAgent reloads

The FineDisplay and SD card setup scripts retry `launchctl bootstrap` once after a short delay. On macOS 27.0.1, the
first bootstrap immediately after unloading FineDisplay returned error 5. A later attempt with the same plist and binary
succeeded. A failed retry stops the setup with an error.
