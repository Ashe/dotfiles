{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.claude = {
    enable = lib.mkEnableOption "claude";
    desktop.enable = lib.mkEnableOption "claude desktop" // {
      default = true;
    };
  };

  config = lib.mkIf config.claude.enable {

    # Configure Claude code - Anthropic's AI agent harness
    programs.claude-code = {
      enable = true;
      package = llm-agents.claude-code;
    };

    # Install Claude desktop app
    home.packages = lib.optionals config.claude.desktop.enable [ llm-agents.claude-desktop ];
  };
}
