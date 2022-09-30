{ pkgs, ...}:

{
  # Configure zsh shell
  programs.zsh = {

    # Enable zsh
    enable = true;

    # Enable zsh features
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    enableVteIntegration = true;

    # Install plugins
    plugins = [

      # Enables vi keybindings
      {
        name = "zsh-vi-mode";
        file = "./share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        src = pkgs.zsh-vi-mode;
      }
    ];

    # Start tmux session automatically
    initExtra = ''
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]]; then
        tmux_unattached=$(tmux list-sessions | grep -v attached | cut -d: -f1 | head -n1)
        if [[ $tmux_unattached ]]; then
          exec tmux attach-session -t "$tmux_unattached"
        else
          exec tmux new-session
        fi
      fi
    '';
  };
}
