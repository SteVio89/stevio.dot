{ pkgs, ... }: {
  # ── Home Manager ──────────────────────────────
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  home-manager.users."stefan" = { pkgs, lib, ... }: {

    home.stateVersion = "26.05";
    home.homeDirectory = "/Users/stefan";
    xdg.enable = true;
    imports = [
      ./applications/zsh.nix
      ./applications/starship.nix
      ./applications/tmux.nix
      ./applications/neovim.nix
      ./applications/nushell.nix
    ];

    home.packages = with pkgs; [
      devbox
      fd
      ripgrep
      pngpaste
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };

    programs.atuin = {
      enable = true;
      enableZshIntegration = false;
      enableNushellIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = [ "--cmd" "cd" ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = false;
    };

    programs.bat = {
      enable = true;
    };
  };
}
