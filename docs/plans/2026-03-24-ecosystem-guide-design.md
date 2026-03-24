# Design: `docs/ecosystem.md` — Building, Bundling, and Distributing the 4-Layer Pattern

**Date:** 2026-03-24
**Status:** Approved

## Goal

Add a lightweight, isolated reference file that points readers (human and AI) toward the practical "how to build and distribute" side of the 4-layer pattern — without duplicating docs, pushing any specific tool, or diluting the repo's architectural focus.

## Design Principles

* **80% pattern-first, 20% Claude Code lead** — Structure around activities, with Claude Code as the most mature concrete example
* **Dual audience** — Serves developers browsing AND AI agents needing discoverable tooling pointers
* **Isolated file** — Maximum utility, minimum interference with the repo's main course
* **Conceptual language first** — Use "workflows," "orchestration" as primary terms, map to implementation in parentheses (e.g., "workflows (implemented as custom agents)")

## File: `docs/ecosystem.md`

### Section 1: Header

One paragraph framing: "You understand the 4-layer pattern. Now here's how to build, bundle, and distribute it."

### Section 2: The Implementation Path (~160 words)

Harness-agnostic 5-step progression:

1. **Develop components** — scripts → [skills](https://code.claude.com/docs/en/skills) → workflows ([custom agents](https://code.claude.com/docs/en/sub-agents)) → orchestration entry points ([custom commands](https://code.claude.com/docs/en/skills)) + [hooks](https://code.claude.com/docs/en/hooks)
2. **Bundle as a plugin** — directory + manifest + components
3. **Distribute via marketplace** — git repo registry, private or public
4. **Discover and compose** — install from multiple marketplaces, layer them
5. **Automate invocation** — Justfiles/Makefiles/shell/Python launch scripts wrapping harness [CLI flags](https://code.claude.com/docs/en/cli-usage) (`--plugin-dir`, `--model`, `--agent`)

Each step optional. A single skill with a bundled script is already valuable.

### Section 3: Cross-Harness Portability (~160 words)

* [Agent Skills open standard](https://agentskills.io) — `SKILL.md` works across Claude Code, Gemini CLI, Cursor, Codex, 8+ others
* Investment in skills is portable
* Scripts (Layer 1) are the ultimate portability layer — they survive harness migrations
* The standard is young but the format is already cross-compatible

### Section 4: Claude Code — Reference Implementation (~280 words)

The largest section. Structured around the implementation path:

**Developing components:**

* Skills with bundled scripts via `${CLAUDE_SKILL_DIR}`, progressive disclosure
* Custom agents with `skills:` preloading, model selection, memory scoping
* 18+ hook lifecycle events, four types, self-correcting feedback
* [`plugin-dev` toolkit](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev) — 7-skill development guide by Anthropic

**Bundling and distributing:**

* Plugins: `plugin.json` manifest, `--plugin-dir` for local testing, `claude plugin validate .`
* Marketplaces: git repos with `marketplace.json`, private or public, enterprise allowlists

**Discovering ecosystem:**

* [Official Anthropic plugins](https://github.com/anthropics/claude-plugins-official)
* Community: [awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins), [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
* [Public Agent Skills repo](https://github.com/anthropics/skills)

**CLI automation:**

* `--plugin-dir`, `--model`, `--agent`, `--allowedTools`, `-p`/`--print`

### Section 5: Other Harnesses (~100 words)

Table format:

| Harness | Extension Mechanism | Notes |
|---------|-------------------|-------|
| OpenCode | MCP, agent skills, custom tools, LSP, SDK | Go CLI/TUI; MIT |
| Kilo Code | Agent Manager, subagent delegation | VS Code; 500+ models |
| Codex CLI | MCP, agent skills | OpenAI terminal agent |
| Cursor | `.cursorrules`, MCP, Agent Skills | VS Code fork |
| Gemini CLI | Agent Skills compatible | Google |
| Crush | Extensible agent framework | By Charm; composable CLI |
| Aider | Conventions files, MCP, multi-model | Git-aware pair programming |
| Goose | Extensions, MCP, custom toolkits | By Block; open-source |

Closing: "This table will age. The principle won't."

### Section 6: Resources (~150 words)

Organized by activity:

* **Learning the pattern** — this repo's docs, IndyDevDan video, Jon Roosevelt blog
* **Developing components** — `plugin-dev`, official docs, bowser repo
* **Distributing plugins** — plugin/marketplace docs, CLI reference
* **Cross-harness portability** — agentskills.io, Anthropic skills repo
* **Community** — awesome-claude-plugins, awesome-claude-code

## Integration Points

**README.md** — One line in "Learning Resources":

> * **[Ecosystem & Distribution](docs/ecosystem.md)** — Building, bundling, and distributing your 4-layer components as plugins

**docs/references.md** — One line in "Official Claude Code Documentation":

> * **Ecosystem guide**: [docs/ecosystem.md](ecosystem.md) — implementation path from components to marketplaces

## What This File Is NOT

* Not a tutorial — points to official docs
* Not Claude Code-specific — pattern-first, tools as examples
* Not exhaustive — curated pointers, not comprehensive coverage
* Not prescriptive — "consider," "you might," never "you must"
