# Concepts vs Implementation

The 4-layer pattern is first a set of **conceptual roles**, then a set of
**implementation artifacts**. This document makes the mapping explicit so the
pattern can travel across harnesses: only the artifacts change when you port
to a different agentic tool; the concepts hold.

This doc addresses (and supersedes) the original proposal in
[issue #1](https://github.com/CLIAI/agentic-4layer-architecture/issues/1)
and resolves the numbering-direction discussion in
[issue #5](https://github.com/CLIAI/agentic-4layer-architecture/issues/5).

---

## The canonical mapping

| # | Concept (what it is) | Example implementation (in Claude Code) | On-disk location | Cognitive mode |
|---|----------------------|-----------------------------------------|------------------|----------------|
| **L0** | **Tools & Primitives** — deterministic, no-AI substrate; "below the AI" | Scripts (bash, Python, any executable) | `scripts/*.sh`, `scripts/*.py`, skill-bundled `scripts/` | Mechanical: "what command, what exit code, what stdout" |
| **L1** | **SOPs / Capabilities** — documented, reusable "what Claude can do", each a Standard Operating Procedure | Skills (`SKILL.md` with YAML frontmatter, optionally bundling L0 tools) | `.claude/skills/*/SKILL.md` | Procedural: "how do I do this one thing well?" |
| **L2** | **Workflows** — specialist pipelines that sequence multiple SOPs to meet a business objective | Custom Agents (subagents) | `.claude/agents/*.md` | Business-logic: "in what order, with what fallbacks?" |
| **L3** | **Orchestration** — thin, user-facing entry prompts; coordinate workflows | Custom Commands (`/slash-command`) | `.claude/commands/*.md` | User-intent: "what one request did the human make?" |
| **L4** | **Launchers** — invocation recipes that start `claude` with a specific flag set; make the stack reproducibly callable from cron/CI/aliases | `justfile`, `Makefile`, `run.sh`, Python entrypoints, shell aliases, cron entries, CI job configs | Project root / `scripts/` / CI config | Ops/integration: "how do I run this reliably in six months?" |
| **Bonus** | **Guardrails** — cross-cutting enforcement, a dimension not a layer | Hooks (PreToolUse, PostToolUse, SessionStart, …) | `.claude/settings.json`, subagent frontmatter, skill frontmatter | Safety/policy: "what should never happen?" |

### Why this shape

The split is driven by **cognitive focus sharding** (see
[issue #7](https://github.com/CLIAI/agentic-4layer-architecture/issues/7)
and [issue #9](https://github.com/CLIAI/agentic-4layer-architecture/issues/9)):
each layer is a distinct *mode of attention* with its own working-memory
requirements. A human reasoning about "does this URL request make sense in
this workflow?" is in a different cognitive mode than one reasoning about
"what's the right `curl` flag for this content type?". The layers mirror that
shift and scope context accordingly.

---

## Comparison to IndyDevDan's original framing

The primary source of this pattern is IndyDevDan's public breakdown of his
[Bowser browser automation framework][video] (see also
[Jon Roosevelt's canonical summary][jon]). Dan numbers his layers **bottom-up**,
starting at 1:

| IndyDevDan's layer (bottom-up, 1-based) | His label / role | Our layer | Match |
|---|---|---|---|
| L1 | **Skills** — "raw capability / vocabulary" | **L1 SOPs / Capabilities** | Identical numbering; our "SOPs / Capabilities" framing explicitly captures both the *procedural* and *vocabulary* faces of a skill |
| L2 | **Agents** — "scale the skill / specialist workflow" | **L2 Workflows** | Identical numbering; near-identical concept |
| L3 | **Commands** — "orchestration layer / higher-order prompt" | **L3 Orchestration** | Identical numbering and concept (we even share the word "orchestration") |
| L4 | **Justfile / Reusability** — "entry point, discoverable interface" | **L4 Launchers** | Identical numbering; we generalize justfile to any management script |
| — (scripts subsumed into Skills) | — | **L0 Tools & Primitives** | We split this out explicitly; Dan keeps scripts inside his L1/Skills |

**Net:** adopting bottom-up numbering lets a reader who arrives from
[IndyDevDan's video][video] translate our L1/L2/L3/L4 1-for-1 with his. The
one divergence is L0: we name Tools & Primitives as their own layer because
they are reusable across SOPs and deserve a testable surface; Dan folds them
into each Skill. Both views are defensible; ours is more explicit, his is
more compact.

[video]: https://www.youtube.com/watch?v=efctPj6bjCY
[jon]: https://jonroosevelt.com/blog/agent-stack-layers

---

## Numbering direction

Bottom-up: **L0 is the foundation, L4 is the outermost surface**. Higher
numbers sit above lower numbers in the stack diagram, which matches:

* OSI network stack intuition (L1 physical → L7 application)
* IndyDevDan's original numbering (L1 Skills → L4 Justfile)
* "Lower level = closer to the machine" mental model
* [issue #5](https://github.com/CLIAI/agentic-4layer-architecture/issues/5): primary-source alignment

A top-down view is equally defensible and may feel natural for people who
think of `/slash-commands` as "level 1" (the first thing they see). If you
prefer that frame internally, just flip the numbers when you map to our docs:
our L4 ↔ top-down L0/L1, our L0 ↔ top-down L4/L5.

---

## Multi-entry-point reminder

The mapping above could imply a strict L4 → L3 → L2 → L1 → L0 call chain.
**It isn't.** (See
[issue #10](https://github.com/CLIAI/agentic-4layer-architecture/issues/10).)

You can legitimately enter the stack at *any* layer:

* **L4:** `just ui-review https://example.com` — launcher starts `claude` with flags
* **L3:** User types `/ui-review …` at the Claude Code prompt
* **L2:** User prompts Claude to delegate to a specific agent by name
* **L1:** User invokes a skill directly for a one-off capability
* **L0:** Developer runs `./scripts/capture.sh` with no AI involved at all

Each layer is self-contained enough to be entered directly. L4 Launchers
merely make one specific invocation *reproducible*; they are not the only
way in.

---

## Guardrails are a dimension, not a tier

Guardrails (Hooks) intentionally don't get a numbered slot. They apply
*across* every layer: `PreToolUse` can block an L0 tool, an L1 SOP, or an
L2 workflow all the same. They are a **dimension**, not a tier.

The "Bonus" label is a reminder: when the other layers are not sufficient to
enforce a constraint mechanically, hooks are the correct tool. They should
not be the *first* tool — prefer putting correctness into the SOP/workflow
it belongs to — but they are the backstop when a rule must hold regardless
of which layer is active.

---

## Quick cross-reference

When you read older docs or external sources, this table helps you translate:

| You may see | We call it |
|---|---|
| "Commands layer" / "slash-commands" | **L3 Orchestration** |
| "Agents layer" / "subagents" | **L2 Workflows** |
| "Skills layer" / "capabilities" / "vocabulary" | **L1 SOPs / Capabilities** |
| "Scripts layer" / "tools" / "shell helpers" | **L0 Tools & Primitives** |
| "Justfile layer" / "Reusability layer" / "task runner" | **L4 Launchers** |
| "Hooks layer" / "cross-cutting layer" | **Bonus Guardrails** |

---

## See also

* [README.md](../README.md) — top-level diagram
* [docs/architecture.md](architecture.md) — deep dive per layer
* [docs/wiring-the-chain.md](wiring-the-chain.md) — exact delegation mechanisms
* [docs/philosophy.md](philosophy.md) — why the separation exists (cognitive horizon)
* [docs/hooks-as-guardrails.md](hooks-as-guardrails.md) — the guardrails dimension
* [docs/references.md](references.md) — sources and further reading
