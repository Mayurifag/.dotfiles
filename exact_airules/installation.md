# Installation and Deployment

- Before installs/deployments/upgrades, research telemetry, analytics, usage/crash reporting, diagnostics, and metrics
  in official docs/source for the selected version; self-hosted/open-source does not imply telemetry-free.
- Disable optional vendor reporting/unnecessary collection through supported settings, preferably before first start; no
  approval needed if functionality is preserved. Cover installers, services, clients, and bundled components.
- Persist opt-outs in authoritative config/deployment source. Verify exact flags, env vars, config keys, defaults, and
  coverage; never invent settings.
- Preserve necessary traffic, security/update checks, operational logs, useful local metrics, and requested monitoring.
  Explain and ask before opt-outs that break functionality or require invasive patches/network blocking.
- Verify effective settings when practical; configured opt-outs do not prove network silence. In the final response,
  report collection found, opt-outs and locations, unsupported opt-outs, unavoidable/enabled collection, and uncertainty
  or verification gaps. If none was found, name sources checked rather than asserting absence.
