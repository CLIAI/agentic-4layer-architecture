# The 4-Layer Agentic Architecture

**Commands → Agents → Skills → Scripts (+Hooks)**

> *"Your brain becomes the bottleneck — AI waits for YOU to catch up."*
> — David Shapiro, on [Cognitive Horizons](https://gist.github.com/gwpl/748b6b9988a575dafc50cf54c258bed5)

This repository documents a **layered architecture pattern** for orchestrating
AI-assisted workflows in [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
It's not a framework to install — it's a **thinking framework** to internalize.

The architecture separates *what to do* from *how to orchestrate it* from
*how to do each step* from *mechanical execution*. Four layers. Each with a
clear purpose. Each making you think harder about the right abstraction level.

```
┌──────────────────────────────────────────────────────────┐
│  Layer 4: Commands    (.claude/commands/*.md)             │
│  "What to do" — User-facing /slash-commands.             │
│  Thin. 5-15 lines. Orchestrate, don't implement.        │
├──────────────────────────────────────────────────────────┤
│  Layer 3: Agents      (.claude/agents/*.md)              │
│  "How to orchestrate" — Stateful pipeline managers.      │
│  Sequence skills, handle errors, ask at decision points. │
├──────────────────────────────────────────────────────────┤
│  Layer 2: Skills      (.claude/skills/*/SKILL.md)        │
│  "How to do each step" — Atomic, reusable operations.    │
│  One skill = one thing done well. Can bundle scripts.    │
├──────────────────────────────────────────────────────────┤
│  Layer 1: Scripts     (scripts/*.sh, scripts/*.py)       │
│  "Mechanical execution" — No AI. Deterministic.          │
│  Testable standalone. Instrumentable for telemetry.      │
├──────────────────────────────────────────────────────────┤
│  Bonus:   Hooks       (.claude/settings.json)            │
│  Cross-cutting enforcement. Guardrails. Telemetry.       │
│  When other layers aren't sufficient — hooks are.        │
└──────────────────────────────────────────────────────────┘
```

---

## Why Should You Care?

Not because it makes AI do more for you. Because it makes **you think more clearly**.

Every time you decide "this belongs in a skill, not a script" or "this command
is too thick — the logic should be in the agent" — you're exercising
architectural judgment. You're **extending your cognitive horizon**, not
offloading cognition to a machine.

> AI as a gym for the mind: spotter, not replacement.

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

This invokes a [Command](.claude/commands/review-my-architecture.md) →
[Agent](.claude/agents/socratic-reviewer-agent.md) →
[Skill](.claude/skills/architecture-audit/SKILL.md) →
[Script](.claude/skills/architecture-audit/scripts/scan-layers.sh)
pipeline that **audits your project** and asks Socratic questions about
your design decisions. It doesn't give answers. It develops *your* understanding.

**How the chain works technically:**

* The command uses `context: fork` + `agent: socratic-reviewer` to launch a subagent
* The subagent's `skills: [architecture-audit]` preloads the skill content
* The skill references its bundled `scripts/scan-layers.sh`
* Each layer delegates downward — no upward dependencies

---

## The Core Thesis

**Orchestration of workflows via Custom Commands** that orchestrate
**Custom Agents** encoding SOPs and workflows, which use **Custom Skills**
encoding the actual details of how actions are done — with the feature of
**bundled custom scripts** for:

* Improved command-line ergonomics
* Instrumentation for telemetry
* Safety assertions and permission checks
* Background work that doesn't need AI reasoning

And **Hooks** as the enforcement layer — injecting guardrails, validation,
and automation whenever the other layers aren't sufficient.

### Why Scripts Matter (The Underappreciated Layer)

When a skill bundles a script, something powerful happens:

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
* [Skills](https://code.claude.com/docs/en/skills) — Layer 4/2: Commands have been merged into skills. Use `context: fork` + `agent` to delegate to subagents
* [Custom Subagents](https://code.claude.com/docs/en/sub-agents) — Layer 3: YAML frontmatter with `tools`, `skills`, `memory`, `hooks`
* [Hooks](https://code.claude.com/docs/en/hooks) — The enforcement layer: nested format with `type: command`/`http`/`prompt`
* [Agent Teams](https://code.claude.com/docs/en/agent-teams) — Multi-agent coordination across separate sessions
* [Plugins](https://code.claude.com/docs/en/plugins) — Package and distribute skills, agents, and hooks

### Conceptual Foundation

* **[Extending Cognitive Horizon](https://gist.github.com/gwpl/748b6b9988a575dafc50cf54c258bed5)** — David Shapiro on why AI should expand what you can think, not replace thinking
* [docs/philosophy.md](docs/philosophy.md) — our take on cognitive growth vs cognitive offloading

---

## Repository Structure

```
agentic-4layer-architecture/
├── README.md                          ← You are here
├── AGENTS.md                          ← Instructions for AI agents in this repo
├── docs/
│   ├── architecture.md                ← Deep dive: the 4 layers + hooks
│   ├── wiring-the-chain.md            ← HOW each layer delegates to the next (frontmatter fields)
│   ├── philosophy.md                  ← Cognitive horizon, not cognitive offloading
│   ├── examples.md                    ← Concrete pattern applications
│   ├── hooks-as-guardrails.md         ← Hooks deep dive
│   └── references.md                  ← All links, resources, further reading
├── .claude/
│   ├── commands/
│   │   └── review-my-architecture.md  ← Example: thin orchestration command
│   ├── agents/
│   │   └── socratic-reviewer-agent.md ← Example: agent that asks, doesn't tell
│   └── skills/
│       └── architecture-audit/
│           ├── SKILL.md               ← Example: atomic audit operation
│           └── scripts/
│               └── scan-layers.sh     ← Example: mechanical discovery script
└── LICENSE
```

Every file in `.claude/` is both **documentation** and **working code**.
Run `/review-my-architecture` to see the 4-layer pattern in action —
*on this very repo*.

---

## The Architecture in One Sentence

> **Commands say what. Agents say when and in what order. Skills say how.
> Scripts just do it. Hooks make sure everyone behaves.**

If that sentence makes sense to you, you understand the pattern.
If it doesn't yet — the [architecture deep-dive](docs/architecture.md) will get you there.

---

## A Word About "Cognitive Offloading"

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

> *"Cognitive horizons represent the scope of what a mind can conceptualize.
> AI's role is to act as a cognitive telescope, expanding horizons —
> not replacing the observer."*

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
