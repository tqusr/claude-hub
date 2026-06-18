# claude-hub

Centralized Claude Code configuration — agents and plugins — managed as a git repository so any machine can be bootstrapped in one command.

## Structure

```
claude-hub/
├── common/
│   └── agents/        # Global agents, symlinked to ~/.claude/agents/ by /apply
├── projects/
│   └── <project>/     # Project-specific config (git submodule)
│       └── agents/    # Project-specific agents
├── skills/
│   └── apply.md       # /apply slash command
└── plugins.md         # Plugin documentation and install commands
```

## Bootstrapping a New Machine

```bash
git clone git@github.com:tqusr/claude-hub.git ~/claude-hub
mkdir -p ~/.claude/commands
ln -s ~/claude-hub/skills/apply.md ~/.claude/commands/apply.md
```

Then run `/apply` in a Claude Code session. It will:
1. Symlink all common agents into `~/.claude/agents/`
2. Install plugins (`superpowers`, `claude-hud`)

## Plugins

See [`plugins.md`](plugins.md) for plugin IDs, sources, and install commands.

## Smoke Test

The `common/_claude.md` instruction requiring Claude to say "hmmmm" (exactly 4 m's) before every response doubles as a session health check. If that prefix stops appearing, the session context has deteriorated and the config is no longer being applied.
