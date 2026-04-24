#!/usr/bin/env bash
# PostToolUse hook: Validate YAML frontmatter in written .md files.
# Checks for deprecated field names (allowed_tools instead of tools/allowed-tools).
# Receives JSON on stdin with tool_input.file_path field.
# This is a non-blocking hook -- it warns but does not prevent the write.
#
# This is a DEMONSTRATION hook for the 4-layer architecture knowledge base.
# See https://code.claude.com/docs/en/hooks for the full hook specification.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Only check .md files
case "$FILE_PATH" in
    *.md) ;;
    *) exit 0 ;;
esac

# Only check files that have YAML frontmatter
if ! head -1 "$FILE_PATH" 2>/dev/null | grep -q '^---$'; then
    exit 0
fi

# Check for deprecated field names in frontmatter
FRONTMATTER=$(sed -n '1,/^---$/p' "$FILE_PATH" 2>/dev/null | tail -n +2)

if echo "$FRONTMATTER" | grep -q 'allowed_tools'; then
    echo "Warning: $FILE_PATH uses 'allowed_tools' in frontmatter." >&2
    echo "  For agents: use 'tools' (per https://code.claude.com/docs/en/sub-agents)" >&2
    echo "  For skills: use 'allowed-tools' (per https://code.claude.com/docs/en/skills)" >&2
fi

exit 0
