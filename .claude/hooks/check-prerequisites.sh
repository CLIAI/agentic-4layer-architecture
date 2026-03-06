#!/usr/bin/env bash
# SessionStart hook: Verify required tools are available.
# Runs once when a Claude Code session begins.
# Exit 0 with no output = allow, output JSON with decision:block = stop.
#
# This is a DEMONSTRATION hook for the 4-layer architecture knowledge base.
# See https://code.claude.com/docs/en/hooks for the full hook specification.

set -euo pipefail

MISSING=()

for cmd in git jq bash; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Warning: Missing tools: ${MISSING[*]}" >&2
    echo "Some scan-layers.sh features may not work without jq." >&2
fi

exit 0
