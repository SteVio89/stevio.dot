{ ... }:

# nix-darwin manages the Brewfile only — it does NOT install brew. A fresh Mac
# needs the upstream installer run by hand before the first darwin-rebuild.
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Flip to "uninstall" once `brew bundle check` passes. Never "zap" — it
      # also deletes the aerospace and hyperkey config files.
      cleanup = "none";
    };

    global.brewfile = true;

    # trusted defaults to false for taps (Homebrew 6 HOMEBREW_REQUIRE_TAP_TRUST),
    # and plain cask/brew names resolve through the tap, so trust must live here.
    taps = [
      {
        name = "docker/tap";
        trusted = true;
      }
      {
        name = "dail8859/notepadnext";
        trusted = true;
      }
      {
        name = "jetbrains/utils";
        trusted = true;
      }
      {
        name = "nikitabobko/tap";
        trusted = true;
      }
      {
        name = "raine/aven";
        trusted = true;
      }
    ];

    brews = [
      "autoconf-archive"
      "automake"
      "cdrtools"
      "dfu-util"
      "gnupg"
      "leaf-markdown-viewer"
      "ios-deploy"
      "libgit2@1.7"
      "libimobiledevice"
      "libuv"
      "llvm"
      "luarocks"
      "mas"
      "mdserve"
      "mole"
      "nanorc"
      "pass"
      "pinentry-mac"
      "pkgconf"
      "protobuf"
      "scrcpy"
      "xcodegen"
      "ykman"
      "ykpers"
      "jetbrains/utils/kotlin-lsp"
      "raine/aven/aven"
    ];

    casks = [
      "aerospace"
      "android-platform-tools"
      "discord"
      "gimp"
      "gstreamer-runtime"
      "hyperkey"
      "miaoyan"
      "notepadnext"
      "octarine"
      "sf-symbols"
      "signal"
      "zed"
      "docker/tap/sbx"
    ];
  };

  # `sbx run|create` default to --clone unless it was passed explicitly.
  # `sbx run claude` also passes my kit right after `claude` (unless --kit was given).
  programs.zsh.interactiveShellInit = ''
    sbx() {
      case "$1" in
        run|create) case " $* " in *" --clone"*) ;; *) local c=$1; shift; set -- "$c" --clone "$@" ;; esac ;;
      esac
      local i=''${argv[(i)claude]}
      if [[ $1 == run && $i -le $# && " $* " != *" --kit"* ]]; then
        set -- "''${(@)argv[1,i]}" --kit ~/.config/sbx-kits/global-claude/ "''${(@)argv[i+1,-1]}"
      fi
      command sbx "$@"
    }
  '';
}
