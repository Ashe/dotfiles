#!/usr/bin/fish

# Remove keybindings for fzf
bind --erase \ct '__fzf_find_file'
bind --erase \ct '__fzf_find_file'
bind --erase \cr '__fzf_reverse_isearch'
bind --erase \ec '__fzf_cd'
bind --erase \eC '__fzf_cd --hidden'
bind --erase \cg '__fzf_open'
bind --erase \co '__fzf_open --editor'
bind -M insert --erase \ct '__fzf_find_file'
bind -M insert --erase \cr '__fzf_reverse_isearch'
bind -M insert --erase \ec '__fzf_cd'
bind -M insert --erase \eC '__fzf_cd --hidden'
bind -M insert --erase \cg '__fzf_open'
bind -M insert --erase \co '__fzf_open --editor'

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
