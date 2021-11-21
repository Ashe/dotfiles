{ pkgs, theme, ... }:

let 
  colours = theme.colourscheme;
in
{
  # Configure tmux
  programs.tmux = {
    enable = true;
    customPaneNavigationAndResize = false;

    # Enable plugins
    plugins = [
      { plugin = pkgs.tmuxPlugins.vim-tmux-navigator; }
    ];

    # Set prefix key
    prefix = "C-Space";

    # Simplify indexing
    baseIndex = 1;
    escapeTime = 0;

    # Additional settings
    extraConfig = ''

      # Enable mouse support
      set -g mouse on

      # Make sure windows are indexed correctly
      set -g renumber-windows on

      # Handle standard window functionality
      setw -g automatic-rename on
      set -g set-titles on
      set -g set-clipboard on

      # Pane switching
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      # Session switching
      bind -r ( switch-client -p 
      bind -r ) switch-client -n

      # Easy splitting
      bind Enter split-window -h -c "#{pane_current_path}"
      bind Space split-window -v -c "#{pane_current_path}"
      bind C-Space split-window -v -c "#{pane_current_path}"

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      # Handle clipboard
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xsel -i -p && xsel -o -p | xsel -i -b"
      bind-key p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"

      # Change appearance
      set -g status off
      set -g visual-activity off
      setw -g monitor-activity off
      setw -g monitor-bell off

      # Panes
      setw -g pane-border-status top
      setw -g pane-border-format '#[bold]#{?#{&&:#{pane_active},#{client_prefix}},#[underscore],}\
      #{?pane_active, ACTIVE ⇒,} #I/#{session_windows} :: #P ⇒ #{pane_current_command} '
      set -g pane-active-border-style fg=${colours.accent-primary}
      set -g pane-border-style fg=${colours.accent-secondary}

      # Windows
      set -g status-justify 'centre'
      set -g status-left-length '80'
      set -g status-right-length '80'
      setw -g window-status-separator '''
    '';
  };
}
