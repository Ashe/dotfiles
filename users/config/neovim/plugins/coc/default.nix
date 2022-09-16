{ pkgs, ... }:

{
  # Install plugins related to CoC
  programs.neovim.plugins = with pkgs.vimPlugins; [

    # CoC plugin itself
    {
      plugin = coc-nvim;
      config = (builtins.readFile ./config.vim);
    }

    # Languages
    coc-clangd
    coc-cmake
    coc-css
    coc-git
    coc-haxe
    coc-highlight
    coc-html
    coc-json
    coc-lua
    coc-markdownlint
    coc-nvim
    coc-python
    coc-rust-analyzer
    coc-spell-checker
    coc-sh
    coc-yaml
  ];

  # Configure Conquer of Completion
  programs.neovim.coc = {
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
}
