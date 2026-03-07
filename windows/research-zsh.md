# Research: zsh on native Windows 11

**Question:** Can zsh replace Git Bash as the primary shell on native Windows 11 (outside WSL2)?

## The MSYS2 approach

MSYS2 provides a Unix-like environment on Windows that can run zsh. The path:
install MSYS2, install zsh via `pacman`, configure Windows Terminal to launch the MSYS2 zsh shell.
It works. It's just not worth it.

## Why it's not recommended

- PATH conflicts: MSYS2 uses Unix-style paths (`/usr/bin`) that don't compose with Windows paths -- native tools like winget, mise, and PowerShell break or behave unexpectedly
- Tool compatibility: many CLI tools behave differently or silently misbehave when launched from MSYS2 zsh vs a native Windows environment
- Maintenance overhead: MSYS2 is a separate package ecosystem (`pacman`) to maintain alongside winget
- Still an emulation layer: Windows-native tools expect Windows paths, not POSIX paths -- the impedance mismatch surfaces constantly

## Conclusion

Git Bash covers the daily driver needs (aliases, mise shims, fzf, bash completions) without the fragility.
zsh's extra features don't justify the integration pain on Windows. Use Git Bash.
