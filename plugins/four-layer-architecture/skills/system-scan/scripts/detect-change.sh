#!/usr/bin/env bash
# detect-change.sh — classify a file path by what kind of component it is.
#
# Usage: detect-change.sh <path>
# Output: one token to stdout, exit 0 always.
#
# Tokens: agent | skill | command | hook | plugin-manifest |
#         doc-architecture | agents-md | none

path="${1:-}"

if [[ -z "$path" ]]; then
  echo none
  exit 0
fi

case "$path" in
  # Agents in any plugin or project-local .claude layout
  plugins/*/agents/*.md|.claude/agents/*.md)
    echo agent ;;
  # Skills (SKILL.md, scripts, resources)
  plugins/*/skills/*/SKILL.md|.claude/skills/*/SKILL.md|\
plugins/*/skills/*/scripts/*|.claude/skills/*/scripts/*|\
plugins/*/skills/*/resources/*|.claude/skills/*/resources/*)
    echo skill ;;
  # Slash commands
  plugins/*/commands/*.md|.claude/commands/*.md)
    echo command ;;
  # Hook registration + hook scripts
  plugins/*/hooks/hooks.json|plugins/*/hooks/*|.claude/hooks/*)
    echo hook ;;
  # Plugin / marketplace manifests
  plugins/*/.claude-plugin/plugin.json|.claude-plugin/plugin.json|\
.claude-plugin/marketplace.json)
    echo plugin-manifest ;;
  # Load-bearing architecture docs
  docs/architecture.md|docs/philosophy.md|docs/wiring-the-chain.md|\
docs/concepts-vs-implementation.md)
    echo doc-architecture ;;
  # Project-wide AI instructions
  AGENTS.md|CLAUDE.md)
    echo agents-md ;;
  *)
    echo none ;;
esac
exit 0
