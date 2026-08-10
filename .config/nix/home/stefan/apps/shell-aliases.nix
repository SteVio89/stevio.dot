{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # POSIX-style aliases (zsh + bash share an identical attrset format).
  # `dotfiles`/`cma`/`cmd` use $HOME expansion that bash and zsh both handle.
  posixAliases = {
    cat = "bat";
    nano = "nvim";
    vim = "nvim";
    vi = "nvim";
    ktx = "kubie ctx";
    replace = "rgr";
    ff = "cdi";
    ls = "eza --group-directories-first --icons --git --header --time-style=relative";
    ll = "eza -lh --group-directories-first --icons --git --header --time-style=relative";
    la = "eza -lah --group-directories-first --icons --git --header --time-style=relative";
    lt = "eza --tree --level=2 --icons --group-directories-first";
    dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
    cma = "dotfiles add -u";
    cmd = "dotfiles diff --staged | delta";
  } // lib.optionalAttrs isDarwin {
    wfi = "caffeinate -d";
    cb = "pbcopy";
  };

in
{
  programs.zsh.shellAliases  = posixAliases;
  programs.bash.shellAliases = posixAliases;
}
