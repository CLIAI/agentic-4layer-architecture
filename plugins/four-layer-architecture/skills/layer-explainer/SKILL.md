---
name: layer-explainer
description: "Explains which layer of the 4-layer architecture a file belongs to and why"
allowed-tools: Read, Glob, Grep
---

# Layer Explainer Skill

Given a file path, determine which layer of the agentic architecture it belongs to
and explain its role in the delegation chain. Each layer is named by its
**conceptual role**, with the Claude Code primitive as the example implementation.

## Classification Rules

Classify the file into one of:

* **L4: Launcher** — Files like `justfile`, `Makefile`, `run.sh`, Python entrypoints,
  shell aliases, cron entries, CI job configs that invoke `claude` with specific flags
  (`--plugin-dir`, `--agent`, `--settings`, `-p`, ...). Declarative, not implementing
  AI logic themselves.

* **L3: Orchestration (Command)** — Files in `.claude/commands/`. Should be thin
  (5–15 lines), use `context: fork` + `agent:` to delegate. Creates a `/slash-command`.

* **L2: Workflow (Agent)** — Files in `.claude/agents/`. Should have `tools:`, `skills:`,
  and a system prompt. Sequences SOPs by reasoning about preloaded skill content.

* **L1: SOP / Capability (Skill)** — `SKILL.md` files in `.claude/skills/*/`. Should have
  `allowed-tools:` and reference bundled scripts via `${CLAUDE_SKILL_DIR}`. Both a
  named capability (what Claude can do) and a documented procedure (how to do it).

* **L0: Tool / Primitive (Script)** — Shell/Python files in `scripts/` or skill-bundled
  `scripts/`. Deterministic, no AI reasoning, testable standalone. "Below the AI."

* **Bonus: Guardrail (Hook)** — Files referenced in `.claude/settings.json` hooks
  (or subagent/skill frontmatter). Lightweight enforcement, not feature implementation.

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
