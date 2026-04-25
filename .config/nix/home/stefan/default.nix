{ pkgs, lib, inputs, isDarwin, ... }:

{
  imports = [
    ./apps/zsh.nix
    ./apps/nushell.nix
    ./apps/starship.nix
    ./apps/tmux.nix
    ./apps/neovim.nix
    ./apps/alacritty.nix
    ./apps/shell-aliases.nix
    inputs.catppuccin.homeModules.catppuccin
  ] ++ lib.optional isDarwin ./darwin.nix
    ++ lib.optional (!isDarwin) ./linux.nix;

  # Each host applied home-manager at a different time; preserve the original
  # state version per platform so existing hosts don't see migrations.
  home.username = "stefan";
  home.homeDirectory = if isDarwin then "/Users/stefan" else "/home/stefan";
  home.stateVersion = if isDarwin then "26.05" else "25.11";

  xdg.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  # XDG_CONFIG_HOME comes from `xdg.enable = true` above — don't redefine it here.
  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "fd --hidden --exclude .git --strip-cwd-prefix";
    RIPGREP_CONFIG_PATH = "$HOME/.config/rg/ripgreprc";
  } // lib.optionalAttrs isDarwin {
    SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";
  };

  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  # Static template consumed by the `dev` shell helpers (nushell + zsh).
  xdg.configFile."dev-helpers/devshell-flake.nix".source =
    ./templates/devshell-flake.nix;

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

  programs.bat.enable = true;
}
