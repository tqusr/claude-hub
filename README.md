# claude-hub

Centralized Claude Code configuration — agents, knowledge vaults, and plugins — managed as a git repository so any machine can be bootstrapped in one command.

## Structure

```
claude-hub/
├── common/
│   ├── agents/        # Global agents, symlinked to ~/.claude/agents/ by /apply
│   └── vaults/        # Shared knowledge vaults (committed directories)
├── projects/
│   └── embedded/      # Embedded Linux project config (git submodule → tqusr/claude-embedded)
│       ├── agents/    # Project-specific agents
│       └── vaults/    # Project-specific vaults
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

## Working on the Embedded Project

```bash
git -C ~/claude-hub submodule update --init -- projects/embedded
ln -s ~/claude-hub/projects/embedded/agents/<agent>.md ~/atlas/.claude/agents/<agent>.md
```

## Plugins

See [`plugins.md`](plugins.md) for plugin IDs, sources, and install commands.
