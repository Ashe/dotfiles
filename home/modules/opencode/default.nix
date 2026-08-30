{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

{
  options.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.opencode.enable {

    # Configure opencode - an opensource AI agent harness
    programs.opencode = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
      settings = builtins.fromJSON (builtins.readFile ./settings.json);
      context = builtins.readFile ./context.md;

      # Formatters, matching the neovim conform set
      extraPackages = with pkgs; [
        nixfmt # Nix
        rustfmt # Rust
        clang-tools # C/C++ (clang-format)
        fourmolu # Haskell
        stylua # Lua
        google-java-format # Java
        yq-go # Yaml
        jq # Json
        taplo # Toml
        libxml2 # Xml (xmllint)
      ];
    };
  };
}
