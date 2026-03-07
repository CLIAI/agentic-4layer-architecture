# Research Findings: 4-Layer Chain Validation

**Date:** 2026-03-06
**Context:** Validating whether the 4-layer architecture pattern is actually supported by Claude Code's official specification, and researching IndyDevDan's real-world implementations.

---

## Key Finding: The Chain Works

The full Command → Agent → Skill → Script chain is **architecturally supported** by the official Claude Code specification:

### Layer 4 → Layer 3: `context: fork` + `agent: <name>`

From [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

> "With `context: fork`, you write the task in your skill and pick an agent type to execute it."

The `agent:` field accepts both built-in agents (`Explore`, `Plan`, `general-purpose`) and **custom subagent names** from `.claude/agents/`.

### Layer 3 → Layer 2: `skills: [name]`

From [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents):

> "The full content of each skill is injected into the subagent's context, not just made available for invocation. Subagents don't inherit skills from the parent conversation; you must list them explicitly."

### Limitation: Depth-2 Maximum

From the same doc:

> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

This means the chain terminates at depth 2: a skill can launch a subagent, but that subagent cannot launch another subagent. However, the subagent CAN use preloaded skills that reference scripts, which is sufficient for the 4-layer pattern.

### Historical Bug (Fixed)

GitHub Issue #17283 (closed Jan 2026): `context: fork` / `agent:` were **ignored** when skills were invoked via the `Skill` tool. This was fixed in ~Claude Code v2.1, and the official docs now describe this as working.

---

## IndyDevDan (disler) Research

### Identity

* **Name:** Dan Disler
* **GitHub:** [github.com/disler](https://github.com/disler) (3.3k followers)
* **YouTube:** IndyDevDan

### Key Repositories

| Repo | Stars | Key Pattern |
|------|-------|-------------|
| [disler/bowser](https://github.com/disler/bowser) | - | Canonical 4-layer: agent with `skills:` preloading |
| [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) | 3.2k+ | All 13 hook events + agents + commands |
| [disler/claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) | 1.2k+ | Multi-agent real-time observability with skills |
| [disler/claude-code-damage-control](https://github.com/disler/claude-code-damage-control) | - | Security SKILL.md + hook wiring |
| [disler/claude-code-is-programmable](https://github.com/disler/claude-code-is-programmable) | - | Programmable Claude Code patterns |

### Concrete Wiring Example from `bowser`

**Agent** (`playwright-bowser-agent.md`):

```yaml
---
name: playwright-bowser-agent
description: Headless browser automation agent using Playwright CLI...
model: opus
color: orange
skills:
  - playwright-bowser
---
```

**Skill** (`playwright-bowser/SKILL.md`):

```yaml
---
name: playwright-bowser
description: Headless browser automation using Playwright CLI...
allowed-tools: Bash
---
```

The `skills:` array in the agent causes the full `SKILL.md` content to be injected at startup (eager loading). This confirms the pattern works exactly as described in our architecture docs.

### Additional Pattern: Justfile as Extra Layer

Dan uses a **Justfile** as an additional entry layer above commands, providing terminal-level entry points. This is beyond the 4-layer model but shows how the pattern can be extended.

---

## Frontmatter Field Names: Official Spec

A major finding: several field names in our original docs were **wrong**.

### Agent Frontmatter (`.claude/agents/*.md`)

Official fields per [code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents):

| Field | Type | Notes |
|-------|------|-------|
| `name` | string (required) | Lowercase + hyphens |
| `description` | string (required) | When Claude should delegate |
| `tools` | string/list | NOT `allowed_tools` |
| `disallowedTools` | string/list | Tools to deny |
| `model` | string | `sonnet`, `opus`, `haiku`, `inherit` |
| `skills` | list | Full content injected at startup |
| `memory` | string | `user`, `project`, `local` |
| `hooks` | object | Scoped lifecycle hooks |
| `permissionMode` | string | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | number | Max agentic turns |
| `background` | boolean | Always run in background |
| `isolation` | string | `worktree` for git isolation |

### Skill Frontmatter (`.claude/skills/*/SKILL.md`)

Official fields per [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | Lowercase + hyphens, max 64 chars |
| `description` | string (recommended) | When to use this skill |
| `allowed-tools` | string | NOT `allowed_tools` (hyphenated!) |
| `disable-model-invocation` | boolean | Prevent auto-invocation |
| `user-invocable` | boolean | Show in `/` menu |
| `argument-hint` | string | Autocomplete hint |
| `model` | string | Model to use |
| `context` | string | `fork` for subagent isolation |
| `agent` | string | Which subagent (with `context: fork`) |
| `hooks` | object | Scoped lifecycle hooks |

### String Substitutions in Skills

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed |
| `$ARGUMENTS[N]` / `$N` | Specific argument by index |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Skill's directory path |

---

## Commands → Skills Merge

From [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills):

> "Custom commands have been merged into skills. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way."

This happened in Claude Code v2.1.3. The 4-layer conceptual model still holds — Layer 4 commands are just "thin skills" that use `context: fork` + `agent:` to delegate.

---

## Hook Configuration Format Change

Hooks now use a nested format with `type` field:

```json
{
  "matcher": "Bash",
  "hooks": [
    { "type": "command", "command": "script.sh" }
  ]
}
```

Supported hook types:

* `command` — Shell script
* `http` — HTTP endpoint
* `prompt` — LLM-based hook

Exit codes:

* `0` — Allow
* `2` — Block (stderr fed back to Claude for self-correction)

---

## Additional Discoveries from Deep Research

### 18 Hook Events (Not 12)

The official docs list **18 hook events**, not the 12 we originally documented. Additional events:

* `TeammateIdle` — Agent teams only
* `TaskCompleted` — Task completion notification
* `InstructionsLoaded` — Fires per CLAUDE.md file load (debugging)
* `ConfigChange` — Settings/skills changes (matcher: `user_settings`/`project_settings`/etc.)
* `WorktreeCreate` / `WorktreeRemove` — Git worktree lifecycle

### 4 Hook Handler Types (Not Just Command)

* `type: "command"` — Shell script (original)
* `type: "http"` — POST JSON to HTTP endpoint (useful for observability)
* `type: "prompt"` — Single-turn LLM eval (Haiku default)
* `type: "agent"` — Multi-turn subagent with tools (up to 50 turns)

### `context: fork` vs `skills:` — Two Wiring Patterns

IndyDevDan uses BOTH patterns for different purposes:

| Pattern | Loading | Use case |
|---------|---------|----------|
| `context: fork` + `agent:` in skill | Lazy (content = task prompt) | User-invoked workflows |
| `skills: [...]` in agent frontmatter | Eager (full content at startup) | Agent needs domain knowledge |

He prefers `skills:` field in `bowser` because agents need browser expertise injected at spawn time for parallelism to work reliably.

### Known Bug: `skills:` Not Preloaded for Team-Spawned Teammates

GitHub Issue [#29441](https://github.com/anthropics/claude-code/issues/29441): When agents are spawned as team teammates, the `skills:` frontmatter field is **not preloaded**. This affects agent teams but not regular subagent spawning.

### IndyDevDan's Actual Layer Numbering

Interestingly, Dan numbers his layers **bottom-up** (Skill=1, Agent=2, Command=3, Justfile=4), while our repo numbers them **top-down** (Command=4, Agent=3, Skill=2, Script=1). Both are valid — the key insight is the separation, not the numbering.

### Jon Roosevelt's Blog Post

[jonroosevelt.com/blog/agent-stack-layers](https://jonroosevelt.com/blog/agent-stack-layers) credits "IndyDevDan's breakdown of Bowser" as the direct source for the 4-layer framework. This serves as a secondary public reference for the pattern.

### `async: true` for Non-Blocking Hooks (Jan 2026)

Hooks support `async: true` field to run without blocking Claude's execution. Useful for telemetry/observability hooks that shouldn't slow down the workflow.

### Settings JSON Schema Available

`https://json.schemastore.org/claude-code-settings.json` provides IDE autocomplete for `.claude/settings.json`. Worth mentioning in docs.

---

## Implications for This Repository

1. All frontmatter field names were corrected across all files
2. The wiring-the-chain.md doc explains exactly how each layer delegates
3. scan-layers.sh now validates frontmatter and wiring correctness
4. The pattern is confirmed by both official docs and IndyDevDan's production use
5. The depth-2 limitation is documented but doesn't affect the 4-layer model
6. Hook documentation should be expanded to cover all 18 events and 4 handler types
7. The `async: true` and `type: "agent"` hook capabilities open new patterns
8. The `skills:` vs `context: fork` distinction deserves its own section
