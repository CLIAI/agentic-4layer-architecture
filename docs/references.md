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

* **Claude Code Overview**: [docs.anthropic.com/en/docs/claude-code](https://docs.anthropic.com/en/docs/claude-code)
  * Main documentation hub for Claude Code features and configuration

### Specific Sections

* **Commands** -- User-facing `/slash-commands` defined in `.claude/commands/*.md`
  * How to define custom commands with `$ARGUMENTS` placeholder
  * Project-level vs user-level command directories

* **Agents** -- Sub-agents defined in `.claude/agents/*.md`
  * YAML frontmatter: `model`, `allowed_tools`, behavioral directives
  * How agents are invoked via the `Agent` tool

* **Skills** -- Reusable atomic operations in `.claude/skills/*/SKILL.md`
  * YAML frontmatter for metadata and tool restrictions
  * Bundling scripts alongside SKILL.md
  * How skills are discovered and invoked by agents

* **Hooks** -- Lifecycle event handlers in `.claude/settings.json`
  * All 12+ hook events (PreToolUse, PostToolUse, etc.)
  * Matcher patterns for targeting specific tools
  * Hook scripts receive JSON on stdin and return JSON on stdout

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
