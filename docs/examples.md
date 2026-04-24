# Examples: The 4-Layer Pattern in Practice

Concrete examples showing how real workflows map to the
Launchers → Orchestration → Workflows → SOPs → Tools & Primitives (+ Guardrails) architecture.

> **Layer naming recap:** L0 Tools & Primitives (Scripts) · L1 SOPs / Capabilities (Skills) · L2 Workflows (Agents) · L3 Orchestration (Commands) · L4 Launchers (justfile / Makefile / run.sh) · Bonus Guardrails (Hooks). See [concepts-vs-implementation.md](concepts-vs-implementation.md).

---

## Example 1: Playwright Browser Automation (UI Review)

Inspired by IndyDevDan's public demonstration of Playwright-based browser automation with Claude Code (see [references](references.md)).

### The User's Goal

"Review this web page for visual defects and accessibility issues."

### Layer Mapping

| Layer | Artifact | Responsibility |
|-------|----------|---------------|
| **L4 Launcher** | `justfile` recipe `ui-review` | `claude --plugin-dir ... --agent browser-qa -p "Review $URL"` |
| **L3 Orchestration** | `.claude/commands/ui-review.md` | Accept URL from user, delegate to workflow |
| **L2 Workflow** | `.claude/agents/browser-qa.md` | Sequence screenshot capture, analyze visuals, compile report |
| **L1 SOP / Capability** | `.claude/skills/playwright-browser/SKILL.md` | Documented capability: install browsers + capture screenshots |
| **L0 Tools & Primitives** | `scripts/setup.sh`, `scripts/capture.sh` | Deterministic: `npx playwright install`, `npx playwright screenshot` |
| **Bonus Guardrail** | `PreToolUse(Bash)` hook | Block dangerous shell commands during the run |

### Flow

```mermaid
sequenceDiagram
    participant User
    participant Command as /ui-review
    participant Agent as browser-qa
    participant Skill as playwright-browser
    participant Script as setup.sh / capture.sh
    participant Hook as validate-bash

    User->>Command: /ui-review https://example.com
    Command->>Agent: Review this URL
    Agent->>Skill: Capture screenshots
    Skill->>Script: Run setup.sh
    Hook-->>Script: PreToolUse validates command
    Script-->>Skill: Browsers installed
    Skill->>Script: Run capture.sh https://example.com
    Script-->>Skill: Screenshots saved
    Skill-->>Agent: Screenshot paths returned
    Agent->>Agent: Analyze screenshots for defects
    Agent->>Agent: Check accessibility
    Agent-->>User: Structured QA report
```

### What Each Layer Looks Like

**Command** (`.claude/commands/ui-review.md`):

```markdown
---
name: ui-review
description: "Review a web UI for visual and accessibility issues"
context: fork
agent: browser-qa
disable-model-invocation: true
---

Review the UI at the given URL for visual and accessibility issues: $ARGUMENTS

Capture screenshots at mobile (375px), tablet (768px), and desktop (1440px).
Report findings with severity levels.
```

> **How it works:** `context: fork` launches this as an isolated subagent.
> `agent: browser-qa` specifies which subagent definition to use.
> The subagent's `skills: [playwright-browser]` preloads the skill automatically.
> This creates the full chain: Command → Agent → Skill → Scripts.

**Agent** (`.claude/agents/browser-qa.md`):

```markdown
---
name: browser-qa
description: "Reviews web UIs for visual defects and accessibility"
tools: Read, Write, Bash
model: sonnet
skills:
  - playwright-browser
---

# Browser QA Agent

You review web UIs for visual defects and accessibility.

## Workflow
1. Use the `playwright-browser` skill to capture screenshots
2. Analyze each screenshot for layout, color, typography issues
3. Check responsive behavior at mobile (375px), tablet (768px), desktop (1440px)
4. Compile findings into a severity-ranked markdown report
5. Commit the report

## On Error
Stop and report. Do not attempt workarounds.
```

**Skill** (`.claude/skills/playwright-browser/SKILL.md`):

```markdown
---
name: playwright-browser
description: Capture browser screenshots using Playwright
allowed-tools: Bash, Read
---

# Playwright Browser Skill

## Setup
Run `${CLAUDE_SKILL_DIR}/scripts/setup.sh` to install Chromium.

## Capture
Run `${CLAUDE_SKILL_DIR}/scripts/capture.sh <url> <output-path>` to capture a full-page screenshot.

## Cleanup
Remove screenshot files after the agent has analyzed them.
```

