# The 4-Layer Agentic Architecture

**Launchers → Orchestration → Workflows → SOPs → Tools & Primitives (+ Guardrails)**

This repository documents a **layered architecture pattern** for orchestrating
AI-assisted workflows in [Claude Code](https://code.claude.com/docs/en).
It's not a framework to install — it's a **thinking framework** to internalize.

We name each layer by its **conceptual role** and give the Claude Code primitive
as the current implementation. The pattern is harness-agnostic: the concepts
survive a switch to another agentic tool; only the implementation artifacts change.

> **Want a compact reference?** See the [handy gist](https://gist.github.com/gwpl/02bcacb9a11ebd6c61bb7fd40f553bc3) — a condensed version you can feed directly to your AI agent.

The architecture separates *how to invoke the stack* from *what a user asks for*
from *how to sequence the work* from *how to do one thing well* from *mechanical
execution*. Five layers plus a cross-cutting dimension. Each making you think
harder about the right abstraction level.

```
┌──────────────────────────────────────────────────────────────────────┐
│  Bonus  : Guardrails   (e.g. Hooks — .claude/settings.json)          │
│           Cross-cutting enforcement. A dimension, not a layer.       │
├──────────────────────────────────────────────────────────────────────┤
│  Layer 4: Launchers    (e.g. Justfile / Makefile / run.sh / Python)  │
│           Management scripts that invoke `claude` with specific      │
│           flags (--plugin-dir, --agent, --settings, -p, ...).        │
│           Make the stack reproducibly callable from cron/CI/aliases. │
├──────────────────────────────────────────────────────────────────────┤
│  Layer 3: Orchestration (e.g. Custom Commands — .claude/commands/)   │
│           "When and in what sequence" — user-facing /slash-commands. │
│           Thin. 5–15 lines. Orchestrate, don't implement.            │
├──────────────────────────────────────────────────────────────────────┤
│  Layer 2: Workflows     (e.g. Custom Agents — .claude/agents/*.md)   │
│           "How to sequence capabilities" — specialist pipelines.     │
│           Sequence SOPs, handle errors, ask at decision points.      │
├──────────────────────────────────────────────────────────────────────┤
│  Layer 1: SOPs / Capabilities                                        │
│           (e.g. Skills — .claude/skills/*/SKILL.md)                  │
│           Standard Operating Procedures — what Claude can do,        │
│           documented as reusable capabilities. One SOP = one thing   │
│           done well. Can bundle L0 tools.                            │
├──────────────────────────────────────────────────────────────────────┤
│  Layer 0: Tools & Primitives (e.g. Scripts — scripts/*.sh, *.py)     │
│           Deterministic substrate. No AI. Testable standalone.       │
│           Instrumentable for telemetry. "Below the AI."              │
└──────────────────────────────────────────────────────────────────────┘
```

**Numbering direction.** We number bottom-up: L0 is the foundation, L4 is the
outermost entry point. This matches [IndyDevDan's original framing][indydevdan]
(he numbers Skills=1, Agents=2, Commands=3, Justfile=4) while still giving
scripts their own explicit tier as L0. See [docs/concepts-vs-implementation.md](docs/concepts-vs-implementation.md)
for the full mapping.

[indydevdan]: https://www.youtube.com/watch?v=efctPj6bjCY

---

## Why Should You Care?

Not because it makes AI do more for you. Because it makes **you think more clearly**.

Every time you decide "this belongs in a skill, not a script" or "this command
is too thick — the logic should be in the agent" — you're exercising
architectural judgment.

The developers who thrive with AI agents won't be the ones who copy-paste prompts.
They'll be the ones who **design systems** — who understand separation of concerns
so deeply that they can decompose *any* workflow into the right layers.

This repo is here to help you get there.

---

## Quick Start

> **TODO/WIP** — After we finish polishing this repo, this section will contain
> a one-liner to bootstrap the architecture in your project. For now, read on
> and build understanding first. That's the point.

If you want to jump straight to the illustrative example that lives *in this
repo* (yes, the repo eats its own dog food):

```
/review-my-architecture
```

This invokes an L3 [Orchestration](.claude/commands/review-my-architecture.md) →
L2 [Workflow](.claude/agents/socratic-reviewer-agent.md) →
L1 [SOP](.claude/skills/architecture-audit/SKILL.md) →
L0 [Tool](.claude/skills/architecture-audit/scripts/scan-layers.sh)
pipeline that **audits your project** and asks Socratic questions about
your design decisions. It doesn't give answers. It develops *your* understanding.

**How the chain works technically:**

* The command uses `context: fork` + `agent: socratic-reviewer` to launch a subagent
* The subagent's `skills: [architecture-audit]` preloads the skill content
* The skill references its bundled `scripts/scan-layers.sh`
* Each layer delegates downward — no upward dependencies

---

## The Core Thesis

**Orchestration (L3)** via Custom Commands delegates to **Workflows (L2)**
implemented as Custom Agents, which compose **SOPs / Capabilities (L1)**
implemented as Skills, which bundle **Tools & Primitives (L0)** — deterministic
scripts — for:

* Improved command-line ergonomics
* Instrumentation for telemetry
* Safety assertions and permission checks
* Background work that doesn't need AI reasoning

**Launchers (L4)** — justfiles, Makefiles, `run.sh`, Python entrypoints — sit
on top and invoke `claude` with the right flags (`--plugin-dir`, `--agent`,
`--settings`, `-p`, …) so the stack is reproducibly callable from cron, CI,
or a teammate's laptop.

**Guardrails (Bonus)** — Hooks — are the enforcement dimension, injecting
validation and automation whenever the other layers aren't sufficient.

### Why L0 (Tools & Primitives) Matters

When an L1 SOP bundles an L0 tool (a script), something powerful happens:

1. **The script is testable standalone** — `./scripts/scan-layers.sh /path/to/project` works without Claude Code
2. **The script is instrumentable** — add logging, metrics, timing without touching AI prompts
3. **The script is auditable** — security review a bash script, not a probabilistic prompt
4. **The script is fast** — no token cost, no API latency, just execution
5. **The script sets boundaries** — mechanical work stays mechanical

This is where many agentic architectures fail: they put everything in prompts.
The 4-layer pattern forces you to ask: "Does this *need* AI reasoning, or is it
just filesystem traversal with a fancy wrapper?"

---

## Learning Resources

Understanding this architecture requires **hands-on practice** with the
underlying primitives. Don't just read about it — build with it.

### Essential Viewing

* **[IndyDevDan: 4-Layer Architecture — Skills → Agents → Commands → Reusability](https://www.youtube.com/watch?v=efctPj6bjCY)**
  The video that crystallizes this pattern through Playwright browser automation.
  Watch how Dan builds capabilities layer by layer, from raw scripts up to
  orchestrated multi-agent workflows.
  * [Companion reference notes](https://gist.github.com/gwpl/02bcacb9a11ebd6c61bb7fd40f553bc3) — maps Dan's concepts to Claude Code primitives

### Official Documentation

* [Claude Code Overview](https://code.claude.com/docs/en) — start here (also available as [llms.txt](https://code.claude.com/docs/llms.txt))
* [CLI reference](https://docs.claude.com/en/docs/claude-code/cli-reference) — flags that L4 Launchers use: `--plugin-dir`, `--agent`, `--settings`, `--mcp-config`, `-p`, `--bare`, `--permission-mode`, `--max-turns`, `--max-budget-usd`
* [Skills](https://code.claude.com/docs/en/skills) — L3 Orchestration & L1 SOPs: commands have been merged into skills. Use `context: fork` + `agent` to delegate to subagents
* [Custom Subagents](https://code.claude.com/docs/en/sub-agents) — L2 Workflows: YAML frontmatter with `tools`, `skills`, `memory`, `hooks`
* [Hooks](https://code.claude.com/docs/en/hooks) — Guardrails (Bonus): nested format with `type: command`/`http`/`prompt`
* [Agent Teams](https://code.claude.com/docs/en/agent-teams) — Multi-agent coordination across separate sessions
* [Plugins](https://code.claude.com/docs/en/plugins) — Package and distribute skills, agents, and hooks

### Ecosystem & Distribution

* **[Building, Bundling, and Distributing](docs/ecosystem.md)** — From local components to plugins, marketplaces, and cross-harness portability

### Conceptual Foundation

* **[Cognitive Horizons](https://gist.github.com/gwpl/748b6b9988a575dafc50cf54c258bed5)** — David Shapiro's "I was the bottleneck, not the AI" (transcript, glossary, diagrams)
* [docs/philosophy.md](docs/philosophy.md) — our take on designing with AI, not delegating to it

---

## Repository Structure

```
agentic-4layer-architecture/
├── README.md                          ← You are here
├── AGENTS.md                          ← Instructions for AI agents in this repo
├── docs/
│   ├── architecture.md                ← Deep dive: the 4 layers + hooks
│   ├── wiring-the-chain.md            ← HOW each layer delegates to the next (frontmatter fields)
│   ├── philosophy.md                  ← Why design matters more than prompting
│   ├── examples.md                    ← Concrete pattern applications
│   ├── hooks-as-guardrails.md         ← Hooks deep dive
│   ├── ecosystem.md                   ← Building, bundling, distributing as plugins
│   └── references.md                  ← All links, resources, further reading
├── .claude/
│   ├── commands/
│   │   ├── review-my-architecture.md  ← Pipeline 1: Socratic architecture review
│   │   └── explain-layer.md           ← Pipeline 2: Layer classification guide
│   ├── agents/
│   │   ├── socratic-reviewer-agent.md ← Asks questions, never prescribes (memory-enabled)
│   │   └── layer-guide-agent.md       ← Explains where files fit in the 4 layers
│   └── skills/
│       ├── architecture-audit/
│       │   ├── SKILL.md               ← Atomic audit with frontmatter validation
│       │   └── scripts/
│       │       └── scan-layers.sh     ← Mechanical discovery + wiring validation
│       └── layer-explainer/
│           └── SKILL.md               ← Layer classification knowledge
└── LICENSE
```

Every file in `.claude/` is both **documentation** and **working code**.
Two pipelines demonstrate the pattern in action:

* `/review-my-architecture` — Socratic audit of your project's 4-layer compliance
* `/explain-layer <file>` — Explains which layer a file belongs to and traces the chain

---

## The Architecture in One Sentence

> **Launchers say how to start. Orchestration says what the user asked for.
> Workflows say when and in what order. SOPs say how to do each thing well.
> Tools & Primitives just do it. Guardrails make sure everyone behaves.**

If that sentence makes sense to you, you understand the pattern.
If it doesn't yet — the [architecture deep-dive](docs/architecture.md) and the
[concepts vs implementation](docs/concepts-vs-implementation.md) mapping will get you there.

---

## A Word About Copy-Pasting

It's tempting to use this architecture to just... let AI do everything.
Copy-paste a command structure, never think about why the layers exist,
treat it as a recipe.

**Don't.**

The value isn't in the commands you create. It's in the **architectural
decisions** you make while creating them. Every "should this be a skill or a
script?" question develops your judgment. Every "is this agent too coupled to
one pipeline?" question grows your design sense.

IndyDevDan didn't become effective with Claude Code by copying someone's
`.claude/` directory. He became effective by **understanding the primitives
deeply** — reading the docs, experimenting with frontmatter options,
discovering what `tools` and `skills` do to agent behavior, learning when
hooks are the right tool vs when skills are sufficient.

That's the path. There are no shortcuts worth taking.
See [docs/philosophy.md](docs/philosophy.md) for the full argument.

---

## Contributing

This is a living document. If you've applied the 4-layer pattern and
discovered something worth sharing — patterns, anti-patterns, examples,
hard-won insights — contributions are welcome.

The best contributions won't be "here's my `.claude/` directory."
They'll be "here's what I learned about decomposition while building X."

---

## License

[MIT](LICENSE) — Use freely. Think deeply. Grow intentionally.

---

*Built with the conviction that the best AI tooling makes humans
sharper, not lazier.*
