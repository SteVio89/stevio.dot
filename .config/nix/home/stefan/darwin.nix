{ pkgs, ... }:

# macOS-specific home facts + GUI packages + the macOS-only zsh wiring.
{
  imports = [
    ./apps/zsh-darwin.nix
  ];

  home.homeDirectory = "/Users/stefan";
  home.stateVersion = "26.05";

  home.sessionVariables.SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";

  home.packages = with pkgs; [
    pngpaste
    neovide
    gitui
    dua
    procs
  ];
}
