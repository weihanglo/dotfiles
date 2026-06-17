# Weihang Lo's Dotfiles

## Usage

Build and activate [home-manager] configuration:

```console
nix run home-manager -- switch --flake github:weihanglo/dotfiles
```

Build and activate [nix-darwin] configuration:

```console
nix run nix-darwin#darwin-rebuild -- switch --flake github:weihanglo/dotfiles
```

Activave different dev shells:

```console
nix develop github:weihanglo/dotfiles#cargo
nix develop github:weihanglo/dotfiles#rust
```

Homebrew casks are not version-pinned and `brew bundle` won't upgrade
already-installed ones during `darwin-rebuild switch`.
Upgrade them explicitly when desired:

```console
brew update && brew upgrade --cask <name>
```

## License

[The MIT License (MIT)](LICENSE)

Copyright © 2015 - Present Weihang Lo

[nix-darwin]: https://github.com/LnL7/nix-darwin
[home-manager]: https://github.com/nix-community/home-manager
