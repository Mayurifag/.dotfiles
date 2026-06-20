# PR Descriptions

## Default Shape

Use this structure unless a repo PR template requires something else:

## Problem

State the concrete issue, gap, risk, or confusing behavior that made the change necessary.

## What Changed

Describe exactly what changed in plain language. Mention user-visible behavior, config, migrations, compatibility, and risk areas when relevant.

## Style

- Keep it concise and human-written.
- Be specific: name changed behavior, files, flows, APIs, commands, or settings when useful.
- Prefer direct verbs over generic PR language.
- Do not summarize commits.
- Do not add `Validation`, `Testing`, or test commands unless explicitly requested or required by the repo template.
- Do not invent motivation, impact, test results, tickets, screenshots, or rollout details.
- Avoid filler: `This PR introduces`, `enhances`, `improves`, `various fixes`, `better maintainability`.

## Example

Problem:

Failed task updates could leave the UI showing the new completion state even though the save did not succeed.

What Changed:

Added rollback handling for failed task updates and reused the existing toast flow to show the API error.
