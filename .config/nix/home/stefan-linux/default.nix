{ ... }: {
  home.stateVersion = "25.11";
  home.username = "stefan";
  home.homeDirectory = "/home/stefan";

  imports = [ ../modules/linux-desktop.nix ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "first-login-passwd"
  ];
}
