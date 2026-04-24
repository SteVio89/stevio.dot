{ pkgs, lib, ... }:

let
  firstLoginPasswd = pkgs.writeShellScriptBin "first-login-passwd" ''
    set -eu
    marker="$HOME/.local/state/password-changed"
    [ -f "$marker" ] && exit 0
    mkdir -p "$(dirname "$marker")"

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
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 1.0;
      font.size = 12;
    };
  };

  programs.fuzzel.enable = true;

  home.packages = [ firstLoginPasswd ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";

      bind = [
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, Q, killactive,"
        "$mod, SPACE, exec, fuzzel"
        "$mod, RETURN, exec, alacritty"
      ];

      windowrule = [
        "workspace 3, class:^(steam)$"
        "fullscreen, class:^(steam)$, title:^(Steam)$"
        "float, title:^(First-login: set your password)$"
        "pin, title:^(First-login: set your password)$"
      ];
    };
  };
}
