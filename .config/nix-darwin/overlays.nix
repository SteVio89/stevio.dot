{ ... }: {
  nixpkgs.overlays = [
    # Workaround: nushell test suite fails on aarch64-darwin due to
    # sandbox + SHLVL-in-exec behavior. Tests:
    #   shell::environment::env::env_shlvl_in_repl
    #   shell::environment::env::env_shlvl_in_exec_repl
    # Remove this overlay once those pass upstream on aarch64-darwin.
    (final: prev: {
      nushell = prev.nushell.overrideAttrs (_: { doCheck = false; });
    })
  ];
}
