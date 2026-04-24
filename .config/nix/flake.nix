{
  description = "Stefan's machines — macOS (nix-darwin) + NixOS (kids-laptop, future Linux VM)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Shared home-manager wiring. Applied identically on Darwin and NixOS;
      # only the home-manager module flavour differs (darwinModules vs nixosModules).
      mkHmShared = isDarwin: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs isDarwin; };
      };

      mkDarwin = { hostname, enableMacosDefaults ? false }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs enableMacosDefaults; };
          modules = [
            ./overlays.nix
            (./hosts + "/${hostname}")
            home-manager.darwinModules.home-manager
            (mkHmShared true)
            { home-manager.users.stefan = import ./home/stefan; }
          ];
        };

      # users :: list of usernames whose home-manager config to wire up.
      # Each name must match a directory under ./home/.
      mkNixos = { hostname, users }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./overlays.nix
            inputs.disko.nixosModules.disko
            (./hosts + "/${hostname}")
            home-manager.nixosModules.home-manager
            (mkHmShared false)
            {
              home-manager.users = nixpkgs.lib.genAttrs users
                (u: import (./home + "/${u}"));
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        # Daily-use macOS profile (no system defaults applied).
        stevio-dev      = mkDarwin { hostname = "stevio-dev"; };
        # Same host, with macOS UI defaults (dock, finder, trackpad, …).
        stevio-dev-full = mkDarwin { hostname = "stevio-dev"; enableMacosDefaults = true; };
      };

      nixosConfigurations = {
        kids-laptop = mkNixos { hostname = "kids-laptop"; users = [ "stefan" "kids" ]; };
        # Placeholder until the VM is installed and hardware-configuration.nix is regenerated.
        stevio-vm   = mkNixos { hostname = "stevio-vm";   users = [ "stefan" ]; };
      };
    };
}
