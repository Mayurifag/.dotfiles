---
name: upgrade-repo
description: Upgrade the current repository to stable languages, dependencies, toolchains, GitHub Actions, and container images; migrate code, verify, and research improvements. Use for comprehensive repository updates or /upgrade.
---

# Upgrade Repository

Bring all versioned surfaces in the current repository to the newest verified stable versions, including major releases
and required code migrations. Follow repository instructions and relevant airules. This upgrades repository code and
configuration, not unrelated checkouts, global packages, the operating system, or deployed services.

## Boundaries

- Preserve user changes and data. Record initial Git status; stop only where existing work conflicts. Never reset,
  clean, automatically stash, switch branches, or stage changes. Do not pull, commit, push, release, or deploy unless
  requested.
- For projects authored or maintained by the user, raise language, runtime, compiler, SDK, and toolchain versions to the
  newest verified stable releases, including declared minimums and supported-version matrices. Dropping older
  language/runtime versions as part of this upgrade is in scope; explain the support changes before work. Update the
  existing support policy rather than treating old pins or matrices as immutable. Respect explicit repository
  instructions, user constraints, and verified incompatibilities.
- For external projects or uncertain ownership, preserve the project's support policy and ask before dropping supported
  language/runtime versions. A user-owned fork or an isolated contribution does not make the upstream project
  user-owned.
- Major upgrades and their internal migrations are in scope. Explain consequential tradeoffs before work; ask before
  destructive migrations, public API breaks, dropping supported operating systems or architectures, paid services, or
  replacing the project's framework, package manager, or architecture.
- Use stable releases by default, not prereleases, nightly builds, or arbitrary default-branch commits. For an existing
  prerelease or branch dependency, inspect its purpose before replacing it. Retain justified compatibility/security pins
  and report exceptions. Newest does not override a verified incompatibility or security issue.
- Use existing package managers, lockfiles, scripts, codemods, and update configuration. Do not add an updater service,
  permanent helper, dependency, or test framework just for this run. Read scripts before running them; apply relevant
  installation, credential, and telemetry rules. Never print secrets.
- Ask before adopting optional research recommendations, including new or replacement dependencies and unrelated
  refactors. Required upgrade migrations remain in scope.

## Workflow

1. Identify the Git root, project authorship or maintenance from user instructions and repository metadata,
   instructions, workspaces, package managers, and supported environments. Inventory versioned surfaces throughout the
   repository, excluding vendored/generated dependencies: manifests, lockfiles, and their direct and transitive
   packages; language editions, targets, runtime pins, and minimums; compilers, SDKs, package managers, build tools,
   linters, formatters, test tools, and plugins; GitHub workflows and local/composite actions; container base/service
   images and digests; devcontainers; pre-commit, mise/asdf/Volta/Corepack configuration; installation scripts;
   submodule pins; and repository-managed deployment/chart/IaC dependencies. Read existing Renovate/Dependabot policies
   and relevant scripts.
2. Establish a baseline with the existing project checks when practical. Record pre-existing failures. Summarize the
   discovered scope and material migration risks, then proceed with routine upgrades without asking for each package.
3. Query the official registries and upstream release notes for current stable versions and major migration guidance.
   Prefer configured tooling and built-in outdated/update commands; verify their semantics rather than assuming they
   cross major-version ranges. Use authenticated `gh` for GitHub source/releases, never unauthenticated GitHub fetches.
   Account for coupled releases, engines, peer constraints, platform support, yanked versions, and security advisories.
   Upgrade coupled tools and migrate code rather than treating their old pins as permanent incompatibilities.
4. Upgrade in coherent groups so failures can be traced. For user-authored or maintained projects, update
   language/runtime versions, stable language editions and targets, minimum-version declarations, compilers, SDKs, and
   package-manager pins; use the latest stable release, not an older LTS by default. Update matching local setup, CI
   matrices, images, and other declarations together. Update dependency ranges and regenerate lockfiles using the
   existing manager; preserve lockfile ownership, integrity hashes, and reproducibility. Include all workspaces and
   dependency categories, not just production dependencies. Resolve transitive updates through the manager; do not
   hand-edit locks or force incompatible overrides. Remove an obsolete workaround only when its reason no longer holds.
5. For repository upgrades, use `npx actions-up --style semver -r -y --prefer-tags` instead of the default Git Actions
   command, authenticated through `gh`. Preview recursive scan paths first; restrict `--dir` if they include ignored
   dependencies. Compare SHA version comments for major upgrades, which the tool may not flag. Review major-release
   input, output, permission, runner, and runtime changes; include reusable workflows and local action manifests.
   Inspect skipped branch refs and unsupported surfaces separately. Preserve SHA pinning and update version comments;
   never widen token permissions just to make CI pass. Align runner/runtime matrices with the upgraded support policy.
6. Refresh remaining repository-owned pins, container tags and corresponding digests/checksums, and tool configurations.
   Keep local development, CI, containers, and deployment definitions consistent. Do not replace reproducible pins with
   floating `latest`. Advance clean submodules to verified stable upstream releases for user-authored or maintained
   projects when safe; ask before advancing external or dirty submodules and never discard their changes. If a newer
   release cannot satisfy project requirements after feasible migrations, use the newest verified compatible release and
   explain the blocker rather than silently skipping it.
7. Apply required source, configuration, fixture, and test migrations. Use official codemods when suitable and inspect
   their output. Remove deprecated usage affected by upgrades, but avoid unrelated rewrites, formatting churn, or
   feature changes. Do not bump the project's own release version or edit a README unless requested.
8. Run the repository's standard checks: dependency resolution, formatting/lint, type checks, tests, builds, and
   relevant workflow/container validation. Verify the upgraded language/runtime and toolchain versions are actually
   used, not just declared. Fix upgrade-caused failures; never weaken tests, suppress errors, or disable security checks
   to obtain green results. Use existing WSL/container/remote environments for platform-specific checks when
   appropriate. Do not deploy to verify. If push was requested, also wait for CI and inspect its results.
9. After upgrades, research improvement opportunities for every distinct inventoried dependency, including direct and
   transitive packages, development/build tools, CI actions, and container images across workspaces, even if already
   current or blocked. Use the dependency graph and project usage to assess relevance; reuse research for duplicates and
   related packages. Check new features, language/runtime built-ins, maintained forks and alternatives, additional
   dependencies, and other approaches that could improve performance, simplicity, security, or maintenance. Compare
   promising options with keeping the current solution using credible sources, compatibility, maintenance, security,
   privacy, license, cost, and migration effort. Mark unmeasured performance claims as unverified; do not invent
   opportunities. Record coverage per dependency, including those with no useful option and those not checked, with
   reasons for gaps.
10. Recheck outdated dependencies and the full diff against the initial state. Account for every discovered surface as
    updated, already current, blocked, or not checked. Remove task-owned temporary files and generated build artifacts;
    preserve intended lockfiles and user work. Stop when verified upgrades are applied and remaining blockers are
    explicit, not after only the first package manager succeeds.

## Report

Summarize upgraded groups, language/runtime minimum and support changes, significant major migrations, checks
passed/failed/skipped, and remaining pins or blockers with reasons. Distinguish pre-existing failures from regressions.
State when current versions or supported environments could not be verified; never claim everything is latest or working
without evidence. Separately report actionable research recommendations with source links, expected benefits, tradeoffs,
feasibility, and estimated effort; say if none were found. Summarize research coverage and list unchecked dependencies
and reasons. Leave changes uncommitted by default.
