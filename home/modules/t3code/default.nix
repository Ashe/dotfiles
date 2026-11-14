{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

{
  options.t3code = {
    enable = lib.mkEnableOption "t3code";
    desktop.enable = lib.mkEnableOption "t3code desktop app" // {
      default = true;
    };
    extraProviders = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional agent packages to put on t3code's PATH, e.g. codex";
    };
  };

  config = lib.mkIf config.t3code.enable {

    # Install t3code - a control surface for coding agents
    home.packages =
      let
        # t3code finds agents by fixed binary names, so expose a package's main program under the expected name
        asBinary =
          name: package:
          pkgs.runCommand "t3code-${name}" { } ''
            mkdir -p $out/bin
            ln -s ${lib.getExe package} $out/bin/${name}
          '';

        # Only hand t3code the agents whose modules are enabled, using the same packages those modules install
        providers =
          lib.optionals config.claude.enable [ config.programs.claude-code.finalPackage ]
          ++ lib.optionals config.opencode.enable [ (asBinary "opencode" config.programs.opencode.package) ]
          ++ config.t3code.extraProviders;

        # Final t3code package
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.t3code.override {
          providerPackages = providers;
        };
      in
      [
        package
      ]
      ++ lib.optionals config.t3code.desktop.enable [ package.desktop ];
  };
}
