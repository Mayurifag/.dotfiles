# System Proxies

- System proxy routing and diagnostics -> `~/Code/proxies-cfg/AGENTS.md` and `README.md`; read them before acting and
  run project commands there.
- Docker HTTPS timeouts while host-network downloads work -> also load those instructions for sing-box/UFW checks, even
  when working outside that repository. Check firewall evidence before changing DNS.
- For changes to macOS route commands or scheduled jobs that run them, test when the target host route is missing.
  Verify that the covering route stays unchanged and that connectivity still works after the next scheduled run.
