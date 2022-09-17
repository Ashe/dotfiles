{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install telescope plugin
    plugins = with pkgs.vimPlugins; [{
      plugin = telescope-nvim;
      config = ''
        " ================================
        " telescope
        " ================================

        let mapleader = " "
        nnoremap <leader><leader> <cmd>Telescope find_files<cr>
        nnoremap <C-p> <cmd>Telescope find_files<cr>
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fr <cmd>Telescope oldfiles<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        nnoremap <leader>? <cmd>Telescope commands<cr>
        nnoremap <C-S-p> <cmd>Telescope commands<cr>
      '';
    }];
  };

  # RipGrep used for telescope
  home.packages = with pkgs; [
    ripgrep
  ];
}
