{
  inputs,
  config,
  lib,
  pkgs,
  shared-lib,
  ...
}:

let
  cfg = config.umbriel;

  # Defaults to the flake's package, the same store path the NixOS module installs
  umbriel = config.programs.umbriel.package;

  # A program started at login; a plain string is taken as its command
  program = lib.types.coercedTo lib.types.str (command: { inherit command; }) (
    lib.types.submodule (
      { config, ... }:
      {
        options = {
          command = lib.mkOption {
            type = lib.types.str;
            description = "Command line that starts the program.";
          };
          appId = lib.mkOption {
            type = lib.types.str;
            default = baseNameOf (lib.head (lib.splitString " " config.command));
            defaultText = lib.literalMD "the command's executable name";
            description = "Application ID its window opens with, as listed by `umbriel windows`.";
          };
        };
      }
    )
  );

  # Send each workspace's programs there, but only while the session is starting
  # Umbriel's at_startup matches for the first 60 seconds, so reopening a program later leaves it where it opens
  placementRules = lib.concatLists (
    lib.imap1 (
      index: workspace:
      map (program: {
        match = {
          app_id = "^${lib.escapeRegex program.appId}$";
          at_startup = true;
        };
        default_workspace = index;
      }) workspace.programs
    ) cfg.workspaces
  );

  # Set each workspace's layout mode by its position
  layoutRules = lib.concatLists (
    lib.imap1 (
      index: workspace:
      lib.optional (workspace.layout != null) {
        inherit index;
        layout.mode = workspace.layout;
      }
    ) cfg.workspaces
  );

  # Run a bind once per key press instead of repeating while held
  once = action: {
    inherit action;
    repeat = false;
  };

  # Step through the focused tab group first, then on to the neighbouring column
  # Relies on layout.tabs.wrap_focus being off, so the last tab leaves focus unchanged
  focusOrTab =
    direction: tab:
    let
      script = pkgs.writeShellScript "umbriel-focus-${direction}" ''
        focused() {
          ${lib.getExe umbriel} focused-window --json 2>/dev/null \
            | ${lib.getExe pkgs.jq} -r '"\(.id) \(.tabbed)"'
        }
        read -r before tabbed <<< "$(focused)"
        if [ "$tabbed" = true ]; then
          ${lib.getExe umbriel} msg column-focus-tab-${tab}
          read -r after _ <<< "$(focused)"
          [ "$after" != "$before" ] && exit 0
        fi
        exec ${lib.getExe umbriel} msg window-focus-${direction}
      '';
    in
    "spawn:${script}";
