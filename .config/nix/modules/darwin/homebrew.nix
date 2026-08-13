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
      { name = "dail8859/notepadnext"; trusted = true; }
      { name = "jetbrains/utils"; trusted = true; }
      { name = "nikitabobko/tap"; trusted = true; }
    ];

    brews = [
      "autoconf-archive"
      "automake"
      "cdrtools"
      "dfu-util"
      "gnupg"
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
    ];

    casks = [
      "aerospace"
      "android-platform-tools"
      "another-redis-desktop-manager"
      "discord"
      "gimp"
      "gstreamer-runtime"
      "hyperkey"
      "miaoyan"
      "notepadnext"
      "octarine"
      "sf-symbols"
      "signal"
      "thaw"
      "zed"
    ];
  };
}
