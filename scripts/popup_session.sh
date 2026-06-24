#!/usr/bin/env bash
#
# Launch (or re-focus) an app in the shared popup session.
#
#   popup_session.sh <session> <window> <command...>
#
# All popup apps live in one tmux session (default name "TmuxPopup"), one window
# per app. This ensures the session and the app's window exist — launching
# <command> via a login+interactive shell so shell functions, aliases and tools
# like volta/node resolve — selects that window, then attaches the popup to it.
# Because the apps live in a long-lived session, closing the popup (detach) just
# leaves them running; reopening resumes where you left off.
set -u

session="${1:?usage: popup_session.sh <session> <window> <command>}"
window="${2:?missing window}"
shift 2
cmd="$*"
[ -n "$cmd" ] || { echo "popup-session: empty command" >&2; exit 2; }

status="$(tmux show-option -gqv @popup-session-status)"
[ -n "$status" ] || status="off"

# Run through a login+interactive shell so $cmd may be a function/alias.
launch="$SHELL -lic $(printf '%q' "$cmd")"

if ! tmux has-session -t "=$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -n "$window" "$launch"
  tmux set-option -t "$session" status "$status"
elif ! tmux list-windows -t "=$session" -F '#{window_name}' | grep -qxF -- "$window"; then
  tmux new-window -d -t "=$session" -n "$window" "$launch"
fi

tmux select-window -t "$session:$window"
exec env -u TMUX tmux attach-session -t "=$session"
