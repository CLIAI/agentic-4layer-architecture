---
title: GitHub issues to raise for the teach-back system
date: 2026-04-24
status: draft
scope: design / process
related_issues: []
depends_on: [2026-04-24-teach-back-system-plan.md]
supersedes: []
---

# GitHub issues to raise

Six issues. Four are raised **before implementation starts** (so commit
messages can reference them). Two follow-ups are raised after implementation
lands.

All issues use the labels `enhancement` and `teach-back` (new label).
The umbrella issue additionally gets `epic`.

## Immediate (raise before implementation)

### Issue A — Umbrella: Add teach-back system (Feynman + Socratic rounds)

```markdown
## Summary

Add a teach-back system to the `four-layer-architecture` plugin so users
actively articulate their understanding of (1) their own system/workflows
and (2) the 4-layer meta-pattern, rather than outsourcing that thinking to
the AI.

Design: [`docs/design/2026-04-24-teach-back-system-plan.md`](../docs/design/2026-04-24-teach-back-system-plan.md)

## Scope

* 3 new L3 commands (`feynman-check`, `socratic`, `brainstorm-architecture`)
* 2 new L2 agents (`teach-back-coach`, `socratic-probe`)
* 4 new L1 skills (`feynman-protocol`, `socratic-protocol`, `system-scan`,
  `teach-back-journal`)
* 3 new L0 scripts (`scan-system.sh`, `detect-change.sh`,
  `suggest-teach-back.sh`)
* Advisory PreToolUse + SessionStart hook wiring
* `docs/tricky-corners.md` seed catalog
* `docs/understanding/` stubs
* `.claude/four-layer-architecture.local.md.example` template
* README Intent section

## Success criteria

See the umbrella plan doc (10 criteria).

## Labels

enhancement, teach-back, epic
```

### Issue B — Anti-outsourcing framing: README Intent section + IndyDevDan quote

```markdown
## Summary

Add a top-level README Intent section carrying the IndyDevDan quote from
the 4-layer architecture video, and a short stance paragraph tying it to
this plugin's mechanics.

Design: [`docs/design/2026-04-24-anti-outsourcing-framing.md`](../docs/design/2026-04-24-anti-outsourcing-framing.md)

## Tasks

- [ ] Fetch transcript via `yt-dlp-priv.py --md` → cache under `docs/reference-cache/`
- [ ] Grep for anti-outsourcing anchor phrases
- [ ] Select tightest quote; cite with timestamp if available
- [ ] If transcript fetch fails, commit clearly-labelled paraphrase + TODO
- [ ] Write Intent section in README.md
- [ ] Link to `docs/philosophy.md`

## Labels

enhancement, teach-back, documentation
```

### Issue C — Two-axis scoping: user's own system vs meta-pattern

```markdown
## Summary

Teach-back rounds must support two scopes at invocation time:

1. **Pane 1 — your system:** the user's own workflows, components, domain.
2. **Pane 2 — meta-pattern:** the 4-layer architecture concepts.

This is more than UI — it shapes what `scan-system.sh` extracts,
what `docs/tricky-corners.md` catalogs, and how `brainstorm-architecture`
renders its menu.

Design: [`docs/design/2026-04-24-system-scanning.md`](../docs/design/2026-04-24-system-scanning.md),
[`docs/design/2026-04-24-feynman-protocol.md`](../docs/design/2026-04-24-feynman-protocol.md),
[`docs/design/2026-04-24-socratic-protocol.md`](../docs/design/2026-04-24-socratic-protocol.md)

## Labels

enhancement, teach-back
```

### Issue D — Advisory hook pattern: gentle nudge + three skip channels

```markdown
## Summary

Implement the advisory hook pattern used by teach-back: `PreToolUse` hook
that emits a single stdout line, always exits 0, and honours three
independent skip channels (persistent `.local.md` prefs,
declared-in-`AGENTS.md`, in-session bail phrases).

Design: [`docs/design/2026-04-24-trigger-model.md`](../docs/design/2026-04-24-trigger-model.md),
[`docs/design/2026-04-24-plugin-settings-pattern.md`](../docs/design/2026-04-24-plugin-settings-pattern.md)

## Labels

enhancement, teach-back, hooks
```

## Follow-up (raise after implementation)

### Issue E — `docs/tricky-corners.md` catalog: seed + contribution guide

```markdown
## Summary

Formalise `docs/tricky-corners.md` as an ongoing catalog. Seeded with six
entries; open invitation for PRs adding new entries (each with a good
anchor question and a source-of-truth reference).

Design: [`docs/design/2026-04-24-socratic-protocol.md`](../docs/design/2026-04-24-socratic-protocol.md)

## Labels

documentation, teach-back, good-first-issue
```

### Issue F — `docs/understanding/` per-layer curated notes pattern

```markdown
## Summary

Document the `docs/understanding/` directory as a portable pattern other
projects can adopt (committed per-layer notes, promoted from teach-back
rounds or manually written).

Design: [`docs/design/2026-04-24-journal-and-promotion.md`](../docs/design/2026-04-24-journal-and-promotion.md)

## Labels

documentation, teach-back
```

## How commit messages will reference these issues

Per repo convention (`Closes #N` or `Part of #N`):

* Umbrella implementation commits → `Part of #<A>`.
* Focused subsystem commits → `Part of #<A>, closes #<C>` (etc.) where
  appropriate.
* After PR/merge — sub-agent checks issue descriptions end with
  `(for Github WebUI isue linking: Closes #{A} )` per global guidelines.

## Labels to create (if not already present)

* `teach-back` (new) — work relating to Feynman/Socratic rounds
* `epic` — umbrella-tracking issues (may already exist)
