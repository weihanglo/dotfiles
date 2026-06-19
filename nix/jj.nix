{
  ...
}:
{
  programs.jjui.enable = true;

  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        ci = [
          "commit"
          "--interactive"
        ];
        difft = [
          "diff"
          "--tool"
          "difft"
        ];
        ll = [
          "log"
          "-r"
          "trunk() | (trunk()..@)::"
        ];
        pull = [
          "git"
          "fetch"
          "--all-remotes"
        ];
        push = [
          "git"
          "push"
        ];
        si = [
          "squash"
          "--interactive"
        ];
      };
      git = {
        sign-on-push = true;
      };
      merge-tools = {
        delta = {
          diff-expected-exit-codes = [
            0
            1
          ];
        };
        difft = {
          diff-args = [
            "--color=always"
            "$left"
            "$right"
          ];
        };
      };
      signing = {
        behavior = "drop";
        backend = "gpg";
        key = "D7DBF189825E82E7";
      };
      ui = {
        pager = "delta";
        diff-formatter = ":git";
      };
      user = {
        name = "Weihang Lo";
        email = "me@weihanglo.tw";
      };
    };
  };
}
