{ pkgs, ... }: {
  home.packages = with pkgs; [
    pngpaste
    ghostty-bin
  ];
}
