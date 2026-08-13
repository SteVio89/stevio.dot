{ enableMacosDefaults, lib, ... }:

{
  imports = [
    ../../modules/darwin/base.nix
    ../../modules/darwin/homebrew.nix
  ]
  ++ lib.optional enableMacosDefaults ../../modules/darwin/system-defaults.nix;
}
