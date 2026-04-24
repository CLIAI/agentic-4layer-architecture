---
name: teach-back-journal
description: "Append teach-back rounds to .four-layer-journal.md and manage promotion of curated insights into docs/understanding/."
version: 0.1.0
---

# Teach-back Journal Skill

Two-tier persistence for the teach-back system:

* **Journal** — `.four-layer-journal.md` at project root. Append-only,
  gitignored, low-friction. Captures every round verbatim.
* **Promotion** — user-curated insights flow from journal entries into the
  committed `docs/understanding/L{0,1,2,3}.md` and `meta-pattern.md` files.

This skill is a thin subroutine. The Feynman and Socratic agents invoke it
to persist a round and to drive the promotion prompt. No AI reasoning
lives here.

## Journal location & bootstrap

* Path: `.four-layer-journal.md` at the current project's root.
* Gitignored by default (entries added to `.gitignore` during plugin
  install).
* If missing when the skill is invoked to append, create it with a single
  header line:

    ```markdown
    # Teach-back journal — <project-name>
    ```

  where `<project-name>` is the basename of `$PWD`.

## Journal entry format

Each round appends one block. Sections are `##` timestamped headers so the
file is grep-friendly.

```markdown
## [2026-04-24 14:07] Feynman-lite on plugins/four-layer-architecture/agents/billing-agent.md

**Trigger:** PreToolUse hook after Edit.
**Scope:** Pane 1 — user's billing-agent.
**Depth:** lite.

### Teach-back (user, verbatim)
> [...user's explanation, copy-paste verbatim, no summarisation...]

### Gap report
- ✅ correctly identified L2 role
- ⚠ unclear about `context:fork` lifetime — see docs/wiring-the-chain.md
- ❌ claimed retry-on-5xx, but no retry logic exists in file

### Status
Completed. Promoted to docs/understanding/L2.md? No.
```

**Rules:**

* User prose goes under `### Teach-back (user, verbatim)` as a blockquote.
  Never paraphrase the user's words — a future re-read should see exactly
  what they said.
* Gap report uses `✅` / `⚠` / `❌` prefixes.
* Status line records the promotion decision so a later grep can find
  un-promoted rounds.

## Append behaviour

* Open the file in append mode; never rewrite existing content.
* Prepend a blank line before the new `##` block if the file does not end
  in one.
* On write failure (disk full, permission), surface the error to the
  calling agent; do not silently drop the round.

## Rotation policy

When the file exceeds the configured threshold — default **200 lines**,
overridable via `journal.max_lines` in
`.claude/four-layer-architecture.local.md` — the skill prompts at the
**start of the next round** (not mid-round):

> *"Journal at 214 lines. Archive to `.four-layer-journal.2026-Q2.md` and
> start fresh? (y/n)"*

* **`y`** — `mv .four-layer-journal.md .four-layer-journal.<YYYY>-Q<N>.md`
  (plain `mv`, since gitignored); start fresh file with header.
* **`n`** — continue appending; ask again at +50 lines.

Archives inherit the gitignore pattern and stay local.

## Promotion flow

At the end of every round, the calling agent prompts:

> *"Promote insights from this round to `docs/understanding/L2.md`?
> (y / n / curate)"*

(The layer file chosen is driven by the round's topic — an agent edit
targets `L2.md`, a hook edit targets `meta-pattern.md` or the Bonus
section, etc.)

* **`y`** — skill appends a default block to the target layer file:

    ```markdown
    ### [2026-04-24] billing-agent sequencing

    * Confirmed: billing-agent is L2, orchestrates fraud-check and charge skills.
    * Source: plugins/four-layer-architecture/agents/billing-agent.md
    * Gap closed: clarified context:fork lifetime (previously uncertain).
    ```

* **`n`** — no change to `docs/understanding/`. Journal entry's status
  line records "Promoted? No."

* **`curate`** — skill drafts the block (same format as `y`) and hands it
  back to the calling agent for a short edit loop with the user:

    > *"Here's the draft. Send changes, or 'ok' to commit."*

  Loop until user says `ok`; then write.

In every case, update the journal entry's **Status** line to reflect the
decision.

## Commit message hint

`docs/understanding/*.md` are committed — they are project
self-documentation. The skill does **not** auto-commit. After a successful
promotion, print a suggested one-line commit message for the user:

> *suggested: `git commit -m 'Promote teach-back insight — billing-agent
> sequencing'`*

Pattern: `Promote teach-back insight — <short-title>`. The user may
rewrite it; the skill never runs `git` itself.

## Edge cases

* Target `docs/understanding/L{n}.md` missing → create it from the stub
  template (header + explanation + `<!-- entries appended below this line -->`
  marker), then append.
* Concurrent rounds in different sessions → append is line-buffered; last
  writer wins on a collision but neither loses data. Not a strong
  guarantee; document as known.
* User answers with something other than `y` / `n` / `curate` → agent
  re-prompts once, then defaults to `n` (safe, non-destructive).

## Reference

* Design note: `docs/design/2026-04-24-journal-and-promotion.md`
* Settings: `docs/design/2026-04-24-plugin-settings-pattern.md`
