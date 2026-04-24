{ pkgs, lib, ... }: {
  home.stateVersion = "25.11";
  home.username = "kids";
  home.homeDirectory = "/home/kids";

  imports = [ ../modules/linux-desktop.nix ];

  programs.librewolf.enable = true;

  wayland.windowManager.hyprland.settings.exec-once = [
    "first-login-passwd"
    "[workspace 1 silent] librewolf"
    "[workspace 2 silent] alacritty"
    "[workspace 3] steam"
  ];
}
