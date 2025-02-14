{
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    ignores = [
      "*.sw[op]"
      "*~"
      ".DS_Store"
      ".idea"
      ".vscode"
      "__debug_bin"
      "__pycache__"
    ];
    includes = [
      { path = ../config/git/gitconfig; }
      {
        path =
          let
            catppuccin-delta = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "delta";
              rev = "e9e21cffd98787f1b59e6f6e42db599f9b8ab399";
              sha256 = "sha256-04po0A7bVMsmYdJcKL6oL39RlMLij1lRKvWl5AUXJ7Q=";
            };
          in
          "${catppuccin-delta}/catppuccin.gitconfig";
      }
    ];
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        features = "catppuccin-latte";
        hyperlinks = true;
        line-numbers = true;
      };
    };
  };

  programs.gitui =
    let
      extrawurst-gitui = pkgs.fetchFromGitHub {
        owner = "extrawurst";
        repo = "gitui";
        rev = "99f69671445a8b9f069e07cd4c6c3fee7e07a77b"; # 0.27.0
        sha256 = "sha256-jKJ1XnF6S7clyFGN2o3bHnYpC4ckl/lNXscmf6GRLbI=";
      };
      catppuccin-gitui = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "gitui";
        rev = "c7661f043cb6773a1fc96c336738c6399de3e617";
        sha256 = "sha256-CRxpEDShQcCEYtSXwLV5zFB8u0HVcudNcMruPyrnSEk=";
      };
    in
    {
      enable = true;
      keyConfig = builtins.readFile "${extrawurst-gitui}/vim_style_key_config.ron";
      theme = builtins.readFile "${catppuccin-gitui}/themes/catppuccin-latte.ron";
    };
}
