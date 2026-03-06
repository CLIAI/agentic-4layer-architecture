#!/usr/bin/env bash
# PreToolUse hook: Block force-push and other destructive git operations.
# Receives JSON on stdin with tool_input.command field.
# Exit 0 = allow, Exit 2 = block (stderr fed back to Claude for self-correction).
#
# This is a DEMONSTRATION hook for the 4-layer architecture knowledge base.
# See https://code.claude.com/docs/en/hooks for the full hook specification.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Block force-push to any branch
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force'; then
    echo "Blocked: force-push is destructive. Use --force-with-lease instead, or remove the force flag." >&2
    exit 2
fi

# Block git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
    echo "Blocked: git reset --hard discards uncommitted changes. Use git stash or git reset --soft instead." >&2
    exit 2
fi

# Block rm -rf on root-like paths
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(/|~|\$HOME)'; then
    echo "Blocked: dangerous rm -rf on a root-like path." >&2
    exit 2
fi

exit 0
