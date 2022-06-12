{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [

      # Appearance
      barbar-nvim
      nvim-web-devicons
      vim-gitgutter
      vim-airline-themes
      {
        plugin = vim-airline;
        config = ''
          " Set airline appearance
          let g:airline_theme='deus'
        '';
      }

      # Functionality
      vim-fugitive
      vim-tmux-navigator
      {
        plugin = ctrlp-vim;
        config = ''
          " Filter what gets shown by ctrlp
          set wildignore+=*/tmp/*,*/bin/*,*/obj/*,*.so,*.swp,*.zi
          let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
        '';
      }

      # Autocomplete
      coc-cmake
      coc-css
      coc-git
      coc-html
      coc-json
      coc-lua
      coc-markdownlint
      coc-python
      coc-rust-analyzer
      coc-spell-checker
      coc-tabnine
      coc-highlight
      coc-nvim
      coc-yaml
      rust-vim
      vim-nix
      {
        plugin = coc-nvim;
        config = ''

          " Change appearance of floating windows
          hi NormalFloat ctermbg=Black ctermfg=White

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

          " Add (Neo)Vim's native statusline support
          " NOTE: Please see `:h coc-status` for integrations with external plugins that
          " provide custom statusline: lightline.vim, vim-airline
          set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}

          " Documentation function
          function! s:show_documentation()
            if(index(['vim','help'], &filetype) >=0)
              execute 'h '.expand('<cword>')
            elseif (coc#rpc#ready())
              call CocActionAsync('doHover')
            else
              execute '!' . &keywordprg . " " . expand('<cword>')
            endif
          endfunction
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

      " Enable syntax highlighting
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

      " Show switch buffers quickly
      nnoremap <Tab> :bn<CR>
      nnoremap <S-Tab> :bp<CR>

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
    '';

    # Configure Conquer of Completion
    coc = {
      enable = true;
      settings = {
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;

        # Configure CoC per language
        languageserver = {

          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "stack.yaml"
              "cabal.project"
              "package.yaml"
              "hie.yaml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
          };

          nix = {
            command = "rnix-lsp";
            filetypes = [ "nix" ];
          };

        };

        # Miscellaneous settings
        "rust-analyzer.server.path" = "rust-analyzer";
        "rust-analyzer.updates.channel" = "nightly";
        "rust-analyzer.updates.prompt" = false;
      };
    };
  };
}
