{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/locale-de.nix
  ];

  # UEFI / systemd-boot. Most macOS hypervisors (UTM, Parallels, VMware) expose
  # a UEFI guest by default. Swap to grub if your VM is BIOS-only.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "stevio-vm";
  networking.networkmanager.enable = true;

  users.users.stefan = {
    isNormalUser = true;
    description = "Stefan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
    initialPassword = "changeme";
  };

  # Same first-login password rotation pattern as kids-laptop.
  system.activationScripts.firstLoginExpiry = {
    deps = [ "users" ];
    text = ''
      marker=/var/lib/nixos/first-login-expired-stefan
      if [ ! -e "$marker" ] && ${pkgs.shadow}/bin/getent passwd stefan >/dev/null; then
        ${pkgs.shadow}/bin/chage -d 0 stefan
        mkdir -p /var/lib/nixos
        touch "$marker"
      fi
    '';
  };

  system.stateVersion = "25.11";
}
