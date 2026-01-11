{
  lib,
  ...
}:
{
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];
}
