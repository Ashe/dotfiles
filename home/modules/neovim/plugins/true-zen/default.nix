{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install true-zen
    plugins = with pkgs.vimPlugins; [{
      plugin = true-zen-nvim;
      type = "lua";
      config = ''
        ----------------------------------
        -- true-zen
        ----------------------------------

        require('true-zen').setup({
          -- Conguration goes here, or leave blank
        })
        vim.api.nvim_set_keymap("n", "<leader>zn", ":TZNarrow<CR>", {})
        vim.api.nvim_set_keymap("v", "<leader>zn", ":'<,'>TZNarrow<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>zf", ":TZFocus<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>zm", ":TZMinimalist<CR>", {})
        vim.api.nvim_set_keymap("n", "<leader>za", ":TZAtaraxis<CR>", {})
      '';
    }];
  };
}
