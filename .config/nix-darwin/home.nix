{ pkgs, ... }: {
  # ── Home Manager ──────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users."stefan" = { pkgs, ... }: {
    home.stateVersion = "24.11";
    home.homeDirectory = "/Users/stefan";

    # User-level packages
    home.packages = with pkgs; [
      devbox
    ];

    # ── direnv ──────────────────────────────────
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
