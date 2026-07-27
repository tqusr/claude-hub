# claude-hub

Centralized Claude Code configuration — agents and plugins — managed as a git repository so any machine can be bootstrapped in one command.

## Structure

```
claude-hub/
├── common/
│   └── agents/        # Global agents, symlinked to ~/.claude/agents/ by apply.sh
├── projects/
│   └── <project>/     # Project-specific config (git submodule)
│       └── agents/    # Project-specific agents
├── scripts/
│   └── apply.sh       # Symlinks agents and installs plugins
└── plugins.md         # Plugin documentation and install commands
```

## Bootstrapping a New Machine

```bash
git clone git@github.com:tqusr/claude-hub.git ~/claude-hub
bash ~/claude-hub/scripts/apply.sh
```

It will:
1. Symlink all common agents into `~/.claude/agents/`
2. Install plugins (`superpowers`, `claude-hud`)

## Plugins

See [`plugins.md`](plugins.md) for plugin IDs, sources, and install commands.

## Smoke Test

The `common/_claude.md` instruction requiring Claude to say "hmmmm" (exactly 4 m's) before every response doubles as a session health check. If that prefix stops appearing, the session context has deteriorated and the config is no longer being applied.

## Usage Window Warmup

Claude's usage limits run on a rolling ~5-hour window that starts from the first request in that window. `scripts/claude-hi.sh` + `.service` + `.timer` fire a trivial "hi" request on a fixed schedule so that window reliably starts at predictable times, instead of whenever you happen to first prompt Claude that day.

- `claude-hi.sh` — one-shot script; runs `claude -p "Say hi in one short sentence." --tools ""` (`--tools ""` disables the CLI's tool subsystem entirely, so the call has zero permissions/tool access) and logs the timestamped response.
- `claude-hi.service` — systemd `--user` oneshot unit that runs `claude-hi.sh`; auto-retries on failure, up to 5 attempts.
- `claude-hi.timer` — systemd `--user` timer; fires the service daily at 05:00, 10:01, 15:02, and 20:03 (roughly 5h01m apart), with `Persistent=true`.

### Setup

```bash
ln -s ~/claude-hub/scripts/claude-hi.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now claude-hi.timer
loginctl enable-linger <username>
```

`loginctl enable-linger` keeps the user's systemd `--user` units running (and able to start at boot) without an active login session — without it, the timer won't fire after a full reboot until you log in.
