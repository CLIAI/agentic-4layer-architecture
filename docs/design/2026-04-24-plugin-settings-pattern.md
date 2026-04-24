---
title: Plugin settings pattern — .claude/four-layer-architecture.local.md
date: 2026-04-24
status: draft
scope: design / configuration
related_issues: []
depends_on: [2026-04-24-trigger-model.md]
supersedes: []
---

# Plugin settings pattern

Per-project, user-editable preferences for the teach-back system, using the
Claude Code convention `.claude/<plugin-name>.local.md` — YAML frontmatter
for structured settings, markdown body for freeform notes.

## File location

`.claude/four-layer-architecture.local.md` — in the user's project root,
**gitignored** by default.

## Template

Shipped as `.claude/four-layer-architecture.local.md.example`:

```markdown
---
teach_back:
  auto_suggest: true
  first_use_shown: false
  depth: lite
  skip_paths: []

journal:
  max_lines: 200

socratic:
  default_topic: ""
---

# four-layer-architecture — local notes

This file holds per-project preferences for the four-layer-architecture plugin's
teach-back system. Edit the frontmatter above to tune behaviour; use this body
for freeform notes to yourself.

## What the settings do

* **teach_back.auto_suggest** — when `true`, the PreToolUse hook prints a
  single advisory line on structural edits (new agent / skill / command /
  plugin.json change). Set `false` to mute.
* **teach_back.first_use_shown** — flips to `true` once the SessionStart
  first-use nudge has fired. Flip back to `false` to see it again.
* **teach_back.depth** — default depth for `/four-layer-architecture:feynman-check`
  when invoked without `--deep` / `--lite`. One of `lite`, `deep`, or `off`.
* **teach_back.skip_paths** — glob patterns where the structural-edit hook
  stays silent even if `auto_suggest: true`. Example: `["plugins/*/hooks/*"]`.
* **journal.max_lines** — threshold at which the skill offers to archive the
  journal to a dated file.
* **socratic.default_topic** — if set, `/four-layer-architecture:socratic` with
  no arg picks this topic instead of showing the two-pane menu.

## Notes

Add freeform notes below as you work through teach-back rounds. The plugin
does not read this body — it's for you.
```

## How the hook reads it

`suggest-teach-back.sh` in pseudocode:

```bash
#!/usr/bin/env bash
set -e

PREF_FILE=".claude/four-layer-architecture.local.md"

# Default: enabled.
AUTO_SUGGEST=true
declare -a SKIP_PATHS=()

if [[ -f "$PREF_FILE" ]]; then
  # Extract YAML frontmatter between first two '---' lines,
  # parse auto_suggest + skip_paths.
  # Prefer yq if available, else awk/sed fallback.
  ...
fi

# Declared-in-instructions opt-out:
for f in AGENTS.md CLAUDE.md; do
  [[ -f "$f" ]] && grep -q 'four-layer-architecture: skip-teach-back' "$f" && exit 0
done

[[ "$AUTO_SUGGEST" == "true" ]] || exit 0

# ... classify change via detect-change.sh ...
# ... glob-check SKIP_PATHS ...
# ... emit advisory line ...

exit 0
```

**Robustness:** on any parse error, default to the *user-friendly* option
(silent). Never emit garbled output; never block tool use.

## .gitignore entries

Added during implementation:

```
# four-layer-architecture teach-back artifacts
.four-layer-journal.md
.four-layer-journal.*.md
.claude/four-layer-architecture.local.md
```

The `.example` template is **not** gitignored — it's checked in as the
seed users copy.

## First-run bootstrap

`/four-layer-architecture:brainstorm-architecture` on first run:

1. Detects absence of `.claude/four-layer-architecture.local.md`.
2. Offers: *"Copy*
   *`plugins/four-layer-architecture/templates/four-layer-architecture.local.md.example`*
   *to `.claude/four-layer-architecture.local.md` now? (y/n)"*
3. On `y` — copies it; user can edit later.
4. On `n` — proceeds with defaults; never asks again this session.

## Why this pattern over alternatives

* **Not `.claude/settings.json`** — that file is shared config for the
  whole Claude Code harness; plugin-specific knobs don't belong there.
* **Not env vars** — survive only the shell session; don't travel with
  the repo; hard to discover.
* **Not a CLI flag on every command** — too much friction; users wouldn't
  set it per-invocation.

The `.local.md` pattern is lightweight, discoverable (file literally named
after the plugin, sits next to other Claude config), and survives the
repo across collaborators (as `.example`) while staying per-user
(`.local.md` itself is gitignored).

## Testing

* Missing file → defaults apply (auto_suggest on).
* `auto_suggest: false` → hook stays silent even on structural edits.
* Malformed YAML → hook stays silent (fail-safe).
* `skip_paths: ["plugins/*/hooks/*"]` → edit to
  `plugins/x/hooks/y.sh` produces no advisory, but edit to
  `plugins/x/agents/z.md` still does.
