---
title: System scanning — scripts, two-pane menu, change detection
date: 2026-04-24
status: draft
scope: design / L0 scripts
related_issues: []
depends_on: []
supersedes: []
---

# System scanning

Two L0 scripts give the teach-back agents a **map of the user's project** and
a way to classify single-file changes. No AI; pure shell.

## `scan-system.sh`

Path: `plugins/four-layer-architecture/skills/system-scan/scripts/scan-system.sh`

**Contract:** emit structured output (JSON-ish block or a simple key/value
format — JSON preferred for easy parsing by the agent) describing the
current project's Claude-Code-relevant surface.

**Output shape:**

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
    {"path": "docs/architecture.md", "title": "...", "top_headings": [...]},
    ...
  ],
  "agents_md":   {"path": "AGENTS.md", "sections": [...]},
  "journal":     {"exists": true|false, "path": ".four-layer-journal.md"},
  "understanding": {"exists": true|false, "files": ["docs/understanding/L2.md", ...]}
}
```

**Behaviour:**

* Walk `plugins/*/` — for each plugin, read `.claude-plugin/plugin.json` and
  enumerate `commands/*.md`, `agents/*.md`, `skills/*/SKILL.md`, and
  `hooks/hooks.json`.
* Walk `.claude/` (project-local layout) — same enumeration.
* For each `.md` component, extract YAML frontmatter (`name`,
  `description`, `tools`, `skills`, `agent`, `context`).
* Walk `docs/*.md` — extract title (first `# …` line) and top-level `##`
  headings.
* Read `AGENTS.md` — extract `##` headings.
* Check existence of `.four-layer-journal.md` and `docs/understanding/*.md`.

**Performance:** target <200ms on this repo. Cache to
`/tmp/four-layer-scan-${PWD_HASH}.json` with a 60-second TTL;
`--fresh` flag bypasses cache.

**Dependencies:** bash, `find`, `grep`, `awk`/`sed`. Prefer `yq`/`jq` if
available but fall back to pure POSIX so it runs on stock systems.

**Exit codes:**

* 0 = success, output valid JSON.
* 1 = fatal error (prints error to stderr, empty `{}` to stdout).

## `detect-change.sh`

Path: `plugins/four-layer-architecture/skills/system-scan/scripts/detect-change.sh`

**Contract:** given a file path as `$1`, print one classification token to
stdout and exit 0.

**Tokens:**

* `agent` — matches `plugins/*/agents/*.md` or `.claude/agents/*.md`
* `skill` — matches `plugins/*/skills/*/SKILL.md` or
  `.claude/skills/*/SKILL.md` or `plugins/*/skills/*/scripts/*`
* `command` — matches `plugins/*/commands/*.md` or `.claude/commands/*.md`
* `hook` — matches `plugins/*/hooks/*` or `.claude/hooks/*` or
  `plugins/*/hooks/hooks.json`
* `plugin-manifest` — matches `plugins/*/.claude-plugin/plugin.json` or
  `.claude-plugin/marketplace.json`
* `doc-architecture` — matches `docs/architecture.md`,
  `docs/philosophy.md`, `docs/wiring-the-chain.md`,
  `docs/concepts-vs-implementation.md`
* `agents-md` — matches `AGENTS.md` or `CLAUDE.md`
* `none` — anything else

**Behaviour:** pure pattern matching via `case` on the path. No file I/O on
the target. <10ms.

## Two-pane menu generation

`/four-layer-architecture:brainstorm-architecture` and
`/four-layer-architecture:socratic` (no-arg) render the two-pane menu:

1. Run `scan-system.sh`.
2. Extract from JSON:

    * Pane 1 entries: every named agent, skill, command in the user's
      plugins + a synthetic entry "`<plugin-name>` end-to-end workflow" per
      plugin with ≥3 components.
    * Pane 2 entries: parsed from `docs/tricky-corners.md` top-level `##`
      headings.

3. Render:

    ```
    YOUR SYSTEM (Pane 1):
      1. billing-agent  (agent, L2)  — "sequences fraud-check + charge"
      2. audit-workflow (command, L3) — "runs review across all plugins"
      3. your-plugin end-to-end

    META-PATTERN (Pane 2 — from docs/tricky-corners.md):
      A. context:fork vs skills: field
      B. eager vs lazy skill loading
      C. when hooks replace vs augment a skill
      D. L3 thinness principle
      E. memory-enabled agents
      F. ${CLAUDE_PLUGIN_ROOT} portability

    Pick [1-3 / A-F / custom topic]:
    ```

4. User picks; selection becomes the `<topic>` for the downstream Feynman
   or Socratic round.

## Eager vs lazy creation of `docs/understanding/`

Eager. On first run of `/brainstorm-architecture`, create
`docs/understanding/` + a stub `README.md` explaining what lives there. The
stub is committed to the repo — its presence is itself a prompt.

## Testing

* `scan-system.sh` on this repo → JSON lists
  `four-layer-architecture` plugin with all its components.
* `scan-system.sh` on an empty directory → JSON with empty arrays, no
  errors.
* `detect-change.sh plugins/x/agents/y.md` → `agent`.
* `detect-change.sh random/file.txt` → `none`.
