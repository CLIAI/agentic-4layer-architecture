---
title: Journal and promotion — append-only .four-layer-journal.md + docs/understanding/
date: 2026-04-24
status: draft
scope: design / persistence
related_issues: []
depends_on: []
supersedes: []
---

# Journal and promotion

Two-tier persistence: a **low-friction append-only journal** in every
teach-back session, and a **user-curated promotion flow** into committed
per-layer understanding notes.

## Journal — `.four-layer-journal.md`

**Location:** project root. Gitignored by default (template `.gitignore`
entry added during implementation).

**Format:**

```markdown
## [2026-04-24 14:07] Feynman-lite on plugins/four-layer-architecture/agents/billing-agent.md

**Trigger:** PreToolUse hook after Edit.
**Scope:** Pane 1 — user's billing-agent.
**Depth:** lite.

### Teach-back (user, verbatim)
> [...user's explanation, copy-paste...]

### Gap report
- ✅ correctly identified L2 role
- ⚠ unclear about `context:fork` lifetime — see docs/wiring-the-chain.md
- ❌ claimed retry-on-5xx, but no retry logic exists in file

### Status
Completed. Promoted to docs/understanding/L2.md? No.
```

**Why markdown and not structured log:**

* Human-readable in a standard editor.
* Greppable.
* Users can hand-edit entries (fix typos, add afterthoughts).
* No parser needed to read it — `cat` works.

**Append behaviour:** skill appends to end of file; creates file if missing
with a one-line header: `# Teach-back journal — <project-name>`.

## Journal rotation

When the file exceeds ~200 lines (configurable via
`journal.max_lines` in `.claude/four-layer-architecture.local.md`), the
skill offers at the start of the next round:

> *"Journal at 214 lines. Archive to*
> *`.four-layer-journal.2026-Q2.md` and start fresh? (y/n)"*

`y` → `git mv` (well, `mv` since gitignored) to the dated archive, start
new file. `n` → continue appending; ask again at +50 lines.

Archives stay gitignored too.

## Promotion — `docs/understanding/`

**Location:** project root, committed.

**Files:** five canonical names, created eagerly on first
`/brainstorm-architecture` run:

* `docs/understanding/README.md` — explains what this directory is for.
* `docs/understanding/L0.md` — Tools & Primitives.
* `docs/understanding/L1.md` — SOPs / Capabilities (Skills).
* `docs/understanding/L2.md` — Workflows (Agents).
* `docs/understanding/L3.md` — Orchestration (Commands).
* `docs/understanding/meta-pattern.md` — cross-cutting insights on the
  4-layer architecture itself.

Each file starts as a stub:

```markdown
# L2 — Workflows / Agents — understanding

This file accumulates confirmed insights about the L2 layer **in this
project's context**, promoted from teach-back rounds.

Insights are user-curated. Each entry should state:
* what was learned / confirmed,
* the source of truth (code path or doc reference),
* the date of the round that produced it.

---

<!-- entries appended below this line -->
```

## Promotion flow

At the end of every round:

> *"Promote insights from this round to `docs/understanding/L2.md`?*
> *(y / n / curate)"*

* **`y`** — skill appends a default-formatted block to the layer file:

    ```markdown
    ### [2026-04-24] billing-agent sequencing

    * Confirmed: billing-agent is L2, orchestrates fraud-check and charge skills.
    * Source: plugins/four-layer-architecture/agents/billing-agent.md
    * Gap closed: clarified context:fork lifetime (previously uncertain).
    ```

* **`n`** — no change. Journal entry still exists.

* **`curate`** — skill drafts the promotion block (same format as `y`) and
  asks the user to edit it before commit. The agent stays in a short edit
  loop ("anything to change? send changes or 'ok'") until user approves.
  Then writes to the layer file.

`docs/understanding/*.md` are **committed** — they're part of the
project's self-documentation. The skill does NOT auto-commit; the user runs
their normal `git add && git commit` when ready. The skill prints a
suggested one-line commit message:

> *"suggested: `git commit -m 'Promote teach-back insight — billing-agent*
> *sequencing'`"*

## Skill spec — `teach-back-journal/SKILL.md`

Thin — captures the journal format, rotation policy, promotion flow, and
default commit-message format. No AI reasoning lives in the skill; the
Feynman and Socratic agents invoke it as a subroutine.

## Testing

* Fresh project → first Feynman round creates `.four-layer-journal.md`
  with header + one entry.
* Second round → appends without disturbing the first entry.
* Promote with `y` → `docs/understanding/L2.md` gains a new `###` block.
* Promote with `curate` → skill waits for user edits before writing.
* Journal crosses 200 lines → next round prompts for archive.
