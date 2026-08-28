{ pkgs, inputs, ... }:

{
  imports = [
    ./apps/zsh.nix
    ./apps/starship.nix
    ./apps/neovim.nix
    ./apps/yazi.nix
    ./apps/shell-aliases.nix
    ./apps/goose.nix
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "stefan";

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
    evil-helix
    _7zz
    act
    age
    buf
    ccache
    dstask
    exercism
    ffmpegthumbnailer
    gh
    glab
    imagemagick
    k9s
    krew
    clusterctl
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubeseal
    magic-wormhole
    ninja
    pandoc
    parallel
    poppler-utils
    shellcheck
    skim
    sops
    topgrade
    tree-sitter
    typst
    universal-ctags
    uv
    wget
    yq-go

    inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Static templates consumed by the `dev` shell helper (apps/zsh.nix).
  # Per-language presets: `packages` is injected into flake.nix, every other file
  # is copied into the project as-is. An optional `flake.nix` replaces the shared
  # one, for languages needing extra inputs (rust, rustlings). Add a language: new dir + a line here.
  xdg.configFile."dev-helpers/devshell-flake.nix".source = ./templates/devshell-flake.nix;
  xdg.configFile."dev-helpers/go".source = ./templates/dev-helpers/go;
  xdg.configFile."dev-helpers/rust".source = ./templates/dev-helpers/rust;
  xdg.configFile."dev-helpers/rustlings".source = ./templates/dev-helpers/rustlings;
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
