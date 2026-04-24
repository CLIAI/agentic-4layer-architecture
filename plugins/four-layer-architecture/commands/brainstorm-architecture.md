---
name: brainstorm-architecture
description: "Guided entry into the teach-back system: scan the project, show a two-pane menu, then run Feynman-deep or Socratic on the chosen topic."
context: fork
agent: teach-back-coach
argument-hint: "[initial-note]"
---

Run the system-scan skill to enumerate this project's Claude-Code-relevant
surface (plugins, skills, agents, commands, docs, AGENTS.md). Then present a
**two-pane menu** to the user:

* **Pane 1 — your system:** every named agent / skill / command / plugin
  extracted from the scan, plus one "`<plugin-name>` end-to-end workflow"
  entry per plugin with ≥3 components.
* **Pane 2 — meta-pattern:** top-level `##` headings of
  [`docs/tricky-corners.md`](../../../docs/tricky-corners.md).

Ask the user to pick `[1-N / A-Z / custom topic]`. On selection:

* Pane 1 pick → run **Feynman-deep** on the chosen user-system component
  (see `feynman-protocol` skill).
* Pane 2 pick → delegate to the `socratic-probe` agent on the chosen
  meta-pattern entry (runs a 3–5 turn Socratic dialogue).
* Custom topic → ask the user which axis (system or meta-pattern), then
  route accordingly.

Before the menu, if `.claude/four-layer-architecture.local.md` does not
exist, offer to copy the example template there. If the user declines,
proceed with defaults (no re-prompt this session).

Initial note from the user (if any): `$ARGUMENTS`.

End the session by appending a journal entry and offering promote-to-
`docs/understanding/` per the `teach-back-journal` skill.

What did you learn about your own system by picking the topic you picked?
