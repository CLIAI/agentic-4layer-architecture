#!/usr/bin/env bash
# scan-system.sh — emit a structured JSON map of the current project's
# Claude-Code-relevant surface: plugins, local .claude/ components, key
# docs, AGENTS.md sections, and teach-back artifacts (journal, understanding/).
#
# Usage: scan-system.sh [--fresh]
#        --fresh    bypass the /tmp cache
#
# Output: JSON to stdout. Exit 0 on success.
# On fatal error: prints '{}' to stdout, message to stderr, exits 1.
#
# Dependencies: bash, python3 (stdlib only).

set -eu

FRESH=0
[[ "${1:-}" == "--fresh" ]] && FRESH=1

REPO_ROOT="$(pwd)"
PWD_HASH="$(echo "$REPO_ROOT" | md5sum 2>/dev/null | cut -c1-12 || echo 'nohash')"
CACHE="/tmp/four-layer-scan-${PWD_HASH}.json"
TTL=60  # seconds

if [[ $FRESH -eq 0 && -f "$CACHE" ]]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
  if [[ $age -lt $TTL ]]; then
    cat "$CACHE"
    exit 0
  fi
fi

RESULT="$(python3 - "$REPO_ROOT" << 'PY'
import json, sys, re
from pathlib import Path

root = Path(sys.argv[1])

def extract_frontmatter(path):
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return {}
    m = re.match(r'^---\s*\n(.*?)\n---\s*\n', text, re.DOTALL)
    if not m:
        return {}
    fm = {}
    for line in m.group(1).splitlines():
        m2 = re.match(r'^([a-zA-Z_][\w-]*)\s*:\s*(.*)$', line)
        if m2:
            k, v = m2.group(1), m2.group(2).strip()
            if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                v = v[1:-1]
            fm[k] = v
    return fm

def list_plugin(plugin_dir):
    name = plugin_dir.name
    manifest = plugin_dir / '.claude-plugin' / 'plugin.json'
    if manifest.exists():
        try:
            j = json.loads(manifest.read_text())
            name = j.get('name', name)
        except Exception:
            pass
    out = {'name': name, 'path': str(plugin_dir.relative_to(root)),
           'agents': [], 'skills': [], 'commands': [], 'hooks': []}
    ag = plugin_dir / 'agents'
    if ag.is_dir():
        for md in sorted(ag.glob('*.md')):
            fm = extract_frontmatter(md)
            out['agents'].append({'name': fm.get('name', md.stem),
                                  'path': str(md.relative_to(root)),
                                  'description': fm.get('description', '')})
    skills_dir = plugin_dir / 'skills'
    if skills_dir.is_dir():
        for skill in sorted(skills_dir.iterdir()):
            sm = skill / 'SKILL.md'
            if sm.exists():
                fm = extract_frontmatter(sm)
                out['skills'].append({'name': fm.get('name', skill.name),
                                      'path': str(sm.relative_to(root)),
                                      'description': fm.get('description', '')})
    cd = plugin_dir / 'commands'
    if cd.is_dir():
        for md in sorted(cd.glob('*.md')):
            fm = extract_frontmatter(md)
            out['commands'].append({'name': fm.get('name', md.stem),
                                    'path': str(md.relative_to(root)),
                                    'description': fm.get('description', '')})
    hooks_json = plugin_dir / 'hooks' / 'hooks.json'
    if hooks_json.exists():
        try:
            hj = json.loads(hooks_json.read_text())
            inner = hj.get('hooks', hj) if isinstance(hj, dict) else {}
            if isinstance(inner, dict):
                for event, entries in inner.items():
                    for entry in entries:
                        matcher = entry.get('matcher', '')
                        for h in entry.get('hooks', []):
                            out['hooks'].append({'event': event,
                                                 'matcher': matcher,
                                                 'command': h.get('command', '')})
        except Exception:
            pass
    return out

plugins = []
plugins_root = root / 'plugins'
if plugins_root.is_dir():
    for d in sorted(plugins_root.iterdir()):
        if d.is_dir() and (d / '.claude-plugin' / 'plugin.json').exists():
            plugins.append(list_plugin(d))

local = {'agents': [], 'skills': [], 'commands': [], 'hooks_events': []}
for sub, key in (('agents', 'agents'), ('commands', 'commands')):
    d = root / '.claude' / sub
    if d.is_dir():
        for md in sorted(d.glob('*.md')):
            fm = extract_frontmatter(md)
            local[key].append({'name': fm.get('name', md.stem),
                               'path': str(md.relative_to(root)),
                               'description': fm.get('description', '')})
skills_local = root / '.claude' / 'skills'
if skills_local.is_dir():
    for skill in sorted(skills_local.iterdir()):
        sm = skill / 'SKILL.md'
        if sm.exists():
            fm = extract_frontmatter(sm)
            local['skills'].append({'name': fm.get('name', skill.name),
                                    'path': str(sm.relative_to(root)),
                                    'description': fm.get('description', '')})
settings = root / '.claude' / 'settings.json'
if settings.exists():
    try:
        sj = json.loads(settings.read_text())
        local['hooks_events'] = sorted(list(sj.get('hooks', {}).keys()))
    except Exception:
        pass

docs = []
docs_dir = root / 'docs'
if docs_dir.is_dir():
    for md in sorted(docs_dir.glob('*.md')):
        try:
            text = md.read_text(encoding='utf-8', errors='replace')
        except Exception:
            continue
        title = ''
        headings = []
        for line in text.splitlines():
            if not title and line.startswith('# '):
                title = line[2:].strip()
            elif line.startswith('## '):
                headings.append(line[3:].strip())
        docs.append({'path': str(md.relative_to(root)),
                     'title': title,
                     'top_headings': headings[:20]})

agents_md = {}
for cand in ('AGENTS.md', 'CLAUDE.md'):
    p = root / cand
    if p.exists():
        try:
            text = p.read_text(encoding='utf-8', errors='replace')
        except Exception:
            continue
        agents_md[cand] = {
            'path': cand,
            'sections': [l[3:].strip() for l in text.splitlines() if l.startswith('## ')][:20],
            'has_skip_marker': 'four-layer-architecture: skip-teach-back' in text,
        }

journal = root / '.four-layer-journal.md'
understanding_dir = root / 'docs' / 'understanding'
understanding_files = []
if understanding_dir.is_dir():
    understanding_files = sorted(str(p.relative_to(root)) for p in understanding_dir.glob('*.md'))

out = {
    'plugins': plugins,
    'local_claude': local,
    'docs': docs,
    'agents_md': agents_md,
    'journal': {'exists': journal.exists(),
                'path': str(journal.relative_to(root)) if journal.exists() else '.four-layer-journal.md'},
    'understanding': {'exists': understanding_dir.is_dir(),
                      'files': understanding_files},
}
print(json.dumps(out, indent=2))
PY
)"

printf '%s\n' "$RESULT"
printf '%s\n' "$RESULT" > "$CACHE" 2>/dev/null || true
exit 0
