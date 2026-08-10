{
  description = "Stefan's machines — macOS (nix-darwin), NixOS (kids-laptop)";

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
    capsule = {
      url = "github:SteVio89/capsule";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuicr = {
      url = "github:agavra/tuicr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, ... }:
    let
      # Shared home-manager wiring. Applied identically on Darwin and NixOS.
      hmShared = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
      };

      # home-manager module sets for user stefan, composed per target from the
      # bundles under ./home/stefan. No platform flags — each target picks the
      # pieces it needs (base = universal CLI, desktop = tmux + terminals,
      # darwin/linux = platform facts, hyprland = WM).
      stefanHome = {
        darwin = {
          imports = [
            ./home/stefan/base.nix
            ./home/stefan/desktop.nix
            ./home/stefan/darwin.nix
          ];
        };
        linuxDesktop = {
          imports = [
            ./home/stefan/base.nix
            ./home/stefan/desktop.nix
            ./home/stefan/linux.nix
            ./home/stefan/hyprland.nix
          ];
        };
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
            { home-manager.users.stefan = stefanHome.darwin; }
          ];
        };

      # homeUsers :: attrset of username -> home-manager module.
      mkNixos = { hostname, homeUsers }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./overlays.nix
            inputs.disko.nixosModules.disko
            (./hosts + "/${hostname}")
            home-manager.nixosModules.home-manager
            hmShared
            { home-manager.users = homeUsers; }
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
        kids-laptop = mkNixos {
          hostname = "kids-laptop";
          homeUsers = {
            stefan = stefanHome.linuxDesktop;
            kids = import ./home/kids;
          };
        };
      };

    };
}
