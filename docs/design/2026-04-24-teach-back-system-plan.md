---
title: Teach-back system — umbrella plan
date: 2026-04-24
status: draft
scope: design / umbrella
related_issues: []
depends_on: []
supersedes: []
---

# Teach-back system — umbrella plan

This is the master plan for adding **Feynman + Socratic teach-back mechanics** to
the `four-layer-architecture` plugin so users of the plugin *exercise and deepen*
their own architectural understanding instead of outsourcing it to the AI.

It operationalises the stance already articulated in [`docs/philosophy.md`](../philosophy.md)
("cognitive telescope, not prompt jockey") by turning that philosophy into
concrete skills, agents, commands, and hooks that the plugin ships.

## Problem statement

Out of the box, a well-crafted agentic plugin risks becoming an *autopilot*: the
user invokes it, gets a result, and never has to articulate their own mental
model of the system they are building. That contradicts the argument
IndyDevDan makes in the originating video ("don't outsource your understanding
of how the most powerful tech humans have made for interacting with agentic
tech") and the [philosophy of this repo](../philosophy.md).

The **teach-back system** adds a cross-cutting *nudge + scaffolding* layer that:

* catches moments where the user is about to make an architectural change and
  advises (non-blocking) a short teach-back before proceeding;
* offers both **Feynman** rounds (user explains their system to the AI; AI
  checks what they got right / missed) and **Socratic** rounds (AI probes one
  tricky corner with 3–5 turn dialogue);
* works on **two axes** — (1) the user's own system and workflows in *their*
  domain, and (2) the meta-pattern of the 4-layer architecture itself;
* leaves an append-only **journal** and an optional promote-to-committed-notes
  flow so understanding accretes in the repo alongside the code it describes;
* is **always skippable** via three independent channels (persistent prefs,
  declared-in-AGENTS.md, in-session bail phrase).

## Success criteria

1. A user who installs this plugin sees a **first-use nudge** exactly once per
   project pointing at `/four-layer-architecture:brainstorm-architecture`.
2. Structural edits (new agent / skill / command / plugin.json change)
   produce a single-line advisory via `PreToolUse` hook — never blocking.
3. `/four-layer-architecture:feynman-check [topic]` runs a lightweight
   single-turn teach-back on the specified or auto-detected scope.
4. `/four-layer-architecture:socratic [topic]` runs a 3–5 turn probing dialogue
   on either a user-system topic or a meta-pattern tricky corner.
5. `/four-layer-architecture:brainstorm-architecture` presents the **two-pane
   menu** (Pane 1 scanned from the user's repo, Pane 2 from
   [`docs/tricky-corners.md`](../tricky-corners.md)).
6. Every round appends to `.four-layer-journal.md` (gitignored) and offers
   promotion to `docs/understanding/L{0..3}.md` or `meta-pattern.md`.
7. Three skip channels are documented and honoured: per-project prefs in
   `.claude/four-layer-architecture.local.md`, declared-in-`AGENTS.md`, and
   natural-language bail phrases mid-session.
8. The README's new **Intent** section carries the IndyDevDan quote (or clearly
   labelled paraphrase with attribution) and links to
   [`docs/philosophy.md`](../philosophy.md).
9. Plugin validates via the standard plugin-validator. Namespaced invocations
   (`/four-layer-architecture:…`) are the canonical form in all docs.
10. Each of the six GitHub issues raised for this work has a trail of
    implementing commits and a closing comment summarising accomplishment.

## Sub-designs

Each row is a design doc that covers one concern. Read them in roughly
implementation order.

| # | Doc | Covers |
|---|-----|--------|
| 1 | [`2026-04-24-anti-outsourcing-framing.md`](2026-04-24-anti-outsourcing-framing.md) | README Intent section, IndyDevDan quote sourcing, tie to philosophy.md |
| 2 | [`2026-04-24-trigger-model.md`](2026-04-24-trigger-model.md) | Mixed-trigger model, advisory hook, three skip channels |
| 3 | [`2026-04-24-feynman-protocol.md`](2026-04-24-feynman-protocol.md) | Feynman-lite (1-turn) and Feynman-deep (4-step) specs |
| 4 | [`2026-04-24-socratic-protocol.md`](2026-04-24-socratic-protocol.md) | Socratic dialogue spec + tricky-corners catalog format |
| 5 | [`2026-04-24-system-scanning.md`](2026-04-24-system-scanning.md) | `scan-system.sh`, `detect-change.sh`, two-pane menu generation |
| 6 | [`2026-04-24-journal-and-promotion.md`](2026-04-24-journal-and-promotion.md) | Journal format, rotation, promote-to-`docs/understanding/` flow |
| 7 | [`2026-04-24-namespacing-and-commands.md`](2026-04-24-namespacing-and-commands.md) | Plugin namespacing, command inventory, frontmatter conventions |
| 8 | [`2026-04-24-plugin-settings-pattern.md`](2026-04-24-plugin-settings-pattern.md) | `.claude/four-layer-architecture.local.md` settings pattern |
| 9 | [`2026-04-24-github-issues-to-raise.md`](2026-04-24-github-issues-to-raise.md) | The six issues, their bodies, and labeling |

## Implementation order

1. **Design drop** — write docs (this one + the nine linked above), commit.
2. **Issues** — create 4 immediate + 2 follow-up issues from doc #9.
3. **Transcript** — fetch IndyDevDan transcript, save to
   `docs/reference-cache/indydevdan-4-layer-transcript.md`, grep for the
   anti-outsourcing quote.
4. **L0 scripts** — `scan-system.sh`, `detect-change.sh`,
   `suggest-teach-back.sh`. Single focused commit.
5. **Feynman stack** — command + agent + skill. Commit.
6. **Socratic stack** — command + agent + skill + `docs/tricky-corners.md`. Commit.
7. **Scanning & journal skills** — `system-scan/SKILL.md`,
   `teach-back-journal/SKILL.md`, `docs/understanding/` stubs. Commit.
8. **Brainstorm entry + settings template** — `brainstorm-architecture.md`,
   `.claude/four-layer-architecture.local.md.example`, `.gitignore`. Commit.
9. **Hook wiring** — extend `hooks.json`, update
   `check-prerequisites.sh` for first-use nudge. Commit.
10. **README** — Intent section + quote + namespaced commands + repo structure. Commit.
11. **QA** — run plugin-validator, verify each success-criterion above.
12. **Issue closure** — for each issue, post summary + commit refs, close.

## Non-goals

* No network calls, no databases, no external storage.
* No global (cross-project) preferences — only per-project.
* No natural-language intent detection in hooks (fragile / annoying).
* No blocking behaviour — all nudges are advisory.
* No auto-commit of `.four-layer-journal.md` — always gitignored.

## Open questions deferred

* Cross-harness portability of the protocols (Cursor, Aider) — tracked in
  `docs/ecosystem.md`, not part of this design.
* Measurement: how do we know teach-back actually improves understanding?
  Qualitative journal review + optional tags in `docs/understanding/`.
  A quantitative answer requires field data we don't have yet.
