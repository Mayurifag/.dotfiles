# CLAUDE.md

## Communication Style

- Never validate or agree with the user ("you're absolutely right", "perfect!", etc.)
- No apologies or unnecessary politeness
- Minimal explanatory text - provide only essential context
- No preambles or postambles unless requested
- Focus on direct action and results

## Code Quality Requirements

- Fix all linting errors when they occur - do not suppress or ignore them
- Address lint failures immediately rather than continuing with broken code

## Repository Overview

This is a dotfiles repository managed by [chezmoi](https://www.chezmoi.io/), containing cross-platform
configuration files for macOS and Linux (primarily Arch Linux with KDE). The repository uses ejson for
encrypted secrets management and includes automated package installation across multiple package managers.

## Key Patterns

**Cross-Platform Compatibility**: Uses conditional logic for OS-specific configurations
(Darwin vs Linux). Example in aliases: different `make` parallelization based on OS.

**Automated Setup**: `run_after_cz_apply.sh` runs post-installation tasks like symlinking MPV scripts
and bundling antidote plugins.

**Development Tools Integration**: Configured for code editing with VS Code, git operations with
GitKraken/lazygit, and includes specialized tools for media downloading (yt-dlp) and translation.

## Important Files and Locations

- `dot_config/chezmoi/chezmoi.toml` - Chezmoi configuration (VS Code as editor, excludes scripts from diff)
- `exact_zsh/plugins.txt` - Antidote plugin definitions
- `keys.ejson` - Encrypted secrets (requires ejson key at `/opt/ejson/`)
- `dot_claude/settings.json` - Claude Code hooks configuration for automated linting
- `Makefile` - Top-level build automation including all package managers

## Claude Code Hooks

The repository includes automated hooks in `dot_claude/settings.json` that run:

- `markdownlint-cli2` after file edits and before git commits
