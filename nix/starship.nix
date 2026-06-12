{ lib, pkgs, ... }:
let
  lang-format = "[$symbol$version]($style) ";
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableInteractive = true;
    settings = {
      add_newline = false;
      battery.format = "[🔋$percentage]($style) ";
      directory = {
        truncation_length = 2;
        fish_style_pwd_dir_length = 1;
      };
      env_var = {
        variable = "__PRIVATE_MODE";
        format = "$env_value ";
      };
      git_branch.format = "[$symbol$branch]($style) ";
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
        "$git_branch"
        "$git_commit"
        "$git_state"
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
