{ pkgs, ... }: {
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
    "com.apple.swipescrolldirection" = false;
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
}