**Scripts** (`scripts/setup.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail
npx playwright install --with-deps chromium
```

**Scripts** (`scripts/capture.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail
URL="${1:?Usage: capture.sh <url> [output-path]}"
OUTPUT="${2:-screenshot-$(date +%s).png}"
npx playwright screenshot --full-page "$URL" "$OUTPUT"
echo "$OUTPUT"
```

---

## Example 2: CI/CD Pipeline Review

### The User's Goal

"Review the CI/CD pipeline configuration for best practices and security issues."

### Layer Mapping

| Layer | Artifact | Responsibility |
|-------|----------|---------------|
| **L4 Launcher** | `justfile` recipe `ci-review` | Invoke `claude` with CI-reviewer plugin set |
| **L3 Orchestration** | `.claude/commands/ci-review.md` | Accept pipeline file path, delegate |
| **L2 Workflow** | `.claude/agents/pipeline-reviewer.md` | Analyze pipeline config, check for anti-patterns, suggest improvements |
| **L1 SOP / Capability** | `.claude/skills/yaml-analyzer/SKILL.md` | Parse and validate YAML/workflow files |
| **L1 SOP / Capability** | `.claude/skills/security-scanner/SKILL.md` | Check for hardcoded secrets, overly permissive permissions |
| **L0 Tools & Primitives** | `scripts/yaml-lint.sh` | Run `yamllint` on config files |
| **Bonus Guardrail** | `PostToolUse(Write)` hook | Lint any modified pipeline files automatically |

### Flow

```
/ci-review .github/workflows/deploy.yml
  -> pipeline-reviewer agent
    -> yaml-analyzer skill (validate structure)
      -> yaml-lint.sh script (run yamllint)
    -> security-scanner skill (check secrets, permissions)
    -> Agent compiles findings into recommendations
```

### Key Insight

The **security-scanner** SOP is reusable — it can serve the CI/CD review workflow, a code review workflow, or a pre-commit guardrail. That is the power of L1: SOPs are building blocks, not single-use modules.

---

## Example 3: Research Agent

### The User's Goal

"Research the current state of WebAssembly support in major browsers and compile a summary."

### Layer Mapping

| Layer | Artifact | Responsibility |
|-------|----------|---------------|
| **L4 Launcher** | `justfile` recipe `research` | Invoke `claude` with research plugin + budget cap |
| **L3 Orchestration** | `.claude/commands/research.md` | Accept topic from user, delegate |
| **L2 Workflow** | `.claude/agents/research-analyst.md` | Plan research strategy, synthesize findings, produce report |
| **L1 SOP / Capability** | `.claude/skills/web-research/SKILL.md` | Fetch and extract content from web sources |
| **L1 SOP / Capability** | `.claude/skills/report-writer/SKILL.md` | Structure findings into formatted markdown |
| **L0 Tools & Primitives** | `scripts/fetch-url.sh` | `curl` a URL and extract text content |
| **Bonus Guardrail** | `PreToolUse(Bash)` hook | Ensure no sensitive data leaks in curl commands |

### Flow

```
/research "WebAssembly browser support 2025"
  -> research-analyst agent
    -> web-research skill (fetch multiple sources)
      -> fetch-url.sh script (deterministic HTTP fetch)
    -> Agent synthesizes across sources
    -> report-writer skill (format as structured markdown)
    -> Agent commits the final report
```

### Key Insight

The L2 workflow is where **synthesis** happens. The web-research SOP fetches content, but it does not decide what is important or how to combine findings. That judgment is the workflow's job. This separation keeps the SOP reusable and the workflow focused on reasoning.

---

## Example 4: Code Review Workflow

### The User's Goal

"Review the changes in this pull request for code quality and potential bugs."

### Layer Mapping

| Layer | Artifact | Responsibility |
|-------|----------|---------------|
| **L4 Launcher** | `justfile` recipe `code-review` | Invoke `claude` from a git pre-push hook or CI |
| **L3 Orchestration** | `.claude/commands/code-review.md` | Accept PR number or branch, delegate |
| **L2 Workflow** | `.claude/agents/code-reviewer.md` | Examine diffs, check patterns, provide feedback |
| **L1 SOP / Capability** | `.claude/skills/diff-analyzer/SKILL.md` | Extract and parse git diffs |
| **L1 SOP / Capability** | `.claude/skills/test-runner/SKILL.md` | Run test suites and report results |
| **L0 Tools & Primitives** | `scripts/get-diff.sh` | `git diff` with appropriate flags |
| **L0 Tools & Primitives** | `scripts/run-tests.sh` | Execute test suite, capture output |
| **Bonus Guardrail** | `PostToolUse(Write)` hook | Auto-lint any files the reviewer suggests modifying |

### Flow

```
/code-review feature-branch
  -> code-reviewer agent
    -> diff-analyzer skill
      -> get-diff.sh script (extract diff)
    -> Agent analyzes each changed file
    -> test-runner skill
      -> run-tests.sh script (run affected tests)
    -> Agent compiles review comments
    -> Agent posts or commits the review
```

### Key Insight

The **test-runner** SOP is completely independent from code review. It can be used by a CI workflow, a deployment workflow, or a developer running `/test`. SOPs are composable across workflows — that is the architectural payoff of keeping them atomic.

---

## Cross-Cutting: How Hooks Apply to All Examples

In every example above, hooks provide enforcement that no individual layer handles:

| Hook Event | What It Does | Which Examples |
|------------|-------------|----------------|
| `PreToolUse(Bash)` | Block dangerous shell commands (`rm -rf /`, `curl \| bash`) | All |
| `PostToolUse(Write)` | Auto-lint or validate any written file | CI Review, Code Review |
| `SessionStart` | Set up environment variables, check prerequisites | All |
| `Stop` | Clean up temporary files (screenshots, diffs) | UI Review, Research |
| `SubagentStop` | Validate subagent output format | Research (multi-source) |

Guardrails are the **safety net**. They ensure that no matter which orchestration, workflow, or SOP is running, the system-wide rules are enforced.

---

## Pattern Summary

Every example follows the same structural pattern:

```
[optional] Launcher (L4) ── claude --agent … -p "…"
                                  │
User Intent → L3 Orchestration → L2 Workflow → L1 SOPs → L0 Tools & Primitives
                                                                  ^
                                                                  │
                                Guardrails (Bonus) enforce rules across all layers
```

The variation is in the **domain**, not the **architecture**. Browser testing, CI/CD review, research, and code review all look different on the surface but share the same skeleton. Once you internalize this pattern, you can design new systems by filling in the layers rather than starting from scratch.
