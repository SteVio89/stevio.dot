# Placeholder. Replace on first install via:
#   sudo nixos-generate-config --root /mnt
#   cp /mnt/etc/nixos/hardware-configuration.nix hosts/kids-laptop/
{ ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
}
