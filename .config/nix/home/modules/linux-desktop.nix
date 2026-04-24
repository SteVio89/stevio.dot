{ pkgs, lib, inputs, ... }:

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
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.75;
        startup_mode = "Maximized";
        padding = { x = 10; y = 10; };
      };
      font = {
        size = 14;
        normal.family      = "JetBrainsMono Nerd Font Mono";
        bold.family        = "JetBrainsMono Nerd Font Mono";
        italic.family      = "JetBrainsMono Nerd Font Mono";
        bold_italic.family = "JetBrainsMono Nerd Font Mono";
      };
      keyboard.bindings = [
        { key = "Return"; mods = "Shift"; chars = "\r"; }
      ];
      env.TERM = "xterm-256color";
    };
  };

  programs.fuzzel.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      cma = "dotfiles add -u";
      cmd = "dotfiles diff --staged | delta";
    };
  };

  programs.hyprlock.enable = true;

  home.packages = [ firstLoginPasswd pkgs.delta ];

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

      monitor = [ ",preferred,auto,1" ];

      xwayland = {
        force_zero_scaling = true;
      };

      env = [
        "GDK_SCALE,1"
        "XCURSOR_SIZE,24"
      ];

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
        "$mod, L, exec, hyprlock"
        "$mod, K, exit,"
      ];

      # windowrule = [
      #   "workspace 3, match:class ^(steam)$"
      #   "fullscreen, match:class ^(steam)$, match:title ^(Steam)$"
      #   "float, match:title ^(First-login: set your password)$"
      #   "pin, match:title ^(First-login: set your password)$"
      # ];
    };
  };
}
