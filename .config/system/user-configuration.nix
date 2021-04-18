{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;

{
  # Packages to install
  home.packages = with pkgs; [

    # Languages
    nodejs
    python3Minimal

    # Programs
    brave
    discord
    dropbox
    dunst
    mpd
    mpv
    ncmpcpp
    neofetch
    polybarFull
    rofi
    scrot
    slock
    youtube-dl

    # Personal fork of ST
    (st.overrideAttrs (oa: rec {
      src = builtins.fetchTarball {
        url = "https://github.com/Ashe/st/archive/master.tar.gz";
      };
      buildInputs = oa.buildInputs ++ [ harfbuzz ];
    }))

    # Fonts
    fira-code
    fira-code-symbols
    (pkgs.callPackage ./packages/waffle.nix {})
  ];

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable discovery of fonts from installed packages
  fonts.fontconfig.enable = lib.mkForce true;

  # Configure FISH
  programs.fish = {
    enable = true;

    # Install plugins
    plugins = [
      
      # 'Pure' prompt theme
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "9d17b2780165572bc6c181cd0e7c5d6dd13be5c1";
          sha256 = "16f8jq2697l0hfv848bn7vzxnbzql4qbi9brkniilfxb1dnllhzb";
        };
      }

      # Notifications when commands are completed
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "done";
          repo = "franciscolourenco";
          rev = "8fd2bc5c95a93b65452281459a167f1bbfb58990";
          sha256 = "16f8jq2697l0hfv848bn7vzxnbzql4qbi9brkniilfxb1dnllhzb";
        };
      }

    ];

    # Add functions
    functions = {
      sudo = {
        body = ''
          if test "$argv" = !!
            eval command sudo $history[1]
          else
            command sudo $argv
          end
        '';
        description = ''
          Replacement for Bash 'sudo !!' command to run last command using sudo
        '';
      };
    };

    # When shell is opened
    interactiveShellInit = ''

      # Allow vi keybindings
      fish_vi_key_bindings

      # Start tmux every session
      if  status is-interactive &&
          command -sq tmux &> /dev/null &&
          not string match -q 'screen*' -- $TERM &&
          not string match -q 'tmux*' -- $TERM &&
          test -z "$TMUX"

        # Check if there's an unattached session
        mkdir -p $HOME/.cache/tmux
        tmux list-sessions > $HOME/.cache/tmux/sessions
        set sessions (cat $HOME/.cache/tmux/sessions | grep -v attached | cut -d: -f1)

        # Reattach to any unattached sessions available
        if set -q sessions[1]
          exec tmux attach-session -t "$sessions[1]"

        # Otherwise start a new session
        else
          exec tmux new-session
        end
      end
    '';
  };

  # Enable fuzzy-file-finder
  programs.fzf.enable = true;

  # Configure git
  programs.git = {
    enable = true;
    userName  = "ashe";
    userEmail = "git@aas.sh";
  };

  # Configure neovim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      coc-cmake
      coc-css
      coc-git
      coc-html
      coc-json
      coc-lua
      coc-markdownlint
      coc-spell-checker
      coc-snippets
      coc-highlight
      coc-nvim
      coc-yaml
      gitgutter
      tmux-navigator
      vim-airline-themes
      {
        plugin = airline;
        config = ''
          " Set airline appearance
          let g:airline_powerline_fonts=1
          let g:airline_theme='deus'
        '';
      }
      {
        plugin = coc-nvim;
        config = ''
          " Goto code navigation
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)

          " Highlight the symbol and its references when holding the cursor
          autocmd CursorHold * silent call CocActionAsync('highlight')

          " Use K to show documentation in preview window
          nnoremap <silent> K :call <SID>show_documentation()<CR>

          " Formatting selected code
          xmap <leader>f  <Plug>(coc-format-selected)
          nmap <leader>f  <Plug>(coc-format-selected)
        '';
      }
      {
        plugin = ctrlp;
        config = ''
          " Filter what gets shown by ctrlp
          set wildignore+=*/tmp/*,*/bin/*,*/obj/*,*.so,*.swp,*.zi
          let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
        '';
      }
    ];

    # Settings for neovim
    extraConfig = ''
      
      " Enable mouse control
      set mouse=a

      " Place swap files in ~/.vim-tmp/
      set backup
      set swapfile
      set backupdir=~/.vim-tmp
      set directory=~/.vim-tmp

      " Enable syntax detection
      syntax on

      " Show column guideline to keep code within 80 lines
      set textwidth=0
      set wrapmargin=0
      set wrap
      set linebreak
      set colorcolumn=81

      " Spellchecking
      set spelllang=en

      " Make terminal title same as the file you're editing
      set title

      " Indent depending on plugins and filetype
      filetype plugin indent on

      " Set leader key to space
      let mapleader = " "

      " Save file with leader-w
      nnoremap <leader>w  :w<CR>

      " Copy to clipboard
      set clipboard+=unnamedplus
      vnoremap  <leader>y "+y
      nnoremap  <leader>Y "+yg_
      nnoremap  <leader>y "+y

      " Paste from clipboard
      nnoremap <leader>p "+p
      nnoremap <leader>P "+P
      vnoremap <leader>p "+p
      vnoremap <leader>P "+P

      " Tabs are 2 spaces
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set expandtab

      " Relative line numbers
      set number
      set relativenumber

      " Autocomplete interface
      set wildmenu

      " Make vim only redraw when needed
      set lazyredraw

      " Show matching parenthesis
      set showmatch

      " Don't pass messages to |ins-completion-menu|
      set shortmess+=c

      " Always show the signcolumn, otherwise it would shift the text each time
      " diagnostics appear/become resolved
      set signcolumn=yes

      " Use tab for trigger completion with characters ahead and navigate
      " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
      " other plugin before putting this into your config
      inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      " Allow the lisp REPL to open with tmux
      let g:slimv_swank_cmd = '! tmux new-window -d -n REPL-SBCL "sbcl --load ~/.config/nvim/plugged/slimv/slime/start-swank.lisp"'

      " Add (Neo)Vim's native statusline support
      " NOTE: Please see `:h coc-status` for integrations with external plugins that
      " provide custom statusline: lightline.vim, vim-airline
      set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}
    '';
  };

  # Enable dropbox service
  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 1;
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Environment = "QT_PLUGIN_PATH=/run/current-system/sw/${pkgs.qt5.qtbase.qtPluginPrefix}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
