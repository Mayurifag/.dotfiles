# Homelab

- Use `~/Code/mayurifag.ru` as the working repository, even when the request starts elsewhere. Read its `AGENTS.md` before acting.
- Read `HOMELAB.md` there for topology, router access/DNS, Proxmox, guests, private DNS/TLS, NetBird, and deployment procedures. Treat it as the source of truth; do not duplicate private infrastructure details in global rules.
- `HOMELAB.md`, `airules/home-assistant.md`, and `homelab/home-assistant/` are git-crypt protected. Unlock locally using `~/airules/git-crypt.md`; never replace encrypted content when it is unreadable.
- Home Assistant, HomeKit, dashboards, vacuum -> also read the repository's `airules/home-assistant.md`.
- Router credentials and other passwords -> follow `~/airules/passwords.md` and look up the exact URL documented in `HOMELAB.md`. Never put credentials in commands, logs, or unencrypted files.
- Follow repository deployment and read-only debugging rules. Keep infrastructure changes and updated operational notes in that repository; do not run VPS bootstrap on existing homelab hosts.
