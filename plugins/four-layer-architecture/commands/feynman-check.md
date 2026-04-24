---
name: feynman-check
description: "Run a Feynman teach-back round on a specified or auto-detected scope."
context: fork
agent: teach-back-coach
argument-hint: "[topic] [--deep]"
---

Run a Feynman teach-back round using the @teach-back-coach agent.

Parse `$ARGUMENTS`:

* If it contains `--deep`, run the **Feynman-deep** variant (4-step loop: explain, counterfactual, explain again, artifacts).
* Otherwise run **Feynman-lite** (3-turn: prompt, user reply, gap report).
* Any non-flag tokens are the `<topic>` — a file path, layer name, or concept. If absent, use the most recently edited architectural file as scope.

Honour bail phrases ("skip", "enough", "move on", "I know this", "proceed", "next") — yield immediately without a gap report.

Never mark a claim ✅ without a concrete citation (file path, frontmatter field, or doc reference).

End with: **What did you just discover about this component that you could not have stated five minutes ago?**
