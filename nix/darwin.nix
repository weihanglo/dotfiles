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
    casks = [
      "firefox"
      "font-jetbrains-mono"
      "jetbrains-toolbox"
      "kitty"
      "signal"
      "visual-studio-code"
      "zed"
    ];
    onActivation.cleanup = "zap";
  };

  ids.gids.nixbld = 30000;

  system.primaryUser = "whlo";
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      AppleAccentColor = 6;
      AppleAquaColorVariant = 1;
      AppleHighlightColor = "1.000000 0.749020 0.823529 Pink";
      AppleICUForce24HourTime = true;
      AppleLanguages = [
        "en-US"
        "zh-Hant-US"
      ];
      AppleLocale = "en_US";
      ApplePressAndHoldEnabled = 0;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.springing.delay" = "0.5";
      "com.apple.springing.enabled" = 1;
      "com.apple.trackpad.forceClick" = 0;
      "com.apple.trackpad.scaling" = 3;
      "com.apple.trackpad.scrolling" = "0.4412";
    };
  };

  system.defaults = {
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
