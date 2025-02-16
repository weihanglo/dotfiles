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
  rust =
    let
      llvmPkgs = pkgs.llvmPackages_20;
    in
    pkgs.mkShell.override { inherit (llvmPkgs) stdenv; } {
      name = "rust";
      nativeBuildInputs =
        with pkgs;
        [
          llvmPkgs.clangUseLLVM
          llvmPkgs.lld
          python3
        ]
        ++ cargo.nativeBuildInputs;
      buildInputs =
        with pkgs;
        [
        ]
        ++ cargo.buildInputs;
    };
}
