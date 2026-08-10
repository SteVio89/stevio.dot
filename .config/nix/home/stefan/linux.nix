{ ... }:

# Shared Linux home facts — composed by both the NixOS desktop and the Docker
# capsule. The desktop/WM stack lives in hyprland.nix (desktop only).
{
  home.homeDirectory = "/home/stefan";
  home.stateVersion = "25.11";
}
