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

  outputs = { nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."stevio-dev" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager

        {
          # ── Nix itself ────────────────────────────────
          nix.enable = true;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nix.settings.trusted-users = [ "stefan" ];
          nixpkgs.config.allowUnfree = true;
          system.stateVersion = 6;
          system.primaryUser = "stefan";

          # ── System packages ───────────────────────────
          # Everything you'd `brew install`. Add freely.
          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; [
            bashInteractive
          ];

          # ── macOS settings ────────────────────────────

          system.defaults.NSGlobalDomain = {
            AppleInterfaceStyle = "Dark";
            AppleShowAllExtensions = true;
            AppleWindowTabbingMode = "manual";
            NSAutomaticCapitalizationEnabled = false;
            NSAutomaticDashSubstitutionEnabled = false;
            NSAutomaticInlinePredictionEnabled = false;
            NSAutomaticPeriodSubstitutionEnabled = false;
            NSAutomaticQuoteSubstitutionEnabled = false;
            NSAutomaticSpellingCorrectionEnabled = false;
            "com.apple.swipescrolldirection" = false;     # natural scroll OFF
            "com.apple.keyboard.fnState" = false;
            "com.apple.trackpad.forceClick" = true;
            "com.apple.sound.beep.volume" = 1.0;
          };

          system.defaults.dock = {
            autohide = true;
            tilesize = 85;
            largesize = 16;
            magnification = false;
            launchanim = false;
            orientation = "bottom";
            mru-spaces = false;
            show-recents = false;
            minimize-to-application = false;
            mineffect = "genie";
            expose-group-apps = true;
            wvous-tl-corner = 1;
            wvous-tr-corner = 1;
            wvous-bl-corner = 1;
            wvous-br-corner = 1;
            persistent-apps = [
              "/System/Applications/Apps.app"
              "/Applications/Firefox.app"
              "/Applications/Zed.app"
              "/Applications/rio.app"
              "/Applications/Claude.app"
            ];
          };

          system.defaults.finder = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            ShowPathbar = true;
            ShowStatusBar = true;
            FXPreferredViewStyle = "Nlsv";
            FXRemoveOldTrashItems = true;
            ShowExternalHardDrivesOnDesktop = false;
            ShowHardDrivesOnDesktop = false;
          };

          system.defaults.trackpad = {
            Clicking = false;
            TrackpadRightClick = true;
            TrackpadThreeFingerDrag = false;
          };

          system.defaults.menuExtraClock = {
            FlashDateSeparators = false;
            IsAnalog = false;
            Show24Hour = true;
            ShowDate = 1;
            ShowDayOfWeek = false;
            ShowSeconds = false;
          };

          system.defaults.CustomUserPreferences = {
            NSGlobalDomain = {
              NSCloseAlwaysConfirmsChanges = true;
              AppleActionOnDoubleClick = "Maximize";
            };
          };

          # ── User ────────────────────────────────────
          users.users.stefan.home = "/Users/stefan";

          # ── Home Manager ──────────────────────────────
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users."stefan" = { pkgs, ... }: {
            home.stateVersion = "24.11";
            home.homeDirectory = "/Users/stefan";

            # User-level packages
            home.packages = with pkgs; [
              devbox
            ];

            # ── direnv ──────────────────────────────────
            programs.direnv = {
              enable = true;
              nix-direnv.enable = true;
            };
          };
        }
      ];
    };
  };
}
