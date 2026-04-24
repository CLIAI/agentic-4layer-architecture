---
name: socratic-protocol
description: "Rules for running a Socratic round: dialogue shape, question-selection heuristic, catalog-entry template, closing-summary format."
version: 0.1.0
---

# Socratic Protocol

This skill encodes the **contract** for a Socratic round. It is invoked
by the `socratic-probe` agent (and may be invoked by other agents that
want to run a Socratic drill-down). It contains no AI reasoning of its
own — just the shape, heuristics, and templates.

Companion command: `/four-layer-architecture:socratic [topic]`.

## Dialogue shape (the contract)

A Socratic round is a **bounded dialogue**:

* **1 anchor question** — opens on the topic, forces a mechanism answer.
* **Up to 4 follow-up questions** — each one drills into the weakest
  part of the previous answer.
* **1 closing summary** — ✅ / ⚠ / ❌ with citations.

Total: **3-5 user-facing turns**. Never exceed 5 without the user
explicitly asking for more. Never ask more than one question per turn.

```
turn 1: AGENT  anchor question
turn 2: USER   answer
turn 3: AGENT  follow-up on weakest span
turn 4: USER   answer
...
turn N: AGENT  closing summary (✅ / ⚠ / ❌ + citations + promote offer)
```

## Question-selection heuristic

After each user answer, pick the next question by scanning the answer
for **one** of these signals, in priority order:

1. **Contradiction with code/docs.** If the user's claim contradicts
   something you can verify with `Read` or `Grep`, that is the target.
   Ask the user to reconcile: *"You said X — but `<path:line>` shows
   Y. Which is running?"*
2. **Ambiguity.** A vague noun, an undefined pronoun, a hand-waved
   step ("it just figures it out"). Ask them to make it concrete:
   *"What does 'it figures it out' mean here — who reads what?"*
3. **Reasoning gap.** The user skipped a step. Name the skipped step
   and ask them to fill it: *"Between X and Z you jumped over Y — walk
   me through Y."*

If two signals tie, prefer contradiction over ambiguity over gap.

If nothing is weak — the user nailed it — say so and either move to
closing or ask a deliberately harder anchor on an adjacent sub-topic.
Do not invent weakness where there is none.

## Anchor question heuristics

A good anchor:

* Forces a **mechanism** answer, not a definition.
* Is answerable in **one sentence** by a confident user.
* Has a verifiable ground truth in code or docs.

A bad anchor:

* Is open-ended ("tell me about X").
* Requires the user to guess your opinion.
* Has no single right shape ("what's the best way to...").

## Catalog-entry template

Each entry in `docs/tricky-corners.md` is a tight block:

```markdown
## <concise title of the tricky corner>

**Why tricky:** <1-3 sentence explanation of the conceptual knot —
what's easy to confuse, and why.>

**Good anchor questions:**

* <question that forces a mechanism answer>
* <question that surfaces a common misconception>
* <question whose answer is verifiable in code or docs>

**Source of truth:** `<path/to/doc.md>`, `<path/to/other-doc.md>`.
```

Rules:

* Title is the `##` heading — used as the topic key when the user runs
  `/four-layer-architecture:socratic <title>`.
* At least three anchor questions.
* At least one source-of-truth pointer. Point to existing docs; do not
  embed answers inline in the catalog (it's a question bank, not an
  answer key).

Users are invited to append their own entries for their own systems.
The catalog grows.

## Closing-summary format

The closing turn uses this exact shape:

```
Socratic summary — <topic>

✅ Held up:
  * <claim, with file:line or frontmatter-field citation>

⚠ Partial:
  * <claim, with citation of what was missing>

❌ Diverged:
  * <claim, with citation of the code/docs it contradicts>

Suggested next step:
  * Promote this round to docs/understanding/<topic-slug>.md? [y/N]
```

Rules:

* At least one bullet must carry a concrete citation (`path:line`,
  quoted frontmatter field, or exact doc heading).
* If a category has no entries, omit it entirely — do not write
  "(none)".
* If nothing was verifiable at all, replace the three categories with
  a single honest line: *"No claims in this round were verifiable
  against code or docs — the topic may be too abstract for a Socratic
  drill, or the round was too short."*
* The promote offer is always the last line.

## Bail phrases (shared with trigger model)

Recognise in any user reply: *"skip"*, *"enough"*, *"move on"*,
*"I know this"*, *"proceed"*, *"next"*. On detection, yield with the
standard phrase (see
`docs/design/2026-04-24-trigger-model.md`) and emit an abbreviated
closing summary with whatever was gathered.

## Anti-patterns

* **Stacking questions.** "What is X, and how does Y interact with Z,
  and why does W?" — ask one.
* **Leading the witness.** "Don't you think X is really just Y?" —
  neutral phrasing only.
* **Lecturing disguised as a question.** "Wouldn't you agree that the
  correct answer involves A, B, and C?" — if you know the answer, ask
  a question that lets the user discover it.
* **Inventing facts.** Never assert behaviour of code you haven't read
  this turn. Open the file.
