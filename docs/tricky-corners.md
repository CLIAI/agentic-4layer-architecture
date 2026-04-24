# Tricky corners

A catalog of conceptual knots in the 4-layer architecture pattern —
places where two mechanisms look similar but behave differently, where
an easy analogy breaks down, or where the obvious default is not the
right one.

## What this file is for

Each entry names one knot, explains *why* it's tricky, and offers
**anchor questions** — the kind of question a confident user answers
quickly and a shaky user hesitates on. It is a **question bank, not an
answer key**: the answers live in the source-of-truth docs each entry
points at.

## How Socratic uses it

The `/four-layer-architecture:socratic` command reads this file to
populate **Pane 2** of its two-pane menu (meta-pattern axis). Each
top-level `##` heading becomes a selectable topic. When the user picks
one, the `socratic-probe` agent uses the entry's anchor questions as
starting points and the source-of-truth pointers as verification
targets during the dialogue.

Invoke directly by heading:

```
/four-layer-architecture:socratic context:fork vs skills: field
```

## How to add your own

Append new `##` sections at the bottom of this file using the format
below. The `socratic-protocol` skill defines the full template; the
short form is:

* `## <title>` — the topic key.
* **Why tricky:** 1-3 sentences on the conceptual knot.
* **Good anchor questions:** 3+ bullets, each forcing a mechanism
  answer.
* **Source of truth:** pointers to existing docs (don't embed answers
  here — this is a question bank).

Entries about *your own* system are welcome and encouraged. The file
grows with the project.

---

## context:fork vs skills: field

**Why tricky:** Both make a skill's content available to an agent, but
via different mechanisms with different lifetimes and context costs.
`context: fork` spawns a subagent with the skill eagerly loaded into
its fresh context (isolated from the parent conversation). The
`skills:` frontmatter field, by contrast, lists skills the agent *can*
invoke lazily in the shared conversation — their content is only
pulled in on demand.

**Good anchor questions:**

* If I change the skill mid-session, which of the two picks up the
  change on the next invocation?
* Which costs more context tokens on an already-running agent?
* Which one can a skill recursively nest inside without blowing the
  context window?
* If two commands both route to the same agent, which mechanism
  isolates their state from each other?

**Source of truth:** `docs/wiring-the-chain.md`, `docs/examples.md`,
`docs/reference-cache/claude-code/plugins-reference.md`.

## Eager vs lazy skill loading

**Why tricky:** "Preload" and "available" sound synonymous but aren't.
An eagerly loaded skill (via `context: fork` or a command-level
preload) sits in the agent's context from turn one and costs tokens
whether or not it's used. A lazily available skill (listed in the
agent's `skills:` field) only consumes context when the agent decides
to invoke it — but its *description* is always in context so the agent
knows it exists.

**Good anchor questions:**

* For a skill that fires on 10% of invocations, which loading strategy
  minimises average context cost?
* The agent's `skills:` field lists five skills. How much context does
  that *minimum* cost, before any of them are invoked?
* If an agent never invokes a lazily-available skill, was listing it
  free?
* When would you prefer eager loading *despite* the token cost?

**Source of truth:** `docs/wiring-the-chain.md`, `docs/architecture.md`,
`docs/reference-cache/claude-code/skills.md`.

## When hooks replace vs augment a skill

**Why tricky:** Hooks and skills can both enforce invariants, but at
different moments and with different authority. A hook fires
deterministically on a tool event (PreToolUse, PostToolUse, etc.) and
can block; a skill is AI-invoked and advisory. If you move a check
from a skill into a hook you gain reliability — and lose the ability
for the agent to reason about *why* the check fired.

**Good anchor questions:**

* Name one invariant that *must* be a hook and cannot be a skill.
  Why?
* Name one check that *must* be a skill and cannot be a hook. Why?
* If a hook blocks, how does the agent learn what happened and adjust
  its next action?
* When you move a check from skill to hook, what does the agent lose?

**Source of truth:** `docs/hooks-as-guardrails.md`,
`docs/architecture.md`,
`docs/reference-cache/claude-code/hooks-reference.md`.

## L3 thinness principle

**Why tricky:** The temptation is to put "just a little logic" in a
slash command because it's the user-facing entry point. But L3 is
orchestration, not implementation — logic in L3 is invisible to other
agents, can't be reused, and bloats the command file past the point
where a user can read it in one glance.

**Good anchor questions:**

* Your command is 30 lines. Name three places that logic could move
  to — and why each destination is the right one.
* If another agent wanted to reuse the behaviour of this command,
  could it? What would it have to duplicate?
* What's the longest a command can reasonably be before it stops being
  L3?
* The command has a conditional branch. Should the branch live in the
  command, the agent, or the skill? Justify.

**Source of truth:** `docs/architecture.md`, `docs/examples.md`,
`docs/wiring-the-chain.md`.

## Memory-enabled agents

**Why tricky:** `memory: project` sounds like a free upgrade — the
agent "remembers" between sessions. In practice it means the agent
writes to and reads from a per-project memory directory, which
introduces state that outlives any single invocation and can drift
from the code. An agent with memory can be smarter over time, or it
can accumulate stale assumptions it keeps re-asserting.

**Good anchor questions:**

* When you set `memory: project`, *what* does the agent actually read
  and write? Where does it live on disk?
* How does an agent know when its remembered assumption has been
  invalidated by a code change?
* Which of your agents benefit from memory, and which are better off
  stateless? What's the test?
* If two agents share a project and one has memory, can the other
  read it?

**Source of truth:** `docs/architecture.md`, `docs/examples.md`,
`docs/reference-cache/claude-code/subagents.md`.

## ${CLAUDE_PLUGIN_ROOT} portability

**Why tricky:** `${CLAUDE_PLUGIN_ROOT}` resolves to the installed
plugin's directory at runtime, which is *not* the path the plugin was
authored at. Hard-coded paths work on the author's machine and break
on install. But the variable is also not available in every context —
skills use `${CLAUDE_SKILL_DIR}`, hooks use `${CLAUDE_PLUGIN_ROOT}`,
and some contexts use neither.

**Good anchor questions:**

* In a hook's `command:` field, which variable resolves to the plugin
  root, and why is that different from what a skill uses?
* If a skill references a bundled script, what's the correct path
  prefix? What breaks if you use a relative path?
* When you invoke `${CLAUDE_PLUGIN_ROOT}/scripts/foo.sh` from a hook,
  what's `$PWD` when `foo.sh` runs?
* A plugin ships on two systems with different install locations.
  Which paths in the plugin source must use a variable, and which can
  be literal?

**Source of truth:** `docs/ecosystem.md`,
`docs/hooks-as-guardrails.md`,
`docs/reference-cache/claude-code/plugins-reference.md`,
`docs/reference-cache/claude-code/hooks-reference.md`.
