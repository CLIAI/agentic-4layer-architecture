#!/usr/bin/env bash
# scan-layers.sh -- Discover 4-layer architecture artifacts and validate wiring
# Usage: ./scan-layers.sh [project-root]
# Output: structured text report of discovered artifacts and potential issues
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

# --- Helper: extract YAML frontmatter field ---
extract_field() {
    local file="$1" field="$2"
    # Extract value from YAML frontmatter (between --- markers)
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | grep -E "^${field}:" | sed "s/^${field}:[[:space:]]*//" | tr -d '"' || true
}

# --- Helper: extract YAML list items ---
extract_list() {
    local file="$1" field="$2"
    sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | sed -n "/^${field}:/,/^[^ -]/p" | grep -E '^\s*-\s' | sed 's/^\s*-\s*//' | tr -d '"' || true
}

# --- Layer 4: Commands ---
echo "--- COMMANDS (.claude/commands/*.md) ---"
if [ -d "$CLAUDE_DIR/commands" ]; then
    CMD_FILES=()
    while IFS= read -r -d '' f; do
        CMD_FILES+=("$f")
    done < <(find "$CLAUDE_DIR/commands" -maxdepth 2 -name '*.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#CMD_FILES[@]}"
    for f in "${CMD_FILES[@]}"; do
        name="$(basename "$f" .md)"
        lines="$(wc -l < "$f")"
        context="$(extract_field "$f" "context")"
        agent="$(extract_field "$f" "agent")"
        echo "  * $name ($lines lines)"
        if [ -n "$context" ]; then
            echo "    context: $context"
        fi
        if [ -n "$agent" ]; then
            echo "    agent: $agent"
            # Check if referenced agent exists
            if [ ! -f "$CLAUDE_DIR/agents/${agent}.md" ] && [ ! -f "$CLAUDE_DIR/agents/${agent}-agent.md" ]; then
                echo "    WARNING: referenced agent '$agent' not found in .claude/agents/"
            fi
        elif [ "$lines" -gt 15 ]; then
            echo "    NOTE: >15 lines without context:fork -- consider delegating to an agent"
        fi
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 3: Agents ---
echo "--- AGENTS (.claude/agents/*.md) ---"
if [ -d "$CLAUDE_DIR/agents" ]; then
    AGENT_FILES=()
    while IFS= read -r -d '' f; do
        AGENT_FILES+=("$f")
    done < <(find "$CLAUDE_DIR/agents" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#AGENT_FILES[@]}"
    for f in "${AGENT_FILES[@]}"; do
        name="$(basename "$f" .md)"
        lines="$(wc -l < "$f")"
        model="$(extract_field "$f" "model")"
        tools="$(extract_field "$f" "tools")"
        memory="$(extract_field "$f" "memory")"

        # Check for deprecated field names
        has_allowed_tools="no"
        if grep -q 'allowed_tools' "$f" 2>/dev/null; then
            has_allowed_tools="yes (DEPRECATED: use 'tools' instead)"
        fi

        # Check skills references
        skills_list="$(extract_list "$f" "skills")"
        has_skills="no"
        if [ -n "$skills_list" ]; then
            has_skills="yes"
        fi

        echo "  * $name ($lines lines)"
        [ -n "$model" ] && echo "    model: $model"
        [ -n "$tools" ] && echo "    tools: $tools"
        [ "$has_allowed_tools" != "no" ] && echo "    allowed_tools: $has_allowed_tools"
        [ -n "$memory" ] && echo "    memory: $memory"
        echo "    skills: $has_skills"

        # Validate skill references
        if [ -n "$skills_list" ]; then
            while IFS= read -r skill; do
                skill="$(echo "$skill" | xargs)"  # trim
                if [ ! -f "$CLAUDE_DIR/skills/${skill}/SKILL.md" ]; then
                    echo "    WARNING: referenced skill '$skill' not found in .claude/skills/"
                fi
            done <<< "$skills_list"
        fi
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 2: Skills ---
echo "--- SKILLS (.claude/skills/*/SKILL.md) ---"
if [ -d "$CLAUDE_DIR/skills" ]; then
    SKILL_DIRS=()
    while IFS= read -r -d '' f; do
        SKILL_DIRS+=("$(dirname "$f")")
    done < <(find "$CLAUDE_DIR/skills" -maxdepth 2 -name 'SKILL.md' -type f -print0 2>/dev/null | sort -z)
    echo "Count: ${#SKILL_DIRS[@]}"
    for d in "${SKILL_DIRS[@]}"; do
        name="$(basename "$d")"
        skill_file="$d/SKILL.md"
        allowed_tools="$(extract_field "$skill_file" "allowed-tools")"
        context="$(extract_field "$skill_file" "context")"
        disable_model="$(extract_field "$skill_file" "disable-model-invocation")"

        # Check for deprecated field names
        has_deprecated="no"
        if grep -q 'allowed_tools' "$skill_file" 2>/dev/null; then
            has_deprecated="yes (use 'allowed-tools' with hyphens)"
        fi

        # Check bundled scripts
        has_scripts="no"
        script_count=0
        if [ -d "$d/scripts" ]; then
            script_count="$(find "$d/scripts" -type f 2>/dev/null | wc -l)"
            if [ "$script_count" -gt 0 ]; then
                has_scripts="yes"
            fi
        fi

        echo "  * $name (scripts: $has_scripts, count: $script_count)"
        [ -n "$allowed_tools" ] && echo "    allowed-tools: $allowed_tools"
        [ -n "$context" ] && echo "    context: $context"
        [ -n "$disable_model" ] && echo "    disable-model-invocation: $disable_model"
        [ "$has_deprecated" != "no" ] && echo "    DEPRECATED field: $has_deprecated"
    done
else
    echo "Count: 0"
    echo "  (directory not found)"
fi
echo ""

# --- Layer 1: Scripts ---
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

# --- Wiring validation summary ---
echo "--- WIRING VALIDATION ---"
issues=0

# Check: do commands reference agents that exist?
if [ -d "$CLAUDE_DIR/commands" ]; then
    while IFS= read -r -d '' f; do
        agent="$(extract_field "$f" "agent")"
        if [ -n "$agent" ]; then
            if [ ! -f "$CLAUDE_DIR/agents/${agent}.md" ] && [ ! -f "$CLAUDE_DIR/agents/${agent}-agent.md" ]; then
                echo "  BROKEN: Command '$(basename "$f" .md)' references agent '$agent' which doesn't exist"
                issues=$((issues + 1))
            fi
        fi
    done < <(find "$CLAUDE_DIR/commands" -maxdepth 2 -name '*.md' -type f -print0 2>/dev/null)
fi

# Check: do agents reference skills that exist?
if [ -d "$CLAUDE_DIR/agents" ]; then
    while IFS= read -r -d '' f; do
        skills_list="$(extract_list "$f" "skills")"
        if [ -n "$skills_list" ]; then
            while IFS= read -r skill; do
                skill="$(echo "$skill" | xargs)"
                if [ -n "$skill" ] && [ ! -f "$CLAUDE_DIR/skills/${skill}/SKILL.md" ]; then
                    echo "  BROKEN: Agent '$(basename "$f" .md)' references skill '$skill' which doesn't exist"
                    issues=$((issues + 1))
                fi
            done <<< "$skills_list"
        fi
    done < <(find "$CLAUDE_DIR/agents" -maxdepth 1 -name '*.md' -type f -print0 2>/dev/null)
fi

# Check: deprecated field names
if grep -rl 'allowed_tools' "$CLAUDE_DIR" 2>/dev/null | grep -q '.md'; then
    echo "  DEPRECATED: Some files use 'allowed_tools' (use 'tools' for agents, 'allowed-tools' for skills)"
    issues=$((issues + 1))
fi

if [ "$issues" -eq 0 ]; then
    echo "  All wiring checks passed!"
fi
echo ""

echo "========================================"
echo "Scan complete. Issues found: $issues"
echo "========================================"
