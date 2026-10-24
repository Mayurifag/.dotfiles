# Installation and Deployment

- Before installing, deploying, or upgrading any app, service, package, CLI, container, or bundled component, research
  its telemetry, analytics, usage reporting, crash uploads, diagnostics, and metrics. Check official docs/source for the
  selected version; do not assume self-hosted or open-source software is telemetry-free.
- Proactively disable optional vendor reporting and unnecessary data collection using supported settings, preferably
  before first start. Do not ask permission for supported opt-outs that preserve requested functionality. Cover
  installers, background services, clients, and bundled components, not only the main server.
- Persist opt-outs in the authoritative configuration or deployment source, not just live state. Verify exact flags,
  environment variables, config keys, defaults, and whether an opt-out covers all reporting; never invent settings.
- Preserve necessary service traffic, security/update checks, operational logs, and explicitly requested monitoring. Do
  not disable useful local metrics merely because they are called metrics. If disabling collection breaks requested
  functionality or requires invasive patches/network blocking, explain the tradeoff and ask first.
- Verify effective settings after installation/deployment where practical. Distinguish configured opt-outs from observed
  network behavior; do not claim no telemetry solely because a flag is set. Report unsupported opt-outs, unavoidable
  collection, and verification gaps.
- In the final response, state what reporting was found, what was disabled and where, and what remains enabled or
  uncertain. If none was found, name the sources checked rather than claiming absence without evidence.
