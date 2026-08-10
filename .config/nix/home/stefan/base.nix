{ pkgs, inputs, ... }:

# Universal home-manager core — imported by every target for user stefan
# (Mac, Linux desktop, Docker capsule). Platform facts live in darwin.nix /
# linux.nix; interactive-terminal extras (tmux, terminal emulators) in
# desktop.nix; the headless capsule adds claude-code via container.nix.
{
  imports = [
    ./apps/zsh.nix
    ./apps/starship.nix
    ./apps/neovim.nix
    ./apps/yazi.nix
    ./apps/shell-aliases.nix
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "stefan";
  # home.homeDirectory + home.stateVersion are platform facts — set in
  # darwin.nix / linux.nix, whichever the target composes.

  xdg.enable = true;

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
  };

  # XDG_CONFIG_HOME comes from `xdg.enable = true` above — don't redefine it here.
  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "fd --hidden --exclude .git --strip-cwd-prefix";
    RIPGREP_CONFIG_PATH = "$HOME/.config/rg/ripgreprc";
  };

  home.packages = with pkgs; [
    fd
    ripgrep
    nixfmt
    luajit
    eza
    delta
    git-filter-repo
    gitleaks
    kubie
    repgrep
    presenterm
    inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Static templates consumed by the `dev` shell helper (apps/zsh.nix).
  # Per-language presets: each dir holds a `packages` list (injected into
  # flake.nix) and a `justfile`. Drop in a new dir + a line here to add a language.
  xdg.configFile."dev-helpers/devshell-flake.nix".source = ./templates/devshell-flake.nix;
  xdg.configFile."dev-helpers/go".source = ./templates/dev-helpers/go;
  xdg.configFile."dev-helpers/zig".source = ./templates/dev-helpers/zig;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      filter_mode = "workspace";
      filter_mode_shell_up_key_binding = "workspace";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
    historyWidget.command = "";
  };

  programs.bat.enable = true;
}
