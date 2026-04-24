---
name: socratic
description: "Run a Socratic probing dialogue on one tricky corner (AI asks, user answers)"
context: fork
agent: socratic-probe
argument-hint: "[topic]"
---

Delegate to the @socratic-probe agent with `$ARGUMENTS` as the topic.

If no topic is supplied, the agent falls back to the two-pane menu
(Pane 1: components discovered in this project via
`${CLAUDE_PLUGIN_ROOT}/skills/system-scan/scripts/scan-system.sh`;
Pane 2: entries from `docs/tricky-corners.md`).

The agent runs a 3-5 turn dialogue, follows up on the weakest part of
each answer, and closes with a summary of where the user's model held
up, was partial, or diverged from code and docs.
