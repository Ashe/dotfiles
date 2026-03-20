{ inputs, pkgs, config, lib, ... }:

{
  imports = [ inputs.agenix.nixosModules.default ];

  options.agenix.secrets = lib.mkOption {
    type = lib.types.nullOr lib.types.path;
    default = null;
    description = "Path to directory containing .age secret files";
  };

  config = lib.mkIf (config.agenix.secrets != null) {

    # Make the agenix CLI available so you can encrypt/re-encrypt secrets on the server
    environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    # Scan the secrets directory and auto-register every .age file with agenix.
    # Each secret becomes available at /run/agenix/<name> at boot, e.g.
    # password.age -> /run/agenix/password
    age.secrets =
      lib.optionalAttrs (config.agenix.secrets != null)
        (lib.mapAttrs'
          (name: _: lib.nameValuePair
            (lib.removeSuffix ".age" name)
            { file = "${config.agenix.secrets}/${name}"; })
          (lib.filterAttrs
            (name: _: lib.hasSuffix ".age" name)
            (builtins.readDir config.agenix.secrets)));
  };
}
