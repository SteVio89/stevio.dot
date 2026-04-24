{
  description = "Stefan's machines — Mac (nix-darwin) + linux notebook (NixOS)";

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
      # the difference is which home-manager module flavour each host imports
      # (darwinModules.home-manager vs. nixosModules.home-manager).
      hmSharedModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit inputs; };
      };
    in {
      # ── Darwin: stevio-dev (daily-use profile, without macOS-Defaults) ──
      darwinConfigurations."stevio-dev" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./overlays.nix
          ./hosts/stevio-dev
          home-manager.darwinModules.home-manager
          hmSharedModule
          { home-manager.users.stefan = import ./home/stevio; }
        ];
      };

      # ── Darwin: stevio-dev-full (same as stevio-dev + macOS-Defaults) ────
      darwinConfigurations."stevio-dev-full" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./overlays.nix
          ./hosts/stevio-dev-full
          home-manager.darwinModules.home-manager
          hmSharedModule
          { home-manager.users.stefan = import ./home/stevio; }
        ];
      };

      # ── NixOS: linux-notebook ───────────────────────────────────────
      nixosConfigurations."kids-laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./overlays.nix
          inputs.disko.nixosModules.disko
          ./hosts/kids-laptop
          home-manager.nixosModules.home-manager
          hmSharedModule
          {
            home-manager.users.kids = import ./home/kids;
            home-manager.users.stefan = import ./home/stefan-linux;
          }
        ];
      };
    };
}
