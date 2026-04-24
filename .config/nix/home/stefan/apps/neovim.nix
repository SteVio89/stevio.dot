{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    sideloadInitLua = true;
  };
  home.packages = with pkgs; [
    lua-language-server
    bash-language-server
    stylua
    nil
    nixd
  ];
}
