{
  description = "Stefan's machines — macOS (nix-darwin)";

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
    tuicr = {
      url = "github:agavra/tuicr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nix-darwin, home-manager, ... }:
    let
      hmShared = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
      };

      stefanHome = {
        imports = [
          ./home/stefan/base.nix
          ./home/stefan/desktop.nix
          ./home/stefan/darwin.nix
        ];
      };

      mkDarwin = { hostname, enableMacosDefaults ? false }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs enableMacosDefaults; };
          modules = [
            ./overlays.nix
            (./hosts + "/${hostname}")
            home-manager.darwinModules.home-manager
            hmShared
            { home-manager.users.stefan = stefanHome; }
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
    };
}
