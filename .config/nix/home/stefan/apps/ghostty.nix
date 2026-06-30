{ lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.ghostty = {
    enable = true;
    package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    clearDefaultKeybinds = true;
    installBatSyntax = false;
    installVimSyntax = false;

    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 14;

      background-opacity = "0.85";
      background-blur = true;

      window-padding-x = 10;
      window-padding-y = 10;
      maximize = true;
      confirm-close-surface = false;

      keybind = [
        "super+q=quit"
        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
        "f13=csi:1;2R"
      ];
    }
    // lib.optionalAttrs isDarwin {
      macos-titlebar-style = "hidden";
    };
  };
}
