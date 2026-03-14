{ lib, ... }:

{
  # Custom module containing commonly required data for service modules
  options.server = {
    ip = lib.mkOption {
      type = lib.types.str;
      description = "Local IP address of this server";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "Local domain name for this server";
    };
    publicDomain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public-facing domain for externally exposed services e.g. aas.sh";
    };
  };
}
