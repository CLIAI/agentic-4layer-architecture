# Per-layer curated understanding notes

This directory holds **user-curated insights** about this project's
4-layer architecture, promoted from teach-back rounds (Feynman and
Socratic) or hand-written during ordinary reflection.

It is part of the repository's self-documentation — these files are
**committed**, unlike the ephemeral `.four-layer-journal.md` at the
project root. Think of `docs/understanding/` as the "confirmed
knowledge" distillate; the journal is the raw transcript.

## Canonical files

One file per conceptual layer, plus a cross-cutting file:

* `L0.md` — Tools & Primitives (Scripts)
* `L1.md` — SOPs / Capabilities (Skills)
* `L2.md` — Workflows (Agents)
* `L3.md` — Orchestration (Commands)
* `meta-pattern.md` — cross-cutting insights on the 4-layer architecture
  itself (trade-offs, anti-patterns, wiring principles)

Each file starts as a short stub and accumulates `###`-prefixed entries
over time.

## Promotion flow

At the end of every teach-back round, the coach asks:

> *Promote insights from this round to `docs/understanding/L<n>.md`?
> (y / n / curate)*

* **`y`** — appends a default block (title, confirmed insight, source
  reference, gap closed).
* **`n`** — keeps the insight in the journal only.
* **`curate`** — drafts the block and lets you edit before commit.

See `plugins/four-layer-architecture/skills/teach-back-journal/SKILL.md`
for the full spec.

## Hand-written entries

Not every insight comes from a round. You are encouraged to open any of
these files and write an entry directly when you notice something worth
remembering — an architectural gotcha, a surprising delegation pattern, a
decision you want future-you to inherit context on.

Keep entries short, dated, and grounded in a file path or doc reference
when possible. One `###` block per insight.

## Why this lives in the repo

* It survives agent sessions — not tied to conversation memory.
* It survives collaborators — the next person cloning the repo inherits
  the accumulated understanding.
* It is diffable — the Pull Request of a promotion is itself a record of
  how your mental model evolved.

## Related

* Design: `docs/design/2026-04-24-journal-and-promotion.md`
* Philosophy: `docs/philosophy.md`
* Architecture overview: `docs/architecture.md`
