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
    };
  };
}