in
{
  imports = [ inputs.umbriel.homeModules.default ];

  options.umbriel = {
    enable = lib.mkEnableOption "umbriel";

    workspaces = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            layout = lib.mkOption {
              type =
                with lib.types;
                nullOr (enum [
                  "scrolling"
                  "dwindle"
                  "master"
                  "floating"
                ]);
              default = null;
              description = "Layout mode for this workspace, or null to use the global default.";
            };
            programs = lib.mkOption {
              type = lib.types.listOf program;
              default = [ ];
              description = "Programs started at login and placed on this workspace.";
            };
          };
        }
      );
      default = [ ];
      description = ''
        Workspaces by position, so the first entry is workspace 1. Each can
        set a layout mode and list programs to start on it at login.

        On a dynamic output, set `min_workspaces` to at least the length of
        this list; a program aimed at a workspace that doesn't exist yet opens
        on the last one instead.
      '';
    };

    autostart = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Commands started at login without a workspace, such as apps that sit in the tray.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Programs aimed at missing workspaces would all pile onto the last one at login
    warnings =
      let
        outputs = lib.attrValues (config.programs.umbriel.settings.output or { });
        floor = lib.foldl' lib.max 1 (map (output: output.min_workspaces or 1) outputs);
      in
      lib.optional (lib.length cfg.workspaces > floor) ''
        umbriel.workspaces lists ${toString (lib.length cfg.workspaces)} workspaces, but no output sets min_workspaces that high, so programs placed on the later ones will open on the last workspace that exists at login.
      '';

    # Configure ~/.config/umbriel/config.toml
    programs.umbriel = {
      enable = true;

      settings = {

        # Start from the packaged config and only override what differs
        include.files = [ "${umbriel}/share/umbriel/config.toml" ];

        # Start programs once the tray is up, so the ones with tray icons can register them
        general.autostart = map (command: "${shared-lib.waitForTray pkgs} ${command}") (
          cfg.autostart
          ++ lib.concatMap (workspace: map (program: program.command) workspace.programs) cfg.workspaces
        );

        # Skipped when empty, as an empty rule list would discard the packaged rules
        workspace = lib.mkIf (layoutRules != [ ]) layoutRules;
        window_rule = lib.mkIf (placementRules != [ ]) placementRules;

        # Colors written by Noctalia's Umbriel template
        include.optional.files = [ "noctalia.toml" ];

        # Don't wrap-around when navigating between tabs
        layout.tabs.wrap_focus = false;

        # Disable mouse acceleration, matching the old COSMIC setting
        input.mouse.accel_profile = "flat";

        # Keys here merge into the packaged keybinds, mirroring the old COSMIC shortcuts
        keybinds = {

          # General
          "Mod+Slash" = once "cheatsheet-toggle";
          "Alt+Tab" = once "spawn:noctalia msg window-switcher hold";
          "Mod+Tab" = once "spawn:noctalia msg window-switcher hold";
          "Mod+W" = once "overview-toggle";
          "Mod+Shift+Escape" = once "session-quit";
          "Mod+Shift+S" = once "spawn:flameshot gui";
          "Print" = once "spawn:flameshot gui";
          "Mod+Q" = once "cursor-show";

          # Application shortcuts
          "Mod+Return" = once "spawn:wezterm start --cwd .";
          "Mod+E" = once "spawn:dolphin";
          "Mod+B" = once "spawn:zen-beta";
          "Mod+Escape" = once "spawn:missioncenter";

          # Window state
          "Mod+Shift+W" = once "window-close";
          "Mod+Shift+Ctrl+W" = once "window-kill";
          "Alt+F4" = once "window-close";
          "Mod+T" = once "column-toggle-tabbed";
          "Mod+Shift+T" = once "column-toggle-tab-bar";
          "Mod+S" = once "window-toggle-floating";
          "Mod+F" = once "window-toggle-fullscreen";
          "Mod+M" = once "window-toggle-maximize";
          "Mod+Shift+M" = once "window-toggle-maximize-to-edges";
          "Mod+P" = once "window-toggle-pinned";
          "Mod+X" = "window-swap-next";

          # Workspace/layout state
          "Mod+Y" = once "workspace-set-layout:toggle";
          "Mod+V" = once "layout-toggle-split";

          # Window focus navigation
          "Mod+H" = focusOrTab "left" "previous";
          "Mod+Left" = focusOrTab "left" "previous";
          "Mod+J" = "window-focus-or-workspace-down";
          "Mod+Down" = "window-focus-or-workspace-down";
          "Mod+K" = "window-focus-or-workspace-up";
          "Mod+Up" = "window-focus-or-workspace-up";
          "Mod+L" = focusOrTab "right" "next";
          "Mod+Right" = focusOrTab "right" "next";

          # Move windows
          "Mod+Shift+H" = "window-move-left";
          "Mod+Shift+Left" = "window-move-left";
          "Mod+Shift+J" = "window-move-down";
          "Mod+Shift+Down" = "window-move-down";
          "Mod+Shift+K" = "window-move-up";
          "Mod+Shift+Up" = "window-move-up";
          "Mod+Shift+L" = "window-move-right";
          "Mod+Shift+Right" = "window-move-right";

          # Move columns
          "Mod+Shift+Ctrl+H" = "column-move-left";
          "Mod+Shift+Ctrl+Left" = "column-move-left";
          "Mod+Shift+Ctrl+L" = "column-move-right";
          "Mod+Shift+Ctrl+Right" = "column-move-right";

          # Focus workspaces
          "Mod+0" = "workspace-focus-last";
          "Mod+I" = "workspace-previous";
          "Mod+Ctrl+Up" = "workspace-previous";
          "Mod+Ctrl+K" = "workspace-previous";
          "Mod+Ctrl+H" = "workspace-previous";
          "Mod+Ctrl+Left" = "workspace-previous";
          "Mod+O" = "workspace-next";
          "Mod+Ctrl+Down" = "workspace-next";
          "Mod+Ctrl+J" = "workspace-next";
          "Mod+Ctrl+Right" = "workspace-next";
          "Mod+Ctrl+L" = "workspace-next";

          # Moving between workspaces
          "Mod+Shift+Ctrl+Up" = "window-move-to-workspace-previous";
          "Mod+Shift+Ctrl+K" = "window-move-to-workspace-previous";
          "Mod+Shift+Ctrl+Down" = "window-move-to-workspace-next";
          "Mod+Shift+Ctrl+J" = "window-move-to-workspace-next";

          # Toggle key passthrough to the focused window (e.g. a VM)
          "Mod+Shift+Q" = {
            action = "shortcuts-inhibit-toggle";
            allow_when_inhibited = true;
            repeat = false;
          };
        };
      };
    };
  };
}
