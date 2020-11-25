#!/usr/bin/fish

# Allow vi keybindings
fish_vi_key_bindings

# Open fuzzy file finder with CTRL+P
bind \cp '__fzf_find_file'
bind -M insert \cp '__fzf_find_file'

# Open file browser with CTRL+O
bind \co 'ranger-cd ; commandline -f repaint'
bind -M insert \co 'ranger-cd ; commandline -f repaint'

# Start tmux every session
if  status is-interactive &&
    command -sq tmux &> /dev/null &&
    not string match -q 'screen*' -- $TERM &&
    not string match -q 'tmux*' -- $TERM &&
    test -z "$TMUX"

  # Check if there's an unattached session
  set tmux_unattached (tmux list-sessions | grep -v attached | cut -d: -f1)

  # Reattach to any unattached sessions available
  if set -q tmux_unattached[1]
    exec /usr/bin/tmux attach-session -t "$tmux_unattached[1]"

  # Otherwise start a new session
  else
    exec /usr/bin/tmux new-session
  end
end
# ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
test -f /home/ashe/.ghcup/env ; and set -gx PATH $HOME/.cabal/bin /home/ashe/.ghcup/bin $PATH
