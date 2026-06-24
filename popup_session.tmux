#!/usr/bin/env bash
#
# Plugin entry point, sourced by TPM (Tmux Plugin Manager) at tmux start.
# Binds one key per configured app; each opens that app in a popup attached to a
# shared "popup" session (one window per app), so app state is kept across opens.
#
# The plugin version lives in the top-level VERSION file.
#
# Configure (in tmux.conf):
#   set -g @popup-session-apps   'myapp lazygit'   # app names
#   set -g @popup-session-myapp-key 'D'            # required per app
#   set -g @popup-session-myapp-cmd 'myapp'       # defaults to the app name
#   set -g @popup-session-lazygit-key 'G'
#   set -g @popup-session-name   'TmuxPopup'        # shared session (default)
#   set -g @popup-session-width  '80%'              # global default popup size
#   set -g @popup-session-height '80%'
#   set -g @popup-session-status 'off'              # inner status bar on/off
# Per-app overrides: @popup-session-<name>-{cmd,window,width,height}.
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

opt() { tmux show-option -gqv "$1"; }

GW="$(opt @popup-session-width)";  [ -n "$GW" ] || GW="80%"
GH="$(opt @popup-session-height)"; [ -n "$GH" ] || GH="80%"
SESSION="$(opt @popup-session-name)"; [ -n "$SESSION" ] || SESSION="TmuxPopup"

# shellcheck disable=SC2086  # intentional word-splitting of the space-separated app list
for name in $(opt @popup-session-apps); do
  key="$(opt "@popup-session-${name}-key")"
  [ -n "$key" ] || continue                       # an app with no key is skipped
  cmd="$(opt "@popup-session-${name}-cmd")";     [ -n "$cmd" ]    || cmd="$name"
  window="$(opt "@popup-session-${name}-window")"; [ -n "$window" ] || window="$name"
  w="$(opt "@popup-session-${name}-width")";     [ -n "$w" ] || w="$GW"
  h="$(opt "@popup-session-${name}-height")";    [ -n "$h" ] || h="$GH"

  run="$CURRENT_DIR/scripts/popup_session.sh $(printf '%q' "$SESSION") $(printf '%q' "$window") $(printf '%q' "$cmd")"
  tmux bind-key "$key" display-popup -E -w "$w" -h "$h" "$run"
done
