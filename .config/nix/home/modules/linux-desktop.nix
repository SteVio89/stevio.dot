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

  programs.bash.enable = true;

  home.packages = [ firstLoginPasswd ];

  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland polkit authentication agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";

      input = {
        kb_layout = "de";
      };

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
