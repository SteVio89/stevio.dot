{ enableMacosDefaults, lib, ... }:

{
  imports = [ ../../modules/darwin/base.nix ]
    ++ lib.optional enableMacosDefaults ../../modules/darwin/system-defaults.nix;
}
