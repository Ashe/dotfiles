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
  };
}
