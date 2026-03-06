# Agents Guide for agentic-4layer-architecture

## What This Repo Is

A public knowledge base documenting the **4-layer agentic architecture pattern** for Claude Code and similar AI-assisted development tools. The architecture organizes agent configuration into four composable layers:

1. **Configuration** (CLAUDE.md / AGENTS.md) -- persistent instructions, conventions, project context
2. **Automation** (hooks) -- event-driven triggers that enforce standards automatically
3. **Skills** (slash commands) -- reusable, parameterized workflows invoked on demand
4. **Orchestration** (agents / teams) -- multi-agent coordination for complex tasks

This repo lives at **github.com/CLIAI/agentic-4layer-architecture**.

## Philosophy

This architecture is about **extending your cognitive horizon**, not offloading your thinking. Every layer you build should deepen your understanding of the problem space. If you find yourself copy-pasting prompts without understanding them, stop. Read the docs. Understand the "why."

See `docs/philosophy.md` for the full argument.

## For AI Agents Working Here

* **Embody cognitive growth.** When contributing to this repo, explain your reasoning. Challenge assumptions. Ask "why?" not just "how?"
* **No private project references.** This is a public knowledge base. Only reference publicly available information, tools, and documentation.
* **Use `*` for bullet points** in markdown (top-level). This is our style convention.
* **Keep docs honest and provocative.** No marketing fluff. If something has tradeoffs, say so.
* **Point to official docs** rather than duplicating them. Link to Claude Code documentation for specifics on YAML frontmatter, hook events, skill format, etc.
* **Deep dives live in `docs/`**. The root README gives the overview; detailed explorations go in the docs directory.
