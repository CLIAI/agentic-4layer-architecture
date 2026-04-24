---
title: Socratic protocol — probing dialogue on one tricky corner
date: 2026-04-24
status: draft
scope: design / protocol
related_issues: []
depends_on: [2026-04-24-trigger-model.md, 2026-04-24-system-scanning.md]
supersedes: []
---

# Socratic protocol

A Socratic round reverses direction: the **AI probes, the user answers**, and
the AI follows up on the shakiest part of each answer. Drill-down on one
topic at a time.

## Key difference from Feynman

* **Feynman:** user → AI (user explains, AI checks).
* **Socratic:** AI → user (AI asks probing questions tied to a specific
  "tricky corner"; user answers; AI follows up).

Both axes apply (user's system vs meta-pattern). Never auto-triggered —
always user-pulled via the command.

## Entry points

* `/four-layer-architecture:socratic <topic>` — drill on that topic directly.
* `/four-layer-architecture:socratic` (no arg) — show the two-pane menu
  (Pane 1 from `scan-system.sh`, Pane 2 from
  [`docs/tricky-corners.md`](../tricky-corners.md)).

## Dialogue shape

**Turns 1–N** (3–5 total user-facing turns):

1. Agent opens with an **anchor question** — the kind that a confident user
   answers quickly and a shaky user hesitates on. Examples:

    * Pane 2, `context:fork` vs `skills:` — *"Your L2 agent uses*
      *`context: fork`. If you removed that and added the skill to the*
      *`skills:` list instead, what would change about when and where the*
      *skill's content loads?"*
    * Pane 1, billing workflow — *"When `billing-agent` calls*
      *`fraud-check`, where does the fraud-check output go — back to the*
      *agent, to the user, to a log? Trace it."*

2. User answers.

3. Agent picks the *weakest* part of the answer and asks a focused follow-up
   ("you said X — walk me through what X looks like when Y happens").

4. 2–4 more rounds following the same pattern.

5. **Closing turn** — agent summarises:

    * ✅ parts of the user's model that held up
    * ⚠ parts where understanding was partial
    * ❌ parts where the model diverged from code/docs

    Offers promote-to-`docs/understanding/` (see
    [`2026-04-24-journal-and-promotion.md`](2026-04-24-journal-and-promotion.md)).

Bail phrases from [`2026-04-24-trigger-model.md`](2026-04-24-trigger-model.md)
honoured throughout.

## Tricky-corners catalog

New file at `docs/tricky-corners.md`. Each entry is a tight block:

```markdown
## context:fork vs skills: field

**Why tricky:** Both make a skill's content available to an agent, but via
different mechanisms with different lifetimes and context costs.
`context: fork` spawns a subagent with the skill in its context (eager,
isolated). `skills:` lists a skill the agent *can* invoke (lazy, shared
conversation).

**Good anchor questions:**
* If I change the skill mid-session, which of the two picks up the change?
* Which costs more context tokens on an already-running agent?
* Which one can a skill recursively nest inside without blowing the context
  window?

**Source of truth:** `docs/wiring-the-chain.md`, `docs/examples.md`.
```

Seeded with 6 entries (listed in the implementation section of the umbrella
plan). Users are invited to append their own for their own systems — the
file grows.

## Agent spec — `socratic-probe-agent`

Lives at `plugins/four-layer-architecture/agents/socratic-probe-agent.md`.

* Tools: `Read`, `Bash` (for `scan-system.sh`), `Grep`.
* Skills preloaded: `socratic-protocol`, `system-scan`,
  `teach-back-journal`.
* Memory: off. (Long Socratic drill-downs could theoretically benefit from
  memory; we skip it here because a single round completes within one
  session and the journal captures outputs.)
* Behavioural rules: ask one question at a time, always follow the weakest
  part of the last answer, never exceed 5 user-facing turns without the
  user explicitly asking for more.

## Skill spec — `socratic-protocol/SKILL.md`

Contains:

* Dialogue-shape contract (1 anchor + up to 4 follow-ups + closing).
* Question-selection heuristic (pick on ambiguity, contradiction, or
  reasoning gap in the last answer).
* Catalog-entry template (matches `docs/tricky-corners.md` format).
* Closing-summary format.

## Testing (acceptance)

* `/socratic context:fork-vs-skills` → runs 3–5 turn dialogue on that entry.
* `/socratic` with no arg and no repo components → shows Pane 2 only,
  cleanly (no errors about missing Pane 1).
* Reply "move on" mid-dialogue → agent yields and offers closing summary.
* Closing summary includes at least one citation to code or docs.
