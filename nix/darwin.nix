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
      "jetbrains-toolbox"
      "firefox"
      "font-jetbrains-mono"
      "kitty"
      "parallels"
      "signal"
      "zed"
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
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.springing.delay" = 0.5;
      "com.apple.springing.enabled" = true;
      "com.apple.trackpad.forceClick" = false;
      "com.apple.trackpad.scaling" = 3.0;
    };
    dock = {
      autohide = true;
      largesize = 92;
      magnification = true;
      show-recents = false;
      orientation = "right";
    };
    trackpad = {
      Clicking = true;
      Dragging = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
