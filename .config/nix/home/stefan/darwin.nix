{ pkgs, ... }: {
  home.packages = with pkgs; [
    pngpaste
    ghostty-bin
    neovide
    gitui
    dua
    procs
    bottom
  ];
}
