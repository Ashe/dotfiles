{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install barbar plugin
    plugins = with pkgs.vimPlugins; [ {
      plugin = barbar-nvim;
      config = ''
        " ================================
        " barbar
        " ================================

        let mapleader = " "
        nnoremap <silent> <S-Tab> <Cmd>BufferPrevious<CR>
        nnoremap <silent> <A-h> <Cmd>BufferPrevious<CR>
        nnoremap <silent> <Tab> <Cmd>BufferNext<CR>
        nnoremap <silent> <A-l> <Cmd>BufferNext<CR>
        nnoremap <silent> <leader>bp <Cmd>BufferMovePrevious<CR>
        nnoremap <silent> <leader>bn <Cmd>BufferMoveNext<CR>
        nnoremap <silent> <A-S-h> <Cmd>BufferMovePrevious<CR>
        nnoremap <silent> <A-S-l> <Cmd>BufferMoveNext<CR>
        nnoremap <silent> <A-p> <Cmd>BufferMovePrevious<CR>
        nnoremap <silent> <A-n> <Cmd>BufferMoveNext<CR>
        nnoremap <silent> <leader>bx <Cmd>BufferClose<CR>
        nnoremap <silent> <A-BS> <Cmd>BufferClose<CR>
        nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
        nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
        nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
        nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
        nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
        nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
        nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
        nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
        nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
        nnoremap <silent> <A-0> <Cmd>BufferLast<CR>
      '';
    }];
  };
}
