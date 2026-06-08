# Research

## Tool Preference

- Prefer Context7 for library/framework/API/SDK/CLI/config-schema/MCP docs.
- Prefer GitHub source/docs when the answer depends on actual implementation, examples, README/docs files, release notes, or repository history.
- Prefer Exa MCP (`exa_web_search_exa`, `exa_web_fetch_exa`) for web search, current facts, broad research, comparisons, news, people, companies, unknown URLs, or docs not covered by Context7/GitHub.
- Prefer Exa over built-in web request/search tools. Built-in tools are often blocked by website owners.
- Use built-in web tools only when Exa fails, is unavailable, or a direct URL fetch is clearly enough.

## Context7

- Use Context7 before coding against external libraries, frameworks, CLIs, SDKs, APIs, config schemas, or MCP servers.
- Skip Context7 when docs are already in the repo/user prompt, the task is purely local code, or Context7 has no relevant library.
- Prefer version-specific docs. Resolve the library ID first unless the user provided an exact `/org/project` Context7 ID.

## Exa

- Search with Exa when the URL is unknown or current/broad context is needed.
- Fetch promising result URLs with Exa when search snippets are not enough.
- Do not over-search. Stop once the answer is well-supported by reliable sources.

## GitHub Research

- Use GitHub for repository docs, source code, examples, releases, and implementation details.
- Use `gh` when it is the fastest reliable path to GitHub content.
- For GitHub issues, PRs, checks, release management, or repository actions, also load `~/airules/github.md`.
