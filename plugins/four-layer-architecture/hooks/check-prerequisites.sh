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

# First-use nudge: if no teach-back artifacts exist and user has not muted,
# emit a one-line suggestion pointing at /four-layer-architecture:brainstorm-architecture.
# Always exits 0, never blocks.
FIRST_USE_FLAG=false
PREF_FILE=".claude/four-layer-architecture.local.md"
if [[ -f "$PREF_FILE" ]]; then
    if grep -qE 'first_use_shown\s*:\s*true' "$PREF_FILE" 2>/dev/null; then
        FIRST_USE_FLAG=true
    fi
fi
for f in AGENTS.md CLAUDE.md; do
    [[ -f "$f" ]] && grep -q 'four-layer-architecture: skip-teach-back' "$f" && FIRST_USE_FLAG=true
done

if [[ "$FIRST_USE_FLAG" != "true" ]] \
    && [[ ! -f .four-layer-journal.md ]] \
    && [[ ! -d docs/understanding ]]; then
    cat <<'EOF'
[four-layer] First session here — no teach-back journal yet.
  Run /four-layer-architecture:brainstorm-architecture for a guided start.
  Mute: set teach_back.first_use_shown=true in .claude/four-layer-architecture.local.md
        or add "four-layer-architecture: skip-teach-back" to AGENTS.md.
EOF
fi

exit 0
