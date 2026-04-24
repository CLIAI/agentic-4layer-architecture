<!--
Cached from: https://docs.claude.com/en/docs/claude-code/tools-reference
Fetch date: 2026-04-24
Fetcher: jina.ai reader proxy (r.jina.ai)
Purpose: L4 Launcher flags + general reference for the 4-layer
         agentic architecture docs. Re-fetch periodically to pick
         up new flags/events — Claude Code docs iterate quickly.
-->

Title: Tools reference - Claude Code Docs

URL Source: https://docs.claude.com/en/docs/claude-code/tools-reference

Markdown Content:
# Tools reference - Claude Code Docs

[Skip to main content](https://docs.claude.com/en/docs/claude-code/tools-reference#content-area)

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

Tools reference

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

*   [Bash tool behavior](https://docs.claude.com/en/docs/claude-code/tools-reference#bash-tool-behavior)
*   [LSP tool behavior](https://docs.claude.com/en/docs/claude-code/tools-reference#lsp-tool-behavior)
*   [Monitor tool](https://docs.claude.com/en/docs/claude-code/tools-reference#monitor-tool)
*   [PowerShell tool](https://docs.claude.com/en/docs/claude-code/tools-reference#powershell-tool)
*   [Enable the PowerShell tool](https://docs.claude.com/en/docs/claude-code/tools-reference#enable-the-powershell-tool)
*   [Shell selection in settings, hooks, and skills](https://docs.claude.com/en/docs/claude-code/tools-reference#shell-selection-in-settings-hooks-and-skills)
*   [Preview limitations](https://docs.claude.com/en/docs/claude-code/tools-reference#preview-limitations)
*   [Check which tools are available](https://docs.claude.com/en/docs/claude-code/tools-reference#check-which-tools-are-available)
*   [See also](https://docs.claude.com/en/docs/claude-code/tools-reference#see-also)

Reference

# Tools reference

Copy page

Complete reference for the tools Claude Code can use, including permission requirements.

Copy page

Claude Code has access to a set of built-in tools that help it understand and modify your codebase. The tool names are the exact strings you use in [permission rules](https://docs.claude.com/docs/en/permissions#tool-specific-permission-rules), [subagent tool lists](https://docs.claude.com/docs/en/sub-agents), and [hook matchers](https://docs.claude.com/docs/en/hooks). To disable a tool entirely, add its name to the `deny` array in your [permission settings](https://docs.claude.com/docs/en/permissions#tool-specific-permission-rules).To add custom tools, connect an [MCP server](https://docs.claude.com/docs/en/mcp). To extend Claude with reusable prompt-based workflows, write a [skill](https://docs.claude.com/docs/en/skills), which runs through the existing `Skill` tool rather than adding a new tool entry.

| Tool | Description | Permission Required |
| --- | --- | --- |
| `Agent` | Spawns a [subagent](https://docs.claude.com/docs/en/sub-agents) with its own context window to handle a task | No |
| `AskUserQuestion` | Asks multiple-choice questions to gather requirements or clarify ambiguity | No |
| `Bash` | Executes shell commands in your environment. See [Bash tool behavior](https://docs.claude.com/en/docs/claude-code/tools-reference#bash-tool-behavior) | Yes |
| `CronCreate` | Schedules a recurring or one-shot prompt within the current session. Tasks are session-scoped and restored on `--resume` or `--continue` if unexpired. See [scheduled tasks](https://docs.claude.com/docs/en/scheduled-tasks) | No |
| `CronDelete` | Cancels a scheduled task by ID | No |
| `CronList` | Lists all scheduled tasks in the session | No |
| `Edit` | Makes targeted edits to specific files | Yes |
| `EnterPlanMode` | Switches to plan mode to design an approach before coding | No |
| `EnterWorktree` | Creates an isolated [git worktree](https://docs.claude.com/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) and switches into it. Pass a `path` to switch into an existing worktree of the current repository instead of creating a new one. Not available to subagents | No |
| `ExitPlanMode` | Presents a plan for approval and exits plan mode | Yes |
| `ExitWorktree` | Exits a worktree session and returns to the original directory. Not available to subagents | No |
| `Glob` | Finds files based on pattern matching | No |
| `Grep` | Searches for patterns in file contents | No |
| `ListMcpResourcesTool` | Lists resources exposed by connected [MCP servers](https://docs.claude.com/docs/en/mcp) | No |
| `LSP` | Code intelligence via language servers: jump to definitions, find references, report type errors and warnings. See [LSP tool behavior](https://docs.claude.com/en/docs/claude-code/tools-reference#lsp-tool-behavior) | No |
| `Monitor` | Runs a command in the background and feeds each output line back to Claude, so it can react to log entries, file changes, or polled status mid-conversation. See [Monitor tool](https://docs.claude.com/en/docs/claude-code/tools-reference#monitor-tool) | Yes |
| `NotebookEdit` | Modifies Jupyter notebook cells | Yes |
| `PowerShell` | Executes PowerShell commands natively. See [PowerShell tool](https://docs.claude.com/en/docs/claude-code/tools-reference#powershell-tool) for availability | Yes |
| `Read` | Reads the contents of files | No |
| `ReadMcpResourceTool` | Reads a specific MCP resource by URI | No |
| `SendMessage` | Sends a message to an [agent team](https://docs.claude.com/docs/en/agent-teams) teammate, or [resumes a subagent](https://docs.claude.com/docs/en/sub-agents#resume-subagents) by its agent ID. Stopped subagents auto-resume in the background. Only available when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set | No |
| `Skill` | Executes a [skill](https://docs.claude.com/docs/en/skills#control-who-invokes-a-skill) within the main conversation | Yes |
| `TaskCreate` | Creates a new task in the task list | No |
| `TaskGet` | Retrieves full details for a specific task | No |
| `TaskList` | Lists all tasks with their current status | No |
| `TaskOutput` | (Deprecated) Retrieves output from a background task. Prefer `Read` on the task’s output file path | No |
| `TaskStop` | Kills a running background task by ID | No |
| `TaskUpdate` | Updates task status, dependencies, details, or deletes tasks | No |
| `TeamCreate` | Creates an [agent team](https://docs.claude.com/docs/en/agent-teams) with multiple teammates. Only available when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set | No |
| `TeamDelete` | Disbands an agent team and cleans up teammate processes. Only available when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set | No |
| `TodoWrite` | Manages the session task checklist. Available in non-interactive mode and the [Agent SDK](https://docs.claude.com/docs/en/headless); interactive sessions use TaskCreate, TaskGet, TaskList, and TaskUpdate instead | No |
| `ToolSearch` | Searches for and loads deferred tools when [tool search](https://docs.claude.com/docs/en/mcp#scale-with-mcp-tool-search) is enabled | No |
| `WebFetch` | Fetches content from a specified URL | Yes |
| `WebSearch` | Performs web searches | Yes |
| `Write` | Creates or overwrites files | Yes |

Permission rules can be configured using `/permissions` or in [permission settings](https://docs.claude.com/docs/en/settings#available-settings). Also see [Tool-specific permission rules](https://docs.claude.com/docs/en/permissions#tool-specific-permission-rules).
## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#bash-tool-behavior)

Bash tool behavior

The Bash tool runs each command in a separate process with the following persistence behavior:
*   When Claude runs `cd` in the main session, the new working directory carries over to later Bash commands as long as it stays inside the project directory or an [additional working directory](https://docs.claude.com/docs/en/permissions#working-directories) you added with `--add-dir`, `/add-dir`, or `additionalDirectories` in settings. Subagent sessions never carry over working directory changes.
    *   If `cd` lands outside those directories, Claude Code resets to the project directory and appends `Shell cwd was reset to <dir>` to the tool result.
    *   To disable this carry-over so every Bash command starts in the project directory, set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1`.

*   Environment variables do not persist. An `export` in one command will not be available in the next.

Activate your virtualenv or conda environment before launching Claude Code. To make environment variables persist across Bash commands, set [`CLAUDE_ENV_FILE`](https://docs.claude.com/docs/en/env-vars) to a shell script before launching Claude Code, or use a [SessionStart hook](https://docs.claude.com/docs/en/hooks#persist-environment-variables) to populate it dynamically.
## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#lsp-tool-behavior)

LSP tool behavior

The LSP tool gives Claude code intelligence from a running language server. After each file edit, it automatically reports type errors and warnings so Claude can fix issues without a separate build step. Claude can also call it directly to navigate code:
*   Jump to a symbol’s definition
*   Find all references to a symbol
*   Get type information at a position
*   List symbols in a file or workspace
*   Find implementations of an interface
*   Trace call hierarchies

The tool is inactive until you install a [code intelligence plugin](https://docs.claude.com/docs/en/discover-plugins#code-intelligence) for your language. The plugin bundles the language server configuration, and you install the server binary separately.
## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#monitor-tool)

Monitor tool

The Monitor tool requires Claude Code v2.1.98 or later.

The Monitor tool lets Claude watch something in the background and react when it changes, without pausing the conversation. Ask Claude to:
*   Tail a log file and flag errors as they appear
*   Poll a PR or CI job and report when its status changes
*   Watch a directory for file changes
*   Track output from any long-running script you point it at

Claude writes a small script for the watch, runs it in the background, and receives each output line as it arrives. You keep working in the same session and Claude interjects when an event lands. Stop a monitor by asking Claude to cancel it or by ending the session.Monitor uses the same [permission rules as Bash](https://docs.claude.com/docs/en/permissions#tool-specific-permission-rules), so `allow` and `deny` patterns you have set for Bash apply here too. It is not available on Amazon Bedrock, Google Vertex AI, or Microsoft Foundry. It is also not available when `DISABLE_TELEMETRY` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set.Plugins can declare monitors that start automatically when the plugin is active, instead of asking Claude to start them. See [plugin monitors](https://docs.claude.com/docs/en/plugins-reference#monitors).
## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#powershell-tool)

PowerShell tool

The PowerShell tool lets Claude run PowerShell commands natively. On Windows, this means commands run in PowerShell instead of routing through Git Bash. The tool is rolling out progressively on Windows and is opt-in on Linux, macOS, and WSL.
### [​](https://docs.claude.com/en/docs/claude-code/tools-reference#enable-the-powershell-tool)

Enable the PowerShell tool

Set `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` in your environment or in `settings.json`:

```
{
  "env": {
    "CLAUDE_CODE_USE_POWERSHELL_TOOL": "1"
  }
}
```

On Windows, set the variable to `0` to opt out of the rollout. On Linux, macOS, and WSL, the tool requires PowerShell 7 or later: install `pwsh` and ensure it is on your `PATH`.On Windows, Claude Code auto-detects `pwsh.exe` for PowerShell 7+ with a fallback to `powershell.exe` for PowerShell 5.1. The Bash tool remains registered alongside the PowerShell tool, so you may need to ask Claude to use PowerShell.
### [​](https://docs.claude.com/en/docs/claude-code/tools-reference#shell-selection-in-settings-hooks-and-skills)

Shell selection in settings, hooks, and skills

Three additional settings control where PowerShell is used:
*   `"defaultShell": "powershell"` in [`settings.json`](https://docs.claude.com/docs/en/settings#available-settings): routes interactive `!` commands through PowerShell. Requires the PowerShell tool to be enabled.
*   `"shell": "powershell"` on individual [command hooks](https://docs.claude.com/docs/en/hooks#command-hook-fields): runs that hook in PowerShell. Hooks spawn PowerShell directly, so this works regardless of `CLAUDE_CODE_USE_POWERSHELL_TOOL`.
*   `shell: powershell` in [skill frontmatter](https://docs.claude.com/docs/en/skills#frontmatter-reference): runs `!`command`` blocks in PowerShell. Requires the PowerShell tool to be enabled.

The same main-session working-directory reset behavior described under the Bash tool section applies to PowerShell commands, including the `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` environment variable.
### [​](https://docs.claude.com/en/docs/claude-code/tools-reference#preview-limitations)

Preview limitations

The PowerShell tool has the following known limitations during the preview:
*   PowerShell profiles are not loaded
*   On Windows, sandboxing is not supported
*   On Windows, Git Bash is still required to start Claude Code

## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#check-which-tools-are-available)

Check which tools are available

Your exact tool set depends on your provider, platform, and settings. To check what’s loaded in a running session, ask Claude directly:

```
What tools do you have access to?
```

Claude gives a conversational summary. For exact MCP tool names, run `/mcp`.
## [​](https://docs.claude.com/en/docs/claude-code/tools-reference#see-also)

See also

*   [MCP servers](https://docs.claude.com/docs/en/mcp): add custom tools by connecting external servers
*   [Permissions](https://docs.claude.com/docs/en/permissions): permission system, rule syntax, and tool-specific patterns
*   [Subagents](https://docs.claude.com/docs/en/sub-agents): configure tool access for subagents
*   [Hooks](https://docs.claude.com/docs/en/hooks-guide): run custom commands before or after tool execution

Was this page helpful?

Yes No

[Environment variables](https://docs.claude.com/docs/en/env-vars)[Interactive mode](https://docs.claude.com/docs/en/interactive-mode)

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

[Privacy choices](https://docs.claude.com/en/docs/claude-code/tools-reference#)[Privacy policy](https://www.anthropic.com/legal/privacy)[Disclosure policy](https://www.anthropic.com/responsible-disclosure-policy)[Usage policy](https://www.anthropic.com/legal/aup)[Commercial terms](https://www.anthropic.com/legal/commercial-terms)[Consumer terms](https://www.anthropic.com/legal/consumer-terms)

Assistant

Responses are generated using AI and may contain mistakes.
