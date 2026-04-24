{ pkgs, lib, ... }: {
  home.stateVersion = "25.11";
  home.username = "kids";
  home.homeDirectory = "/home/kids";

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 1.0;
      font.size = 12;
    };
  };

  programs.librewolf.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      # Enable if HiDPI scaling is off for GTK apps or Steam client.
      # env = [
      #   "GDK_SCALE,2"
      #   "STEAM_FORCE_DESKTOPUI_SCALING,1.25"
      # ];

      "$mod" = "SUPER";

      exec-once = [
        "[workspace 1 silent] librewolf"
        "[workspace 2 silent] alacritty"
        "[workspace 3] steam"
      ];

      windowrulev2 = [
        "workspace 3, class:^(steam)$"
        "fullscreen, class:^(steam)$, title:^(Steam)$"
      ];

      bind = [
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, Q, killactive,"
      ];
    };
  };
}
