{ pkgs, ... }: {
  # ── Nix itself ────────────────────────────────
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "stefan" ];
  nix.gc = {
    automatic = true;
    interval = { Weekday = 1; Hour = 14; Minute = 0; };
    options = "--delete-older-than 7d";
  };
  nix.optimise = {
    automatic = true;
    interval = { Weekday = 1; Hour = 14; Minute = 30; };
  };
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 6;
  system.primaryUser = "stefan";

  # ── Zsh (system-level) ────────────────────────
  # Disable compinit in /etc/zshrc — home-manager handles it with caching
  programs.zsh.enableGlobalCompInit = false;

  # ── System packages ───────────────────────────
  # Everything you'd `brew install`. Add freely.
  environment.systemPackages = with pkgs; [
    bashInteractive
    just
    jq
    git
    nodejs
  ];

  environment.shells = with pkgs; [ nushell ];

  # ── User ────────────────────────────────────
  users.users.stefan.home = "/Users/stefan";
}
