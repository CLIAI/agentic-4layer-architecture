# Reference Cache

Local snapshots of official third-party documentation pages that the 4-layer
architecture docs rely on. Cached so that:

* The repo's teaching content has a stable, versioned baseline it was written against
* AI agents reading this repo can load authoritative flag/API docs without
  network access
* Readers can diff "what the official docs said on date X" against "what they
  say today" when upstream changes

**These files are reference material, not part of the architecture pattern itself.**
They are not authoritative — the live upstream pages are. Re-fetch periodically
and inspect the diff.

---

## claude-code/

Snapshots of [docs.claude.com/en/docs/claude-code/*](https://docs.claude.com/en/docs/claude-code/).

| File | Upstream | Primary relevance |
|------|----------|-------------------|
| [`cli-reference.md`](claude-code/cli-reference.md) | [cli-reference](https://docs.claude.com/en/docs/claude-code/cli-reference) | **L4 Launchers** — the canonical source of flags (`--plugin-dir`, `--agent`, `--settings`, `--mcp-config`, `-p`, `--bare`, `--permission-mode`, `--max-turns`, `--max-budget-usd`, etc.). Note the docs warn: "`claude --help` does not list every flag." |
| [`skills.md`](claude-code/skills.md) | [skills](https://docs.claude.com/en/docs/claude-code/skills) | **L1 SOPs & L3 Orchestration** — frontmatter fields (`name`, `description`, `allowed-tools`, `context`, `agent`, `hooks`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `model`), `${CLAUDE_SKILL_DIR}`, `$ARGUMENTS` substitutions, `context: fork` semantics |
| [`sub-agents.md`](claude-code/sub-agents.md) | [sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents) | **L2 Workflows** — subagent frontmatter (`tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`), skill preloading semantics |
| [`hooks.md`](claude-code/hooks.md) | [hooks](https://docs.claude.com/en/docs/claude-code/hooks) | **Bonus Guardrails** — all 18 lifecycle events, the 4 handler types (`command`, `http`, `prompt`, `agent`), `async: true`, nested matcher format, exit-code contract |
| [`plugins-reference.md`](claude-code/plugins-reference.md) | [plugins-reference](https://docs.claude.com/en/docs/claude-code/plugins-reference) | **L4 Launchers + distribution** — how `--plugin-dir` content is structured, plugin manifest, marketplace interaction |
| [`settings.md`](claude-code/settings.md) | [settings](https://docs.claude.com/en/docs/claude-code/settings) | **Cross-layer** — settings hierarchy (user/project/local), permission-rule syntax, how `--settings` and `--setting-sources` resolve |
| [`commands.md`](claude-code/commands.md) | [commands](https://docs.claude.com/en/docs/claude-code/commands) | **L3 Orchestration** — interactive-mode commands (distinct from CLI flags), including the built-in `/config`, `/model`, `/resume`, etc. |
| [`env-vars.md`](claude-code/env-vars.md) | [env-vars](https://docs.claude.com/en/docs/claude-code/env-vars) | **L4 Launchers** — environment variables that launchers can set to bind behavior (`CLAUDE_CODE_SIMPLE`, debug vars, telemetry, auth) |
| [`tools-reference.md`](claude-code/tools-reference.md) | [tools-reference](https://docs.claude.com/en/docs/claude-code/tools-reference) | **All layers** — tool inventory that `--allowedTools` / `--disallowedTools` reference |

Each cached file begins with an HTML comment recording the source URL, the
fetch date, and the fetcher. The body is the Markdown produced by the
[Jina.ai Reader](https://jina.ai/reader/) proxy (`https://r.jina.ai/<url>`).

### Refreshing the cache

```bash
DATE=$(date +%Y-%m-%d)
for slug in cli-reference skills sub-agents plugins-reference hooks settings commands env-vars tools-reference; do
    url="https://docs.claude.com/en/docs/claude-code/$slug"
    out="docs/reference-cache/claude-code/${slug}.md"
    {
        echo "<!--"
        echo "Cached from: $url"
        echo "Fetch date: $DATE"
        echo "Fetcher: jina.ai reader proxy (r.jina.ai)"
        echo "-->"
        echo
        curl -sL "https://r.jina.ai/$url"
    } > "$out"
done
```

If an upstream page is renamed or removed, diff its last cached version
against whatever replaces it — that is often where our docs need edits.
