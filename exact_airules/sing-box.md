# System Proxies

- Canonical repo: `~/Code/proxies-cfg`; read its `AGENTS.md` and `README.md` first. Run the commands below there.
- Change config generation in `shared/build_config.py`, not generated `linux/runtime/` or other platform runtime files. Never edit `proxies.conf` manually.
- Routing: `make add-domain domain=<domain> proxy=<tag>`, `make add-geosite geosite=<name> proxy=<tag>`, `make remove-domain domain=<domain>`.
- Prefer geosites/categories over domain lists; valid tags: `proxy_ru`, `proxy_it`, `proxy_ipv6_it_novnc`, `direct`. Recheck repo docs before choosing.
- Lifecycle/diagnostics: `make setup`, `make teardown`, `make status`, `make logs`, `make doctor`.
- Linux uses sing-box-extended TUN; keep `auto_redirect` enabled unless deliberately implementing an alternative routing design.
- Docker HTTPS downloads timing out while host-network downloads work can mean UFW INPUT blocks sing-box's transparent redirect, not generic DNS corruption. Check firewall evidence before changing DNS.
- For that firewall issue, use scoped `make linux-firewall`; it does not restart the proxy or fetch subscriptions.
- Persistent rules live in `/etc/ufw/before.rules`, owned by tag `proxies-cfg-docker-https`; setup installs them and teardown removes them.
- Keep the exception Docker-only and IPv4: TCP from `docker0`/`br-*` to the ingress bridge's local address, conntrack DNAT original direction with original destination port `443`.
- Do not hardcode the changing redirect listener port, disable UFW, or add broad host/LAN/WAN allow rules.
- Real proxy secrets (`secrets.json`, `proxies.conf`) use git-crypt with GPG; a `GITCRYPT` header means locked, not corrupt. Use `make unlock` with the existing GPG key; never expose secret contents.
- Avoid repeated `make setup` or config-generation subscription fetches; providers can temporarily return 403 after rapid requests.
