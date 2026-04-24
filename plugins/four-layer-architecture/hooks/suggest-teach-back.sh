#!/usr/bin/env bash
# suggest-teach-back.sh — advisory PreToolUse hook.
# Emits a single-line suggestion on structural edits; honours three skip
# channels; always exits 0 (never blocks tool use).
#
# Runs only if the hook's matcher (configured in hooks.json) already narrowed
# the tool to Write|Edit. Reads the edited-file path from the hook's stdin JSON
# payload. On any parse/read failure, stays silent (fail-safe).

set -u

# Never block tool use — always exit 0.
trap 'exit 0' ERR

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
[[ -z "$PLUGIN_ROOT" ]] && {
  # Try to locate relative to this script if env var unavailable.
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"
}

DETECT="${PLUGIN_ROOT}/skills/system-scan/scripts/detect-change.sh"
[[ -x "$DETECT" ]] || DETECT=""

# --- Read edited file path from stdin JSON (PreToolUse contract) ---
STDIN_JSON="$(cat 2>/dev/null || echo '{}')"
EDITED_PATH="$(
  printf '%s' "$STDIN_JSON" |
  python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read() or "{}")
    ti = d.get("tool_input", d)
    for k in ("file_path", "path", "target_file"):
        v = ti.get(k)
        if isinstance(v, str) and v:
            print(v); break
except Exception:
    pass
' 2>/dev/null
)"

[[ -z "$EDITED_PATH" ]] && exit 0

# Normalise to repo-relative path if possible.
REPO_ROOT="$(pwd)"
case "$EDITED_PATH" in
  "$REPO_ROOT"/*) EDITED_PATH="${EDITED_PATH#"$REPO_ROOT"/}" ;;
esac

# --- Skip channel 1: persistent per-project preference ---
PREF_FILE=".claude/four-layer-architecture.local.md"
AUTO_SUGGEST=true
if [[ -f "$PREF_FILE" ]]; then
  VAL="$(
    python3 -c '
import re, sys
t = open(sys.argv[1]).read()
m = re.match(r"^---\s*\n(.*?)\n---", t, re.DOTALL)
if m:
    fm = m.group(1)
    # crude search for teach_back.auto_suggest
    m2 = re.search(r"auto_suggest\s*:\s*(true|false)", fm)
    if m2: print(m2.group(1))
' "$PREF_FILE" 2>/dev/null
  )"
  [[ "$VAL" == "false" ]] && AUTO_SUGGEST=false
fi
[[ "$AUTO_SUGGEST" == "true" ]] || exit 0

# --- Skip channel 2: declared-in-instructions ---
for f in AGENTS.md CLAUDE.md; do
  [[ -f "$f" ]] && grep -q 'four-layer-architecture: skip-teach-back' "$f" && exit 0
done

# --- Classify the change ---
KIND="none"
if [[ -n "$DETECT" ]]; then
  KIND="$(bash "$DETECT" "$EDITED_PATH" 2>/dev/null || echo none)"
fi
[[ "$KIND" == "none" ]] && exit 0

# --- Emit advisory ---
case "$KIND" in
  agent)            LABEL="L2 agent" ;;
  skill)            LABEL="L1 skill" ;;
  command)          LABEL="L3 command" ;;
  hook)             LABEL="guardrail hook" ;;
  plugin-manifest)  LABEL="plugin manifest" ;;
  doc-architecture) LABEL="architecture doc" ;;
  agents-md)        LABEL="AI-agent instructions" ;;
  *)                LABEL="component" ;;
esac

cat <<EOF
[four-layer] Architectural edit detected (${LABEL}: ${EDITED_PATH}).
  Consider /four-layer-architecture:feynman-check before continuing.
  Skip: set teach_back.auto_suggest=false in .claude/four-layer-architecture.local.md
        or add "four-layer-architecture: skip-teach-back" to AGENTS.md.
EOF

exit 0
