# tmux-popup-session

Keep your favourite terminal apps one keystroke away in tmux popups, each with
its **state preserved** between opens.

All configured apps live in a single shared tmux session (default `TmuxPopup`),
one window per app. Pressing an app's key opens a popup attached to that session
with the app's window selected. Because the session is long-lived, closing the
popup just detaches — the app keeps running, and reopening resumes exactly where
you left off. (Inside the popup you can even hop between apps with `prefix`+number.)

## Requirements

- `tmux` 3.2+ (`display-popup`)
- the apps you configure, available in your login shell

## Install

### With [TPM](https://github.com/tmux-plugins/tpm)

```tmux
set -g @plugin 'youruser/tmux-popup-session'
```

### Manual

```tmux
run-shell /path/to/tmux-popup-session/popup_session.tmux
```

## Configure

Define your apps and their keys in `~/.tmux.conf`:

```tmux
# Which apps to expose (space- or comma-separated names).
set -g @popup-session-apps 'myapp lazygit'

# Per app: a key is required; the command defaults to the app name.
set -g @popup-session-myapp-key  'D'
set -g @popup-session-myapp-cmd  'myapp'      # optional (defaults to 'myapp')
set -g @popup-session-myapp-width '90%'        # optional per-app size override

set -g @popup-session-lazygit-key 'G'
set -g @popup-session-lazygit-cmd 'lazygit'

# Shared/global options (all optional; defaults shown):
set -g @popup-session-name   'TmuxPopup'        # the shared session
set -g @popup-session-width  '80%'              # default popup width
set -g @popup-session-height '80%'              # default popup height
set -g @popup-session-status 'off'              # status bar inside the popup
```

Reload with `tmux source-file ~/.tmux.conf`.

### Options

| Option | Default | Scope |
| --- | --- | --- |
| `@popup-session-apps` | — | list of app names to bind |
| `@popup-session-<name>-key` | — (required) | the prefix key for that app |
| `@popup-session-<name>-cmd` | the app name | command run for that app |
| `@popup-session-<name>-window` | the app name | window name in the session |
| `@popup-session-<name>-width` / `-height` | global default | per-app popup size |
| `@popup-session-name` | `TmuxPopup` | shared session name |
| `@popup-session-width` / `-height` | `80%` | global popup size |
| `@popup-session-status` | `off` | inner status bar (`on` shows window tabs) |

The command runs through a login+interactive shell, so shell **functions** and
**aliases** work as commands (not just binaries on `PATH`).

## Usage

- **`prefix + <key>`** — open that app's popup.
- **`prefix` then `d`** — detach: closes the popup, the app keeps running (state
  preserved). This is the everyday "close".
- **`Esc`** and other keys — go straight into the app (no conflict).
- The app's own quit (e.g. `q`) exits *that app's window*; reopening relaunches it.

## How it works

Each configured key is bound to:

```tmux
display-popup -E -w <w> -h <h> "scripts/popup_session.sh <session> <window> <cmd>"
```

`popup_session.sh` creates the shared session / the app's window on first use
(`tmux new-session`/`new-window … "$SHELL -lic <cmd>"`), selects the window, then
`exec env -u TMUX tmux attach-session` — `TMUX` is unset so tmux allows attaching
to a session on the same server from inside the popup.

## Layout

```
popup_session.tmux       # plugin entry: reads @popup-session-* options, binds keys
scripts/
  popup_session.sh       # launcher: ensure session+window, select, attach
```
