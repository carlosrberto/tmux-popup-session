# tmux-popup-session

Open [myapp](https://github.com/your-org/myapp) in a tmux popup that's
always one keystroke away, with its state preserved between opens.

`popup-session` ensures a persistent tmux session named `myapp` exists (creating
it on first use and launching the `myapp` shell function via a login+interactive
shell so volta/node resolve), then attaches to it. Because the popup *attaches*
to a long-lived session, closing it just detaches — myapp keeps running and
reopening resumes exactly where you left off.

## Install

The script is symlinked onto `PATH`:

```sh
ln -sf "$PWD/popup-session" ~/.local/bin/popup-session
```

Then bind a key in `~/.tmux.conf`:

```tmux
bind D display-popup -E -w 90% -h 90% "~/.local/bin/popup-session"
```

Reload with `tmux source-file ~/.tmux.conf`.

## Usage

- **`prefix + D`** — open the popup (myapp).
- **`prefix` then `d`** — detach: closes the popup, myapp keeps running (state
  preserved). This is the everyday "close".
- **`Esc`** and all other keys — go straight into myapp (no conflict).
- **`q`** (myapp's own quit) — exits myapp; the next open starts fresh.

## How it works

`display-popup` runs `popup-session`, which does:

```sh
tmux has-session -t '=myapp' || tmux new-session -d -s myapp "$SHELL -lic myapp"
exec env -u TMUX tmux attach-session -t myapp
```

`TMUX` is unset for the attach so tmux allows attaching to a session on the same
server from inside the popup. The `myapp` session's status bar is turned off for
a clean popup.

## Requirements

- `tmux` 3.2+ (`display-popup`)
- a `myapp` command/function available in your login shell
