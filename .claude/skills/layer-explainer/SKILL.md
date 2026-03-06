---
name: layer-explainer
description: "Explains which layer of the 4-layer architecture a file belongs to and why"
allowed-tools: Read, Glob, Grep
---

# Layer Explainer Skill

Given a file path, determine which layer of the 4-layer agentic architecture it belongs to
and explain its role in the delegation chain.

## Classification Rules

Classify the file into one of:

* **Layer 4: Command** — Files in `.claude/commands/`. Should be thin (5-15 lines),
  use `context: fork` + `agent:` to delegate. Creates a `/slash-command`.

* **Layer 3: Agent** — Files in `.claude/agents/`. Should have `tools:`, `skills:`,
  and a system prompt. Orchestrates workflows by reasoning about preloaded skills.

* **Layer 2: Skill** — `SKILL.md` files in `.claude/skills/*/`. Should have
  `allowed-tools:` and reference bundled scripts via `${CLAUDE_SKILL_DIR}`.

* **Layer 1: Script** — Shell/Python files in `scripts/` or skill-bundled `scripts/`.
  Should be deterministic, no AI reasoning, testable standalone.

* **Cross-cutting: Hook** — Files referenced in `.claude/settings.json` hooks.
  Should be lightweight enforcement, not feature implementation.

* **Configuration** — `CLAUDE.md`, `AGENTS.md`. Persistent project context.

## Output Format

For each file, report:

1. **Layer**: Which layer it belongs to
2. **Purpose**: What it does in one sentence
3. **Upstream**: What invokes it (which layer above)
4. **Downstream**: What it delegates to (which layer below)
5. **Frontmatter check**: Are field names correct per official spec?
6. **Improvement hint**: One question to provoke architectural thinking

## Reference

* Official skill docs: https://code.claude.com/docs/en/skills
* Official subagent docs: https://code.claude.com/docs/en/sub-agents
* Official hooks docs: https://code.claude.com/docs/en/hooks
