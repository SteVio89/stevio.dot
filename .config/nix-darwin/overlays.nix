{ lib, ... }: {
  nixpkgs.overlays = [
    # Workaround: nushell test suite fails on aarch64-darwin due to
    # sandbox + SHLVL-in-exec behavior. Tests:
    #   shell::environment::env::env_shlvl_in_repl
    #   shell::environment::env::env_shlvl_in_exec_repl
    # Gated to Darwin so Linux hosts keep the upstream binary cache.
    (final: prev: lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
      nushell = prev.nushell.overrideAttrs (_: { doCheck = false; });
      # direnv's zsh test suite hangs intermittently under the Nix sandbox on
      # aarch64-darwin (same class of issue as nushell). Skip tests on Darwin.
      direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
    })
  ];
}
