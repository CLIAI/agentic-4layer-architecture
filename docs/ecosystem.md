# Ecosystem: Building, Bundling, and Distributing the 4-Layer Pattern

You understand the architecture. Now here's how to take your components from
local `.claude/` directories to distributable, composable plugins — and where
to look in the broader ecosystem. This guide is deliberately concise: it points
to official documentation rather than duplicating it, and suggests rather than
prescribes.

---

## The Implementation Path

The 4-layer pattern describes *what* to build. The ecosystem around modern
agentic harnesses provides *how* to package and share it. The progression is
the same regardless of tooling:

1. **Develop components** — Start with deterministic scripts, wrap them in reusable [skills](https://code.claude.com/docs/en/skills), compose workflows (implemented as [custom agents](https://code.claude.com/docs/en/sub-agents)), and expose orchestration entry points (implemented as [custom commands](https://code.claude.com/docs/en/skills)), with [hooks](https://code.claude.com/docs/en/hooks) for automated guardrails. Each component is independently useful.

2. **Bundle as a plugin** — Group related components into a distributable unit: a directory with a manifest, your skills/agents/commands/hooks, and any supporting scripts or resources.

3. **Distribute via marketplace** — Publish your plugin to a registry (a git repo with an index file) so others can install it by name. Private marketplaces for teams, public ones for the community.

4. **Discover and compose** — Install plugins from multiple marketplaces. Layer them. Your project's architecture becomes a composition of your own components plus community plugins.

5. **Automate invocation** — Wrap harness invocations in project-level launch scripts (Justfiles, Makefiles, shell/Python scripts) that set the right model, load specific plugins via [CLI flags](https://code.claude.com/docs/en/cli-usage) (e.g. `--plugin-dir`, `--model`, `--agent`), and encode repeatable entry points for CI or team workflows.

Each step is optional. A single skill with a bundled script is already
valuable. You don't need plugins or marketplaces until you're sharing across
projects or teams.

---

## Cross-Harness Portability

The 4-layer pattern is not tied to any single tool. The emerging [Agent Skills
open standard](https://agentskills.io) validates this — a `SKILL.md` file with
YAML frontmatter and markdown instructions works across Claude Code, Gemini
CLI, Cursor, Codex, and 8+ other coding agents.

This matters because:

* **Your investment in skills is portable.** A well-structured skill (Layer 2) with bundled scripts (Layer 1) can move between harnesses without rewriting.
* **The pattern transcends tooling.** Whether your harness calls them "skills," "rules," "prompts," or "tools," the architectural separation — deterministic scripts wrapped by declarative AI instructions, composed into workflows, exposed via entry points — remains the same.
* **Scripts are the ultimate portability layer.** A bash script doesn't care which AI harness invoked it. This is why Layer 1 (Scripts) exists as a separate concern — it's the part that survives harness migrations.

The standard is young but growing. If you're building skills today, structuring
them as `SKILL.md` + supporting files in a directory is already the
cross-compatible format.

---

## Claude Code: Reference Implementation

Claude Code offers the most complete implementation of the 4-layer pattern
today, with first-class support for each layer and a full distribution
pipeline. It's also unique in supporting skills with bundled scripts across
local CLI, cloud environments, and even the claude.ai chatbot.

**Developing components:**

* [Skills](https://code.claude.com/docs/en/skills) support bundled scripts via `${CLAUDE_SKILL_DIR}`, progressive disclosure (metadata always in context, full content loads on invocation), and scoped hooks
* [Custom agents](https://code.claude.com/docs/en/sub-agents) preload skills via the `skills:` frontmatter field, with model selection, permission modes, and memory scoping
* [Hooks](https://code.claude.com/docs/en/hooks) cover 18+ lifecycle events with four types: command, HTTP, prompt, and agent — exit code 2 blocks with self-correcting feedback
* Consider using [`plugin-dev`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev) by Anthropic — a 7-skill development toolkit that guides you through creating each component type, with validation scripts and production examples

**Bundling and distributing:**

* [Plugins](https://code.claude.com/docs/en/plugins) package skills, agents, commands, hooks, and MCP servers into a single directory with a `plugin.json` manifest
* Test locally with `--plugin-dir ./my-plugin` before publishing
* Validate structure with `claude plugin validate .`
* [Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) are git repos with a `marketplace.json` index — create private ones for your team or publish to community registries
* Enterprise teams can enforce marketplace allowlists via managed settings

**Discovering ecosystem:**

* [Official Anthropic plugins](https://github.com/anthropics/claude-plugins-official) — curated, maintained by Anthropic
* Community aggregators: [awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins), [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
* [Public Agent Skills repo](https://github.com/anthropics/skills) — cross-harness compatible

**CLI automation** ([full reference](https://code.claude.com/docs/en/cli-usage)):

* `--plugin-dir` — load a plugin for a single invocation
* `--model` — select model per run
* `--agent` — start with a specific custom agent
* `--allowedTools` — scope tool access
* `-p` / `--print` — headless mode for CI/scripts

---

## Other Harnesses

The pattern applies wherever an agentic tool supports layered configuration.
Current landscape:

| Harness | Extension Mechanism | Notes |
|---------|-------------------|-------|
| [OpenCode](https://opencode.ai) | MCP servers, agent skills, custom tools, LSP, SDK | Go-based CLI/TUI; MIT licensed |
| [Kilo Code](https://github.com/Kilo-Org/kilocode) | Agent Manager, subagent delegation, OpenCode server | VS Code extension; 500+ models via OpenRouter |
| [Codex CLI](https://github.com/openai/codex) | MCP integration, agent skills | OpenAI's terminal agent |
| [Cursor](https://cursor.com) | `.cursorrules`, MCP servers, Agent Skills compatible | VS Code fork |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Agent Skills standard compatible | Google; cross-compatible skill format |
| [Crush](https://github.com/charmbracelet/crush) | Extensible agent framework | By Charm; composable CLI agents |
| [Aider](https://aider.chat) | Conventions files, MCP, multi-model | Git-aware AI pair programming |
| [Goose](https://github.com/block/goose) | Extensions, MCP servers, custom toolkits | By Block; open-source AI agent |

This table will age. The principle won't: if your harness supports declarative
instructions, reusable skill units, and composable agents, the 4-layer
separation applies.

---

## Resources

Organized by what you're trying to do:

**Learning the pattern:**

* This repo's [architecture deep dive](architecture.md) and [philosophy](philosophy.md)
* [IndyDevDan's original video](https://www.youtube.com/watch?v=efctPj6bjCY) demonstrating the 4-layer chain
* [Jon Roosevelt's blog post](https://jonroosevelt.com/blog/agent-stack-layers) — secondary public reference

**Developing components (Claude Code):**

* [`plugin-dev` toolkit](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev) — guided creation of skills, agents, hooks, commands
* [Skills docs](https://code.claude.com/docs/en/skills) · [Subagents docs](https://code.claude.com/docs/en/sub-agents) · [Hooks docs](https://code.claude.com/docs/en/hooks)
* [IndyDevDan's bowser repo](https://github.com/disler/bowser) — canonical reference implementation

**Distributing plugins (Claude Code):**

* [Creating plugins](https://code.claude.com/docs/en/plugins) · [Plugin reference](https://code.claude.com/docs/en/plugins-reference)
* [Creating marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) · [Discovering plugins](https://code.claude.com/docs/en/discover-plugins)
* [CLI reference](https://code.claude.com/docs/en/cli-usage) — flags for automation scripts

**Cross-harness portability:**

* [Agent Skills open standard](https://agentskills.io)
* [Anthropic public skills repo](https://github.com/anthropics/skills)

**Community:**

* [awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins) — 29+ plugins across 9 categories
* [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — curated skills, hooks, agents, plugins
