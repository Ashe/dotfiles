{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  # Defaults to the flake's package, the same store path the NixOS module installs
  umbriel = config.programs.umbriel.package;

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

  options.umbriel.enable = lib.mkEnableOption "umbriel";

  config = lib.mkIf config.umbriel.enable {

    # Configure ~/.config/umbriel/config.toml
    programs.umbriel = {
      enable = true;

      settings = {

        # Start from the packaged config and only override what differs
        include.files = [ "${umbriel}/share/umbriel/config.toml" ];

        # Colors written by Noctalia's Umbriel template; it can't add this itself as the config is read-only
        include.optional.files = [ "${config.xdg.configHome}/umbriel/noctalia.toml" ];

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
