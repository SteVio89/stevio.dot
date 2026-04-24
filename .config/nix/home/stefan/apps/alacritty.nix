{ lib, pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.75;
        startup_mode = "Maximized";
        padding = { x = 10; y = 10; };
      } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        decorations = "Buttonless";
        blur = true;
      };
      font = {
        size = 14;
        normal.family      = "JetBrainsMono Nerd Font Mono";
        bold.family        = "JetBrainsMono Nerd Font Mono";
        italic.family      = "JetBrainsMono Nerd Font Mono";
        bold_italic.family = "JetBrainsMono Nerd Font Mono";
      };
      keyboard.bindings = [
        { key = "Return"; mods = "Shift"; chars = "\r"; }
      ];
      env.TERM = "xterm-256color";
    };
  };
}
