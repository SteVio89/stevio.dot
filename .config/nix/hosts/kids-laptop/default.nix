{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/locale-de.nix
  ];

  # UEFI / systemd-boot. For legacy BIOS, replace with boot.loader.grub.*
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.btrfs.autoScrub.enable = true;

  networking.hostName = "kids-laptop";
  networking.networkmanager.enable = true;

  # System-level Steam (kids-laptop only). Per-user autostart lives in home/kids.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  users.users.stefan = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
    initialPassword = "changeme";
  };

  users.users.kids = {
    isNormalUser = true;
    description = "Kid";
    extraGroups = [ "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
    initialPassword = "kids";
  };

  # Marker prevents re-expiry after the user picks a new password.
  system.activationScripts.firstLoginExpiry = {
    deps = [ "users" ];
    text = ''
      for user in stefan kids; do
        marker=/var/lib/nixos/first-login-expired-$user
        if [ ! -e "$marker" ] && ${pkgs.shadow}/bin/getent passwd "$user" >/dev/null; then
          ${pkgs.shadow}/bin/chage -d 0 "$user"
          mkdir -p /var/lib/nixos
          touch "$marker"
        fi
      done
    '';
  };

  system.stateVersion = "25.11";
}
