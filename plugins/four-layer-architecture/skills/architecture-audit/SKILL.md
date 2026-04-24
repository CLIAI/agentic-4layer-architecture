---
name: architecture-audit
description: "Scans a project's .claude/ directory for 4-layer pattern compliance"
allowed-tools: Bash, Read, Glob, Grep
disable-model-invocation: true
---

# Architecture Audit Skill

This skill performs a single atomic operation: scan a project directory and produce a
structured compliance report against the 4-layer pattern.

## Usage

1. Run the bundled discovery script on the target directory:

   ```
   bash .claude/skills/architecture-audit/scripts/scan-layers.sh [project-root]
   ```

2. Parse the script output into structured findings. Categorize:

   * **Commands found** -- count, filenames, line counts
   * **Agents found** -- count, filenames, whether they reference skills/scripts
   * **Skills found** -- count, directory names, whether they bundle scripts
   * **Scripts found** -- count, filenames, whether they are executable
   * **Hooks configured** -- present/absent, event types, hook count
   * **Root documents** -- CLAUDE.md and/or AGENTS.md presence

3. Flag potential issues as questions, not assertions:

   * A command over 15 lines might contain logic that belongs in an agent
   * A skill without a bundled script might be missing its mechanical component
   * An agent that does not reference any skill might be doing too much itself
   * Scripts containing prompt-like language might belong in the skill layer

4. Return the structured report. Do not take further action -- the calling agent
   decides what to do with the findings.

This is an ATOMIC operation. One input (project path), one output (structured report).
