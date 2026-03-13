{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [

    # Install nvim-cmp plugin
    {
      plugin = nvim-cmp;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }

    # Install lsp integrations for cmp
    cmp-nvim-lsp

    # Install nvim-treesitter integrations for cmp
    cmp-treesitter

    # Install fancy icons for cmp
    lspkind-nvim
  ];
}
