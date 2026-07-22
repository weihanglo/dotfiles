{
  system.stateVersion = 6;

  nix.enable = false;
  nix.settings = {
    accept-flake-config = true;
    build-users-group = "nixbld";
    experimental-features = "nix-command flakes";
    bash-prompt-prefix = "(nix:$name) ";
    max-jobs = "auto";
    extra-nix-path = "nixpkgs=flake:nixpkgs";
    trusted-users = [
      "whlo"
      "root"
      "@wheel"
    ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  homebrew = {
    enable = true;
    taps = [ "st0012/cctop" ];
    casks = [
      "cctop"
      "font-jetbrains-mono"
      "ghostty"
      "kitty"
      "parallels"
      "signal"
    ];
    onActivation.cleanup = "zap";
  };

  ids.gids.nixbld = 30000;

  system.primaryUser = "whlo";
  # Keys without a typed `system.defaults.NSGlobalDomain` option in nix-darwin
  # must be written through this raw escape hatch.
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      AppleAccentColor = 6;
      AppleAquaColorVariant = 1;
      AppleHighlightColor = "1.000000 0.749020 0.823529 Pink";
      AppleLanguages = [
        "en-US"
        "zh-Hant-US"
      ];
      AppleLocale = "en_US";
      "com.apple.trackpad.scrolling" = "0.4412";
    };
    "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
      # (toggole last two used input sources)
      "60" = {
        enabled = false;
      };
      # (cycle all input sources)
      "61" = {
        enabled = true;
        value = {
          # Option+Space
          parameters = [
            32 # ASCII code for space
            49 # virtual keycode for space
            524288 # modifier mask: Option
          ];
          type = "standard";
        };
      };
    };
    # Free the three-finger swipe so it can drive TrackpadThreeFingerDrag.
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadThreeFingerHorizSwipeGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 0;
      TrackpadThreeFingerTapGesture = 2;
    };
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
      "com.apple.trackpad.forceClick" = false;
      "com.apple.trackpad.scaling" = 3.0;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };
    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 0;
      ShowDayOfWeek = true;
    };
    hitoolbox.AppleFnUsageType = "Do Nothing";
    dock = {
      autohide = true;
      largesize = 92;
      magnification = true;
      show-recents = false;
      orientation = "right";
      wvous-br-corner = 1; # disable Quick Note hot corner
    };
    trackpad = {
      Clicking = true;
      Dragging = true;
      TrackpadThreeFingerDrag = true;
    };
    universalaccess = {
      mouseDriverCursorSize = 4.0;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
