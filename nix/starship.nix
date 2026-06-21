{ lib, pkgs, ... }:
let
  lang-format = "[$symbol$version]($style) ";

  jj-config = (pkgs.formats.toml { }).generate "starship-jj.toml" {
    module_separator = " ";
    module = [
      {
        type = "Bookmarks";
        color = "Magenta";
        max_bookmarks = 1;
      }
      {
        type = "Commit";
        max_length = 24;
        previous_message_symbol = "⇣";
      }
      {
        type = "State";
        separator = " ";
      }
      {
        type = "Metrics";
        hide_if_empty = true;
        template = "[{changed} {added}{removed}]";
      }
    ];
  };
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableInteractive = true;
    extraPackages = [ pkgs.starship-jj ];
    settings = {
      add_newline = false;
      battery.format = "[🔋$percentage]($style) ";
      custom.jj = {
        format = "$output";
        # Note we can't append `--starship-config` to `command`.
        # If used with `use_stdin = false`,
        # starship hands `command` to the shell as a single argument,
        # which starship-jj would reject as a subcommand.
        command = "prompt";
        ignore_timeout = true;
        shell = [
          "starship-jj"
          "--ignore-working-copy"
          "starship"
          "prompt"
          "--starship-config"
          "${jj-config}"
        ];
        use_stdin = true;
        when = true;
      };
      directory = {
        truncation_length = 2;
        fish_style_pwd_dir_length = 1;
      };
      env_var = {
        variable = "__PRIVATE_MODE";
        format = "$env_value ";
      };
      nix_shell = {
        format = "[$state(\($name\))]($style) ";
        impure_msg = "*";
        pure_msg = "";
        unknown_msg = "?";
      };
      time = {
        disabled = false;
        format = "[$time](dimmed white)";
      };
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$\{custom.jj\} "
        "$nix_shell"
        "$env_var"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$character"
      ];
    };
  };
}
