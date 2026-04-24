{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # POSIX-style aliases (zsh + bash share an identical attrset format).
  # `dotfiles`/`cma`/`cmd` use $HOME expansion that bash and zsh both handle;
  # nushell's grammar differs, so its versions live in apps/nushell.nix as `def`.
  posixAliases = {
    cat = "bat";
    nano = "nvim";
    vim = "nvim";
    vi = "nvim";
    ktx = "kubie ctx";
    replace = "rgr";
    ff = "cdi";
    dotfiles = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
    cma = "dotfiles add -u";
    cmd = "dotfiles diff --staged | delta";
  } // lib.optionalAttrs isDarwin {
    wfi = "caffeinate -d";
    cb = "pbcopy";
  };

  nushellAliases = {
    cat = "bat";
    nano = "nvim";
    vim = "nvim";
    vi = "nvim";
    ktx = "kubie ctx";
    replace = "rgr";
    ff = "cdi";
  } // lib.optionalAttrs isDarwin {
    wfi = "caffeinate -d";
    cb = "pbcopy";
  };
in
{
  programs.zsh.shellAliases     = posixAliases;
  programs.bash.shellAliases    = posixAliases;
  programs.nushell.shellAliases = nushellAliases;
}
