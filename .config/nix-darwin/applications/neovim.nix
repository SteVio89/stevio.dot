{ pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    home.packages = with pkgs; [
      lua-language-server
      bash-language-server
      stylua
    ];
}
