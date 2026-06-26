{
  pkgs,
  lib,
  ...
}:
let
  # Tree-sitter grammars to expose to Neovim's built-in treesitter.
  grammars = with pkgs.tree-sitter-grammars; {
    bash = tree-sitter-bash;
    c = tree-sitter-c;
    cmake = tree-sitter-cmake;
    cpp = tree-sitter-cpp;
    css = tree-sitter-css;
    csv = tree-sitter-csv;
    diff = tree-sitter-diff;
    dockerfile = tree-sitter-dockerfile;
    fish = tree-sitter-fish;
    git_config = tree-sitter-git-config;
    git_rebase = tree-sitter-git-rebase;
    gitattributes = tree-sitter-gitattributes;
    gitcommit = tree-sitter-gitcommit;
    gitignore = tree-sitter-gitignore;
    go = tree-sitter-go;
    gomod = tree-sitter-gomod;
    gotmpl = tree-sitter-gotmpl;
    gowork = tree-sitter-gowork;
    html = tree-sitter-html;
    json = tree-sitter-json;
    json5 = tree-sitter-json5;
    llvm = tree-sitter-llvm;
    lua = tree-sitter-lua;
    make = tree-sitter-make;
    markdown = tree-sitter-markdown;
    markdown_inline = tree-sitter-markdown-inline;
    mermaid = tree-sitter-mermaid;
    nix = tree-sitter-nix;
    ocaml = tree-sitter-ocaml;
    proto = tree-sitter-proto;
    python = tree-sitter-python;
    regex = tree-sitter-regex;
    ron = tree-sitter-ron;
    rst = tree-sitter-rst;
    ruby = tree-sitter-ruby;
    rust = tree-sitter-rust;
    strace = tree-sitter-strace;
    tera = tree-sitter-tera;
    toml = tree-sitter-toml;
    typescript = tree-sitter-typescript;
    vim = tree-sitter-vim;
    xml = tree-sitter-xml;
    yaml = tree-sitter-yaml;
    zig = tree-sitter-zig;
  };

  # nixpkgs ships the compiled grammar as a file literally named "parser";
  # Neovim wants it at parser/<lang>.so. Queries live under queries/<lang>/.
  parserFiles = lib.mapAttrs' (
    lang: drv: lib.nameValuePair "nvim/site/parser/${lang}.so" { source = "${drv}/parser"; }
  ) grammars;
  queryFiles = lib.mapAttrs' (
    lang: drv: lib.nameValuePair "nvim/site/queries/${lang}" { source = "${drv}/queries"; }
  ) grammars;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    extraConfig = builtins.readFile ../config/nvim/init.vim;
  };

  xdg.dataFile = parserFiles // queryFiles;
}
