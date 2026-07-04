{ config, lib, ... }:

{
  options.ssh =
    let
      serviceUserSubmodule = lib.types.submodule {
        options.authorizedKeysCommand = lib.mkOption {
          type = lib.types.str;
          description = "Absolute path + args for AuthorizedKeysCommand, run as this same user.";
        };
      };
    in
    {
      disableAssertion = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Set true to skip the sanity check that services.openssh.enable
          agrees with whether config.server.domain is set. Leave this false
          unless you're deliberately building a config with no SSH at all.
        '';
      };

      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Master switch for local (LAN) SSH — regular interactive logins plus anything registered under ssh.local.services.";
      };

      local = {

        port = lib.mkOption {
          type = lib.types.port;
          default = 22;
          description = "Port for local SSH. Not meant to be forwarded through your router.";
        };

        enableServices = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Kill switch for accounts registered under ssh.local.services, without
            touching regular interactive logins or ssh.enable itself.
          '';
        };

        services = lib.mkOption {
          type = lib.types.attrsOf serviceUserSubmodule;
          default = { };
          description = ''
            Registry of non-interactive local SSH service accounts, keyed by
            username, e.g.:
              ssh.local.services.git = { authorizedKeysCommand = "..."; };
            Because this is a plain attrsOf keyed by the literal username, two
            modules registering the same name with conflicting definitions is
            a hard eval-time error, not a silent clobber.
          '';
        };
      };

      public = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Master switch for a second, internet-facing SSH port. Only
            accounts registered in ssh.public.services may authenticate on
            it — regular users can never reach it, regardless of this flag.
          '';
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 2222;
          description = "Port for public SSH. The only SSH port you should ever forward through your router.";
        };

        enableServices = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Kill switch for accounts registered under ssh.public.services.";
        };

        services = lib.mkOption {
          type = lib.types.attrsOf serviceUserSubmodule;
          default = { };
          description = ''
            Registry of service accounts allowed on the public port. Entirely
            separate from ssh.local.services — registering a user locally does
            NOT expose it publicly; a deliberate second registration here is
            required for that.
          '';
        };
      };
    };

  config = lib.mkMerge [
    (lib.mkIf config.ssh.enable {

      # Enable SSH
      services.openssh = {
        enable = true;
        ports = [ config.ssh.local.port ] ++ lib.optional config.ssh.public.enable config.ssh.public.port;

        # Require keys to be set up, disallow using passwords
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      services.openssh.extraConfig =
        let
          # One Match block per registered service account: force it through
          # AuthorizedKeysCommand, deny it a shell, tty, and forwarding no matter
          # what the connecting client asks for.
          mkServiceUserBlock = user: def: ''
            Match User ${user}
              AuthorizedKeysCommand ${def.authorizedKeysCommand}
              AuthorizedKeysCommandUser ${user}
              AllowTcpForwarding no
              X11Forwarding no
              PermitTTY no
            Match All
          '';

          localBlocks = lib.optionalString config.ssh.local.enableServices (
            lib.concatStrings (lib.mapAttrsToList mkServiceUserBlock config.ssh.local.services)
          );

          publicUsers = lib.attrNames config.ssh.public.services;

          # Gate the public port itself: only these usernames may even attempt
          # auth here. Everyone else — including every regular human account —
          # is rejected before authentication starts, on this port only.
          publicGate =
            lib.optionalString
              (config.ssh.public.enable && config.ssh.public.enableServices && publicUsers != [ ])
              ''
                Match LocalPort ${toString config.ssh.public.port}
                  AllowUsers ${lib.concatStringsSep " " publicUsers}
                Match All
              '';

          publicBlocks = lib.optionalString (config.ssh.public.enable && config.ssh.public.enableServices) (
            lib.concatStrings (lib.mapAttrsToList mkServiceUserBlock config.ssh.public.services)
          );
        in
        localBlocks + publicGate + publicBlocks;

      # Allow ssh port through firewall
      networking.firewall.allowedTCPPorts = [
        config.ssh.local.port
      ]
      ++ lib.optional config.ssh.public.enable config.ssh.public.port;
    })

    {
      assertions = [
        {
          # Prevent disabling ssh access if this machine is a server
          assertion =
            config.ssh.disableAssertion || (config.services.openssh.enable == (config.server.domain != null));
          message = ''
            services.openssh.enable is ${lib.boolToString config.services.openssh.enable} but
            config.server.domain is ${if config.server.domain == null then "unset" else "set"}.
            A server with a domain that you can't SSH into (or SSH open on
            something with no domain at all) is usually a mistake. Fix it via
            ssh.enable, or set ssh.disableAssertion = true if this is
            deliberate.
          '';
        }
        {
          # Prevent restricting ssh access to zero authorized users
          assertion =
            !config.ssh.enable
            || lib.any (u: u.openssh.authorizedKeys.keys != [ ] || u.openssh.authorizedKeys.keyFiles != [ ]) (
              lib.attrValues config.users.users
            );
          message = "ssh.enable is true but no user has any openssh.authorizedKeys configured — this would build a server nobody can get into. Add at least one authorizedKeys.keys/keyFiles entry before enabling.";
        }
      ];
    }
  ];
}
