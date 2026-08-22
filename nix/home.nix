{
  config,
  pkgs,
  lib,
  xdg,
  ...
}:
{
  imports = [
    ./starship.nix
    ./git.nix
    ./jj.nix
    ./neovim.nix
  ];

  home.username = "whlo";
  home.homeDirectory =
    (if pkgs.stdenv.hostPlatform.isDarwin then /Users else /home) + "/${config.home.username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  home.shellAliases = {
    cat = "bat";
    ll = "eza -lhgF --git";
    ls = "eza";
    ports = "lsof -PiTCP -sTCP:LISTEN";
    tree = "eza -TF --group-directories-first";
    P = "fish -P";

    bre = "brazil-runtime-exec";
    brc = "brazil-recursive-cmd";
    bws = "brazil ws";
    bb = "brazil-build";
  };

  home.shell.enableShellIntegration = false;

  home.language.base = "en_US.UTF-8";

  home.sessionPath = [
    "${config.home.homeDirectory}/.toolbox/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  home.packages = with pkgs; [
    (lib.hiPrio rust-analyzer)
    hyperfine
    mdbook
    rustup
    shellcheck
    shfmt
  ];

  home.file = {
    ".kiro/steering/agents.md".source = ../config/ai/AGENTS.md;
    ".kiro/steering/commit-style.md".source = ../config/ai/commit-style.md;
  };

  home.sessionVariables = {
    LESS = "isFRMX";
  };

  # Claude Code rewrites settings.json at runtime,
  # so it cannot be a read-only store symlink.
  # See anthropics/claude-code#3575
  home.activation.claudeSettings =
    let
      baseline = (pkgs.formats.json { }).generate "claude-settings-baseline.json" {
        includeCoAuthoredBy = false;
        permissions = {
          defaultMode = "bypassPermissions";
          allow = [
            "Read(*)"
            "Bash(cargo *)"
            "Bash(fd *)"
            "Bash(find *)"
            "Bash(gh issue list*)"
            "Bash(gh issue view*)"
            "Bash(gh pr checks*)"
            "Bash(gh pr diff*)"
            "Bash(gh pr list*)"
            "Bash(gh pr view*)"
            "Bash(gh search *)"
            "Bash(grep:*)"
            "Bash(jj:*)"
            "Bash(rg *)"
            "Bash(wc *)"
          ];
          ask = [
            "Bash(git push:*)"
            "Bash(jj git push:*)"
            "Bash(jj push:*)"
          ];
        };
        skipDangerousModePermissionPrompt = true;
        enabledPlugins."cctop@cctop" = true;
        extraKnownMarketplaces.cctop.source = {
          source = "github";
          repo = "st0012/cctop";
        };
      };
      merge = pkgs.writeShellScript "merge-claude-settings" ''
        set -euo pipefail
        settings="$HOME/.claude/settings.json"
        mkdir -p "$HOME/.claude"
        [ -s "$settings" ] || echo '{}' > "$settings"
        tmp="$(mktemp)"
        ${lib.getExe pkgs.jq} --slurp '.[0] * .[1]' "$settings" ${baseline} > "$tmp"
        mv "$tmp" "$settings"
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${merge}
    '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      inline_height = 11;
      search_mode = "fuzzy";
      show_help = false;
      show_preview = false;
      style = "compact";
      update_check = false;
    };
  };

  programs.awscli.enable = true;

  programs.bash.enable = true;

  programs.claude-code = {
    enable = true;
    context = ../config/ai/AGENTS.md;
    rules = {
      commit-style = ../config/ai/commit-style.md;
    };
  };

  programs.codex = {
    enable = true;
    context = ../config/ai/AGENTS.md;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Latte";
      italic-text = "always";
      style = "plain";
    };
    themes = {
      "Catppuccin Latte" = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "699f60fc8ec434574ca7451b444b880430319941";
          sha256 = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
        };
        file = "themes/Catppuccin Latte.tmTheme";
      };
    };
  };

  programs.eza.enable = true;

  programs.fd.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ../config/fish/config.fish;
    functions = {
      fish_user_key_bindings = "fish_vi_key_bindings";
    };
  };

  programs.gpg.enable = true;

  programs.jq.enable = true;

  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Latte";
    settings = {
      font_family = "JetBrains Mono ExtraLight";
      bold_font = "JetBrains Mono Bold";
      italic_font = "JetBrains Mono Light Italic";
      bold_italic_font = "JetBrains Mono Bold Italic";
      font_size = 20.0;
      scrollback_lines = 10000;
      hide_window_decorations = "yes";
      background_opacity = 0.7;
      dynamic_background_opacity = "yes";
      clipboard_control = "write-clipboard write-primary no-append";
      macos_option_as_alt = "left";
      macos_quit_when_last_window_closed = "yes";
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty-{kitty_pid}";
    };
  };

  # fish enables this for `apropos` completions,
  # but on Darwin programs.man.package is null and it only warns on every switch.
  programs.man.generateCaches = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin false;

  programs.readline = {
    enable = true;
    extraConfig = builtins.readFile ../config/inputrc;
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--follow"
      "--smart-case"
      "--hyperlink-format=default"
    ];
  };

  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "fish";
      simplified_ui = true;
      pane_frames = false;
      scroll_buffer_size = 10000;
      theme = "catppuccin-latte";
    };
  };

  programs.zsh.enable = true;

  xdg = {
    enable = true;
    configFile."nvim/lua".source = ../config/nvim/lua;
    configFile."nvim/lazy-lock.json".source = ../config/nvim/lazy-lock.json;
    configFile."fish/themes/Catppuccin Latte.theme".source =
      let
        catppuccin-fish = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "cc8e4d8fffbdaab07b3979131030b234596f18da";
          hash = "sha256-udiU2TOh0lYL7K7ylbt+BGlSDgCjMpy75vQ98C1kFcc=";
        };
      in
      "${catppuccin-fish}/themes/Catppuccin Latte.theme";
  };
}
