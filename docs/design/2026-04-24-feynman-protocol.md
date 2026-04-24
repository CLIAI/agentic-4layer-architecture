---
title: Feynman protocol — lite and deep variants
date: 2026-04-24
status: draft
scope: design / protocol
related_issues: []
depends_on: [2026-04-24-trigger-model.md, 2026-04-24-system-scanning.md]
supersedes: []
---

# Feynman protocol

A Feynman round asks the user to **explain in their own words** and checks
the explanation against ground truth (their code + the repo's docs). Two
variants — a lightweight default and a deeper opt-in.

## Axes (what gets taught back)

Every round runs on one of two axes, decided at invocation time:

* **Pane 1 — your system:** "explain what `<your component>` does in your
  domain, what it calls, what calls it, where it can fail."
* **Pane 2 — meta-pattern:** "explain what `<4-layer concept>` means and
  when it applies."

The two-pane menu (see [`2026-04-24-system-scanning.md`](2026-04-24-system-scanning.md))
lets the user choose. Hook-triggered rounds default to Pane 1 scoped to the
file that just changed.

## Feynman-lite (default)

**Entry points:** hook Trigger A advisory; `/four-layer-architecture:feynman-check`
with no flags; `/four-layer-architecture:feynman-check <topic>`.

**Turn 1 — Agent:**

1. Receives: (a) optional `<topic>` argument, (b) optional `<file>` context
   from the hook, (c) output of `scan-system.sh` scoped to neighbourhood.
2. Prompts the user (≤60 words):

    > *"You're about to work on `<scope>`. Before I act — in your own words,*
    > *≤200 words: what is this component's job, what does it call, what*
    > *calls it, where can it fail?"*

**Turn 2 — User:** replies (or bails via phrase in
[`2026-04-24-trigger-model.md`](2026-04-24-trigger-model.md)).

**Turn 3 — Agent:** cross-checks the reply against:

1. The file(s) referenced by the scope (read directly).
2. Frontmatter fields: `tools`, `skills`, `agent`, `context`, `name`.
3. `docs/architecture.md` for layer-boundary claims.
4. `AGENTS.md` for project-specific constraints.

Emits a short gap report — each bullet prefixed with ✅ (confirmed),
⚠ (uncertain / partially right), or ❌ (contradicted):

```
✅ correctly identifies this as L2 (agent orchestrates skills)
⚠ unclear whether context:fork is intentional here — your note says
   "preloaded skill" but the file uses `context: fork` which spawns
   subagent; see docs/wiring-the-chain.md
❌ you said it calls `fraud-check` but the `skills:` list only has
   `audit-log`; `fraud-check` is referenced nowhere
```

**Turn 4 (silent):** appends to `.four-layer-journal.md` (see
[`2026-04-24-journal-and-promotion.md`](2026-04-24-journal-and-promotion.md))
and offers promote-to-`docs/understanding/`.

**Budget:** 2–3 user-facing turns. Designed for frequent use without fatigue.

## Feynman-deep (explicit opt-in)

**Entry points:** `/four-layer-architecture:feynman-check --deep [topic]`;
`/four-layer-architecture:brainstorm-architecture` (routes here after menu
selection).

Four-step loop:

**Step 1 — Explain:**

Agent asks for a full explanation, no length cap. User answers.

**Step 2 — Counterfactual probe:**

Agent asks *one* counterfactual chosen to stress the weakest-looking part of
the answer:

> *"What breaks if `<specific component>` is removed / swapped / runs twice /*
> *returns an error?"*

**Step 3 — Explain again:**

User answers the counterfactual.

**Step 4 — Artifacts:**

Agent produces **two** outputs:

1. A gap report (same format as Feynman-lite) comparing user's explanations
   against code + docs.
2. A **teach-back claims list** — every non-trivial assertion the user made
   that the code doesn't yet support. These become TODOs, e.g.
   *"you said the workflow retries on 5xx but `billing-agent.md` has no retry
   logic — add it, or remove the claim from your mental model."*

## Agent spec — `teach-back-coach-agent`

Lives at `plugins/four-layer-architecture/agents/teach-back-coach-agent.md`.

* Tools: `Read`, `Bash` (for `scan-system.sh`), `Grep`, `Glob`.
* Skills preloaded: `feynman-protocol`, `system-scan`, `teach-back-journal`.
* Memory: off. Each invocation starts fresh; the journal carries state.
* System prompt responsibilities: enforce the protocol exactly, honour bail
  phrases, cite sources in the gap report, never mark something ✅ without
  a concrete citation.

## Skill spec — `feynman-protocol/SKILL.md`

Thin. Captures only the protocol rules (both variants above), bail-phrase
list, gap-report format, and the cross-check sources. No AI-specific prose
— the agent is the operator; the skill is the rules of the game.

## Testing (acceptance)

* Lite on a well-written agent file → produces ≥1 ✅ and 0 ❌.
* Lite on a file with a broken `skills:` reference → produces at least one ❌
  citing the missing skill.
* "skip" mid-Turn-2 → agent yields, no gap report emitted.
* Deep variant on `/brainstorm-architecture` pane-1 pick →
  emits both gap report and teach-back claims list.
