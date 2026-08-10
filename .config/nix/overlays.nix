{ lib, ... }: {
  nixpkgs.overlays = [
    # Workaround: direnv's zsh test suite hangs intermittently under the Nix
    # sandbox on aarch64-darwin. Gated to Darwin so Linux hosts keep the
    # upstream binary cache.
    (final: prev: lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
    })
  ];
}
