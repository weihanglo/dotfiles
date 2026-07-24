{
  lib,
  pkgs,
  ...
}:
let
  cargo = {
    nativeBuildInputs = with pkgs; [
      perl
      pkg-config
    ];
    buildInputs = with pkgs; [
      curl
      openssl
      libgit2
      libssh2
      zlib
    ];
  };
in
{
  # Dev shell for cargo development
  cargo = pkgs.mkShell (cargo // { name = "cargo"; });

  # Dev shell for rustc development
  #
  # On Darwin, ship no C compiler: nix clang dynamically links libLLVM.dylib,
  # and rustc's bootstrap sets DYLD_LIBRARY_PATH to its own lib dirs, which
  # dyld searches by leaf name before the install name — so nix clang loads
  # rustc's libLLVM and aborts on missing symbols. Apple's statically-linked
  # clang (via /usr/bin/cc from the inherited PATH) is immune.
  rust =
    let
      llvmPkgs = pkgs.llvmPackages_19;
      mkShell' =
        if pkgs.stdenv.isDarwin then
          pkgs.mkShellNoCC
        else
          pkgs.mkShell.override { inherit (llvmPkgs) stdenv; };
    in
    mkShell' {
      name = "rust";
      nativeBuildInputs =
        [ pkgs.python3 ]
        ++ lib.optionals (!pkgs.stdenv.isDarwin) [
          llvmPkgs.clangUseLLVM
          llvmPkgs.lld
        ]
        ++ cargo.nativeBuildInputs;
      buildInputs = cargo.buildInputs;
    };
}
