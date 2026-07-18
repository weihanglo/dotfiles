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
        tidy = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            {
              jj bookmark list -r 'merged()' -T 'if(remote, "", name ++ "\n")'
              jj bookmark list -T 'if(remote, "", if(present, "", name ++ "\n"))'
            } | sort -u | xargs jj bookmark forget --include-remotes
          ''
          ""
        ];
      };
      git = {
        private-commits = "denylist()";
        push = "weihanglo";
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
      revsets = {
        bookmark-advance-to = "closest_pushable(@)";
      };
      revset-aliases = {
        "closest_pushable(to)" = "heads(::to & ready())";
        "wip()" = "description(glob-i:'wip:*')";
        "private()" = "description(glob-i:'private:*')";
        "denylist()" = "wip() | private()";
        "stack()" = "trunk()..@";
        "merged()" = "::trunk() ~ trunk()";
        "undescribed()" = "description(exact:'')";
        "ready()" = "mutable() ~ denylist() ~ empty() ~ undescribed()";
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
