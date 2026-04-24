<!--
Cached from: https://docs.claude.com/en/docs/claude-code/commands
Fetch date: 2026-04-24
Fetcher: jina.ai reader proxy (r.jina.ai)
Purpose: L4 Launcher flags + general reference for the 4-layer
         agentic architecture docs. Re-fetch periodically to pick
         up new flags/events — Claude Code docs iterate quickly.
-->

Title: Commands - Claude Code Docs

URL Source: https://docs.claude.com/en/docs/claude-code/commands

Markdown Content:
# Commands - Claude Code Docs

[Skip to main content](https://docs.claude.com/en/docs/claude-code/commands#content-area)

[Claude Code Docs home page![Image 1: light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![Image 2: dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://docs.claude.com/docs/en/overview)

![Image 3: US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

⌘K Ask AI

*   [Claude Developer Platform](https://platform.claude.com/)
*   [Claude Code on the Web](https://claude.ai/code)
*   [Claude Code on the Web](https://claude.ai/code)

Search...

Navigation

Reference

Commands

[Getting started](https://docs.claude.com/docs/en/overview)[Build with Claude Code](https://docs.claude.com/docs/en/sub-agents)[Deployment](https://docs.claude.com/docs/en/third-party-integrations)[Administration](https://docs.claude.com/docs/en/admin-setup)[Configuration](https://docs.claude.com/docs/en/settings)[Reference](https://docs.claude.com/docs/en/cli-reference)[Agent SDK](https://docs.claude.com/docs/en/agent-sdk/overview)[What's New](https://docs.claude.com/docs/en/whats-new)[Resources](https://docs.claude.com/docs/en/legal-and-compliance)

##### Reference

*   [CLI reference](https://docs.claude.com/docs/en/cli-reference)
*   [Commands](https://docs.claude.com/docs/en/commands)
*   [Environment variables](https://docs.claude.com/docs/en/env-vars)
*   [Tools reference](https://docs.claude.com/docs/en/tools-reference)
*   [Interactive mode](https://docs.claude.com/docs/en/interactive-mode)
*   [Checkpointing](https://docs.claude.com/docs/en/checkpointing)
*   [Hooks reference](https://docs.claude.com/docs/en/hooks)
*   [Plugins reference](https://docs.claude.com/docs/en/plugins-reference)
*   [Channels reference](https://docs.claude.com/docs/en/channels-reference)

On this page

*   [MCP prompts](https://docs.claude.com/en/docs/claude-code/commands#mcp-prompts)
*   [See also](https://docs.claude.com/en/docs/claude-code/commands#see-also)

Reference

# Commands

Copy page

Complete reference for commands available in Claude Code, including built-in commands and bundled skills.

Copy page

Commands control Claude Code from inside a session. They provide a quick way to switch models, manage permissions, clear context, run a workflow, and more.Type `/` to see every command available to you, or type `/` followed by letters to filter.The table below lists all the commands included in Claude Code. Entries marked **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills)** are bundled skills. They use the same mechanism as skills you write yourself: a prompt handed to Claude, which Claude can also invoke automatically when relevant. Everything else is a built-in command whose behavior is coded into the CLI. To add your own commands, see [skills](https://docs.claude.com/docs/en/skills).Not every command appears for every user. Availability depends on your platform, plan, and environment. For example, `/desktop` only shows on macOS and Windows, and `/upgrade` only shows on Pro and Max plans.In the table below, `<arg>` indicates a required argument and `[arg]` indicates an optional one.

| Command | Purpose |
| --- | --- |
| `/add-dir <path>` | Add a working directory for file access during the current session. Most `.claude/` configuration is [not discovered](https://docs.claude.com/docs/en/permissions#additional-directories-grant-file-access-not-configuration) from the added directory. You can later resume the session from the added directory with `--continue` or `--resume` |
| `/agents` | Manage [agent](https://docs.claude.com/docs/en/sub-agents) configurations |
| `/autofix-pr [prompt]` | Spawn a [Claude Code on the web](https://docs.claude.com/docs/en/claude-code-on-the-web#auto-fix-pull-requests) session that watches the current branch’s PR and pushes fixes when CI fails or reviewers leave comments. Detects the open PR from your checked-out branch with `gh pr view`; to watch a different PR, check out its branch first. By default the remote session is told to fix every CI failure and review comment; pass a prompt to give it different instructions, for example `/autofix-pr only fix lint and type errors`. Requires the `gh` CLI and access to [Claude Code on the web](https://docs.claude.com/docs/en/claude-code-on-the-web#who-can-use-claude-code-on-the-web) |
| `/batch <instruction>` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Orchestrate large-scale changes across a codebase in parallel. Researches the codebase, decomposes the work into 5 to 30 independent units, and presents a plan. Once approved, spawns one background agent per unit in an isolated [git worktree](https://docs.claude.com/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees). Each agent implements its unit, runs tests, and opens a pull request. Requires a git repository. Example: `/batch migrate src/ from Solid to React` |
| `/branch [name]` | Create a branch of the current conversation at this point. Switches you into the branch and preserves the original, which you can return to with `/resume`. Alias: `/fork`. When [`CLAUDE_CODE_FORK_SUBAGENT`](https://docs.claude.com/docs/en/env-vars) is set, `/fork` instead spawns a [forked subagent](https://docs.claude.com/docs/en/sub-agents#fork-the-current-conversation) and is no longer an alias for this command |
| `/btw <question>` | Ask a quick [side question](https://docs.claude.com/docs/en/interactive-mode#side-questions-with-%2Fbtw) without adding to the conversation |
| `/chrome` | Configure [Claude in Chrome](https://docs.claude.com/docs/en/chrome) settings |
| `/claude-api` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Load Claude API reference material for your project’s language (Python, TypeScript, Java, Go, Ruby, C#, PHP, or cURL) and Managed Agents reference. Covers tool use, streaming, batches, structured outputs, and common pitfalls. Also activates automatically when your code imports `anthropic` or `@anthropic-ai/sdk` |
| `/clear` | Start a new conversation with empty context. The previous conversation stays available in `/resume`. To free up context while continuing the same conversation, use `/compact` instead. Aliases: `/reset`, `/new` |
| `/color [color|default]` | Set the prompt bar color for the current session. Available colors: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. Use `default` to reset. When [Remote Control](https://docs.claude.com/docs/en/remote-control) is connected, the color syncs to claude.ai/code |
| `/compact [instructions]` | Free up context by summarizing the conversation so far. Optionally pass focus instructions for the summary. See [how compaction handles rules, skills, and memory files](https://docs.claude.com/docs/en/context-window#what-survives-compaction) |
| `/config` | Open the [Settings](https://docs.claude.com/docs/en/settings) interface to adjust theme, model, [output style](https://docs.claude.com/docs/en/output-styles), and other preferences. Alias: `/settings` |
| `/context` | Visualize current context usage as a colored grid. Shows optimization suggestions for context-heavy tools, memory bloat, and capacity warnings |
| `/copy [N]` | Copy the last assistant response to clipboard. Pass a number `N` to copy the Nth-latest response: `/copy 2` copies the second-to-last. When code blocks are present, shows an interactive picker to select individual blocks or the full response. Press `w` in the picker to write the selection to a file instead of the clipboard, which is useful over SSH |
| `/cost` | Alias for `/usage` |
| `/debug [description]` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Enable debug logging for the current session and troubleshoot issues by reading the session debug log. Debug logging is off by default unless you started with `claude --debug`, so running `/debug` mid-session starts capturing logs from that point forward. Optionally describe the issue to focus the analysis |
| `/desktop` | Continue the current session in the Claude Code Desktop app. macOS and Windows only. Alias: `/app` |
| `/diff` | Open an interactive diff viewer showing uncommitted changes and per-turn diffs. Use left/right arrows to switch between the current git diff and individual Claude turns, and up/down to browse files |
| `/doctor` | Diagnose and verify your Claude Code installation and settings. Results show with status icons. Press `f` to have Claude fix any reported issues |
| `/effort [level|auto]` | Set the model [effort level](https://docs.claude.com/docs/en/model-config#adjust-effort-level). Accepts `low`, `medium`, `high`, `xhigh`, or `max`; available levels depend on the model and `max` is session-only. `auto` resets to the model default. Without an argument, opens an interactive slider; use left and right arrows to pick a level and `Enter` to apply. Takes effect immediately without waiting for the current response to finish |
| `/exit` | Exit the CLI. Alias: `/quit` |
| `/export [filename]` | Export the current conversation as plain text. With a filename, writes directly to that file. Without, opens a dialog to copy to clipboard or save to a file |
| `/extra-usage` | Configure extra usage to keep working when rate limits are hit |
| `/fast [on|off]` | Toggle [fast mode](https://docs.claude.com/docs/en/fast-mode) on or off |
| `/feedback [report]` | Submit feedback about Claude Code. Alias: `/bug` |
| `/fewer-permission-prompts` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Scan your transcripts for common read-only Bash and MCP tool calls, then add a prioritized allowlist to project `.claude/settings.json` to reduce permission prompts |
| `/focus` | Toggle the focus view, which shows only your last prompt, a one-line tool-call summary with edit diffstats, and the final response. The selection persists across sessions. Only available in [fullscreen rendering](https://docs.claude.com/docs/en/fullscreen) |
| `/heapdump` | Write a JavaScript heap snapshot and a memory breakdown to `~/Desktop` for diagnosing high memory usage. See [troubleshooting](https://docs.claude.com/docs/en/troubleshooting#high-cpu-or-memory-usage) |
| `/help` | Show help and available commands |
| `/hooks` | View [hook](https://docs.claude.com/docs/en/hooks) configurations for tool events |
| `/ide` | Manage IDE integrations and show status |
| `/init` | Initialize project with a `CLAUDE.md` guide. Set `CLAUDE_CODE_NEW_INIT=1` for an interactive flow that also walks through skills, hooks, and personal memory files |
| `/insights` | Generate a report analyzing your Claude Code sessions, including project areas, interaction patterns, and friction points |
| `/install-github-app` | Set up the [Claude GitHub Actions](https://docs.claude.com/docs/en/github-actions) app for a repository. Walks you through selecting a repo and configuring the integration |
| `/install-slack-app` | Install the Claude Slack app. Opens a browser to complete the OAuth flow |
| `/keybindings` | Open or create your keybindings configuration file |
| `/login` | Sign in to your Anthropic account |
| `/logout` | Sign out from your Anthropic account |
| `/loop [interval] [prompt]` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Run a prompt repeatedly while the session stays open. Omit the interval and Claude self-paces between iterations. Omit the prompt and Claude runs an autonomous maintenance check, or the prompt in `.claude/loop.md` if present. Example: `/loop 5m check if the deploy finished`. See [Run prompts on a schedule](https://docs.claude.com/docs/en/scheduled-tasks). Alias: `/proactive` |
| `/mcp` | Manage MCP server connections and OAuth authentication |
| `/memory` | Edit `CLAUDE.md` memory files, enable or disable [auto-memory](https://docs.claude.com/docs/en/memory#auto-memory), and view auto-memory entries |
| `/mobile` | Show QR code to download the Claude mobile app. Aliases: `/ios`, `/android` |
| `/model [model]` | Select or change the AI model. For models that support it, use left/right arrows to [adjust effort level](https://docs.claude.com/docs/en/model-config#adjust-effort-level). With no argument, opens a picker that asks for confirmation when the conversation has prior output, since the next response re-reads the full history without cached context. Once confirmed, the change applies without waiting for the current response to finish |
| `/passes` | Share a free week of Claude Code with friends. Only visible if your account is eligible |
| `/permissions` | Manage allow, ask, and deny rules for tool permissions. Opens an interactive dialog where you can view rules by scope, add or remove rules, manage working directories, and review [recent auto mode denials](https://docs.claude.com/docs/en/auto-mode-config#review-denials). Alias: `/allowed-tools` |
| `/plan [description]` | Enter plan mode directly from the prompt. Pass an optional description to enter plan mode and immediately start with that task, for example `/plan fix the auth bug` |
| `/plugin` | Manage Claude Code [plugins](https://docs.claude.com/docs/en/plugins) |
| `/powerup` | Discover Claude Code features through quick interactive lessons with animated demos |
| `/pr-comments [PR]` | Removed in v2.1.91. Ask Claude directly to view pull request comments instead. On earlier versions, fetches and displays comments from a GitHub pull request; automatically detects the PR for the current branch, or pass a PR URL or number. Requires the `gh` CLI |
| `/privacy-settings` | View and update your privacy settings. Only available for Pro and Max plan subscribers |
| `/recap` | Generate a one-line summary of the current session on demand. See [Session recap](https://docs.claude.com/docs/en/interactive-mode#session-recap) for the automatic recap that appears after you’ve been away |
| `/release-notes` | View the changelog in an interactive version picker. Select a specific version to see its release notes, or choose to show all versions |
| `/reload-plugins` | Reload all active [plugins](https://docs.claude.com/docs/en/plugins) to apply pending changes without restarting. Reports counts for each reloaded component and flags any load errors |
| `/remote-control` | Make this session available for [remote control](https://docs.claude.com/docs/en/remote-control) from claude.ai. Alias: `/rc` |
| `/remote-env` | Configure the default remote environment for [web sessions started with `--remote`](https://docs.claude.com/docs/en/claude-code-on-the-web#configure-your-environment) |
| `/rename [name]` | Rename the current session and show the name on the prompt bar. Without a name, auto-generates one from conversation history |
| `/resume [session]` | Resume a conversation by ID or name, or open the session picker. Alias: `/continue` |
| `/review [PR]` | Review a pull request locally in your current session. For a deeper cloud-based review, see [`/ultrareview`](https://docs.claude.com/docs/en/ultrareview) |
| `/rewind` | Rewind the conversation and/or code to a previous point, or summarize from a selected message. See [checkpointing](https://docs.claude.com/docs/en/checkpointing). Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Toggle [sandbox mode](https://docs.claude.com/docs/en/sandboxing). Available on supported platforms only |
| `/schedule [description]` | Create, update, list, or run [routines](https://docs.claude.com/docs/en/routines). Claude walks you through the setup conversationally. Alias: `/routines` |
| `/security-review` | Analyze pending changes on the current branch for security vulnerabilities. Reviews the git diff and identifies risks like injection, auth issues, and data exposure |
| `/setup-bedrock` | Configure [Amazon Bedrock](https://docs.claude.com/docs/en/amazon-bedrock) authentication, region, and model pins through an interactive wizard. Only visible when `CLAUDE_CODE_USE_BEDROCK=1` is set. First-time Bedrock users can also access this wizard from the login screen |
| `/setup-vertex` | Configure [Google Vertex AI](https://docs.claude.com/docs/en/google-vertex-ai) authentication, project, region, and model pins through an interactive wizard. Only visible when `CLAUDE_CODE_USE_VERTEX=1` is set. First-time Vertex AI users can also access this wizard from the login screen |
| `/simplify [focus]` | **[Skill](https://docs.claude.com/docs/en/skills#bundled-skills).** Review your recently changed files for code reuse, quality, and efficiency issues, then fix them. Spawns three review agents in parallel, aggregates their findings, and applies fixes. Pass text to focus on specific concerns: `/simplify focus on memory efficiency` |
| `/skills` | List available [skills](https://docs.claude.com/docs/en/skills). Press `t` to sort by token count |
| `/stats` | Alias for `/usage`. Opens on the Stats tab |
| `/status` | Open the Settings interface (Status tab) showing version, model, account, and connectivity. Works while Claude is responding, without waiting for the current response to finish |
| `/statusline` | Configure Claude Code’s [status line](https://docs.claude.com/docs/en/statusline). Describe what you want, or run without arguments to auto-configure from your shell prompt |
| `/stickers` | Order Claude Code stickers |
| `/tasks` | List and manage background tasks. Also available as `/bashes` |
| `/team-onboarding` | Generate a team onboarding guide from your Claude Code usage history. Claude analyzes your sessions, commands, and MCP server usage from the past 30 days and produces a markdown guide a teammate can paste as a first message to get set up quickly |
| `/teleport` | Pull a [Claude Code on the web](https://docs.claude.com/docs/en/claude-code-on-the-web#from-web-to-terminal) session into this terminal: opens a picker, then fetches the branch and conversation. Also available as `/tp`. Requires a claude.ai subscription |
| `/terminal-setup` | Configure terminal keybindings for Shift+Enter and other shortcuts. Only visible in terminals that need it, like VS Code, Cursor, Windsurf, Alacritty, or Zed |
| `/theme` | Change the color theme. Includes an `auto` option that matches your terminal’s light or dark background, light and dark variants, colorblind-accessible (daltonized) themes, ANSI themes that use your terminal’s color palette, and any [custom themes](https://docs.claude.com/docs/en/terminal-config#create-a-custom-theme) from `~/.claude/themes/` or plugins. Select **New custom theme…** to create one |
| `/tui [default|fullscreen]` | Set the terminal UI renderer and relaunch into it with your conversation intact. `fullscreen` enables the [flicker-free alt-screen renderer](https://docs.claude.com/docs/en/fullscreen). With no argument, prints the active renderer |
| `/ultraplan <prompt>` | Draft a plan in an [ultraplan](https://docs.claude.com/docs/en/ultraplan) session, review it in your browser, then execute remotely or send it back to your terminal |
| `/ultrareview [PR]` | Run a deep, multi-agent code review in a cloud sandbox with [ultrareview](https://docs.claude.com/docs/en/ultrareview). Includes 3 free runs on Pro and Max through May 5, 2026, then requires [extra usage](https://support.claude.com/en/articles/12429409-extra-usage-for-paid-claude-plans) |
| `/upgrade` | Open the upgrade page to switch to a higher plan tier |
| `/usage` | Show session cost, plan usage limits, and activity stats. See the [cost tracking guide](https://docs.claude.com/docs/en/costs#using-the-%2Fusage-command) for subscription-specific details. `/cost` and `/stats` are aliases |
| `/vim` | Removed in v2.1.92. To toggle between Vim and Normal editing modes, use `/config` → Editor mode |
| `/voice [hold|tap|off]` | Toggle [voice dictation](https://docs.claude.com/docs/en/voice-dictation), or enable it in a specific mode. Requires a Claude.ai account |
| `/web-setup` | Connect your GitHub account to [Claude Code on the web](https://docs.claude.com/docs/en/web-quickstart#connect-from-your-terminal) using your local `gh` CLI credentials. `/schedule` prompts for this automatically if GitHub isn’t connected |

## [​](https://docs.claude.com/en/docs/claude-code/commands#mcp-prompts)

MCP prompts

MCP servers can expose prompts that appear as commands. These use the format `/mcp__<server>__<prompt>` and are dynamically discovered from connected servers. See [MCP prompts](https://docs.claude.com/docs/en/mcp#use-mcp-prompts-as-commands) for details.
## [​](https://docs.claude.com/en/docs/claude-code/commands#see-also)

See also

*   [Skills](https://docs.claude.com/docs/en/skills): create your own commands
*   [Interactive mode](https://docs.claude.com/docs/en/interactive-mode): keyboard shortcuts, Vim mode, and command history
*   [CLI reference](https://docs.claude.com/docs/en/cli-reference): launch-time flags

Was this page helpful?

Yes No

[CLI reference](https://docs.claude.com/docs/en/cli-reference)[Environment variables](https://docs.claude.com/docs/en/env-vars)

⌘I

[Claude Code Docs home page![Image 4: light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![Image 5: dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://docs.claude.com/docs/en/overview)

[x](https://x.com/AnthropicAI)[linkedin](https://www.linkedin.com/company/anthropicresearch)

Company

[Anthropic](https://www.anthropic.com/company)[Careers](https://www.anthropic.com/careers)[Economic Futures](https://www.anthropic.com/economic-futures)[Research](https://www.anthropic.com/research)[News](https://www.anthropic.com/news)[Trust center](https://trust.anthropic.com/)[Transparency](https://www.anthropic.com/transparency)

Help and security

[Availability](https://www.anthropic.com/supported-countries)[Status](https://status.anthropic.com/)[Support center](https://support.claude.com/)

Learn

[Courses](https://www.anthropic.com/learn)[MCP connectors](https://claude.com/partners/mcp)[Customer stories](https://www.claude.com/customers)[Engineering blog](https://www.anthropic.com/engineering)[Events](https://www.anthropic.com/events)[Powered by Claude](https://claude.com/partners/powered-by-claude)[Service partners](https://claude.com/partners/services)[Startups program](https://claude.com/programs/startups)

Terms and policies

[Privacy choices](https://docs.claude.com/en/docs/claude-code/commands#)[Privacy policy](https://www.anthropic.com/legal/privacy)[Disclosure policy](https://www.anthropic.com/responsible-disclosure-policy)[Usage policy](https://www.anthropic.com/legal/aup)[Commercial terms](https://www.anthropic.com/legal/commercial-terms)[Consumer terms](https://www.anthropic.com/legal/consumer-terms)

Assistant

Responses are generated using AI and may contain mistakes.
