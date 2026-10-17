# Option shared by every arrstack service, settable as a bool or as { enable, port, subdomain }
{ lib }:

description: defaultPort: defaultSubdomain:
lib.mkOption {
  type = lib.types.coercedTo lib.types.bool (enable: { inherit enable; }) (
    lib.types.submodule {
      options = {
        enable = lib.mkEnableOption description // {
          default = true;
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = defaultPort;
          description = "Port for ${description}.";
        };
      }
      // lib.optionalAttrs (defaultSubdomain != null) {
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = defaultSubdomain;
          description = "Subdomain for ${description}.";
        };
      };
    }
  );
  default = { };
  description = "Configuration for ${description}.";
}
