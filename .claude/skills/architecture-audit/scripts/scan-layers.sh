#!/usr/bin/env bash
# scan-layers.sh -- Discover 4-layer architecture artifacts
# Usage: ./scan-layers.sh [project-root]
# Output: structured text report of discovered artifacts
#
# This script is MECHANICAL -- no AI reasoning, just filesystem discovery.
# Testable standalone: ./scan-layers.sh /path/to/project

set -euo pipefail

PROJECT_ROOT="${1:-.}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

echo "========================================"
echo "4-Layer Architecture Scan"
echo "Project: $PROJECT_ROOT"
echo "========================================"
echo ""

# --- Layer 1: Commands ---
echo "--- COMMANDS (.claude/commands/*.md) ---"
if [ -d "$CLAUDE_DIR/commands" ]; then
    CMD_FILES=()
    while IFS= read -r -d '' f; do
        CMD_FILES+=("$f")
    done < <(find "$CLAUDE_DIR/commands" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#CMD_FILES[@]}"
    for f in "${CMD_FILES[@]}"; do
        name="$(basename "$f")"
        lines="$(wc -l < "$f")"
        echo "  * $name ($lines lines)"
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 2: Agents ---
echo "--- AGENTS (.claude/agents/*.md) ---"
if [ -d "$CLAUDE_DIR/agents" ]; then
    AGENT_FILES=()
    while IFS= read -r -d '' f; do
        AGENT_FILES+=("$f")
    done < <(find "$CLAUDE_DIR/agents" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#AGENT_FILES[@]}"
    for f in "${AGENT_FILES[@]}"; do
        name="$(basename "$f")"
        lines="$(wc -l < "$f")"
        has_skill_ref="no"
        if grep -qiE '(skill|SKILL\.md|skills/)' "$f" 2>/dev/null; then
            has_skill_ref="yes"
        fi
        has_script_ref="no"
        if grep -qiE '(script|\.sh\b|scripts/)' "$f" 2>/dev/null; then
            has_script_ref="yes"
        fi
        echo "  * $name ($lines lines, refs skills: $has_skill_ref, refs scripts: $has_script_ref)"
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 3: Skills ---
echo "--- SKILLS (.claude/skills/*/SKILL.md) ---"
if [ -d "$CLAUDE_DIR/skills" ]; then
    SKILL_DIRS=()
    while IFS= read -r -d '' f; do
        SKILL_DIRS+=("$(dirname "$f")")
    done < <(find "$CLAUDE_DIR/skills" -maxdepth 2 -name 'SKILL.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#SKILL_DIRS[@]}"
    for d in "${SKILL_DIRS[@]}"; do
        name="$(basename "$d")"
        has_scripts="no"
        script_count=0
        if [ -d "$d/scripts" ]; then
            script_count="$(find "$d/scripts" -type f 2>/dev/null | wc -l)"
            if [ "$script_count" -gt 0 ]; then
                has_scripts="yes"
            fi
        fi
        echo "  * $name (bundled scripts: $has_scripts, script count: $script_count)"
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 4: Scripts ---
echo "--- SCRIPTS (standalone scripts/) ---"
SCRIPT_LOCATIONS=("$PROJECT_ROOT/scripts" "$CLAUDE_DIR/scripts")
total_scripts=0
for loc in "${SCRIPT_LOCATIONS[@]}"; do
    if [ -d "$loc" ]; then
        rel="$(realpath --relative-to="$PROJECT_ROOT" "$loc")"
        while IFS= read -r -d '' f; do
            name="$(basename "$f")"
            is_exec="no"
            if [ -x "$f" ]; then
                is_exec="yes"
            fi
            echo "  * $rel/$name (executable: $is_exec)"
            total_scripts=$((total_scripts + 1))
        done < <(find "$loc" -maxdepth 1 -type f -print0 2>/dev/null | sort -z)
    fi
done
# Also count scripts bundled inside skills
if [ -d "$CLAUDE_DIR/skills" ]; then
    while IFS= read -r -d '' f; do
        rel="$(realpath --relative-to="$PROJECT_ROOT" "$f")"
        is_exec="no"
        if [ -x "$f" ]; then
            is_exec="yes"
        fi
        echo "  * $rel (executable: $is_exec) [skill-bundled]"
        total_scripts=$((total_scripts + 1))
    done < <(find "$CLAUDE_DIR/skills" -path '*/scripts/*' -type f -print0 2>/dev/null | sort -z)
fi
echo "Total scripts found: $total_scripts"
echo ""

# --- Hooks ---
echo "--- HOOKS (.claude/settings.json) ---"
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ]; then
    echo "Settings file: present"
    if command -v jq &>/dev/null; then
        hook_count="$(jq '[.hooks // {} | to_entries[] | .value | length] | add // 0' "$SETTINGS" 2>/dev/null || echo "parse-error")"
        hook_events="$(jq '.hooks // {} | keys[]' "$SETTINGS" 2>/dev/null | tr '\n' ', ' || echo "parse-error")"
        echo "Hook events: ${hook_events:-none}"
        echo "Total hooks: $hook_count"
    else
        echo "  (jq not available -- cannot parse hooks)"
        if grep -q '"hooks"' "$SETTINGS" 2>/dev/null; then
            echo "  hooks key: present"
        else
            echo "  hooks key: absent"
        fi
    fi
else
    echo "Settings file: absent"
    echo "Total hooks: 0"
fi
echo ""

# --- Root documents ---
echo "--- ROOT DOCUMENTS ---"
for doc in CLAUDE.md AGENTS.md README.md; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        lines="$(wc -l < "$PROJECT_ROOT/$doc")"
        echo "  * $doc: present ($lines lines)"
    else
        echo "  * $doc: absent"
    fi
done
echo ""

echo "========================================"
echo "Scan complete."
echo "========================================"
