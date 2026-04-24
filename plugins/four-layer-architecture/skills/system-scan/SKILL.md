---
name: system-scan
description: "Extract a structured map of the project's Claude-Code-relevant surface (plugins, agents, skills, commands, hooks, docs) for downstream reasoning."
version: 0.1.0
---

# System Scan Skill

This skill performs a single atomic operation: walk the project and emit a
structured map of everything Claude-Code-relevant — plugins, agents, skills,
commands, hooks, architecture docs, `AGENTS.md`, and the teach-back
artifacts (`.four-layer-journal.md`, `docs/understanding/`).

No AI reasoning lives here. The skill is a thin wrapper around two bundled
L0 scripts; the calling agent parses their output.

## When to invoke

* Before a Feynman round — so the teach-back coach knows which files exist
  in the user's project and can cross-reference claims against real code.
* Before a Socratic round on a named component — to resolve the component
  name to a file path and extract its frontmatter.
* At the top of `/four-layer-architecture:brainstorm-architecture` — to
  populate **Pane 1** ("YOUR SYSTEM") of the two-pane topic menu.
* Inside the PreToolUse hook chain, only via `detect-change.sh` — classify
  a single edited path as `agent` / `skill` / `command` / `hook` /
  `plugin-manifest` / `doc-architecture` / `agents-md` / `none`.

Do NOT invoke it just to answer a user question about one file — that's
overkill. Use `Read` + `Glob` directly.

## Bundled scripts

Both scripts live at
`plugins/four-layer-architecture/skills/system-scan/scripts/`. They already
exist; this skill documents their contract, it does not re-implement them.

### `scan-system.sh`

Full-project scan. Pure shell; targets <200ms on this repo. Caches to
`/tmp/four-layer-scan-${PWD_HASH}.json` with a 60-second TTL. Pass
`--fresh` to bypass cache.

**Output** — JSON on stdout, exit 0 on success. Shape:

```json
{
  "plugins": [
    {
      "name": "four-layer-architecture",
      "path": "plugins/four-layer-architecture",
      "agents":    [{"name": "...", "path": "...", "description": "..."}],
      "skills":    [{"name": "...", "path": "...", "description": "..."}],
      "commands":  [{"name": "...", "path": "...", "description": "..."}],
      "hooks":     [{"event": "PreToolUse", "matcher": "...", "command": "..."}]
    }
  ],
  "local_claude": {
    "agents":    [...], "skills": [...], "commands": [...], "hooks_events": [...]
  },
  "docs": [
    {"path": "docs/architecture.md", "title": "...", "top_headings": [...]}
  ],
  "agents_md":     {"path": "AGENTS.md", "sections": [...]},
  "journal":       {"exists": true, "path": ".four-layer-journal.md"},
  "understanding": {"exists": true, "files": ["docs/understanding/L2.md"]}
}
```

On fatal error: exit 1, empty `{}` on stdout, message on stderr.

### `detect-change.sh`

Single-path classifier. Input: one file path as `$1`. Output: exactly one
token on stdout. Target <10ms. Pure `case`-based pattern matching; no file
I/O on the target path.

**Tokens:**

* `agent` — `plugins/*/agents/*.md` or `.claude/agents/*.md`
* `skill` — `plugins/*/skills/*/SKILL.md`, `.claude/skills/*/SKILL.md`, or
  `plugins/*/skills/*/scripts/*`
* `command` — `plugins/*/commands/*.md` or `.claude/commands/*.md`
* `hook` — `plugins/*/hooks/*`, `.claude/hooks/*`, or
  `plugins/*/hooks/hooks.json`
* `plugin-manifest` — `plugins/*/.claude-plugin/plugin.json` or
  `.claude-plugin/marketplace.json`
* `doc-architecture` — `docs/architecture.md`, `docs/philosophy.md`,
  `docs/wiring-the-chain.md`, `docs/concepts-vs-implementation.md`
* `agents-md` — `AGENTS.md` or `CLAUDE.md`
* `none` — anything else

## Usage from an agent

```bash
# Full scan for menu generation or round prep
bash ${CLAUDE_PLUGIN_ROOT}/skills/system-scan/scripts/scan-system.sh

# Force-fresh scan (bypass 60s cache)
bash ${CLAUDE_PLUGIN_ROOT}/skills/system-scan/scripts/scan-system.sh --fresh

# Classify a single edited path (hook use case)
bash ${CLAUDE_PLUGIN_ROOT}/skills/system-scan/scripts/detect-change.sh \
  "plugins/my-plugin/agents/foo.md"
# → prints: agent
```

## Two-pane menu (Pane 1 inputs)

For `/four-layer-architecture:brainstorm-architecture` and the no-arg form
of `/four-layer-architecture:socratic`, the calling agent should:

1. Run `scan-system.sh`.
2. From the JSON, build Pane 1:

    * one entry per named agent, skill, command across all plugins and
      `.claude/`;
    * one synthetic entry *"`<plugin-name>` end-to-end workflow"* for any
      plugin with ≥3 components.

3. Build Pane 2 from `docs/tricky-corners.md` top-level `##` headings.
4. Render both panes; collect user selection.

## Failure modes

* Empty project (no plugins, no `.claude/`) → scan returns JSON with empty
  arrays, exit 0. Not an error.
* Missing dependencies (`jq`, `yq`) → scripts fall back to POSIX
  `awk`/`sed`. No hard dep beyond bash + coreutils.
* Parse failure on one plugin's `plugin.json` → that plugin's entry is
  omitted from output; scan continues. Never fails the whole scan for one
  bad file.

## Reference

* Design note: `docs/design/2026-04-24-system-scanning.md`
* Official plugin reference: https://code.claude.com/docs/en/plugins-reference
