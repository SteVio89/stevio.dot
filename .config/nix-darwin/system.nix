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

  # ── System packages ───────────────────────────
  # Everything you'd `brew install`. Add freely.
  environment.systemPackages = with pkgs; [
    bashInteractive
    just
    jq
    git
    nodejs
  ];

  # ── User ────────────────────────────────────
  users.users.stefan.home = "/Users/stefan";
}
