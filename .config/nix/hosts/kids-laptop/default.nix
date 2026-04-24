{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # UEFI / systemd-boot. For legacy BIOS, replace with boot.loader.grub.*
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.btrfs.autoScrub.enable = true;

  networking.hostName = "kids-laptop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # System-level Hyprland provides the Wayland session to greetd.
  # Per-user keybinds and window rules live in home-manager.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # --cmd Hyprland skips the session chooser — single-session system.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

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

  environment.systemPackages = with pkgs; [
    git
    vim
    just
    tuigreet
    networkmanagerapplet
  ];

  system.stateVersion = "25.11";
}
