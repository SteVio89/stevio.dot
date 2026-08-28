{ lib, ... }: {
  nixpkgs.overlays = [
    # Workaround: direnv's zsh test suite hangs intermittently under the Nix
    # sandbox on aarch64-darwin. Gated to Darwin so Linux hosts keep the
    # upstream binary cache.
    (final: prev: lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
    })

    # Workaround: tmux 3.7c's configure aborts on darwin unless given an
    # explicit jemalloc flag and nixpkgs passes neither. Disabled, against
    # upstream's advice, because nixpkgs' jemalloc is symbol-prefixed and so
    # cannot interpose calloc.
    (final: prev: lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      tmux =
        lib.warnIf
          (lib.any (lib.hasInfix "jemalloc") (prev.tmux.configureFlags or [ ]))
          "overlays.nix: nixpkgs now sets a jemalloc flag for tmux — drop this workaround"
          (prev.tmux.overrideAttrs (old: {
            configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-jemalloc" ];
          }));
    })
  ];
}
