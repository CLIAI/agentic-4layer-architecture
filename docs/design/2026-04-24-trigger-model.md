---
title: Trigger model — commands, advisory hook, three skip channels
date: 2026-04-24
status: draft
scope: design / architecture
related_issues: []
depends_on: []
supersedes: []
---

# Trigger model

Three trigger paths — all advisory, all skippable.

## Triggers

### A. Structural-edit `PreToolUse` hook (gentle nudge)

Registered in `plugins/four-layer-architecture/hooks/hooks.json`:

```json
{
  "PreToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/suggest-teach-back.sh"
        }
      ]
    }
  ]
}
```

`suggest-teach-back.sh`:

1. Reads the file path from the hook's environment (stdin JSON per hook
   contract).
2. Uses `detect-change.sh <path>` to classify: `agent | skill | command |
   hook | plugin-manifest | doc-architecture | agents-md | none`.
3. If `none` → exits 0 silently.
4. Reads skip prefs (see below). If any skip channel is on for this scope →
   exits 0 silently.
5. Otherwise emits a single advisory line to stdout, for example:

    > *"[four-layer] Architectural edit detected (L2 agent). Consider*
    > *`/four-layer-architecture:feynman-check` before continuing. Skip:*
    > *set `teach_back.auto_suggest=false` in*
    > *`.claude/four-layer-architecture.local.md`."*

6. Always exits 0. Never blocks tool use.

### B. `SessionStart` first-use nudge

Existing `check-prerequisites.sh` gets a small addendum (or a new
`suggest-first-use.sh` companion). If both conditions hold:

* plugin is active (its `plugin.json` resolvable),
* no `.four-layer-journal.md` and no `docs/understanding/` directory exist in
  the project,

then emit once per session a one-line suggestion:

> *"[four-layer] First session here. Run*
> *`/four-layer-architecture:brainstorm-architecture` for a guided start, or*
> *set `teach_back.first_use_shown=true` to mute."*

### C. Explicit user-invoked commands

No skip needed — user ran them:

* `/four-layer-architecture:feynman-check [topic]`
* `/four-layer-architecture:socratic [topic]`
* `/four-layer-architecture:brainstorm-architecture`

## Skip channels (any one suffices)

### 1. Persistent per-project preference

`.claude/four-layer-architecture.local.md` (per the plugin-settings pattern):

```yaml
---
teach_back:
  auto_suggest: true      # hook A — set false to mute per-edit nudges
  first_use_shown: false  # hook B — flips to true once user has seen nudge
  depth: lite             # lite | deep | off  (default depth for feynman-check)
  skip_paths:             # optional path globs where hook A stays silent
    - "plugins/*/hooks/*"
---

Free-form notes about your teach-back preferences for this project.
```

File is per-project, gitignored by default, authored by the user.
`suggest-teach-back.sh` parses only the frontmatter (simple `yq` or
`sed`/`awk` fallback).

### 2. Declared-in-instructions

A project can opt out globally by adding a line to `AGENTS.md` or `CLAUDE.md`:

```
four-layer-architecture: skip-teach-back
```

`suggest-teach-back.sh` greps for this exact token (simple, documented).
Primary use case: a team decides "not now, we know what we're doing," commits
the opt-out so every collaborator gets the same experience.

### 3. In-session bail-out

The Feynman and Socratic *agents* themselves recognise natural-language bail
phrases in the user's reply:

* *"skip"*, *"enough"*, *"move on"*, *"I know this"*, *"proceed"*, *"next"*.

On detection the agent yields immediately with:

> *"Understood — proceeding. You can re-enter with*
> *`/four-layer-architecture:feynman-check` at any time."*

No re-prompt for the rest of the session. No grudge.

## Why advisory-only

Blocking hooks fast-path to being disabled. Advisory hooks survive because
they respect user autonomy. The cost is that users can ignore the nudge —
that's fine: the teach-back system is *optional cognitive scaffolding*, not a
gate on merging code.

## Implementation notes

* `detect-change.sh` must be cheap (<50ms) — called on every Write/Edit.
* Hook script exits 0 on *any* error (parse failure, missing file, etc.).
  Broken teach-back must never block user work.
* First-use nudge fires at most once per session (track via a
  `/tmp/four-layer-first-use-shown-<session-id>` flag file — ephemeral).

## Testing

* Dry-run: edit `plugins/four-layer-architecture/agents/foo.md` → expect
  advisory line.
* Edit `README.md` → expect silence (not in match paths).
* Set `auto_suggest: false` → expect silence on all edits.
* Grep `AGENTS.md` → expect silence on all edits.
* Reply "skip" to Feynman prompt → expect agent to yield within one turn.
