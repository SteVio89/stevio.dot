{ pkgs, ... }: {
  home.packages = with pkgs; [
    pngpaste
    neovide
    gitui
    dua
    procs
    bottom
  ];
}
