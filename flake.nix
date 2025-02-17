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
        {
          legacyPackages.homeConfigurations.whlo = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

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
