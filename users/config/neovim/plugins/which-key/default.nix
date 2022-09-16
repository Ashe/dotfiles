{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install which-key plugin
    plugins = with pkgs.vimPlugins; [ {
      plugin = vim-which-key;
      config = ''
        " ================================
        " which-key
        " ================================
        let g:mapleader = ' '
        nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
        vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
        set timeoutlen=500
        highlight WhichKeyFloating cterm=NONE ctermfg=8 ctermbg=0
      '';
    }];
  };
}
