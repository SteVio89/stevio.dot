{ pkgs, lib, inputs, ... }:

# Steam-only kiosk profile.
# Hyprland boots straight into Steam on workspace 1. No browser, no terminal,
# no app launcher are installed. The only escape hatches are:
#   $mod+L  → hyprlock
#   $mod+K  → exit Hyprland (returns to greetd; parent re-login recovery)
#   $mod+Q  → killactive
let
  firstLoginPasswd = pkgs.writeShellScriptBin "first-login-passwd" ''
    set -eu
    marker="$HOME/.local/state/password-changed"
    [ -f "$marker" ] && exit 0
    mkdir -p "$(dirname "$marker")"

    # The kids profile has no terminal emulator installed, so the password
    # prompt borrows alacritty from the system closure for this one purpose.
    ${pkgs.alacritty}/bin/alacritty \
      --title 'First-login: set your password' \
      -e bash -c '
        echo "Please choose a new password for $USER."
        echo "You must change it before using this machine."
        echo
        while ! passwd; do
          echo
          echo "Try again..."
          echo
        done
        touch "'"$marker"'"
      '
  '';
in
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  home.username = "kids";
  home.homeDirectory = "/home/kids";
  home.stateVersion = "25.11";

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  home.packages = [ firstLoginPasswd ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";

      monitor = [ ",preferred,auto,1" ];

      xwayland.force_zero_scaling = true;

      env = [
        "GDK_SCALE,1"
        "XCURSOR_SIZE,24"
      ];

      input.kb_layout = "de";

      bind = [
        "$mod, Q, killactive,"
        "$mod, L, exec, hyprlock"
        "$mod, K, exit,"
      ];

      exec-once = [
        "first-login-passwd"
        "[workspace 1] steam"
      ];
    };
  };

  programs.hyprlock.enable = true;
}
