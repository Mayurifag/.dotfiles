# Homelab

- For shared homelab topology and infrastructure managed by `~/Code/mayurifag.ru`, read its `AGENTS.md` before acting.
  Work in the requested or component-owning repository for standalone projects.
- For shared topology, read `~/Code/mayurifag.ru/HOMELAB.md` for router access/DNS, Proxmox, guests, private DNS/TLS,
  NetBird, and deployment procedures. Treat it as the source of truth for its scope; do not duplicate private
  infrastructure details in global rules.
- `HOMELAB.md`, `airules/home-assistant.md`, and `homelab/home-assistant/` are git-crypt protected. Unlock locally using
  `~/airules/git-crypt.md`; never replace encrypted content when it is unreadable.
- Home Assistant, HomeKit, dashboards, vacuum -> also read `~/Code/mayurifag.ru/airules/home-assistant.md`.
- Router credentials and other passwords -> follow `~/airules/passwords.md` and look up the exact URL documented in
  `HOMELAB.md`. Never put credentials in commands, logs, or unencrypted files.
- For infrastructure managed by `mayurifag.ru`, follow its deployment and read-only debugging rules; keep its changes
  and updated operational notes there. Do not run VPS bootstrap on existing homelab hosts.
