{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nix-darwin,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        darwinConfigurations.whlo = nix-darwin.lib.darwinSystem {
          modules = [ ./nix/darwin.nix ];
        };
      };

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      perSystem =
        ctx@{
          pkgs,
          lib,
          ...
        }:
        let
          pkgs' = import pkgs.path {
            system = ctx.system;
            overlays = [
              (final: prev: {
                kitty = prev.kitty.overrideAttrs (old: {
                  # Probably not NixOS/nixpkgs#448279 but let's skip it for a while.
                  doCheck = false;
                });
                gitui = prev.gitui.overrideAttrs (attrs: {
                  # https://github.com/NixOS/nixpkgs/issues/450861
                  postPatch =
                    attrs.postPatch
                    + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
                      local asm_file="../gitui-0.27.0-vendor/sha1-asm-0.5.3/src/aarch64_apple.S"
                      substituteInPlace "$asm_file" \
                        --replace-fail $'\tldr\tq4, [x1, #:lo12:.K0@PAGEOFF]' $'\tadd\tx1, x1, .K0@PAGEOFF\n\tldr\tq4, [x1]'
                      substituteInPlace "$asm_file" \
                        --replace-fail $'\tldr\tq4, [x1, #:lo12:.K1@PAGEOFF]' $'\tadd\tx1, x1, .K1@PAGEOFF\n\tldr\tq4, [x1]'
                      substituteInPlace "$asm_file" \
                        --replace-fail $'\tldr\tq4, [x1, #:lo12:.K2@PAGEOFF]' $'\tadd\tx1, x1, .K2@PAGEOFF\n\tldr\tq4, [x1]'
                      substituteInPlace "$asm_file" \
                        --replace-fail $'\tldr\tq4, [x1, #:lo12:.K3@PAGEOFF]' $'\tadd\tx1, x1, .K3@PAGEOFF\n\tldr\tq4, [x1]'
                    '';
                });
              })
            ];
          };
        in
        {
          legacyPackages.homeConfigurations.whlo = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs';

            modules = [
              ./nix/home.nix
            ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
          };

          devShells = import ./nix/dev-shells.nix ctx;

          # This enables `nix fmt`.
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              fish_indent.enable = true;
              nixfmt.enable = true;
              shfmt.enable = true;
              stylua.enable = true;
            };
          };
        };
    };
}
