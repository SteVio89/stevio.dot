{ pkgs, inputs, lib, ... }: {
  home.stateVersion = "26.05";
  home.homeDirectory = "/Users/stefan";
  xdg.enable = true;
  imports = [
    ./applications/zsh.nix
    ./applications/starship.nix
    ./applications/tmux.nix
    ./applications/neovim.nix
    ./applications/nushell.nix
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.packages = with pkgs; [
    devbox
    fd
    ripgrep
    pngpaste
    ghostty-bin
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

  programs.alacritty = {
    enable = true;
    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
    settings = {
      window = {
        decorations = "Buttonless";
        opacity = 0.75;
        blur = true;
        startup_mode = "Maximized";
        padding = { x = 10; y = 10; };
      };
      font = {
        size = 14;
        normal.family      = "JetBrainsMono Nerd Font Mono";
        bold.family        = "JetBrainsMono Nerd Font Mono";
        italic.family      = "JetBrainsMono Nerd Font Mono";
        bold_italic.family = "JetBrainsMono Nerd Font Mono";
      };
      keyboard.bindings = [
        { key = "Return"; mods = "Shift"; chars = "\r"; }
      ];
      env.TERM = "xterm-256color";
    };
  };
}
