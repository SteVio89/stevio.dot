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
    # `exit` (and Ctrl-D) drop to the parent zsh prompt — nu's REPL
    # special-cases the `exit` keyword and bypasses alias resolution, so we
    # can't change it. `quit` (a non-keyword) is aliased to exit with code 99,
    # which the parent zsh propagates as a real exit (closes the terminal/pane).
    quit = "exit 99";
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
