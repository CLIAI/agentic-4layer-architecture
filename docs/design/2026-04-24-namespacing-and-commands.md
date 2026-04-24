---
title: Namespacing, command inventory, frontmatter conventions
date: 2026-04-24
status: draft
scope: design / plugin surface
related_issues: []
depends_on: []
supersedes: []
---

# Namespacing and command inventory

## Namespacing (confirmed from docs)

Claude Code plugins namespace slash commands and skills with a colon
separator derived from the `name` field of `plugin.json`. Our plugin name
is `four-layer-architecture`, so **every** component is invoked as:

```
/four-layer-architecture:<command-name>
```

Skills appear in the skill picker as `four-layer-architecture:<skill-name>`.
Agents are selected from the `/agents` picker and are logically scoped to
the plugin (no forced UI prefix, but no collision with other plugins).

**There is no separate namespace field.** The plugin's `name` is the single
source of truth.

**Collisions are impossible** between enabled plugins because the namespace
is always present. This is deliberate on the harness side; it costs
ergonomics but buys predictability.

**Reference:** `https://code.claude.com/docs/en/plugins-reference`

## Command inventory (after this work lands)

| Invocation | Purpose | Layer |
|---|---|---|
| `/four-layer-architecture:review-my-architecture` | Existing — Socratic audit pipeline | L3 |
| `/four-layer-architecture:explain-layer` | Existing — classify a file by layer | L3 |
| `/four-layer-architecture:feynman-check` | NEW — Feynman round (lite default; `--deep` flag) | L3 |
| `/four-layer-architecture:socratic` | NEW — Socratic dialogue on one topic | L3 |
| `/four-layer-architecture:brainstorm-architecture` | NEW — guided entry: two-pane menu → Feynman-deep or Socratic | L3 |

Every command is **thin** (L3 is orchestration, not implementation):
5–15 lines of markdown with YAML frontmatter that delegates to an agent and
preloads skills.

## Frontmatter convention for commands

Canonical pattern (matches existing `review-my-architecture.md`):

```yaml
---
name: feynman-check
description: "Run a Feynman teach-back round on a specified or auto-detected scope."
context: fork
agent: teach-back-coach
argument-hint: "[topic] [--deep]"
---
```

* `name` — must match the filename stem; this is what appears after the
  colon in the namespaced invocation.
* `context: fork` — spawns a subagent (see `docs/wiring-the-chain.md`).
* `agent:` — the L2 agent to delegate to; the agent itself declares which
  skills it preloads.
* `argument-hint` — shown in the command picker.

## Frontmatter convention for agents

```yaml
---
name: teach-back-coach
description: "Runs Feynman rounds — user explains, agent checks against code and docs."
tools: [Read, Bash, Grep, Glob]
skills: [feynman-protocol, system-scan, teach-back-journal]
memory: off
---
```

## Frontmatter convention for skills

```yaml
---
name: feynman-protocol
description: "Rules for running a Feynman round: turn sequence, bail phrases, gap-report format."
version: 0.1.0
---
```

## README implications

The Quick Start and Repository Structure sections need updates so every
example uses the namespaced form. Users copying from the README should not
see `/review-my-architecture` — it will not work after install; they need
`/four-layer-architecture:review-my-architecture`.

A short subsection near the install methods documents this explicitly:

> *All commands from this plugin live under the*
> *`four-layer-architecture:` namespace after install. For example,*
> *`/four-layer-architecture:brainstorm-architecture`. The namespace*
> *prevents collisions with other plugins you may have enabled.*

## Testing

* Every component's `name:` frontmatter field matches its filename stem.
* After `claude --plugin-dir plugins/four-layer-architecture`, running
  `/four-layer-architecture:<name>` for each command succeeds.
* No existing command still referenced as bare `/review-my-architecture`
  in any doc after this work.
