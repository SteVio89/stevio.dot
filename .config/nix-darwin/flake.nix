{
  description = "Stefan's Mac — system + user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      baseModules = [
        home-manager.darwinModules.home-manager
        ./system.nix
        ./home.nix
      ];
    in {
      darwinConfigurations."stevio-dev" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = baseModules;
      };

      darwinConfigurations."stevio-dev-full" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = baseModules ++ [ ./macos.nix ];
      };
    };
}
