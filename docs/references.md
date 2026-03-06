# References and Resources

Links, sources, and further reading for the 4-layer agentic architecture pattern.

---

## Primary Sources

### IndyDevDan: Playwright Browser Automation with Claude Code

* **Video**: [Claude Code + Playwright Browser Automation](https://www.youtube.com/watch?v=efctPj6bjCY)
  * Public demonstration of using Claude Code with Playwright for browser-based QA
  * Shows the layered pattern: commands delegating to agents, agents using skills, skills calling scripts
  * Key insight: separation of thin commands from heavy agent logic

### Companion Gist: 4-Layer Architecture Notes

* **Gist**: [gwpl/02bcacb9a11ebd6c61bb7fd40f553bc3](https://gist.github.com/gwpl/02bcacb9a11ebd6c61bb7fd40f553bc3)
  * Condensed notes on the 4-layer architecture pattern
  * Includes layer definitions, naming conventions, and quick-reference rules

### David Shapiro: Cognitive Horizon

* **Gist**: [gwpl/748b6b9988a575dafc50cf54c258bed5](https://gist.github.com/gwpl/748b6b9988a575dafc50cf54c258bed5)
  * The concept of "cognitive horizon" -- the boundary of what you can conceptualize and design
  * Understanding architectural patterns deeply extends this horizon
  * Applies directly: knowing the 4-layer pattern expands what you consider buildable

---

## Official Claude Code Documentation

* **Claude Code Overview**: [code.claude.com/docs](https://code.claude.com/docs/en)
  * Main documentation hub -- also available as [llms.txt](https://code.claude.com/docs/llms.txt) for AI consumption

### Specific Sections (with frontmatter field references)

* **Skills** -- [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
  * Commands and skills are now merged: `.claude/commands/` and `.claude/skills/` both create `/slash-commands`
  * YAML frontmatter fields: `name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`
  * String substitutions: `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`
  * `context: fork` + `agent: <name>` runs the skill in an isolated subagent
  * Dynamic context injection with `!`command\`\` syntax

* **Subagents** -- [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents)
  * YAML frontmatter fields: `name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`
  * `skills` field preloads skill content into subagent context at startup
  * `memory` field enables persistent cross-session learning (`user`, `project`, or `local` scope)
  * Model aliases: `sonnet`, `opus`, `haiku`, `inherit`
  * Tool restriction: `Agent(worker, researcher)` limits which subagents can be spawned

* **Hooks** -- [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)
  * Nested format: each entry has `matcher` and `hooks` array with `type` field
  * Hook types: `command` (shell), `http` (HTTP endpoint), `prompt` (LLM-based)
  * Exit codes: 0=allow, 2=block (stderr fed back to Claude for self-correction)
  * 12+ lifecycle events: PreToolUse, PostToolUse, SubagentStart, SubagentStop, SessionStart, etc.
  * Hooks can be defined in settings.json, subagent frontmatter, or skill frontmatter

* **Agent Teams** -- [code.claude.com/docs/en/agent-teams](https://code.claude.com/docs/en/agent-teams)
  * Multi-agent coordination across separate sessions
  * For parallel work that exceeds single-session context

* **Plugins** -- [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)
  * Package and distribute skills, agents, and hooks as installable plugins

---

## Public Frameworks and Tools

### claude-flow

* Multi-agent orchestration framework for Claude Code
* Demonstrates patterns for coordinating multiple agents with shared state
* Open source reference for team-based agentic workflows

### Anthropic Cookbooks

* Official collection of patterns and examples for building with Claude
* Includes examples of tool use, multi-turn conversations, and agent patterns
* Useful for understanding the primitives the 4-layer architecture builds upon

---

## Key Computer Science Principles

The 4-layer architecture is grounded in established software engineering principles:

### Separation of Concerns

* Each layer handles one kind of responsibility
* Commands handle user interaction; agents handle reasoning; skills handle atomic operations; scripts handle deterministic execution
* Changes in one layer do not cascade to others

### Single Responsibility Principle

* A command does one thing: delegate
* An agent does one thing: orchestrate a workflow
* A skill does one thing: perform an atomic operation
* A script does one thing: execute a deterministic task
* A hook does one thing: enforce a cross-cutting rule

### Dependency Inversion

* Upper layers depend on abstractions (skill names, agent names), not concrete implementations
* You can swap a script without changing the skill; swap a skill without changing the agent

### Testability

* Layer 1 (Scripts) are independently testable with standard shell testing tools
* Layer 2 (Skills) can be tested with mocked scripts
* Layer 3 (Agents) can be tested with mocked skills
* Layer 4 (Commands) are tested by verifying they delegate correctly
* Hooks are tested by providing mock tool-use events

### Defense in Depth

* Multiple layers of validation: hooks check safety, agents check logic, skills check inputs, scripts check arguments
* No single point of failure for safety-critical constraints
* Trust hierarchy provides layered enforcement

---

## Further Reading

* **CLIAI GitHub Organization**: [github.com/CLIAI](https://github.com/CLIAI) -- Community explorations of Claude Code agentic patterns
* **Anthropic Documentation**: [docs.anthropic.com](https://docs.anthropic.com) -- Official documentation for all Claude products
* **Mermaid Diagrams**: [mermaid.js.org](https://mermaid.js.org) -- Diagramming tool used throughout this documentation for architecture visualizations
