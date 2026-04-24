---
name: feynman-protocol
description: "Rules for running a Feynman round: turn sequence, bail phrases, gap-report format."
version: 0.1.0
---

# Feynman Protocol

The rules of a Feynman teach-back round. This skill is **not** AI prose — it
is the rulebook. The `teach-back-coach` agent is the operator; this file
tells it (and any other caller) exactly how the game is played.

Two variants: **lite** (default, 3-turn) and **deep** (explicit opt-in,
4-step). Pick one at invocation time.

## Axes

Every round runs on exactly one axis, decided before turn 1:

* **Pane 1 — user's system:** a concrete file or component in this project.
* **Pane 2 — meta-pattern:** a 4-layer architecture concept.

Hook-triggered rounds default to Pane 1 scoped to the changed file.

## Feynman-lite (default)

Three user-facing turns. Designed for frequent use without fatigue.

**Turn 1 — Agent prompts (≤60 words):**

> *"You're about to work on `<scope>`. Before I act — in your own words,*
> *≤200 words: what is this component's job, what does it call, what*
> *calls it, where can it fail?"*

Before prompting, the agent may scope the neighbourhood via:

```
bash ${CLAUDE_PLUGIN_ROOT}/skills/system-scan/scripts/scan-system.sh <scope>
```

**Turn 2 — User replies** (or bails — see bail phrases below).

**Turn 3 — Agent emits gap report** after cross-checking against the sources
listed below. Format: bulleted, each bullet prefixed with ✅ / ⚠ / ❌ and a
citation.

**Turn 4 (silent):** the `teach-back-journal` skill appends the round to
`.four-layer-journal.md` and offers promotion to `docs/understanding/`.

**Budget:** 2–3 user-facing turns.

## Feynman-deep (explicit opt-in)

Entry: `/four-layer-architecture:feynman-check --deep [topic]` or the
`/four-layer-architecture:brainstorm-architecture` flow.

Four steps:

**Step 1 — Explain.** Agent asks for a full explanation, no length cap.
User answers.

**Step 2 — Counterfactual probe.** Agent asks *one* counterfactual, chosen
to stress the weakest-looking part of the answer:

> *"What breaks if `<specific component>` is removed / swapped / runs*
> *twice / returns an error?"*

**Step 3 — Explain again.** User answers the counterfactual.

**Step 4 — Two artifacts:**

1. **Gap report** — same format as Feynman-lite.
2. **Teach-back claims list** — every non-trivial assertion the user made
   that the code doesn't yet support. These become TODOs, e.g.
   *"you said the workflow retries on 5xx but `billing-agent.md` has no*
   *retry logic — add it, or remove the claim from your mental model."*

## Bail phrases

If the user's reply contains any of these as a standalone word or phrase,
the agent yields immediately without emitting a gap report and does not
re-prompt for the rest of the session:

* "skip"
* "enough"
* "move on"
* "I know this"
* "proceed"
* "next"

Yield message:

> *"Understood — proceeding. You can re-enter with*
> *`/four-layer-architecture:feynman-check` at any time."*

## Gap report — format

Each bullet begins with one symbol:

* `✅` — **confirmed** against a concrete citation.
* `⚠` — **uncertain or partial** — cite what is ambiguous.
* `❌` — **contradicted** by ground truth — cite the contradicting source.

**Hard rule:** `✅` without a citation is forbidden. If it cannot be cited,
it is `⚠` at best.

Example:

```
✅ correctly identifies this as L2 (agent orchestrates skills)
   — plugins/four-layer-architecture/agents/billing-agent.md frontmatter `skills:`
⚠ unclear whether `context: fork` lifetime is intentional
   — docs/wiring-the-chain.md §"fork vs. preload"
❌ claimed it calls `fraud-check`; `skills:` list only has `audit-log`
   — plugins/four-layer-architecture/agents/billing-agent.md L3-L8
```

## Cross-check sources

For **Pane 1 (user's system):**

1. The file(s) in the scope — read directly.
2. Frontmatter fields: `tools`, `skills`, `agent`, `context`, `name`.
3. `docs/architecture.md` — layer-boundary claims.
4. `AGENTS.md` (or `CLAUDE.md`) — project-specific constraints.

For **Pane 2 (meta-pattern):**

* `docs/concepts-vs-implementation.md`
* `docs/wiring-the-chain.md`
* `docs/philosophy.md`

## Invariants

* Never ✅ without citation.
* Never block or re-prompt after a bail phrase.
* Never prescribe fixes — report gaps, let the user act.
* Always append to `.four-layer-journal.md` after a completed round (via the
  `teach-back-journal` skill). Bailed rounds are not journalled.

## Acceptance tests

* Lite on a well-written agent file → ≥1 ✅, 0 ❌.
* Lite on a file with a broken `skills:` reference → at least one ❌ citing
  the missing skill.
* "skip" mid-Turn-2 → agent yields, no gap report.
* Deep variant on a Pane-1 pick → emits both gap report and teach-back
  claims list.
