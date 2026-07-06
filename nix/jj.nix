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
          "trunk() | stack()::"
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
        private-commits = "denylist()";
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
        key = "CE332572CAB157E9";
      };
      revset-aliases = {
        "wip()" = "description(glob-i:'wip:*')";
        "private()" = "description(glob-i:'private:*')";
        "denylist()" = "wip() | private()";
        "stack()" = "trunk()..@";
        "ready()" = "mutable() ~ denylist() ~ empty() ~ description(exact:'')";
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
